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
    ec_lib.c ecp_smpl.c ecp_mont.c ecp_nist.c ec_cvt.c ec_mult.c
    ec_err.c ec_curve.c ec_check.c ec_print.c ec_asn1.c ec_key.c
    ec2_smpl.c ec2_mult.c ec_ameth.c ec_pmeth.c eck_prn.c
    ecp_nistp224.c ecp_nistp256.c ecp_nistp521.c ecp_nistputil.c
    ecp_oct.c ec2_oct.c ec_oct.c ec_kmeth.c ecdh_ossl.c ecdh_kdf.c
    ecdsa_ossl.c ecdsa_sign.c ecdsa_vrf.c curve25519.c ecx_meth.c
)

if(NOT OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} ecp_nistz256.c)
    if(HOST_X64)
        generate_asm(ecp_nistz256-x86_64)
    else()
        generate_asm(ecp_nistz256-x86)
    endif()
    add_definitions(-DECP_NISTZ256_ASM)
endif()

set(TARGET_NAME ec)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
