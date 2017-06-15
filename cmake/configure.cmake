################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015, 2017, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################
include (CheckIncludeFile)
include (TestBigEndian)

if(BUILD_STATIC_LIBS)
    set(OPENSSL_NO_SHARED ON)
endif()

set(OPENSSL_FEATURES
    afalgeng
    asan
    asm
    async
    autoalginit
    autoerrinit
    bf
    blake2
    camellia
    capieng
    cast
    chacha
    cmac
    cms
    comp
    crypto-mdebug
    crypto-mdebug-backtrace
    ct
    deprecated
    des
    dgram
    dh
    dsa
    dso
    dtls
    dynamic-engine
    ec
    ec2m
    ecdh
    ecdsa
    ec_nistp_64_gcc_128
    egd
    engine
    err
    filenames
    fuzz-libfuzzer
    fuzz-afl
    gost
    heartbeats
    hw
    idea
    makedepend
    md2
    md4
    mdc2
    msan
    multiblock
    nextprotoneg
    ocb
    ocsp
    pic
    poly1305
    posix-io
    psk
    rc2
    rc4
    rc5
    rdrand
    rfc3779
    rmd160
    scrypt
    sctp
    seed
    shared
    sock
    srp
    srtp
    sse2
    ssl
    ssl-trace
    static-engine
    stdio
    threads
    tls
    ts
    ubsan
    ui
    unit-test
    whirlpool
    weak-ssl-ciphers
#    zlib
#    zlib-dynamic
)

set(OPENSSL_TLS ssl3 tls1 tls1_1 tls1_2)
set(OPENSSL_DTLS dtls1 dtls1_2)

foreach(OPENSSL_FEATURE IN LISTS OPENSSL_TLS OPENSSL_DTLS)
    list(APPEND OPENSSL_FEATURES ${OPENSSL_FEATURE})
    list(APPEND OPENSSL_FEATURES ${OPENSSL_FEATURE}-method)
endforeach()

set(OPENSSL_FEATURES_DISABLED
    asan
    crypto-mdebug
    crypto-mdebug-backtrace
    ec_nistp_64_gcc_128
    egd
    fuzz-libfuzzer
    fuzz-afl
    heartbeats
    md2
    msan
    rc5
    sctp
    ssl-trace
    ssl3
    ssl3-method
    ubsan
    unit-test
    weak-ssl-ciphers
#    zlib
#    zlib-dynamic
)

foreach(OPENSSL_FEATURE ${OPENSSL_FEATURES})
    list(FIND OPENSSL_FEATURES_DISABLED "${OPENSSL_FEATURE}" ITEM_NO)
    if(ITEM_NO EQUAL -1)
        set(IS_DISABLED OFF)
    else()
        set(IS_DISABLED ON)
    endif()

    # change '-' to '_'
    string(REPLACE "-" "_" OPENSSL_FEATURE ${OPENSSL_FEATURE})
    # make uppercase
    string(TOUPPER ${OPENSSL_FEATURE} OPENSSL_FEATURE)

    option(OPENSSL_NO_${OPENSSL_FEATURE} "do not compile support for ${OPENSSL_FEATURE}" ${IS_DISABLED})
    if(IS_DISABLED)
        add_definitions(-DOPENSSL_NO_${OPENSSL_FEATURE})
    endif()
endforeach()

if(OPENSSL_NO_RSA AND (OPENSSL_NO_DSA OR OPENSSL_NO_DH))
    set(OPENSSL_NO_SSL ON)
endif()

if(OPENSSL_NO_TLS)
    set(OPENSSL_NO_SSL3 ON)
    set(OPENSSL_NO_TLS1 ON)
    set(OPENSSL_NO_TLS1_1 ON)
    set(OPENSSL_NO_TLS1_2 ON)
endif()

if(OPENSSL_NO_DTLS)
    set(OPENSSL_NO_DTLS1 ON)
    set(OPENSSL_NO_DTLS1_2 ON)
endif()

if(OPENSSL_NO_RSA AND (OPENSSL_NO_DSA OR OPENSSL_NO_DH) AND (OPENSSL_NO_ECDSA OR OPENSSL_NO_ECDH))
    set(OPENSSL_NO_TLS1 ON)
    set(OPENSSL_NO_TLS1_1 ON)
    set(OPENSSL_NO_TLS1_2 ON)
    set(OPENSSL_NO_DTLS1 ON)
    set(*OPENSSL_NO_DTLS1_2 ON)
endif()

