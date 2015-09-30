# Based on original work by David Manura
# Copyright (C) 2007-2012 LuaDist.
# Copyright (C) 2013 Brian Sidebotham

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


project( openssl )
cmake_minimum_required( VERSION 2.8.10 )

file(GLOB_RECURSE HHEADERS FOLOW_SYMLYNKS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h )

foreach(TO ${HHEADERS})
    file(READ ${TO} PATH_CONTENTS)
    #message(STATUS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/${PATH_CONTENTS})
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/${PATH_CONTENTS} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/include/openssl)
endforeach()

file(READ ${CMAKE_CURRENT_BINARY_DIR}/include/openssl/opensslv.h VERSION_H_CONTENTS)
string(REGEX MATCH "SHLIB_VERSION_NUMBER \"+([0-9.0-9.0-9]+)" VERSION ${VERSION_H_CONTENTS})
string (REGEX MATCH "([0-9.0-9.0-9]+)" VERSION ${VERSION})

set(PROJECT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  
message(STATUS "openssl version=[${VERSION}]")  

add_definitions( -DOPENSSL_NO_ASM )

if( WIN32 AND NOT CYGWIN )
  add_definitions( -DOPENSSL_SYSNAME_WIN32 )
  add_definitions( -DWIN32_LEAN_AND_MEAN )

  # avoid conflict: ocsp.h and wincrypt.h
  add_definitions( -D_WINDLL )

endif ( )

if( MINGW )
  set( CMAKE_SHARED_LINKER_FLAGS "-Wl,--export-all" )
endif()

# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

add_subdirectory( crypto )
add_subdirectory( ssl )
#add_subdirectory( apps )

install( FILES e_os2.h DESTINATION include/openssl )

install( FILES tools/c_hash tools/c_info tools/c_issuer tools/c_name tools/c_rehash
    FAQ LICENSE PROBLEMS README README.ASN1 README.ENGINE
    DESTINATION share/openssl )

install( DIRECTORY doc DESTINATION ./ )


