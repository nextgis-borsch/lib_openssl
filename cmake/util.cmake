################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015-2018, NextGIS <info@nextgis.com>
# Copyright (C) 2015-2018 Dmitry Baryshnikov <dmitry.baryshnikov@nextgis.com>
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
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

macro(hexchar2dec VAR VAL)
    if (${VAL} MATCHES "[0-9]")
        set(${VAR} ${VAL})
    elseif(${VAL} MATCHES "[aA]")
        set(${VAR} 10)
    elseif(${VAL} MATCHES "[bB]")
        set(${VAR} 11)
    elseif(${VAL} MATCHES "[cC]")
        set(${VAR} 12)
    elseif(${VAL} MATCHES "[dD]")
        set(${VAR} 13)
    elseif(${VAL} MATCHES "[eE]")
        set(${VAR} 14)
    elseif(${VAL} MATCHES "[fF]")
        set(${VAR} 15)
    else()
        message(FATAL_ERROR "Invalid format for hexidecimal character")
    endif()
endmacro()

macro(hex2dec VAR VAL)

    if (${VAL} EQUAL 0)
        set(${VAR} 0)
    else()
        set(CURINDEX 0)
        string(LENGTH "${VAL}" CURLENGTH)

        set(${VAR} 0)

        while (CURINDEX LESS CURLENGTH)

            string(SUBSTRING "${VAL}" ${CURINDEX} 1 CHAR)

            hexchar2dec(CHAR ${CHAR})

            math(EXPR POWAH "(1<<((${CURLENGTH}-${CURINDEX}-1)*4))")
            math(EXPR CHAR "(${CHAR}*${POWAH})")
            math(EXPR ${VAR} "${${VAR}}+${CHAR}")
            math(EXPR CURINDEX "${CURINDEX}+1")
        endwhile()
    endif()

endmacro()

macro(make_def LIB_NAME FUNCTION_LIST FILE_PATH)

    if(NOT EXISTS FILE_PATH)

        message(STATUS "make_def ${LIB_NAME} ${FILE_PATH}")

    set( CONF
    "
;
; Definition file for the DLL version of the SSLEAY library from OpenSSL
;

LIBRARY         ${LIB_NAME}

EXPORTS
"
    )

    foreach(FUNC ${FUNCTION_LIST})
        set( CONF "${CONF}    ${FUNC}\n")
    endforeach()
    file( WRITE ${FILE_PATH} "${CONF}" )

    endif()
endmacro()

macro(generate_asm FILE_NAME)
    if(NOT WIN32)
        set(GEN_ASM_CMD_PREFIX "CC=\"${CMAKE_C_COMPILER}\"")
    endif()

    get_directory_property(DIRECTORY_DEFS COMPILE_DEFINITIONS)
    foreach (DEF ${TARGET_DEFS} ${DIRECTORY_DEFS})
        if (DEF)
            string(REPLACE "\"" "\\\"" DEF "${DEF}")
            list(APPEND COMPILER_FLAGS "-D${DEF}")
        endif ()
    endforeach ()

    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
        COMMAND ${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/asm/${FILE_NAME}.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/asm/${FILE_NAME}.pl
    )

    if(CMAKE_CROSSCOMPILING)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
            COMMAND ${CMAKE_C_COMPILER} -I${CMAKE_CURRENT_SOURCE_DIR} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR}/include -I${CMAKE_CURRENT_BINARY_DIR}/include ${COMPILER_FLAGS} -E ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT} | ${PERL_EXECUTABLE} -ne "/^#+/ or print" > ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.i && mv -f ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.i ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
        )
    endif()

    set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT})
endmacro()

macro(generate_asm1 FILE_NAME)
    if(NOT WIN32)
        set(GEN_ASM_CMD_PREFIX "CC=\"${CMAKE_C_COMPILER}\"")
    endif()

    get_directory_property(DIRECTORY_DEFS COMPILE_DEFINITIONS)
    foreach (DEF ${TARGET_DEFS} ${DIRECTORY_DEFS})
        if (DEF)
            string(REPLACE "\"" "\\\"" DEF "${DEF}")
            list(APPEND COMPILER_FLAGS "-D${DEF}")
        endif ()
    endforeach ()

    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
        COMMAND ${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/${FILE_NAME}.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${FILE_NAME}.pl
    )

    if(CMAKE_CROSSCOMPILING)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
            COMMAND ${CMAKE_C_COMPILER} -I${CMAKE_CURRENT_SOURCE_DIR} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR}/include -I${CMAKE_CURRENT_BINARY_DIR}/include ${COMPILER_FLAGS} -E ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT} | ${PERL_EXECUTABLE} -ne "/^#+/ or print" > ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.i && mv -f ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.i ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT}
        )
    endif()

    set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.${ASM_FILE_EXT})
