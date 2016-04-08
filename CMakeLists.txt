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

# Note for Windows from here: http://developer.covenanteyes.com/building-openssl-for-visual-studio/
# Don’t try to build 32-bit and 64-bit OpenSSL in the same folder.

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

set(PROJECT_NAME "openssl")
project(${PROJECT_NAME})

set(CMAKE_COLOR_MAKEFILE ON)
#set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

# TODO: do we need to name them libeay32 & ssleay32 for windows?
set(LIB_CRYPTO_NAME) 
set(LIB_SSL_NAME) 
if(BUILD_SHARED_LIBS)
    set(LIB_CRYPTO_NAME crypto) 
    set(LIB_SSL_NAME ssl) 
else()
    set(LIB_CRYPTO_NAME cryptostatic) 
    set(LIB_SSL_NAME sslstatic)
endif()

include(FindAnyProject)

include(GNUInstallDirs)

set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)

file(GLOB_RECURSE HHEADERS FOLOW_SYMLYNKS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h )

foreach(TO ${HHEADERS})
    file(READ ${TO} PATH_CONTENTS)
    #message(STATUS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/${PATH_CONTENTS})
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/${PATH_CONTENTS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/include/openssl)
endforeach()

file(READ ${CMAKE_CURRENT_BINARY_DIR}/include/openssl/opensslv.h VERSION_H_CONTENTS)
string(REGEX MATCH "OPENSSL_VERSION_NUMBER  0x([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])"
      VERSION_NUM ${VERSION_H_CONTENTS})      
string(SUBSTRING ${VERSION_NUM} 26 1 MAJOR_VER)
string(SUBSTRING ${VERSION_NUM} 27 2 MINOR_VER)
string(SUBSTRING ${VERSION_NUM} 29 2 REL_VER)
string(SUBSTRING ${VERSION_NUM} 31 2 FIX_VER)
include(util)
hex2dec(MAJOR_VER ${MAJOR_VER})
hex2dec(MINOR_VER ${MINOR_VER})
hex2dec(REL_VER ${REL_VER})
hex2dec(FIX_VER ${FIX_VER})
set(VERSION ${MAJOR_VER}.${MINOR_VER}.${REL_VER})
message(STATUS "${PROJECT_NAME} version=[${VERSION}]")  

set(PROJECT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

add_definitions(-DOPENSSL_NO_ASM -DOPENSSL_THREADS)

if(WIN32 AND NOT CYGWIN)
    configure_file( ${CMAKE_MODULE_PATH}/version32.rc.cmake ${CMAKE_BINARY_DIR}/version32.rc )

    add_definitions(-DOPENSSL_SYSNAME_WIN32)
    add_definitions(-DWIN32_LEAN_AND_MEAN -DDSO_WIN32)
    add_definitions(-D_UNICODE -D_UNICODE -D_CRT_SECURE_NO_DEPRECATE)
  
    # avoid conflict: ocsp.h and wincrypt.h
    add_definitions(-D_WINDLL)
endif()

if(MINGW)
  set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--export-all")
endif()

if(BUILD_SHARED_LIBS)
    add_definitions(-DOPENSSL_NO_STATIC_ENGINE)
endif()

set(EXT_LIBS)

find_anyproject(ZLIB DEFAULT ON)
if(ZLIB_FOUND)
    set(EXT_LIBS ${EXT_LIBS} ${ZLIB_LIBRARIES})
#    include_directories(${ZLIB_INCLUDE_DIRS})
    add_definitions(-DZLIB)
    if(BUILD_SHARED_LIBS)
        add_definitions(-DZLIB_SHARED)
    endif()
endif()

set(EXPORT_TARGETS)

add_subdirectory(crypto)
add_subdirectory(ssl)

install(FILES e_os2.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/openssl)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/openssl DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

#install(FILES tools/c_hash tools/c_info tools/c_issuer tools/c_name tools/c_rehash
#    FAQ LICENSE PROBLEMS README README.ASN1 README.ENGINE
#    DESTINATION share/openssl )
#install( DIRECTORY doc DESTINATION ./ )

if(BUILD_SHARED_LIBS)
    set(EXPORT_NAME ${PROJECT_NAME})
else()
    set(EXPORT_NAME ${PROJECT_NAME}static)
endif()
if(EXPORT_TARGETS)
    export(TARGETS ${EXPORT_TARGETS} FILE ${EXPORT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()
