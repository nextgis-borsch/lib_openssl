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

set(CSOURCES
    encode.c digest.c evp_enc.c evp_key.c evp_cnf.c 
    e_des.c e_bf.c e_idea.c e_des3.c e_camellia.c
    e_rc4.c e_aes.c names.c e_seed.c e_aria.c e_sm4.c 
    e_xcbc_d.c e_rc2.c e_cast.c e_rc5.c 
    m_null.c m_md2.c m_md4.c m_md5.c m_sha1.c m_wp.c 
    m_md5_sha1.c m_mdc2.c m_ripemd.c m_sha3.c 
    p_open.c p_seal.c p_sign.c p_verify.c p_lib.c p_enc.c p_dec.c 
    bio_md.c bio_b64.c bio_enc.c evp_err.c e_null.c 
    c_allc.c c_alld.c evp_lib.c bio_ok.c 
    evp_pkey.c evp_pbe.c p5_crpt.c p5_crpt2.c pbe_scrypt.c 
    e_old.c pmeth_lib.c pmeth_fn.c pmeth_gn.c m_sigver.c 
    e_aes_cbc_hmac_sha1.c e_aes_cbc_hmac_sha256.c e_rc4_hmac_md5.c 
    e_chacha20_poly1305.c cmeth_lib.c
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../modes)

set(TARGET_NAME evp)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
