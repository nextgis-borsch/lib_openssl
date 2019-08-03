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
    sha1dgst.c sha1_one.c sha256.c sha512.c keccak1600.c
)

if(NOT OPENSSL_NO_ASM)
    if(ANDROID_ARMV4 OR IOS_ARM32)
        set(ASM_SOURCES sha1-armv4-large sha256-armv4 sha512-armv4 keccak1600-armv4)
    elseif(ANDROID_MIPS32)
        set(ASM_SOURCES sha1-mips sha256-mips)
    elseif(ANDROID_AARCH64 OR IOS_ARM64)
        set(ASM_SOURCES sha1-armv8 sha256-armv8 sha512-armv8 keccak1600-armv8)
    elseif(ANDROID_MIPS64)
        set(ASM_SOURCES sha512-mips)
    elseif(HOST_X64)
        set(ASM_SOURCES sha1-x86_64 sha512-x86_64 sha1-mb-x86_64 sha256-mb-x86_64 keccak1600-x86_64)
        generate_asm2(sha512-x86_64 sha256-x86_64)
    else()
        set(ASM_SOURCES sha1-586 sha256-586 sha512-586)
    endif()

    if(ARM_SOURCE)
        add_definitions(-DSHA1_ASM -DSHA256_ASM -DSHA512_ASM)

        foreach(ARM_SOURCE ${ASM_SOURCES})
            generate_asm(${ARM_SOURCE})
        endforeach()
    endif()
endif()

set(TARGET_NAME sha)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
