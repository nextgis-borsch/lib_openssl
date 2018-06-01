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

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(SOURCES_C
    openssl.c
    asn1pars.c ca.c ciphers.c cms.c crl.c crl2p7.c dgst.c dhparam.c
    dsa.c dsaparam.c ec.c ecparam.c enc.c engine.c errstr.c gendsa.c
    genpkey.c genrsa.c nseq.c ocsp.c passwd.c pkcs12.c pkcs7.c pkcs8.c
    pkey.c pkeyparam.c pkeyutl.c prime.c rand.c req.c rsa.c rsautl.c
    s_client.c s_server.c s_time.c sess_id.c smime.c speed.c spkac.c
    srp.c ts.c verify.c version.c x509.c rehash.c
    apps.c opt.c s_cb.c s_socket.c
    app_rand.c
)

if(WIN32)
    set(SOURCES_C ${SOURCES_C}
        win32_init.c
    )
endif()

foreach(file ${SOURCES_C})
    set(APPS_OPENSSL "${APPS_OPENSSL} ${file}")
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/progs.h
    COMMAND ${PERL_EXECUTABLE} progs.pl "${APPS_OPENSSL}" > ${CMAKE_CURRENT_BINARY_DIR}/progs.h
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/progs.pl
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    VERBATIM
)

set(HEADERS_H
    ${CMAKE_CURRENT_BINARY_DIR}/progs.h
)

set_source_files_properties(
    ${HEADERS_H} PROPERTIES GENERATED TRUE
)

add_executable(openssl_app ${SOURCES_C} ${HEADERS_H})
target_link_libraries(openssl_app ${LIB_NAME} ${TARGET_LINK_LIB})
if(OSX_FRAMEWORK)
    set_target_properties(openssl_app PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
endif()
set_target_properties(openssl_app PROPERTIES OUTPUT_NAME "openssl")
set(APP_TARGETS openssl_app)

if(NOT WIN32)
    include_directories(${PROJECT_SOURCE_DIR}/engines/gost)
    add_executable(cryptopro2openssl cryptopro2openssl.c)
    target_link_libraries(cryptopro2openssl ${LIB_NAME} ${TARGET_LINK_LIB})
    if(OSX_FRAMEWORK)
        set_target_properties(cryptopro2openssl PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
    endif()
    set(APP_TARGETS ${APP_TARGETS} cryptopro2openssl)
endif()

if(NOT SKIP_INSTALL_EXECUTABLES AND NOT SKIP_INSTALL_ALL)
    install(TARGETS ${APP_TARGETS}
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR} )
endif()

# Get Mosilla certs from curl site
file(DOWNLOAD "https://curl.haxx.se/ca/cacert.pem" ${CMAKE_CURRENT_BINARY_DIR}/cert.pem
    INACTIVITY_TIMEOUT 30
    TLS_VERIFY OFF
)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/ct_log_list.cnf DESTINATION ${INSTALL_SHARE_DIR}/private)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/openssl.cnf DESTINATION ${INSTALL_SHARE_DIR})
if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/cert.pem)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/cert.pem DESTINATION ${INSTALL_SHARE_DIR}/certs)
endif()

# TODO: create app see https://packages.ubuntu.com/artful/amd64/openssl/filelist
