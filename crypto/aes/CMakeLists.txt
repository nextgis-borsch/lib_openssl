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
    aes_misc.c aes_ecb.c aes_cfb.c aes_ofb.c aes_ige.c aes_wrap.c
)

if(OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} aes_core.c aes_cbc.c)
elseif(ANDROID_ARMV4)
    set(CSOURCES ${CSOURCES} aes_core.c aes_cbc.c)
    # FIXME: Error: selected processor does not support ARM mode
    # set(CSOURCES ${CSOURCES} aes_cbc.c)
    # set(ASM_SOURCES aes-armv4 bsaes-armv7 aesv8-armx)
    # add_definitions(-DBSAES_ASM -DAES_ASM)
elseif(ANDROID_MIPS32)
    set(CSOURCES ${CSOURCES} aes_cbc.c)
    set(ASM_SOURCES aes-mips)
    add_definitions(-DAES_ASM)
elseif(ANDROID_AARCH64 OR IOS_ARM64)
    set(CSOURCES ${CSOURCES} aes_core.c aes_cbc.c)
    set(ASM_SOURCES aesv8-armx vpaes-armv8)
    add_definitions(-DAES_ASM -DVPAES_ASM)
elseif(ANDROID_MIPS64)
    set(CSOURCES ${CSOURCES} aes_cbc.c)
    set(ASM_SOURCES aes-mips)
    add_definitions(-DAES_ASM)
elseif(HOST_X64)
    # aes_asm_src     => "aes-x86_64.s vpaes-x86_64.s bsaes-x86_64.s aesni-x86_64.s aesni-sha1-x86_64.s aesni-sha256-x86_64.s aesni-mb-x86_64.s",
    set(ASM_SOURCES aes-x86_64 vpaes-x86_64 bsaes-x86_64 aesni-x86_64
        aesni-sha1-x86_64 aesni-sha256-x86_64 aesni-mb-x86_64
    )
    add_definitions(-DBSAES_ASM -DVPAES_ASM -DAES_ASM)
else()
    # aes_asm_src	=> "aes-586.s vpaes-x86.s aesni-x86.s",
    set(ASM_SOURCES aes-586 vpaes-x86 aesni-x86)
    add_definitions(-DVPAES_ASM -DAES_ASM)
endif()

foreach(ASM_NAME ${ASM_SOURCES})
    generate_asm(${ASM_NAME})
endforeach()

set(TARGET_NAME aes)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
