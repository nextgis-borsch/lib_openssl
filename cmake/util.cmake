################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
# Copyright (C) 2015 Dmitry Baryshnikov <dmitry.baryshnikov@nextgis.com>
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
            SET(${VAR} ${VAL})
        elseif(${VAL} MATCHES "[aA]")
            SET(${VAR} 10)
        elseif(${VAL} MATCHES "[bB]")
            SET(${VAR} 11)
        elseif(${VAL} MATCHES "[cC]")
            SET(${VAR} 12)
        elseif(${VAL} MATCHES "[dD]")
            SET(${VAR} 13)
        elseif(${VAL} MATCHES "[eE]")
            SET(${VAR} 14)
        elseif(${VAL} MATCHES "[fF]")
            SET(${VAR} 15)
        else()
            MESSAGE(FATAL_ERROR "Invalid format for hexidecimal character")
        endif()

endmacro()

macro(hex2dec VAR VAL)

    IF (${VAL} EQUAL 0)
        SET(${VAR} 0)
    ELSE()

        SET(CURINDEX 0)
        STRING(LENGTH "${VAL}" CURLENGTH)

        SET(${VAR} 0)

        while (CURINDEX LESS  CURLENGTH)

            STRING(SUBSTRING "${VAL}" ${CURINDEX} 1 CHAR)

            hexchar2dec(CHAR ${CHAR})

            MATH(EXPR POWAH "(1<<((${CURLENGTH}-${CURINDEX}-1)*4))")
            MATH(EXPR CHAR "(${CHAR}*${POWAH})")
            MATH(EXPR ${VAR} "${${VAR}}+${CHAR}")
            MATH(EXPR CURINDEX "${CURINDEX}+1")
        endwhile()
    ENDIF()

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

function(check_version major minor rev fix)
    if(WIN32)
        file(READ ${CMAKE_CURRENT_BINARY_DIR}/include/openssl/opensslv.h VERSION_H_CONTENTS)
    else()
        file(READ ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/opensslv.h VERSION_H_CONTENTS)
    endif()
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
     
endfunction()

function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")
        
    message(STATUS "${BoldYellow}${name} version ${ver}${ColourReset}")
    
endfunction()    
