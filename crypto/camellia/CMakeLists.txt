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

if(NOT OPENSSL_NO_CAMELLIA)
set(CSOURCES
    cmll_ecb.c cmll_ofb.c cmll_cfb.c cmll_ctr.c
)

if(OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} camellia.c cmll_misc.c cmll_cbc.c)
else()
    if(ANDROID_ARMV4)
        set(CSOURCES ${CSOURCES} camellia.c cmll_misc.c cmll_cbc.c)
    elseif(ANDROID_MIPS32 OR ANDROID_MIPS64)
        set(CSOURCES ${CSOURCES} camellia.c cmll_misc.c cmll_cbc.c)
    elseif(ANDROID_AARCH64 OR IOS_ARM64)
        set(CSOURCES ${CSOURCES} camellia.c cmll_misc.c cmll_cbc.c)
    elseif(HOST_X64)
        set(CSOURCES ${CSOURCES} cmll_misc.c)
        generate_asm(cmll-x86_64)
    else()
        generate_asm(cmll-x86)
    endif()
endif()

set(TARGET_NAME camellia)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
endif()
