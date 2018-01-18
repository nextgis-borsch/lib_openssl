################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015-2018, NextGIS <info@nextgis.com>
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
)

macro(add_onefile_test file)
    get_filename_component(name ${file} NAME_WE)
    add_executable(${name} ${file})
    target_link_libraries(${name} ${LIB_NAME})
    add_test(${name} ${name})
endmacro()

macro(add_multifile_test name)
    set(files "${ARGN}")
    add_executable(${name} ${files})
    target_link_libraries(${name} ${LIB_NAME})
    add_test(${name} ${name})
endmacro()

# add_onefile_test(aborttest.c) #Is crash normal here?
# set_tests_properties(aborttest PROPERTIES WILL_FAIL TRUE)

add_onefile_test(sanitytest.c)
add_onefile_test(exdatatest.c)
add_onefile_test(bntest.c)
add_onefile_test(ectest.c)
add_onefile_test(ecdsatest.c)
add_onefile_test(gmdifftest.c)
add_onefile_test(pbelutest.c)
add_onefile_test(ideatest.c)
add_onefile_test(md2test.c)
add_onefile_test(md4test.c)
add_onefile_test(md5test.c)
add_onefile_test(hmactest.c)
add_onefile_test(wp_test.c)
add_onefile_test(rc2test.c)
add_onefile_test(rc4test.c)
add_onefile_test(rc5test.c)
add_onefile_test(destest.c)
add_onefile_test(sha1test.c)
add_onefile_test(sha256t.c)
add_onefile_test(sha512t.c)
add_onefile_test(mdc2test.c)
add_onefile_test(rmdtest.c)
add_onefile_test(randtest.c)
add_onefile_test(dhtest.c)
add_onefile_test(enginetest.c)
add_onefile_test(casttest.c)
add_onefile_test(bftest.c)

# add_onefile_test(ssltest_old.c)
add_executable(ssltest_old ssltest_old.c)
target_link_libraries(ssltest_old ${LIB_NAME})

add_test(ssltest_old1 ssltest_old -v -bio_pair -tls1 -s_cert ${PROJECT_SOURCE_DIR}/apps/server2.pem -no_dhe -no_ecdhe -num 10 -f -time)
set_property(TEST ssltest_old1 PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
)

add_test(ssltest_old2 ssltest_old -v -bio_pair -tls1 -s_cert ${PROJECT_SOURCE_DIR}/apps/server2.pem -dhe1024dsa -num 10 -f -time)
set_property(TEST ssltest_old2 PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
)

add_test(ssltest_old3 ssltest_old -bio_pair -ssl3)
set_property(TEST ssltest_old3 PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
)

add_test(ssltest_old4 ssltest_old -bio_pair -ssl3 -server_auth -CApath ${CMAKE_CURRENT_SOURCE_DIR}/certs)
set_property(TEST ssltest_old4 PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
)

add_test(ssltest_old5 ssltest_old -bio_pair -ssl3 -client_auth -CApath ${CMAKE_CURRENT_SOURCE_DIR}/certs)
set_property(TEST ssltest_old5 PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
)

add_test(ssltest_old6 ssltest_old -bio_pair -ssl3 -server_auth -client_auth -CApath ${CMAKE_CURRENT_SOURCE_DIR}/certs)
set_property(TEST ssltest_old6 PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
)

# TODO: Additional tests from ./test/recipes/80-test_ssl_old.t

add_onefile_test(dsatest.c)
add_onefile_test(exptest.c)
add_onefile_test(rsa_test.c)

# add_onefile_test(evp_test.c)
add_executable(evp_test evp_test.c)
target_link_libraries(evp_test ${LIB_NAME})
add_test(
    NAME evp_test
    COMMAND evp_test ${CMAKE_CURRENT_SOURCE_DIR}/evptests.txt
)

add_onefile_test(evp_extra_test.c)
add_onefile_test(igetest.c)
add_onefile_test(v3nametest.c)

# add_onefile_test(v3ext.c)
add_executable(v3ext v3ext.c)
target_link_libraries(v3ext ${LIB_NAME})
add_test(
    NAME v3ext
    COMMAND v3ext ${CMAKE_CURRENT_SOURCE_DIR}/certs/pathlen.pem
)

# add_onefile_test(danetest.c)
add_executable(danetest danetest.c)
target_link_libraries(danetest ${LIB_NAME})
add_test(
    NAME danetest
    COMMAND danetest "example.com" ${CMAKE_CURRENT_SOURCE_DIR}/danetest.pem ${CMAKE_CURRENT_SOURCE_DIR}/danetest.in
)

add_onefile_test(p5_crpt2_test.c)
add_onefile_test(constant_time_test.c)

