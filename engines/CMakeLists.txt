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

set(ENGINE_PUBLIC_HDRS)

if(NOT OPENSSL_NO_STATIC_ENGINE)
    set(CSOURCES
        e_padlock.c
    )

    if(NOT OPENSSL_NO_ASM)
        if(ANDROID_ARMV4 OR IOS_ARM32)
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
        set(CSOURCES ${CSOURCES} e_afalg.c e_afalg_err.c)
    endif()

    if(NOT OPENSSL_NO_GOSTENG)
        set(GOST_89_SOURCE_FILES
            gost/gost89.c
            gost/gost89.h
        )

        set(GOST_HASH_SOURCE_FILES
            gost/gosthash.c
            gost/gosthash.h
        )

        set(GOST_HASH_2012_SOURCE_FILES
            gost/gosthash2012.c
            gost/gosthash2012.h
            gost/gosthash2012_const.h
            gost/gosthash2012_precalc.h
            gost/gosthash2012_ref.h
            gost/gosthash2012_sse2.h
        )

        set(GOST_GRASSHOPPER_SOURCE_FILES
            gost/gost_grasshopper.h
            gost/gost_grasshopper_core.h
            gost/gost_grasshopper_core.c
            gost/gost_grasshopper_defines.h
            gost/gost_grasshopper_defines.c
            gost/gost_grasshopper_math.h
            gost/gost_grasshopper_galois_precompiled.c
            gost/gost_grasshopper_precompiled.c
            gost/gost_grasshopper_cipher.h
            gost/gost_grasshopper_cipher.c
            gost/gost_grasshopper_mac.h
            gost/gost_grasshopper_mac.c
        )

        set(GOST_CORE_SOURCE_FILES
            gost/e_gost_err.c
            gost/e_gost_err.h
            gost/gost_asn1.c
            gost/gost_crypt.c
            gost/gost_ctl.c
            gost/gost_eng.c
            gost/gost_keywrap.c
            gost/gost_keywrap.h
            gost/gost_lcl.h
            gost/gost_params.c
        )

        set(GOST_EC_SOURCE_FILES
            gost/gost_ec_keyx.c
            gost/gost_ec_sign.c
        )

        set(GOST_LIB_SOURCE_FILES
            ${GOST_EC_SOURCE_FILES}
            ${GOST_89_SOURCE_FILES}
            ${GOST_HASH_SOURCE_FILES}
            ${GOST_GRASSHOPPER_SOURCE_FILES}
            ${GOST_HASH_2012_SOURCE_FILES}
        )

        set(GOST_ENGINE_SOURCE_FILES
            ${GOST_CORE_SOURCE_FILES}
            gost/gost_ameth.c
            gost/gost_md.c
            gost/gost_md2012.c
            gost/gost_pmeth.c
        )

        set(CSOURCES ${CSOURCES} ${GOST_LIB_SOURCE_FILES} ${GOST_ENGINE_SOURCE_FILES})
        set(ENGINE_PUBLIC_HDRS ${ENGINE_PUBLIC_HDRS}
            ${CMAKE_CURRENT_SOURCE_DIR}/gost/gost_lcl.h
            ${CMAKE_CURRENT_SOURCE_DIR}/gost/gost_keywrap.h
        )
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
        add_library(capi MODULE e_capi.c)
        target_link_libraries(capi ${LIB_NAME} ${TARGET_LINK_LIB})
        set(ENGINE_TARGETS ${ENGINE_TARGETS} capi)
    endif()

    if(NOT OPENSSL_NO_AFALGENG)
        add_library(afalg MODULE afalg/e_afalg.c afalg/e_afalg_err.c)
        target_link_libraries(afalg ${LIB_NAME} ${TARGET_LINK_LIB})
        set(ENGINE_TARGETS ${ENGINE_TARGETS} afalg)
    endif()

    if(NOT OPENSSL_NO_GOSTENG)
        set(GOST_89_SOURCE_FILES
            gost/gost89.c
            gost/gost89.h
        )

        set(GOST_HASH_SOURCE_FILES
            gost/gosthash.c
            gost/gosthash.h
        )

        set(GOST_HASH_2012_SOURCE_FILES
            gost/gosthash2012.c
            gost/gosthash2012.h
            gost/gosthash2012_const.h
            gost/gosthash2012_precalc.h
            gost/gosthash2012_ref.h
            gost/gosthash2012_sse2.h
        )

        set(GOST_GRASSHOPPER_SOURCE_FILES
            gost/gost_grasshopper.h
            gost/gost_grasshopper_core.h
            gost/gost_grasshopper_core.c
            gost/gost_grasshopper_defines.h
            gost/gost_grasshopper_defines.c
            gost/gost_grasshopper_math.h
            gost/gost_grasshopper_galois_precompiled.c
            gost/gost_grasshopper_precompiled.c
            gost/gost_grasshopper_cipher.h
            gost/gost_grasshopper_cipher.c
            gost/gost_grasshopper_mac.h
            gost/gost_grasshopper_mac.c
        )

        set(GOST_CORE_SOURCE_FILES
            gost/e_gost_err.c
            gost/e_gost_err.h
            gost/gost_asn1.c
            gost/gost_crypt.c
            gost/gost_ctl.c
            gost/gost_eng.c
            gost/gost_keywrap.c
            gost/gost_keywrap.h
            gost/gost_lcl.h
            gost/gost_params.c
        )

        set(GOST_EC_SOURCE_FILES
            gost/gost_ec_keyx.c
            gost/gost_ec_sign.c
        )

        set(GOST_LIB_SOURCE_FILES
            ${GOST_EC_SOURCE_FILES}
            ${GOST_89_SOURCE_FILES}
            ${GOST_HASH_SOURCE_FILES}
            ${GOST_GRASSHOPPER_SOURCE_FILES}
            ${GOST_HASH_2012_SOURCE_FILES}
        )

        set(GOST_ENGINE_SOURCE_FILES
            ${GOST_CORE_SOURCE_FILES}
            gost/gost_ameth.c
            gost/gost_md.c
            gost/gost_md2012.c
            gost/gost_pmeth.c
        )

        add_library(gost STATIC ${GOST_LIB_SOURCE_FILES})
        set_target_properties(gost PROPERTIES POSITION_INDEPENDENT_CODE ON)

        add_library(gost_engine MODULE ${GOST_ENGINE_SOURCE_FILES})
        set_target_properties(gost_engine PROPERTIES
            PREFIX ""
            OUTPUT_NAME "gost"
        )

        target_link_libraries(gost_engine ${LIB_NAME} ${TARGET_LINK_LIB} gost)
        set(ENGINE_TARGETS ${ENGINE_TARGETS} gost_engine)

        set(ENGINE_PUBLIC_HDRS ${ENGINE_PUBLIC_HDRS}
            ${CMAKE_CURRENT_SOURCE_DIR}/gost/gost_lcl.h
            ${CMAKE_CURRENT_SOURCE_DIR}/gost/gost_keywrap.h
        )
    endif()

    install(TARGETS ${ENGINE_TARGETS}
        LIBRARY DESTINATION ${INSTALL_ENGINES_DIR}
        RUNTIME DESTINATION ${INSTALL_ENGINES_DIR}
        ARCHIVE DESTINATION ${INSTALL_ENGINES_DIR}
    )
endif()

set(TARGET_OBJECTS ${TARGET_OBJECTS} PARENT_SCOPE)

set(PUBLIC_HDRS ${PUBLIC_HDRS} ${ENGINE_PUBLIC_HDRS} PARENT_SCOPE)
