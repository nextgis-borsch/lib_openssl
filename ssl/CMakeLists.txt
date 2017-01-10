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
    pqueue.c
    statem/statem_srvr.c statem/statem_clnt.c  s3_lib.c  s3_enc.c record/rec_layer_s3.c
    statem/statem_lib.c s3_cbc.c s3_msg.c
    methods.c   t1_lib.c  t1_enc.c t1_ext.c
    d1_lib.c  record/rec_layer_d1.c d1_msg.c
    statem/statem_dtls.c d1_srtp.c
    ssl_lib.c ssl_cert.c ssl_sess.c
    ssl_ciph.c ssl_stat.c ssl_rsa.c
    ssl_asn1.c ssl_txt.c ssl_init.c ssl_conf.c  ssl_mcnf.c
    bio_ssl.c ssl_err.c t1_reneg.c tls_srp.c t1_trce.c ssl_utst.c
    record/ssl3_buffer.c record/ssl3_record.c record/dtls1_bitmap.c
    statem/statem.c
)

set(TARGET_NAME ssl)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
