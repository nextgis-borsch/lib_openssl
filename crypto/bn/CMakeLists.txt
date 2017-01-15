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
    bn_add.c bn_div.c bn_exp.c bn_lib.c bn_ctx.c bn_mul.c bn_mod.c
    bn_print.c bn_rand.c bn_shift.c bn_word.c bn_blind.c
    bn_kron.c bn_sqrt.c bn_gcd.c bn_prime.c bn_err.c bn_sqr.c
    bn_recp.c bn_mont.c bn_mpi.c bn_exp2.c bn_nist.c
    bn_depr.c bn_const.c bn_x931p.c bn_intern.c bn_dh.c bn_srp.c
)

if(OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} bn_asm.c)
else()
    if(ANDROID_ARMV4)
        set(CSOURCES ${CSOURCES} bn_asm.c)
        set(ASM_SOURCES armv4-mont armv4-gf2m)
        add_definitions(-DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_GF2m)
    elseif(ANDROID_MIPS32 OR ANDROID_MIPS64)
        set(ASM_SOURCES bn-mips mips-mont)
        add_definitions(-DOPENSSL_BN_ASM_MONT)
    elseif(ANDROID_AARCH64)
        set(CSOURCES ${CSOURCES} bn_asm.c)
        set(ASM_SOURCES armv8-mont)
        add_definitions(-DOPENSSL_BN_ASM_MONT)
    elseif(HOST_X64)
        set(CSOURCES ${CSOURCES} asm/x86_64-gcc.c rsaz_exp.c)
        set(ASM_SOURCES x86_64-mont x86_64-mont5 x86_64-gf2m  rsaz-x86_64 rsaz-avx2)
        add_definitions(-DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_GF2m -DOPENSSL_BN_ASM_MONT5)
    else()
        set(ASM_SOURCES bn-586 co-586 x86-mont x86-gf2m)
        add_definitions(-DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_GF2m -DOPENSSL_BN_ASM_PART_WORDS)
    endif()

    if(NOT OPENSSL_NO_SSE2)
        add_definitions(-DOPENSSL_IA32_SSE2)
    endif()
endif()

if(NOT OPENSSL_NO_EC2M)
    set(CSOURCES ${CSOURCES} bn_gf2m.c)
endif()

foreach(ASM_SOURCE ${ASM_SOURCES})
    generate_asm(${ASM_SOURCE})
endforeach()

set(TARGET_NAME bn)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
