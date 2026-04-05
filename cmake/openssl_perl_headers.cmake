# Generate include/openssl/*.h from *.h.in using OpenSSL's Perl toolchain (util/dofile.pl).
# Upstream git omits these headers (.gitignore); CI clones need this step unless headers are vendored.

function(openssl_try_perl_public_headers)
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/VERSION.dat")
        return()
    endif()

    # Prefer a full Perl (e.g. Strawberry). Git/MSYS perl often lacks modules required by configdata.pm.
    if(DEFINED ENV{OPENSSL_PERL} AND EXISTS "$ENV{OPENSSL_PERL}")
        set(OPENSSL_PERL "$ENV{OPENSSL_PERL}")
    elseif(WIN32)
        # Prefer Strawberry Perl explicitly; PATH may list Git/MSYS perl first (too minimal for configdata.pm).
        if(EXISTS "C:/Strawberry/perl/bin/perl.exe")
            set(OPENSSL_PERL "C:/Strawberry/perl/bin/perl.exe")
        else()
            find_program(OPENSSL_PERL NAMES perl perl.exe
                PATHS
                    "C:/Strawberry/perl/bin"
                    "C:/Strawberry/c/bin"
                    "$ENV{ProgramFiles}/Strawberry Perl/c/bin"
                    "$ENV{ProgramFiles}/Strawberry Perl/perl/bin"
                    "$ENV{ProgramFiles}/Perl/bin"
                    "$ENV{LOCALAPPDATA}/Programs/Perl/bin"
                NO_DEFAULT_PATH
            )
        endif()
    endif()
    if(NOT OPENSSL_PERL)
        find_program(OPENSSL_PERL NAMES perl perl.exe)
    endif()
    if(NOT OPENSSL_PERL)
        message(WARNING
            "Perl not found. OpenSSL public headers (crypto.h, x509.h, ...) are not in git; "
            "install Perl (e.g. Strawberry Perl) or place pre-generated headers under include/openssl/.")
        return()
    endif()

    # Pick an OpenSSL Configure target matching this build (headers are mostly platform-agnostic).
    # Note: OpenSSL 3.x/4.x has VC-WIN64A / VC-WIN64I, not "VC-WIN64" (invalid -> Configure prints help and fails).
    if(DEFINED ENV{OPENSSL_CONFIGURE_TARGET} AND NOT "$ENV{OPENSSL_CONFIGURE_TARGET}" STREQUAL "")
        set(_ssl_target "$ENV{OPENSSL_CONFIGURE_TARGET}")
    elseif(WIN32)
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            if(CMAKE_SYSTEM_PROCESSOR MATCHES "ARM64|aarch64|AARCH64")
                set(_ssl_target "VC-WIN64-ARM")
            else()
                set(_ssl_target "VC-WIN64A")
            endif()
        else()
            set(_ssl_target "VC-WIN32")
        endif()
    elseif(APPLE)
        if(CMAKE_OSX_ARCHITECTURES MATCHES "arm64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
            set(_ssl_target "darwin64-arm64")
        else()
            set(_ssl_target "darwin64-x86_64")
        endif()
    else()
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|ARM64|arm64")
            set(_ssl_target "linux-aarch64")
        elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "riscv64")
            set(_ssl_target "linux64-riscv64")
        else()
            set(_ssl_target "linux-x86_64")
        endif()
    endif()

    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/configdata.pm")
        message(STATUS "Running OpenSSL Configure (${_ssl_target} no-asm) to create configdata.pm for header generation...")
        execute_process(
            COMMAND ${OPENSSL_PERL} Configure ${_ssl_target} no-asm
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
            RESULT_VARIABLE _cfg_ec
            OUTPUT_VARIABLE _cfg_out
            ERROR_VARIABLE _cfg_err
        )
        if(NOT _cfg_ec EQUAL 0)
            message(FATAL_ERROR
                "OpenSSL 'perl Configure ${_ssl_target} no-asm' failed (exit ${_cfg_ec}). "
                "Install Perl + MSVC build tools, or generate headers manually.\n"
                "${_cfg_err}\n${_cfg_out}")
        endif()
    endif()

    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/configdata.pm")
        message(FATAL_ERROR "configdata.pm missing after Configure; cannot generate public headers.")
    endif()

    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/openssl")
    file(GLOB _h_in LIST_DIRECTORIES false "${CMAKE_SOURCE_DIR}/include/openssl/*.h.in")
    foreach(_hin IN LISTS _h_in)
        get_filename_component(_base "${_hin}" NAME)
        string(REPLACE ".in" "" _hname "${_base}")
        set(_out "${CMAKE_CURRENT_BINARY_DIR}/include/openssl/${_hname}")
        file(RELATIVE_PATH _rel "${CMAKE_SOURCE_DIR}" "${_hin}")
        file(TO_CMAKE_PATH "${_rel}" _rel)
        string(REPLACE "\\" "/" _rel "${_rel}")
        execute_process(
            COMMAND ${OPENSSL_PERL} -I. -Mconfigdata util/dofile.pl -omakefile "${_rel}"
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
            OUTPUT_FILE "${_out}"
            RESULT_VARIABLE _gen_ec
        )
        if(NOT _gen_ec EQUAL 0)
            message(FATAL_ERROR "perl util/dofile.pl failed for ${_rel} (exit ${_gen_ec})")
        endif()
    endforeach()

    set(OPENSSL_USE_PERL_PUBLIC_HEADERS TRUE PARENT_SCOPE)
endfunction()
