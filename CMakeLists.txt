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

set(PROJECT_NAME openssl)
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

# Replace stub headers with actual ones.
if(WIN32)
    file(GLOB_RECURSE HHEADERS FOLOW_SYMLYNKS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h )
    foreach(TO ${HHEADERS})
        file(READ ${TO} PATH_CONTENTS)
        #message(STATUS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/${PATH_CONTENTS})
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/${PATH_CONTENTS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/include/openssl)
    endforeach()
else()
    file(GLOB_RECURSE HHEADERS FOLOW_SYMLYNKS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h )
    foreach(TO ${HHEADERS})
        get_filename_component(HHEADER ${TO} NAME)
        configure_file(${TO} ${CMAKE_CURRENT_BINARY_DIR}/include/openssl/${HHEADER} COPYONLY)
    endforeach()    
endif()

include(util)
check_version(MAJOR_VER MINOR_VER REL_VER FIX_VER)
set(VERSION ${MAJOR_VER}.${MINOR_VER}.${REL_VER})
report_version(${PROJECT_NAME} ${VERSION})  

set(PROJECT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

add_definitions(-DOPENSSL_NO_ASM -DOPENSSL_THREADS)

if(WIN32 AND NOT CYGWIN)
    configure_file( ${CMAKE_SOURCE_DIR}/cmake/version32.rc.cmake ${CMAKE_BINARY_DIR}/version32.rc )

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
else()    
    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        set( CMAKE_CXX_FLAGS "-fpic ${CMAKE_CXX_FLAGS}" )
        set( CMAKE_C_FLAGS   "-fpic ${CMAKE_C_FLAGS}" )  
    endif()
endif()

#set(EXT_LIBS)

find_anyproject(ZLIB DEFAULT OFF)
if(ZLIB_FOUND)
#    set(EXT_LIBS ${EXT_LIBS} ${ZLIB_LIBRARIES})
#    include_directories(${ZLIB_INCLUDE_DIRS})
    add_definitions(-DZLIB)
    if(BUILD_SHARED_LIBS)
        add_definitions(-DZLIB_SHARED)
    endif()
endif()

set(EXPORT_TARGETS)

add_subdirectory(crypto)
add_subdirectory(ssl)

#install(FILES e_os2.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/openssl)

#install(FILES tools/c_hash tools/c_info tools/c_issuer tools/c_name tools/c_rehash
#    FAQ LICENSE PROBLEMS README README.ASN1 README.ENGINE
#    DESTINATION share/openssl )
#install( DIRECTORY doc DESTINATION ./ )

# Replaced headers will be copied. 
#if(WIN32)
    file(GLOB_RECURSE FINAL_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/include/openssl/*.h )
#else()
#    file(GLOB_RECURSE FINAL_HEADERS FOLOW_SYMLYNKS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h )
#endif()
install(FILES ${FINAL_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/openssl)

set(EXPORT_NAME openssl)
if(EXPORT_TARGETS)
    export(TARGETS ${EXPORT_TARGETS} FILE ${EXPORT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()