if(OPENSSL_NO_MD5 OR OPENSSL_NO_SHA)
    set(OPENSSL_NO_SSL ON)
    set(OPENSSL_NO_TLS1 ON)
    set(OPENSSL_NO_TLS1_1 ON)
    set(OPENSSL_NO_DTLS1 ON)
endif()

if(OPENSSL_NO_SSL)
    set(OPENSSL_NO_SSL3 ON)
endif()

if(OPENSSL_NO_SSL3)
    set(OPENSSL_NO_SSL3_METHOD ON)
endif()

if(OPENSS_NO_DES)
    set(OPENSS_NO_MDC2 ON)
endif()

if(OPENSSL_NO_EC)
    set(OPENSSL_NO_ECDSA ON)
    set(OPENSSL_NO_ECDH ON)
endif()

if(OPENSSL_NO_SOCK)
    set(OPENSSL_NO_DGRAM ON)
endif()

if(OPENSSL_NO_DGRAM)
    set(OPENSSL_NO_DTLS ON)
    set(OPENSSL_NO_SCTP ON)
endif()

if(OPENSSL_NO_TLSEXT)
    set(OPENSSL_NO_SRP ON)
    set(OPENSSL_NO_HEARTBEATS ON)
endif()

if(OPENSSL_NO_DSO)
    set(OPENSSL_NO_DYNAMIC_ENGINE ON)
endif()

if(OPENSSL_NO_PIC)
    set(OPENSSL_NO_SHARED ON)
    set(BUILD_STATIC_LIBS ON)
    set(BUILD_SHARED_LIBS OFF)
    set(OSX_FRAMEWORK OFF)
endif()

if(OPENSSL_NO_ENGINE)
    set(OPENSSL_NO_AFALGENG ON)
endif()

if(OPENSSL_NO_AUTOERRINIT)
    set(OPENSSL_NO_SHARED ON)
    set(OPENSSL_NO_APPS ON)
endif()

if(OPENSSL_NO_SHARED)
    set(OPENSSL_NO_DYNAMIC_ENGINE ON)
endif()

if(OPENSSL_NO_STDIO)
    set(OPENSSL_NO_APPS ON)
    set(OPENSSL_NO_CAPIENG ON)
endif()

if(OPENSSL_NO_APPS)
    set(OPENSSL_NO_TESTS ON)
endif()

if(NOT OPENSSL_NO_ASM)
    # If Assembler enabled need perl
    find_exthost_package(Perl 5)
    if(NOT PERL_FOUND)
        message(WARNING "Perl not found. Assembler will be disabled")
        set(OPENSSL_NO_ASM ON)
    endif()
endif()

option(OPENSSL_FIPS "Enable FIPS" FALSE)
if(OPENSSL_FIPS)
    add_definitions(-DOPENSSL_FIPS)
endif()

if(NOT UNIX OR APPLE)
    set(OPENSSL_NO_AFALGENG ON)
endif()

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    set(DEBUG_SAFESTACK ON)
    set(CRYPTO_MDEBUG_BACKTRACE ON)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -rdynamic")
    add_definitions(-DDEBUG -D_DEBUG -DDEBUG_UNUSED)
    set(DEBUG_MODE TRUE)
else()
    add_definitions(-DNDEBUG)
    set(OPENSSL_NO_CRYPTO_MDEBUG ON)
    set(OPENSSL_NO_CRYPTO_MDEBUG_BACKTRACE ON)
endif()

if( CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64|arm64|ARM64" )
    set(HOST_X64 TRUE)
endif()

test_big_endian(WORDS_BIGENDIAN)
if (WORDS_BIGENDIAN)
    add_definitions(-DB_ENDIAN)
else()
    add_definitions(-DL_ENDIAN)
endif ()

if(UNIX)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wall")
    if(APPLE)
        set(OPENSSL_TARGET MACOSX)
        set(PERLASM_SCHEME macosx)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Qunused-arguments -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-language-extension-token -Wno-extended-offsetof -Wconditional-uninitialized -Wincompatible-pointer-types-discards-qualifiers -Wmissing-variable-declarations")
        if(HOST_X64)
            set(SIXTY_FOUR_BIT_LONG TRUE)
            set(RC4_INT "unsigned int")
        else()
            set(THIRTY_TWO_BIT TRUE)
            set(BN_LLONG ON)
            set(RC4_INT "unsigned char")
        endif()
    elseif(IOS)
        set(OPENSSL_TARGET iOS)
        set(OPENSSL_NO_DYNAMIC_ENGINE TRUE)
        set(OPENSSL_NO_STATIC_ENGINE TRUE)
        set(OPENSSL_NO_DSO ON)
        set(OPENSSL_NO_HW ON)

        if(IOS_ARCH MATCHES "amd64|x86_64|AMD64|arm64|ARM64")
            set(HOST_X64 TRUE)
            set(OPENSSL_TARGET ios64)
        else()
            set(HOST_X64 FALSE)
            set(OPENSSL_TARGET ios32)
        endif()

        if(IOS_ARCH MATCHES "i386|x86_64")
            if(HOST_X64)
                set(SIXTY_FOUR_BIT_LONG TRUE)
                set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch x86_64 -DL_ENDIAN -mios-version-min=7.0.0")
                set(PERLASM_SCHEME macosx)
                set(OPENSSL_NO_AFALGENG ON)
                set(RC4_INT "unsigned int")
            else()
                set(OPENSSL_NO_ASM TRUE)
                set(PERLASM_SCHEME macosx)
                set(THIRTY_TWO_BIT TRUE)
                set(BN_LLONG ON)
                set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch i386 -DL_ENDIAN -mios-version-min=7.0.0")
                set(RC4_INT "unsigned char")
            endif()
        else()
            if(HOST_X64)
                set(SIXTY_FOUR_BIT_LONG TRUE)
                set(RC4_INT "unsigned char")
                set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch arm64 -mios-version-min=7.0.0")
                set(PERLASM_SCHEME ios64)
                set(IOS_ARM64 ON)
            else()
                set(OPENSSL_NO_ASM TRUE)
                set(PERLASM_SCHEME ios32)
                set(THIRTY_TWO_BIT TRUE)
                set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch armv7 -mios-version-min=7.0.0")
                set(RC4_INT "unsigned char")
            endif()
        endif()

        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-common")
        set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -Qunused-arguments -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-language-extension-token -Wno-extended-offsetof -Wconditional-uninitialized -Wincompatible-pointer-types-discards-qualifiers -Wmissing-variable-declarations")
    elseif(ANDROID)
        if(ANDROID_ABI)
            if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang") # using regular Clang or AppleClang
                set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mandroid")
            endif()
            set(OPENSSL_NO_ASM ON) # All tests show that openssl configure disable asm for android (arm, arm64, x86 and x86_64 standalone toolchain)
            if(ANDROID_ABI MATCHES "armeabi-v7a")
                # add_definitions(-DARM -D_ARM_ -DTHUMB -D_THUMB_)
                set(OPENSSL_TARGET ANDROID_ARMEABI)
                set(BN_LLONG ON)
                set(THIRTY_TWO_BIT TRUE)
                set(PERLASM_SCHEME void)
                set(RC4_INT "unsigned char")
                set(ANDROID_ARMV4 ON)
                # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=arm7 -mthumb")
            elseif(ANDROID_ABI MATCHES "x86")
                # add_definitions(-Dx86 -D_X86_)
                set(OPENSSL_TARGET ANDROID_X86)
                set(BN_LLONG ON)
                set(THIRTY_TWO_BIT TRUE)
                set(PERLASM_SCHEME android)
                set(RC4_INT "unsigned char")
                set(ANDROID_X86 ON)
            elseif(ANDROID_ABI MATCHES "mips")
                # add_definitions(-DMIPS -D_MIPS_ -DR4000)
                set(OPENSSL_TARGET ANDROID_MIPS32)
                set(BN_LLONG ON)
                set(PERLASM_SCHEME o32)
                set(THIRTY_TWO_BIT TRUE)
                set(RC4_INT "unsigned char")
                set(ANDROID_MIPS32 ON)
            elseif(ANDROID_ABI MATCHES "arm64-v8a")
                # add_definitions(-DARM -D_ARM_)
                set(OPENSSL_TARGET ANDROID_AARCH64)
                set(SIXTY_FOUR_BIT_LONG ON)
                set(PERLASM_SCHEME linux64)
                set(RC4_INT "unsigned char")
                set(ANDROID_AARCH64 ON)
            elseif(ANDROID_ABI MATCHES "x86_64")
                # add_definitions(-Dx86_64 -D_X86_64_)
                set(OPENSSL_TARGET ANDROID_X86_64)
                set(SIXTY_FOUR_BIT_LONG ON)
                set(PERLASM_SCHEME android)
                set(RC4_INT "unsigned char")
                set(ANDROID_X86_64 ON)
            elseif(ANDROID_ABI MATCHES "mips64")
                # add_definitions(-DARM -D_ARM_ -DTHUMB -D_THUMB_)
                set(OPENSSL_TARGET ANDROID_ARMEABI)
                set(BN_LLONG ON)
                set(THIRTY_TWO_BIT TRUE)
                set(PERLASM_SCHEME void)
                set(RC4_INT "unsigned char")
                set(ANDROID_ARMV4 ON)
                # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=arm7 -mthumb")
            endif()
        else()
            add_definitions(-DARM -D_ARM_ -DTHUMB -D_THUMB_)
            set(OPENSSL_TARGET ANDROID_ARMEABI)
            set(BN_LLONG ON)
            set(THIRTY_TWO_BIT TRUE)
            set(PERLASM_SCHEME linux32)
            set(RC4_INT "unsigned char")
            set(ANDROID_ARMV4 ON)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=arm7 -mthumb")
        endif()
    else()
        option(PEDANTIC "-DPEDANTIC complements -pedantic and is meant to mask code that
         is not strictly standard-compliant and/or implementation-specific,
         e.g. inline assembly, disregards to alignment requirements, such
         that -pedantic would complain about. Incidentally -DPEDANTIC has
         to be used even in sanitized builds, because sanitizer too is
         supposed to and does take notice of non-standard behaviour. Then
         -pedantic with pre-C9x compiler would also complain about 'long
         long' not being supported. As 64-bit algorithms are common now,
         it grew impossible to resolve this without sizeable additional
         code, so we just tell compiler to be pedantic about everything
         but 'long long' type." TRUE)

        if(PEDANTIC)
            add_definitions(-DPEDANTIC)
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -pedantic -Wno-long-long")
        endif()
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wsign-compare -Wmissing-prototypes  -Wshadow -Wformat -Wtype-limits -Werror -Wl,-znodelete") # TODO: put in right place -Wl,--export-all
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DOPENSSL_USE_NODELETE")

        if(HOST_X64)
            set(SIXTY_FOUR_BIT_LONG TRUE)
            set(PERLASM_SCHEME elf)
            set(OPENSSL_TARGET LINUX_GENERIC64)
        else()
            set(THIRTY_TWO_BIT TRUE)
            set(PERLASM_SCHEME elf32)
            set(OPENSSL_TARGET LINUX_GENERIC32)
        endif()
        set(RC4_INT "unsigned char")
    endif()

    find_package(Threads)
    if(Threads_FOUND)
        set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${CMAKE_THREAD_LIBS_INIT})
        add_definitions(-D_THREAD_SAFE -D_REENTRANT -DOPENSSL_THREADS)
        set(OPENSSL_THREADS TRUE)
    endif()

    find_library(DL_LIB dl)
    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${DL_LIB})
    find_library(M_LIB m)
    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${M_LIB})

    check_include_file("dlfcn.h" HAVE_DLFCN_H)
    if(HAVE_DLFCN_H)
        add_definitions(-DDSO_DLFCN -DHAVE_DLFCN_H)
    endif()

    if(BUILD_SHARED_LIBS OR OSX_FRAMEWORK)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
        add_definitions(-DOPENSSL_PIC)
        set(SHARED_CFLAG "-fPIC")
    endif()

    if(NOT OPENSSL_NO_ASM)
        enable_language(ASM OPTIONAL)
        if(NOT CMAKE_ASM_COMPILER_WORKS)
            set(OPENSSL_NO_ASM ON)
            message(STATUS "Assembler disabled")
        endif()
        set(ASM_FILE_EXT s)
    endif()

