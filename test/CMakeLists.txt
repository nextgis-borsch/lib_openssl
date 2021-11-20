################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015-2019, NextGIS <info@nextgis.com>
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

include_directories(
    ${PROJECT_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/crypto/include
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/crypto/ec
    ${PROJECT_SOURCE_DIR}/crypto/ec/curve448
)

set(TEST_UTIL_SRS
    testutil/basic_output.c testutil/output_helpers.c 
    testutil/driver.c testutil/tests.c testutil/cb.c testutil/stanza.c 
    testutil/format_output.c testutil/tap_bio.c 
    testutil/test_cleanup.c testutil/main.c testutil/init.c
    testutil/random.c testutil/testutil_init.c
)

add_library(testutil STATIC ${TEST_UTIL_SRS})
target_link_libraries(testutil ${LIB_NAME})

macro(add_onefile_test file)
    get_filename_component(name ${file} NAME_WE)
    add_executable(${name} ${file})
    target_link_libraries(${name} ${LIB_NAME} testutil)
    add_test(${name} ${name})
endmacro()

macro(add_multifile_test name)
    set(files "${ARGN}")
    add_executable(${name} ${files})
    target_link_libraries(${name} ${LIB_NAME} testutil)
    add_test(${name} ${name})
endmacro()

if(CMAKE_BUILD_STATIC)
    add_onefile_test(rdrand_sanitytest.c)
    add_onefile_test(asn1_internal_test.c)
    add_onefile_test(modes_internal_test.c)
    add_onefile_test(x509_internal_test.c)
    add_onefile_test(tls13encryptiontest.c)
    add_onefile_test(wpackettest.c)
    add_onefile_test(ctype_internal_test.c)                     
endif()

add_onefile_test(versions.c)
# add_onefile_test(aborttest.c) How to catch expected abort?
add_onefile_test(sanitytest.c)
add_onefile_test(rsa_complex.c)
add_onefile_test(test_test.c)
add_onefile_test(exdatatest.c)
add_onefile_test(bntest.c)
add_onefile_test(ectest.c)

if(WITH_LONG_TESTS)
    add_onefile_test(ecstresstest.c)
endif()

add_onefile_test(ecdsatest.c)
add_onefile_test(gmdifftest.c)
add_onefile_test(pbelutest.c)
add_onefile_test(ideatest.c)
add_onefile_test(md2test.c)
add_onefile_test(hmactest.c)
add_onefile_test(rc2test.c)
add_onefile_test(rc4test.c)
add_onefile_test(rc5test.c)
add_onefile_test(destest.c)
add_onefile_test(mdc2test.c)
add_onefile_test(dhtest.c)
add_onefile_test(enginetest.c)
add_onefile_test(casttest.c)
add_onefile_test(bftest.c)
# add_onefile_test(ssltest_old.c) in favour ssl_test.c
add_onefile_test(dsatest.c)
add_onefile_test(dsa_no_digest_size_test.c)
add_onefile_test(exptest.c)
add_onefile_test(rsa_test.c)
add_onefile_test(rsa_mp_test.c)
# add_multifile_test(fatalerrtest fatalerrtest.c ssltestlib.c) How to catch expected fatal error?
# add_multifile_test(tls13ccstest tls13ccstest.c ssltestlib.c)

add_executable(tls13ccstest tls13ccstest.c ssltestlib.c)
target_link_libraries(tls13ccstest ${LIB_NAME} testutil)
add_test(tls13ccstest tls13ccstest 
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

# add_onefile_test(evp_test.c)    
add_executable(evp_test evp_test.c)
target_link_libraries(evp_test ${LIB_NAME} testutil)

set(EVP_TEST_FILES 
    evpciph.txt evpdigest.txt evpencod.txt evpkdf.txt evpmac.txt evppbe.txt
    evppkey.txt evppkey_ecc.txt evpcase.txt evpccmcavs.txt
)

foreach(EVP_TEST_FILE ${EVP_TEST_FILES})
    add_test(evp_test_${EVP_TEST_FILE} evp_test ${CMAKE_CURRENT_SOURCE_DIR}/recipes/30-test_evp_data/${EVP_TEST_FILE})
endforeach()



add_onefile_test(evp_extra_test.c)
add_onefile_test(igetest.c)
add_onefile_test(v3nametest.c)
add_onefile_test(crltest.c)

# add_onefile_test(v3ext.c)
add_executable(v3ext v3ext.c)
target_link_libraries(v3ext ${LIB_NAME} testutil)
add_test(v3ext v3ext ${CMAKE_CURRENT_SOURCE_DIR}/certs/pathlen.pem)

# add_onefile_test(danetest.c)
add_executable(danetest danetest.c)
target_link_libraries(danetest ${LIB_NAME} testutil)
add_test(danetest danetest "example.com" ${CMAKE_CURRENT_SOURCE_DIR}/danetest.pem ${CMAKE_CURRENT_SOURCE_DIR}/danetest.in)

add_onefile_test(constant_time_test.c)

# add_onefile_test(verify_extra_test.c)
add_executable(verify_extra_test verify_extra_test.c)
target_link_libraries(verify_extra_test ${LIB_NAME} testutil)
add_test(verify_extra_test verify_extra_test
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/roots.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/untrusted.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/bad.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/rootCA.pem
)

# add_onefile_test(clienthellotest.c)
add_executable(clienthellotest clienthellotest.c)
target_link_libraries(clienthellotest ${LIB_NAME} testutil)
add_test(clienthellotest clienthellotest ${CMAKE_CURRENT_SOURCE_DIR}/session.pem)

add_onefile_test(bad_dtls_test.c)
add_onefile_test(packettest.c)
add_onefile_test(asynctest.c)
add_onefile_test(secmemtest.c)
add_onefile_test(srptest.c)
add_onefile_test(memleaktest.c)
add_onefile_test(stack_test.c)
add_onefile_test(lhash_test.c)
add_onefile_test(dtlsv1listentest.c)

# add_onefile_test(ct_test.c)
add_executable(ct_test ct_test.c)
target_link_libraries(ct_test ${LIB_NAME} testutil)
add_test(ct_test ct_test ct ec)
set_property(TEST ct_test PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
    "CT_DIR=${CMAKE_CURRENT_SOURCE_DIR}/ct"
    "CERTS_DIR=${CMAKE_CURRENT_SOURCE_DIR}/certs"
)

add_onefile_test(threadstest.c)
add_onefile_test(afalgtest.c)

# add_onefile_test(d2i_test.c)
add_executable(d2i_test d2i_test.c)
target_link_libraries(d2i_test ${LIB_NAME} testutil)
add_test(d2i_test_bad_cert d2i_test "X509" "decode" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/bad_cert.der)
add_test(d2i_test_bad_generalname d2i_test "GENERAL_NAME" "decode" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/bad_generalname.der)
add_test(d2i_test_bad_bio d2i_test "ASN1_ANY" "BIO" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/bad_bio.der)
add_test(d2i_test_high_tag d2i_test "ASN1_ANY" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/high_tag.der)
add_test(d2i_test_high_tag1 d2i_test "ASN1_INTEGER" "decode" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/high_tag.der)
add_test(d2i_test_int0 d2i_test "ASN1_INTEGER" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/int0.der)
add_test(d2i_test_int1 d2i_test "ASN1_INTEGER" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/int1.der)
add_test(d2i_test_intminus1 d2i_test "ASN1_INTEGER" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/intminus1.der)
add_test(d2i_test_int2 d2i_test "ASN1_ANY" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/int0.der)
add_test(d2i_test_int3 d2i_test "ASN1_ANY" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/int1.der)
add_test(d2i_test_intminus2 d2i_test "ASN1_ANY" "OK" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/intminus1.der)
add_test(d2i_test_bad-int-pad0 d2i_test "ASN1_INTEGER" "decode" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/bad-int-pad0.der)
add_test(d2i_test_bad-int-padminus1 d2i_test "ASN1_INTEGER" "decode" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/bad-int-padminus1.der)
add_test(d2i_test_bad-cms d2i_test "CMS_ContentInfo" "decode" ${CMAKE_CURRENT_SOURCE_DIR}/d2i-tests/bad-cms.der)


# add_multifile_test(ssl_test_ctx_test ssl_test_ctx_test.c ssl_test_ctx.c)
add_executable(ssl_test_ctx_test ssl_test_ctx_test.c ssl_test_ctx.c)
target_link_libraries(ssl_test_ctx_test ${LIB_NAME} testutil)
add_test(ssl_test_ctx_test ssl_test_ctx_test ${CMAKE_CURRENT_SOURCE_DIR}/ssl_test_ctx_test.conf)

# add_multifile_test(ssl_test ssl_test.c ssl_test_ctx.c handshake_helper.c)
# ok(run(perltest(["generate_ssl_tests.pl", $input_file],
#                         interpreter_args => [ "-I", srctop_dir("util", "perl")],
#                         stdout => $tmp_file)),
#            "Getting output from generate_ssl_tests.pl.");
# add_executable(ssl_test ssl_test.c ssl_test_ctx.c handshake_helper.c)
# target_link_libraries(ssl_test ${LIB_NAME} testutil)
# add_test(ssl_test ssl_test ${CMAKE_CURRENT_BINARY_DIR}/ssl_test.tmp)
# set_property(TEST ssl_test PROPERTY ENVIRONMENT
#     "TEST_CERTS_DIR=${CMAKE_CURRENT_SOURCE_DIR}/certs"
#     "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
# )

# Disable this test as added GOST ciphers: add_onefile_test(cipherlist_test.c)

# add_onefile_test(x509aux.c)
add_executable(x509aux x509aux.c)
target_link_libraries(x509aux ${LIB_NAME} testutil)
add_test(x509aux x509aux
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/roots.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/root+anyEKU.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/root-anyEKU.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/root-cert.pem
)

# add_multifile_test(asynciotest asynciotest.c ssltestlib.c)
add_executable(asynciotest asynciotest.c ssltestlib.c)
target_link_libraries(asynciotest ${LIB_NAME} testutil)
add_test(asynciotest asynciotest
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

add_onefile_test(bio_callback_test.c)
add_onefile_test(bio_memleak_test.c)
add_onefile_test(bioprinttest.c)

# add_multifile_test(sslapitest sslapitest.c ssltestlib.c)
add_executable(sslapitest sslapitest.c ssltestlib.c)
target_link_libraries(sslapitest ${LIB_NAME} testutil)
add_test(sslapitest sslapitest
    ${CMAKE_CURRENT_SOURCE_DIR}/certs
    ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_sslapi_data/passwd.txt
    ${CMAKE_CURRENT_BINARY_DIR}/sslapitest.tmp
)

# add_onefile_test(ocspapitest.c)
# add_executable(ocspapitest ocspapitest.c)
# target_link_libraries(ocspapitest ${LIB_NAME} testutil)
# add_test(ocspapitest ocspapitest

# )

# add_multifile_test(dtlstest dtlstest.c ssltestlib.c)
add_executable(dtlstest dtlstest.c ssltestlib.c)
target_link_libraries(dtlstest ${LIB_NAME} testutil)
add_test(dtlstest dtlstest
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

# add_multifile_test(sslcorrupttest sslcorrupttest.c ssltestlib.c)
add_executable(sslcorrupttest sslcorrupttest.c ssltestlib.c)
target_link_libraries(sslcorrupttest ${LIB_NAME} testutil)
add_test(sslcorrupttest sslcorrupttest
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

add_onefile_test(bio_enc_test.c)
add_onefile_test(pkey_meth_test.c)
add_onefile_test(pkey_meth_kdf_test.c)
add_onefile_test(x509_time_test.c)
# add_multifile_test(recordlentest recordlentest.c ssltestlib.c)
add_executable(recordlentest recordlentest.c ssltestlib.c)
target_link_libraries(recordlentest ${LIB_NAME} testutil)
add_test(recordlentest recordlentest 
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

add_onefile_test(drbgtest.c)
add_multifile_test(drbg_cavs_test drbg_cavs_test.c drbg_cavs_data.c)
# add_onefile_test(x509_dup_cert_test.c)
add_executable(x509_dup_cert_test x509_dup_cert_test.c)
target_link_libraries(x509_dup_cert_test ${LIB_NAME} testutil)
add_test(x509_dup_cert_test x509_dup_cert_test 
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/leaf.pem
)

# add_onefile_test(x509_check_cert_pkey_test.c)
add_executable(x509_check_cert_pkey_test x509_check_cert_pkey_test.c)
target_link_libraries(x509_check_cert_pkey_test ${LIB_NAME} testutil)

# rsa
add_test(x509_check_cert_pkey_test1 x509_check_cert_pkey_test 
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/servercert.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/serverkey.pem
    "cert" "ok"
)

# mismatched rsa
add_test(x509_check_cert_pkey_test2 x509_check_cert_pkey_test 
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/servercert.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/wrongkey.pem
    "cert" "failed"
)

# dsa
if(NOT OPENSSL_NO_DSA)
    add_test(x509_check_cert_pkey_test3 x509_check_cert_pkey_test 
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/server-dsa-cert.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/server-dsa-key.pem
        "cert" "ok"
    )
endif()

# ecc
if(NOT OPENSSL_NO_EC)
    add_test(x509_check_cert_pkey_test4 x509_check_cert_pkey_test 
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/server-ecdsa-cert.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/server-ecdsa-key.pem
        "cert" "ok"
    )
endif()

# certificate request (rsa)
add_test(x509_check_cert_pkey_test5 x509_check_cert_pkey_test 
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/x509-check.csr
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/x509-check-key.pem
    "req" "ok"
)

# mismatched certificate request (rsa)
add_test(x509_check_cert_pkey_test6 x509_check_cert_pkey_test 
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/x509-check.csr
    ${CMAKE_CURRENT_SOURCE_DIR}/certs/wrongkey.pem
    "req" "failed"
)

add_onefile_test(pemtest.c)
if(CMAKE_BUILD_STATIC)
    add_onefile_test(ssl_cert_table_internal_test.c)
endif()
# add_onefile_test(ciphername_test.c)

# add_multifile_test(servername_test servername_test.c ssltestlib.c)
add_executable(servername_test servername_test.c ssltestlib.c)
target_link_libraries(servername_test ${LIB_NAME} testutil)
add_test(servername_test servername_test 
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

if(NOT OPENSSL_NO_CMS)
    # add_onefile_test(cmsapitest)
    add_executable(cmsapitest cmsapitest.c)
    target_link_libraries(cmsapitest ${LIB_NAME} testutil)
    add_test(cmsapitest cmsapitest 
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/servercert.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/serverkey.pem
    )
endif()
if(NOT OPENSSL_NO_PSK)
    add_multifile_test(dtls_mtu_test dtls_mtu_test.c ssltestlib.c)
endif()
#if(NOT OPENSSL_NO_SHARED)
    # add_onefile_test(shlibloadtest)
    # add_executable(shlibloadtest shlibloadtest.c)
    # target_link_libraries(shlibloadtest ${LIB_NAME} testutil)
    # add_test(shlibloadtest shlibloadtest 
    # )
    #add_onefile_test(cipher_overhead_test.c)
#endif()
add_onefile_test(cipherbytes_test.c)
add_onefile_test(asn1_encode_test.c)
add_onefile_test(asn1_decode_test.c)
add_onefile_test(asn1_string_table_test.c)
add_onefile_test(time_offset_test.c)

# add_onefile_test(conf_include_test.c)
add_executable(conf_include_test conf_include_test.c)
target_link_libraries(conf_include_test ${LIB_NAME} testutil)
add_test(conf_include_test1 conf_include_test ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_includes_data/includes.cnf)
add_test(conf_include_test2 conf_include_test ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_includes_data/includes-file.cnf)
add_test(conf_include_test3 conf_include_test ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_includes_data/includes-eq.cnf)
add_test(conf_include_test4 conf_include_test ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_includes_data/includes-eq-ws.cnf)
add_test(conf_include_test5 conf_include_test ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_includes_data/includes-broken.cnf "f")

if(CMAKE_BUILD_STATIC)
    if(NOT OPENSSL_NO_POLY1305)
        add_onefile_test(poly1305_internal_test.c)
    endif()
    if(NOT OPENSSL_NO_CHACHA)
        add_onefile_test(chacha_internal_test.c)
    endif()
    if(NOT OPENSSL_NO_SIPHASH)
        add_onefile_test(siphash_internal_test.c)
    endif()
    if(NOT OPENSSL_NO_SM2)
        add_onefile_test(sm2_internal_test.c)
    endif()
    if(NOT OPENSSL_NO_SM4)
        add_onefile_test(sm4_internal_test.c)
    endif()
    if(NOT OPENSSL_NO_EC)
        add_onefile_test(ec_internal_test.c)
    endif()

    add_onefile_test(curve448_internal_test.c)
    if(NOT OPENSSL_NO_MDC2)
        add_onefile_test(mdc2_internal_test.c)
    endif()
endif()
    
add_onefile_test(asn1_time_test.c)

# if(NOT OPENSSL_NO_SHARED AND NOT OPENSSL_NO_TLS1_3)
#     add_onefile_test(tls13secretstest.c)
# endif()

# add_multifile_test(sslbuffertest sslbuffertest.c ssltestlib.c)
add_executable(sslbuffertest sslbuffertest.c ssltestlib.c)
target_link_libraries(sslbuffertest ${LIB_NAME} testutil)
add_test(sslbuffertest sslbuffertest 
    ${PROJECT_SOURCE_DIR}/apps/server.pem
    ${PROJECT_SOURCE_DIR}/apps/server.pem
)

if(NOT OPENSSL_NO_TLS1_2 AND NOT OPENSSL_NO_RSA)
    add_onefile_test(sysdefaulttest.c)
    set_property(TEST sysdefaulttest PROPERTY ENVIRONMENT
        "OPENSSL_CONF=${CMAKE_CURRENT_SOURCE_DIR}/sysdefault.cnf"
    )
endif()

add_onefile_test(errtest.c)

# add_multifile_test(gosttest gosttest.c ssltestlib.c)
add_executable(gosttest gosttest.c ssltestlib.c)
target_link_libraries(gosttest ${LIB_NAME} testutil)
add_test(gosttest gosttest 
    ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_gost_data/server-cert2001.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_gost_data/server-key2001.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_gost_data/server-cert2012.pem
    ${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_gost_data/server-key2012.pem
)
set_property(TEST gosttest PROPERTY ENVIRONMENT
    "OPENSSL_CONF=${CMAKE_CURRENT_SOURCE_DIR}/recipes/90-test_gost_data/gost.conf"
)