# add_onefile_test(verify_extra_test.c)
add_executable(verify_extra_test verify_extra_test.c)
target_link_libraries(verify_extra_test ${LIB_NAME})
add_test(
    NAME verify_extra_test
    COMMAND verify_extra_test
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/roots.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/untrusted.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/bad.pem
)

add_onefile_test(clienthellotest.c)
add_onefile_test(bad_dtls_test.c)
add_onefile_test(packettest.c)
add_onefile_test(asynctest.c)
add_onefile_test(secmemtest.c)
add_onefile_test(srptest.c)
add_onefile_test(memleaktest.c)
add_onefile_test(dtlsv1listentest.c)
add_onefile_test(threadstest.c)
add_onefile_test(afalgtest.c)

# add_onefile_test(x509aux.c)
add_executable(x509aux x509aux.c)
target_link_libraries(x509aux ${LIB_NAME})
add_test(
    NAME x509aux
    COMMAND x509aux
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/roots.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/root+anyEKU.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/root-anyEKU.pem
        ${CMAKE_CURRENT_SOURCE_DIR}/certs/root-cert.pem
)

add_onefile_test(bioprinttest.c)
add_onefile_test(bio_enc_test.c)

add_multifile_test(crltest crltest.c testutil.c)
add_multifile_test(heartbeat_test heartbeat_test.c testutil.c)

add_executable(ct_test ct_test.c testutil.c)
target_link_libraries(ct_test ${LIB_NAME})
add_test(ct_test ct_test ct ec)
set_property(TEST ct_test PROPERTY ENVIRONMENT
    "CTLOG_FILE=${CMAKE_CURRENT_SOURCE_DIR}/ct/log_list.conf"
    "CT_DIR=${CMAKE_CURRENT_SOURCE_DIR}/ct"
    "CERTS_DIR=${CMAKE_CURRENT_SOURCE_DIR}/certs"
)

# add_multifile_test(d2i_test d2i_test.c testutil.c)
add_executable(d2i_test d2i_test.c testutil.c)
target_link_libraries(d2i_test ${LIB_NAME})
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

# add_multifile_test(ssl_test_ctx_test ssl_test_ctx_test.c ssl_test_ctx.c testutil.c)
add_executable(ssl_test_ctx_test ssl_test_ctx_test.c ssl_test_ctx.c testutil.c)
target_link_libraries(ssl_test_ctx_test ${LIB_NAME})
add_test(ssl_test_ctx_test ssl_test_ctx_test ${CMAKE_CURRENT_SOURCE_DIR}/ssl_test_ctx_test.conf)

# add_multifile_test(ssl_test ssl_test_ctx_test.c ssl_test_ctx.c testutil.c) # Complicated - see ./test/recipes/80-test_ssl_new.t

add_multifile_test(cipherlist_test cipherlist_test.c testutil.c)

# add_multifile_test(asynciotest asynciotest.c ssltestlib.c)
add_executable(asynciotest asynciotest.c ssltestlib.c)
target_link_libraries(asynciotest ${LIB_NAME})
add_test(
    NAME asynciotest
    COMMAND asynciotest
        ${PROJECT_SOURCE_DIR}/apps/server.pem
        ${PROJECT_SOURCE_DIR}/apps/server.pem
)

# add_multifile_test(sslapitest sslapitest.c ssltestlib.c testutil.c)
add_executable(sslapitest sslapitest.c ssltestlib.c testutil.c)
target_link_libraries(sslapitest ${LIB_NAME})
add_test(
    NAME sslapitest
    COMMAND sslapitest
        ${PROJECT_SOURCE_DIR}/apps/server.pem
        ${PROJECT_SOURCE_DIR}/apps/server.pem
)

# add_multifile_test(dtlstest dtlstest.c ssltestlib.c testutil.c)
add_executable(dtlstest dtlstest.c ssltestlib.c testutil.c)
target_link_libraries(dtlstest ${LIB_NAME})
add_test(
    NAME dtlstest
    COMMAND dtlstest
        ${PROJECT_SOURCE_DIR}/apps/server.pem
        ${PROJECT_SOURCE_DIR}/apps/server.pem
)

# add_multifile_test(sslcorrupttest sslcorrupttest.c ssltestlib.c testutil.c)
add_executable(sslcorrupttest sslcorrupttest.c ssltestlib.c testutil.c)
target_link_libraries(sslcorrupttest ${LIB_NAME})
add_test(
    NAME sslcorrupttest
    COMMAND sslcorrupttest
        ${PROJECT_SOURCE_DIR}/apps/server.pem
        ${PROJECT_SOURCE_DIR}/apps/server.pem
)