elseif(WIN32)
    set(OPENSSL_EXPORT_VAR_AS_FUNCTION TRUE)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -W3 -wd4090 -Gs0 -GF -Gy -nologo")
    add_definitions(-DOPENSSL_SYS_WINDOWS -DWIN32_LEAN_AND_MEAN -DL_ENDIAN -D_CRT_SECURE_NO_DEPRECATE -DUNICODE -D_UNICODE -D_WINDLL)
    add_definitions(-DOPENSSL_THREADS -DOPENSSL_PIC)

    set(OPENSSL_TARGET WINDOWS)
    if(CMAKE_CL_64)
        set(SIXTY_FOUR_BIT TRUE)
        set(OPENSSL_TARGET WIN64)
    else()
        set(THIRTY_TWO_BIT TRUE)
        set(OPENSSL_TARGET WIN32)
        set(BN_LLONG ON)
    endif()
    set(RC4_INT "unsigned int")

    # Search asm
    if(NOT OPENSSL_NO_ASM)
        enable_language(ASM_NASM OPTIONAL)
        if(CMAKE_ASM_NASM_COMPILER_WORKS)
            if(CMAKE_CL_64)
                set(CMAKE_ASM_FLAGS "--DNEAR -Ox -g")
                set(PERLASM_SCHEME auto)
            else()
                set(CMAKE_ASM_FLAGS "")
                set(PERLASM_SCHEME win32n)
            endif()
            set(CMAKE_ASM_COMPILER_WORKS TRUE)
        # else()
            # enable_language(ASM_MASM OPTIONAL)
            # if(CMAKE_ASM_MASM_COMPILER_WORKS)
                # if(CMAKE_CL_64)
                    # set(CMAKE_ASM_FLAGS "/Cp /Cx /Zi")
                    # set(PERLASM_SCHEME auto)
                # else()
                    # set(CMAKE_ASM_FLAGS "/nologo /Cp /coff /Cx /Zi")
                    # set(PERLASM_SCHEME win32)
                # endif()
                # set(CMAKE_ASM_COMPILER_WORKS TRUE)
            # else()
