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

if(NOT DEFINED GOST_ENGINE_SOURCE_DIR)
    set(GOST_ENGINE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/gost")
endif()

# Prefix gost-engine repo paths (submodule: engines/gost; tag v3.0.3 layout).
function(gost_prefixed _out)
    set(_lst)
    foreach(_gf ${ARGN})
        list(APPEND _lst "${GOST_ENGINE_SOURCE_DIR}/${_gf}")
    endforeach()
    set(${_out} ${_lst} PARENT_SCOPE)
endfunction()

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
        # Aligned with gost-engine v3.0.3 CMakeLists (GOST_LIB + ERR + engine; no duplicate GOST_OMAC).
        gost_prefixed(GOST_ERR_SRCS
            e_gost_err.c
            e_gost_err.h
        )
        gost_prefixed(GOST_89_SRCS
            gost89.c
            gost89.h
        )
        gost_prefixed(GOST_HASH_SRCS
            gosthash.c
            gosthash.h
        )
        gost_prefixed(GOST_HASH2012_SRCS
            gosthash2012.c
            gosthash2012.h
            gosthash2012_const.h
            gosthash2012_precalc.h
            gosthash2012_ref.h
            gosthash2012_sse2.h
        )
        gost_prefixed(GOST_GRASS_SRCS
            gost_grasshopper.h
            gost_grasshopper_core.h
            gost_grasshopper_core.c
            gost_grasshopper_defines.h
            gost_grasshopper_defines.c
            gost_grasshopper_math.h
            gost_grasshopper_galois_precompiled.c
            gost_grasshopper_precompiled.c
            gost_grasshopper_cipher.h
            gost_grasshopper_cipher.c
        )
        gost_prefixed(GOST_CORE_SRCS
            gost_ameth.c
            gost_pmeth.c
            gost_ctl.c
            gost_asn1.c
            gost_crypt.c
            gost_keywrap.c
            gost_keywrap.h
            gost_md.c
            gost_md2012.c
            gost_omac.c
            gost_omac_acpkm.c
            gost_gost2015.c
            gost_lcl.h
            gost_params.c
            gost_keyexpimp.c
        )
        gost_prefixed(GOST_EC_SRCS
            gost_ec_keyx.c
            gost_ec_sign.c
            ecp_id_GostR3410_2001_CryptoPro_A_ParamSet.c
            ecp_id_GostR3410_2001_CryptoPro_B_ParamSet.c
            ecp_id_GostR3410_2001_CryptoPro_C_ParamSet.c
            ecp_id_GostR3410_2001_TestParamSet.c
            ecp_id_tc26_gost_3410_2012_256_paramSetA.c
            ecp_id_tc26_gost_3410_2012_512_paramSetA.c
            ecp_id_tc26_gost_3410_2012_512_paramSetB.c
            ecp_id_tc26_gost_3410_2012_512_paramSetC.c
        )
        gost_prefixed(GOST_ENG_ONLY
            gost_eng.c
        )

        set(GOST_STATIC_BUNDLE
            ${GOST_ERR_SRCS}
            ${GOST_89_SRCS}
            ${GOST_HASH_SRCS}
            ${GOST_HASH2012_SRCS}
            ${GOST_GRASS_SRCS}
            ${GOST_CORE_SRCS}
            ${GOST_EC_SRCS}
            ${GOST_ENG_ONLY}
        )

        set(CSOURCES ${CSOURCES} ${GOST_STATIC_BUNDLE})
        set(ENGINE_PUBLIC_HDRS ${ENGINE_PUBLIC_HDRS}
            "${GOST_ENGINE_SOURCE_DIR}/gost_lcl.h"
            "${GOST_ENGINE_SOURCE_DIR}/gost_keywrap.h"
        )
    endif()

    set(TARGET_NAME engines)
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
        # Shared gost module: static lib = full tree without gost_eng.c (gost-engine v3.0.3 layout).
        gost_prefixed(GOST_DYN_LIB_SRCS
            e_gost_err.c
            e_gost_err.h
            gost89.c
            gost89.h
            gosthash.c
            gosthash.h
            gosthash2012.c
            gosthash2012.h
            gosthash2012_const.h
            gosthash2012_precalc.h
            gosthash2012_ref.h
            gosthash2012_sse2.h
            gost_grasshopper.h
            gost_grasshopper_core.h
            gost_grasshopper_core.c
            gost_grasshopper_defines.h
            gost_grasshopper_defines.c
            gost_grasshopper_math.h
            gost_grasshopper_galois_precompiled.c
            gost_grasshopper_precompiled.c
            gost_grasshopper_cipher.h
            gost_grasshopper_cipher.c
            gost_ameth.c
            gost_pmeth.c
            gost_ctl.c
            gost_asn1.c
            gost_crypt.c
            gost_keywrap.c
            gost_keywrap.h
            gost_md.c
            gost_md2012.c
            gost_omac.c
            gost_omac_acpkm.c
            gost_gost2015.c
            gost_lcl.h
            gost_params.c
            gost_keyexpimp.c
            gost_ec_keyx.c
            gost_ec_sign.c
            ecp_id_GostR3410_2001_CryptoPro_A_ParamSet.c
            ecp_id_GostR3410_2001_CryptoPro_B_ParamSet.c
            ecp_id_GostR3410_2001_CryptoPro_C_ParamSet.c
            ecp_id_GostR3410_2001_TestParamSet.c
            ecp_id_tc26_gost_3410_2012_256_paramSetA.c
            ecp_id_tc26_gost_3410_2012_512_paramSetA.c
            ecp_id_tc26_gost_3410_2012_512_paramSetB.c
            ecp_id_tc26_gost_3410_2012_512_paramSetC.c
        )
        gost_prefixed(GOST_DYN_ENG_SRCS
            gost_eng.c
        )

        add_library(gost STATIC ${GOST_DYN_LIB_SRCS})
        set_target_properties(gost PROPERTIES POSITION_INDEPENDENT_CODE ON)

        add_library(gost_engine MODULE ${GOST_DYN_ENG_SRCS})
        set_target_properties(gost_engine PROPERTIES
            PREFIX ""
            OUTPUT_NAME "gost"
        )

        target_link_libraries(gost_engine ${LIB_NAME} ${TARGET_LINK_LIB} gost)
        set(ENGINE_TARGETS ${ENGINE_TARGETS} gost_engine)

        set(ENGINE_PUBLIC_HDRS ${ENGINE_PUBLIC_HDRS}
            "${GOST_ENGINE_SOURCE_DIR}/gost_lcl.h"
            "${GOST_ENGINE_SOURCE_DIR}/gost_keywrap.h"
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
