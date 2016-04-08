# Based on original work by David Manura
# Copyright (C) 2007-2012 LuaDist.
# Copyright (C) 2013 Brian Sidebotham
# Copyright (C) 2015 NextGIS <info@nextgis.com>, Dmitry Baryshnikov <dmitry.baryshnikov@nextgis.com>
#
# Redistribution and use of this file is allowed according to the terms of the
# MIT license.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
 
include_directories ( ../crypto .. ${PROJECT_BINARY_DIR}/include )

if(BUILD_SHARED_LIBS)
    add_definitions ( -DOPENSSL_BUILD_SHLIBSSL )
endif()

set ( LIBSRC s2_meth.c s2_srvr.c s2_clnt.c s2_lib.c s2_enc.c s2_pkt.c s3_meth.c s3_srvr.c
  s3_clnt.c s3_lib.c s3_enc.c s3_pkt.c s3_both.c s23_meth.c s23_srvr.c s23_clnt.c
  s23_lib.c s23_pkt.c t1_meth.c t1_srvr.c t1_clnt.c t1_lib.c t1_enc.c d1_meth.c d1_srvr.c
  d1_clnt.c d1_lib.c d1_pkt.c d1_both.c ssl_lib.c ssl_err2.c ssl_cert.c
  ssl_sess.c ssl_ciph.c ssl_stat.c ssl_rsa.c ssl_asn1.c ssl_txt.c ssl_algs.c bio_ssl.c
  ssl_err.c kssl.c t1_reneg.c tls_srp.c s3_cbc.c d1_srtp.c t1_ext.c )
  
set(HHEADERS
    ssl.h ssl2.h ssl3.h ssl23.h tls1.h dtls1.h kssl.h
    )
    
include(util)
include(ssl)

make_def(SSL "${EXPORT_FUNC}"  "${CMAKE_BINARY_DIR}/ssl.def")

if(WIN32)   
    set(LIBSRC ${LIBSRC} ${CMAKE_BINARY_DIR}/version32.rc)
endif()
  
if(BUILD_SHARED_LIBS)  
    add_library (${LIB_SSL_NAME} SHARED ${LIBSRC} ${CMAKE_BINARY_DIR}/ssl.def)    
else()    
    add_library (${LIB_SSL_NAME} STATIC ${LIBSRC})
endif()

target_link_libraries (${LIB_SSL_NAME} ${LIB_CRYPTO_NAME} ${EXT_LIBS})

#if(UNIX)
#    # On unix-like platforms the library is almost always called libproj
#   set_target_properties(${the_target} PROPERTIES OUTPUT_NAME ssl)
#elseif(WIN32)
#    if( BUILD_SHARED_LIBS )
#        # Creates ssl.dll when building shared library version libeay/ssleay?
#        set_target_properties(${the_target} PROPERTIES OUTPUT_NAME ssl)
#    else()
#        # Creates ssl_inc.lib when building static library version
#        set_target_properties(${the_target} PROPERTIES OUTPUT_NAME ssl_inc)
#    endif()
#endif()
    
set_target_properties(${LIB_SSL_NAME} PROPERTIES VERSION ${VERSION})
set_target_properties(${LIB_SSL_NAME} PROPERTIES SOVERSION 1)

# install( FILES ${HHEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/openssl)

install( TARGETS ${LIB_SSL_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
    
#export(TARGETS ${LIB_SSL_NAME} FILE ${LIB_SSL_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
set(EXPORT_TARGETS ${EXPORT_TARGETS} ${LIB_SSL_NAME} PARENT_SCOPE)