#                message(FATAL_ERROR "NASM not found - please read INSTALL and NOTES.WIN for further details")
#            endif()
        else()
            set(OPENSSL_NO_ASM ON)
            message(STATUS "Assembler disabled")
#            message(FATAL_ERROR "NASM not found - please read INSTALL and NOTES.WIN for further details")
        endif()
        set(ASM_FILE_EXT asm)
    endif()

    configure_file( ${CMAKE_SOURCE_DIR}/cmake/version32.rc.cmake ${CMAKE_BINARY_DIR}/version32.rc )
endif()

if(NOT OPENSSL_NO_ASM)
    set(OPENSSL_CPUID_OBJ ON)
endif()

if( CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "386")
    set(I386_ONLY ON)
    set(OPENSSL_NO_SSE2 ON)
endif()

check_include_file("unistd.h" HAVE_UNISTD_H)
if(HAVE_UNISTD_H)
    set(OPENSSL_UNISTD <unistd.h>)
endif()

option(OPENSSL_EXPORT_VAR_AS_FUNCTION "Export variables as function" FALSE)
if(WIN32)
    # override value
    set(OPENSSL_EXPORT_VAR_AS_FUNCTION ON)
endif()

string(LENGTH CMAKE_C_FLAGS FLAGS_LEN)
foreach(CHAR_POS RANGE FLAGS_LEN)
    string(SUBSTRING CMAKE_C_FLAGS CHAR_POS 1 CHAR_VAL)
    if(CHAR_POS EQUAL 0)
        set(OPENSSL_CFLAGS "'${CHAR_VAL}'")
    else()
        set(OPENSSL_CFLAGS "'${OPENSSL_CFLAGS}', '${CHAR_VAL}'")
    endif()
endforeach()
string(TIMESTAMP OPENSSL_BUILD_DATE "%Y-%m-%d %H:%M:%S" UTC)

configure_file(${CMAKE_SOURCE_DIR}/cmake/buildinf.h.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/buildinf.h IMMEDIATE @ONLY)

add_definitions(-DENGINESDIR="${INSTALL_ENGINES_DIR}")
if(OSX_FRAMEWORK)
    add_definitions(-DOPENSSLDIR="/etc/ssl")
else()
    add_definitions(-DOPENSSLDIR="${INSTALL_SHARE_DIR}")
endif()

# Generate include/openssl/opensslconf.h
configure_file(${CMAKE_SOURCE_DIR}/cmake/opensslconf.h.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/openssl/opensslconf.h IMMEDIATE @ONLY)
# Generate crypto/include/internal/bn_conf.h
configure_file(${CMAKE_SOURCE_DIR}/cmake/bn_conf.h.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/internal/bn_conf.h IMMEDIATE @ONLY)
# Generate crypto/include/internal/dso_conf.h
set(DSO_EXTENSION ${CMAKE_SHARED_LIBRARY_SUFFIX})
configure_file(${CMAKE_SOURCE_DIR}/cmake/dso_conf.h.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/internal/dso_conf.h IMMEDIATE @ONLY)

if(OPENSSL_NO_STATIC_ENGINE)
    add_definitions(-DOPENSSL_NO_STATIC_ENGINE)
endif()

if(BUILD_SHARED_LIBS OR OSX_FRAMEWORK)

else()
    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR APPLE)
        set( CMAKE_CXX_FLAGS "-fpic ${CMAKE_CXX_FLAGS}" )
        set( CMAKE_C_FLAGS   "-fpic ${CMAKE_C_FLAGS}" )
    endif()
endif()

configure_file(${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)