endmacro()

macro(generate_asm2 FILE_NAME OUT_FILE_NAME)
    if(NOT WIN32)
        set(GEN_ASM_CMD_PREFIX "CC=\"${CMAKE_C_COMPILER}\"")
    endif()

    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT}
        COMMAND ${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/asm/${FILE_NAME}.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/asm/${FILE_NAME}.pl
    )

    if(CMAKE_CROSSCOMPILING)
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT}
            COMMAND ${CMAKE_C_COMPILER} -I${CMAKE_CURRENT_SOURCE_DIR} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR}/include -I${CMAKE_CURRENT_BINARY_DIR}/include ${COMPILER_FLAGS} -E ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT} | ${PERL_EXECUTABLE} -ne "/^#+/ or print" > ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.i && mv -f ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.i ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT}
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT}
        )
    endif()
    set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/${OUT_FILE_NAME}.${ASM_FILE_EXT})
endmacro()

function( check_version major minor rev fix )

    set(VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/opensslv.h)

    file(READ ${VERSION_FILE} VERSION_H_CONTENTS)
    string(REGEX MATCH "OPENSSL_VERSION_NUMBER  0x([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])"
          VERSION_NUM ${VERSION_H_CONTENTS})
    string(SUBSTRING ${VERSION_NUM} 26 1 MAJOR_VER)
    string(SUBSTRING ${VERSION_NUM} 27 2 MINOR_VER)
    string(SUBSTRING ${VERSION_NUM} 29 2 REL_VER)
    string(SUBSTRING ${VERSION_NUM} 31 2 FIX_VER)

    hex2dec(MAJOR_VER ${MAJOR_VER})
    hex2dec(MINOR_VER ${MINOR_VER})
    hex2dec(REL_VER ${REL_VER})
    hex2dec(FIX_VER ${FIX_VER})

    set(${major} ${MAJOR_VER} PARENT_SCOPE)
    set(${minor} ${MINOR_VER} PARENT_SCOPE)
    set(${rev} ${REL_VER} PARENT_SCOPE)
    set(${fix} ${FIX_VER} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${VERSION_FILE} VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    set(VERSION ${MAJOR_VER}.${MINOR_VER}.${REL_VER}.${FIX_VER})
    get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION}\n${VERSION_DATETIME}\n${PROJECT_CPACK_FILENAME}")

endfunction()

function( report_version name ver )

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")

    message("${BoldYellow}${name} version ${ver}${ColourReset}")

endfunction()

function( get_cpack_filename ver name )
    get_compiler_version(COMPILER)
    if(BUILD_SHARED_LIBS OR OSX_FRAMEWORK)
        set(${name} ${PROJECT_NAME}-${ver}-${COMPILER} PARENT_SCOPE)
    else()
        set(${name} ${PROJECT_NAME}-${ver}-STATIC-${COMPILER} PARENT_SCOPE)
    endif()
endfunction()

function( get_compiler_version ver )
    ## Limit compiler version to 2 or 1 digits
    string(REPLACE "." ";" VERSION_LIST ${CMAKE_C_COMPILER_VERSION})
    list(LENGTH VERSION_LIST VERSION_LIST_LEN)
    if(VERSION_LIST_LEN GREATER 2 OR VERSION_LIST_LEN EQUAL 2)
        list(GET VERSION_LIST 0 COMPILER_VERSION_MAJOR)
        list(GET VERSION_LIST 1 COMPILER_VERSION_MINOR)
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${COMPILER_VERSION_MAJOR}.${COMPILER_VERSION_MINOR})
    else()
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${CMAKE_C_COMPILER_VERSION})
    endif()

    if(WIN32)
        if(CMAKE_CL_64)
            set(COMPILER "${COMPILER}-64bit")
        endif()
    endif()

    set(${ver} ${COMPILER} PARENT_SCOPE)
endfunction()

# macro to find packages on the host OS
macro( find_exthost_package )
    if(CMAKE_CROSSCOMPILING OR ANDROID OR IOS)
        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )

        find_package( ${ARGN} )

        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
    else()
        find_package( ${ARGN} )
    endif()
endmacro()


# macro to find programs on the host OS
macro( find_exthost_program )
    if(CMAKE_CROSSCOMPILING OR ANDROID OR IOS)
        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )

        find_program( ${ARGN} )

        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
    else()
        find_program( ${ARGN} )
    endif()
endmacro()
