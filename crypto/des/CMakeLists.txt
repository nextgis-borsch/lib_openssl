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
    set_key.c  ecb_enc.c  cbc_enc.c
    ecb3_enc.c cfb64enc.c cfb64ede.c cfb_enc.c
    ofb64ede.c ofb64enc.c ofb_enc.c
    str2key.c  pcbc_enc.c qud_cksm.c rand_key.c
    fcrypt.c xcbc_enc.c rpc_enc.c  cbc_cksm.c
)

if(OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} des_enc.c fcrypt_b.c)
else()
    if(ANDROID_ARMV4 OR IOS_ARM32)
        set(CSOURCES ${CSOURCES} des_enc.c fcrypt_b.c)
    elseif(ANDROID_MIPS32 OR ANDROID_MIPS64)
        set(CSOURCES ${CSOURCES} des_enc.c fcrypt_b.c)
    elseif(ANDROID_AARCH64 OR IOS_ARM64)
        set(CSOURCES ${CSOURCES} des_enc.c fcrypt_b.c)
    elseif(HOST_X64)
        set(CSOURCES ${CSOURCES} des_enc.c fcrypt_b.c)
    else()
        generate_asm(des-586)
        generate_asm(crypt586)
    endif()
endif()

set(TARGET_NAME des)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
