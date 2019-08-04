################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015,2017,2019 NextGIS <info@nextgis.com>
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

set(FUNCTION_LIST)

set(IGNORE_DEPRECATION_NAMES "ASN1_STRING_data" "TLSv1_server_method" "TLSv1_client_method" "TLSv1_method" "TLSv1_1_method" "TLSv1_2_method")

macro(fill_list)
    foreach(FILE_STRING ${FILE_STRINGS})
        string(REGEX MATCHALL "[a-zA-Z0-9_:!,]+" STRING_LIST ${FILE_STRING})
        list(GET STRING_LIST 0 FUNC_NAME)
        list(GET STRING_LIST 3 FUNC_DESCRIPTION)
        string(REPLACE ":" ";" FUNC_LIST ${FUNC_DESCRIPTION})

        list(GET FUNC_LIST 0 EXIST_TEST)
        if(EXIST_TEST MATCHES NOEXIST)
            continue()
        endif()

        list(GET FUNC_LIST 1 EXTERNAL_TEST)

        if(EXTERNAL_TEST MATCHES ZLIB AND NOT ZLIB_FOUND)
            continue()
        elseif(WIN32 AND EXTERNAL_TEST MATCHES "!WIN32")
            continue()
        elseif(EXTERNAL_TEST MATCHES VMS)
            continue()
        elseif(NOT UNIX AND EXTERNAL_TEST MATCHES UNIX)
            continue()
        endif()

        list(GET FUNC_LIST 3 FUNC_TEST)
        set(ADD_ITEM ON)
        if(FUNC_TEST)
            string(REPLACE "," ";" FUNC_ITEMS ${FUNC_TEST})
        endif()
        foreach(FUNC_ITEM ${FUNC_ITEMS})
            if(OPENSSL_NO_${FUNC_ITEM})
                set(ADD_ITEM OFF)
                break()
            elseif(FUNC_ITEM MATCHES "DEPRECATEDIN_")
                set(IGNORE_DEPRECATION FALSE)
                foreach(IGNORE_NAME ${IGNORE_DEPRECATION_NAMES})
                    if(NOT SUPPRESS_VERBOSE_OUTPUT)
                        message(">>> Check ${FUNC_NAME} IGNORE_NAME: ${IGNORE_NAME}")
                    endif()
                    if(FUNC_NAME MATCHES ${IGNORE_NAME})
                        set(IGNORE_DEPRECATION TRUE)
                        break()
                    endif()
                endforeach()
                if(NOT IGNORE_DEPRECATION)
                    if(NOT SUPPRESS_VERBOSE_OUTPUT)
                        message(">>> IGNORE DEp")
                    endif()
                    set(ADD_ITEM OFF)
                    break()
                endif()
            endif()
        endforeach()
        if(ADD_ITEM)
            # Fix long function name
            if(FUNC_NAME MATCHES SSL_CTX_set_not_resumable_session_callba)
                set(FUNC_NAME SSL_CTX_set_not_resumable_session_callback)
            elseif(FUNC_NAME MATCHES CT_POLICY_EVAL_CTX_set_shared_CTLOG_STOR)
                set(FUNC_NAME CT_POLICY_EVAL_CTX_set_shared_CTLOG_STORE)
            endif()
            list(APPEND FUNCTION_LIST ${FUNC_NAME})
        endif()
        unset(FUNC_ITEMS)
        unset(FUNC_TEST)
    endforeach()
endmacro()

message("Process libssl.num")
file(STRINGS libssl.num FILE_STRINGS)
fill_list()

message("Process libcrypto.num")
file(STRINGS libcrypto.num FILE_STRINGS)
fill_list()

make_def(${LIB_NAME} "${FUNCTION_LIST}" "${CMAKE_CURRENT_BINARY_DIR}/openssl.def")
