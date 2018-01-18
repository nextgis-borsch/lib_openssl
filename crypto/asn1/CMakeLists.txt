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
    a_object.c a_bitstr.c a_utctm.c a_gentm.c a_time.c a_int.c a_octet.c
    a_print.c a_type.c a_dup.c a_d2i_fp.c a_i2d_fp.c
    a_utf8.c a_sign.c a_digest.c a_verify.c a_mbstr.c a_strex.c
    x_algor.c x_val.c x_sig.c x_bignum.c
    x_int64.c x_long.c x_info.c x_spki.c nsseq.c
    d2i_pu.c d2i_pr.c i2d_pu.c i2d_pr.c
    t_pkey.c t_spki.c t_bitst.c
    tasn_new.c tasn_fre.c tasn_enc.c tasn_dec.c tasn_utl.c tasn_typ.c
    tasn_prn.c tasn_scn.c ameth_lib.c
    f_int.c f_string.c n_pkey.c
    x_pkey.c bio_asn1.c bio_ndef.c asn_mime.c
    asn1_gen.c asn1_par.c asn1_lib.c asn1_err.c a_strnid.c
    evp_asn1.c asn_pack.c p5_pbe.c p5_pbev2.c p5_scrypt.c p8_pkey.c
    asn_moid.c asn_mstbl.c
)

set(TARGET_NAME asn1)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
