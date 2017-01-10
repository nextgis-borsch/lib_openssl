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
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

set(FUNCTION_LIST)

macro(fill_list)
    foreach(FILE_STRING ${FILE_STRINGS})
        string(SUBSTRING ${FILE_STRING} 0 40 FUNC_NAME)
        string(SUBSTRING ${FILE_STRING} 50 -1 FUNC_DESCRIPTION)
        string(REPLACE ":" ";" FUNC_LIST ${FUNC_DESCRIPTION})
        list(GET FUNC_LIST 3 FUNC_TEST)
        set(ADD_ITEM ON)
        if(FUNC_TEST)
            string(REPLACE ":" ";" FUNC_ITEMS ${FUNC_TEST})
        endif()
        foreach(FUNC_ITEM ${FUNC_ITEMS})
            if(OPENSSL_NO_${FUNC_ITEM})
                set(ADD_ITEM OFF)
                break()
            elseif(FUNC_ITEM MATCHES "DEPRECATEDIN_")
                set(ADD_ITEM OFF)
                break()
            endif()
        endforeach()
        if(ADD_ITEM)
            list(APPEND FUNCTION_LIST ${FUNC_NAME})
        endif()
    endforeach()
endmacro()

message("Process libssl.num")
file(STRINGS libssl.num FILE_STRINGS)
fill_list()

message("Process libcrypto.num")
file(STRINGS libcrypto.num FILE_STRINGS)
fill_list()

make_def(${LIB_NAME} "${FUNCTION_LIST}" "${CMAKE_CURRENT_BINARY_DIR}/openssl.def")
