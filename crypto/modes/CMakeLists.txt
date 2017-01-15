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

set(CSOURCES
    cbc128.c ctr128.c cts128.c cfb128.c ofb128.c gcm128.c
    ccm128.c xts128.c wrap128.c ocb128.c
)

if(NOT OPENSSL_NO_ASM)
    if(ANDROID_ARMV4)
        generate_asm(ghash-armv4)
        generate_asm(ghashv8-armx)
    elseif(ANDROID_MIPS32)
    elseif(ANDROID_AARCH64)
        generate_asm(ghashv8-armx)
    elseif(ANDROID_MIPS64)
    elseif(HOST_X64)
        generate_asm(aesni-gcm-x86_64)
        generate_asm(ghash-x86_64)
    else()
        generate_asm(ghash-x86)
    endif()
    add_definitions(-DGHASH_ASM)
endif()

set(TARGET_NAME modes)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
