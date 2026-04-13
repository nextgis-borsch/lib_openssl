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

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB CSOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
file(GLOB CURVE448_CSOURCES ${CMAKE_CURRENT_SOURCE_DIR}/curve448/*.c)
file(GLOB CURVE448_ARCH32_CSOURCES ${CMAKE_CURRENT_SOURCE_DIR}/curve448/arch_32/*.c)
set(CSOURCES ${CSOURCES} ${CURVE448_CSOURCES} ${CURVE448_ARCH32_CSOURCES})

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR} 
    ${CMAKE_CURRENT_SOURCE_DIR}/curve448 
    ${CMAKE_CURRENT_SOURCE_DIR}/curve448/arch_32
)

if(NOT OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} ecp_nistz256.c)
    if(ANDROID_ARMV4 OR IOS_ARM32)
    	generate_asm(ecp_nistz256-armv4)
    elseif(ANDROID_MIPS32)
    elseif(ANDROID_AARCH64 OR IOS_ARM64)
    	generate_asm(ecp_nistz256-armv8)
    elseif(ANDROID_MIPS64)
    elseif(HOST_X64)
        generate_asm(ecp_nistz256-x86_64)
        generate_asm(x25519-x86_64)
    else()
        generate_asm(ecp_nistz256-x86)
    endif()
    add_definitions(-DECP_NISTZ256_ASM)
endif()

# MSVC doesn't support __int128, required by these optimized implementations.
if(MSVC)
    list(FILTER CSOURCES EXCLUDE REGEX ".*/ecp_nistp(224|256|384|521)\\.c$")
    list(FILTER CSOURCES EXCLUDE REGEX ".*/ecp_nistz256_table\\.c$")
endif()

set(TARGET_NAME ec)
set(_openssl_source_lists
    CSOURCES
    SOURCES_C
    SOURCES_H
    HEADERS_H
    TESTUTIL_SOURCES
    TEST_SOURCES
)
foreach(_openssl_src_list ${_openssl_source_lists})
    if(DEFINED ${_openssl_src_list})
        filter_existing_sources(${_openssl_src_list})
    endif()
endforeach()


if(NOT CSOURCES)
    return()
endif()

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
