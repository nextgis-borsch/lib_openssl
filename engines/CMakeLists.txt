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

if(NOT OPENSSL_NO_STATIC_ENGINE)
    set(CSOURCES
        e_padlock.c
    )

    if(NOT OPENSSL_NO_ASM)
        if(ANDROID_ARMV4)
        elseif(ANDROID_MIPS32 OR ANDROID_MIPS64)
        elseif(ANDROID_AARCH64 OR IOS_ARM64)
        elseif(HOST_X64)
            generate_asm(e_padlock-x86_64)
        else()
            generate_asm(e_padlock-x86)
        endif()
    endif()

    if(NOT OPENSSL_NO_CAPIENG)
        set(CSOURCES ${CSOURCES} e_capi.c)
    endif()

    if(NOT OPENSSL_NO_AFALGENG)
        set(CSOURCES ${CSOURCES} afalg/e_afalg.c afalg/e_afalg_err.c)
    endif()

    set(TARGET_NAME engines)

    add_library(${TARGET_NAME} OBJECT ${CSOURCES})

    set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}>)
endif()

if(NOT OPENSSL_NO_DYNAMIC_ENGINE)
    set(CSOURCES e_padlock.c)
    if(NOT OPENSSL_NO_ASM)
        if(ANDROID_ARMV4)
        elseif(ANDROID_MIPS32 OR ANDROID_MIPS64)
        elseif(ANDROID_AARCH64 OR IOS_ARM64)
        elseif(HOST_X64)
            generate_asm(e_padlock-x86_64)
        else()
            generate_asm(e_padlock-x86)
        endif()
    endif()

    add_library(padlock SHARED ${CSOURCES})
    target_link_libraries(padlock ${LIB_NAME} ${TARGET_LINK_LIB})

    set(ENGINE_TARGETS padlock)

    if(NOT OPENSSL_NO_CAPIENG)
        add_library(capi SHARED e_capi.c)
        target_link_libraries(capi ${LIB_NAME} ${TARGET_LINK_LIB})
        set(ENGINE_TARGETS ${ENGINE_TARGETS} capi)
    endif()

    if(NOT OPENSSL_NO_AFALGENG)
        add_library(afalg SHARED afalg/e_afalg.c afalg/e_afalg_err.c)
        target_link_libraries(afalg ${LIB_NAME} ${TARGET_LINK_LIB})
        set(ENGINE_TARGETS ${ENGINE_TARGETS} afalg)
    endif()

    install(TARGETS ${ENGINE_TARGETS}
        LIBRARY DESTINATION ${INSTALL_ENGINES_DIR}
        RUNTIME DESTINATION ${INSTALL_ENGINES_DIR}
        ARCHIVE DESTINATION ${INSTALL_ENGINES_DIR}
    )
endif()

set(TARGET_OBJECTS ${TARGET_OBJECTS} PARENT_SCOPE)
