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

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/include)

add_subdirectory(aria)

add_subdirectory(objects)
if(NOT OPENSSL_NO_MD2)
    add_subdirectory(md2)
endif()

if(NOT OPENSSL_NO_MD4)
    add_subdirectory(md4)
endif()

add_subdirectory(md5)
add_subdirectory(sha)

if(NOT OPENSSL_NO_MDC2)
    add_subdirectory(mdc2)
endif()

add_subdirectory(hmac)
add_subdirectory(ripemd)

if(NOT OPENSSL_NO_WHIRLPOOL)
    add_subdirectory(whrlpool)
endif()

if(NOT OPENSSL_NO_POLY1305)
    add_subdirectory(poly1305)
endif()

if(NOT OPENNSSL_NO_BLAKE2)
    add_subdirectory(blake2)
endif()

if(NOT OPENSSL_NO_DES)
    add_subdirectory(des)
endif()

add_subdirectory(aes)

if(NOT OPENSSL_NO_RC2)
    add_subdirectory(rc2)
endif()

if(NOT OPENSSL_NO_RC4)
    add_subdirectory(rc4)
endif()

if(NOT OPENSSL_NO_RC5)
    add_subdirectory(rc5)
endif()

if(NOT OPENSSL_NO_IDEA)
    add_subdirectory(idea)
endif()

if(NOT OPENSSL_NO_BF)
    add_subdirectory(bf)
endif()

if(NOT OPENSSL_NO_CAST)
    add_subdirectory(cast)
endif()

if(NOT OPENSSL_NO_CAMELLIA)
    add_subdirectory(camellia)
endif()

if(NOT OPENSSL_NO_SEED)
    add_subdirectory(seed)
endif()

if(NOT OPENSSL_NO_CHACHA)
    add_subdirectory(chacha)
endif()

if(NOT OPENSSL_NO_MODES)
    add_subdirectory(modes)
endif()

add_subdirectory(bn)

if(NOT OPENSSL_NO_EC)
    add_subdirectory(ec)
endif()

add_subdirectory(rsa)

if(NOT OPENSSL_NO_DSA)
    add_subdirectory(dsa)
endif()

if(NOT OPENSSL_NO_DH)
    add_subdirectory(dh)
endif()

if(NOT OPENSSL_NO_DSO)
    if(WIN32)
        add_definitions(-DDSO_WIN32)
    endif()
    add_subdirectory(dso)
endif()

if(NOT OPENSSL_NO_ENGINE)
    add_subdirectory(engine)
endif()

add_subdirectory(buffer)
add_subdirectory(bio)
add_subdirectory(stack)
add_subdirectory(lhash)
add_subdirectory(rand)

if(NOT OPENSSL_NO_ERR)
    add_subdirectory(err)
endif()

add_subdirectory(evp)
add_subdirectory(asn1)
add_subdirectory(pem)
add_subdirectory(x509)
add_subdirectory(x509v3)
add_subdirectory(conf)
add_subdirectory(txt_db)
add_subdirectory(pkcs7)
add_subdirectory(pkcs12)

if(NOT OPENSSL_NO_COMP)
    add_subdirectory(comp)
endif()

if(NOT OPENSSL_NO_OCSP)
    add_subdirectory(ocsp)
endif()

if(NOT OPENSSL_NO_UI)
    add_subdirectory(ui)
endif()

if(NOT OPENSSL_NO_CMS)
    add_subdirectory(cms)
endif()

if(NOT OPENSSL_NO_TS)
    add_subdirectory(ts)
endif()

if(NOT OPENSSL_NO_SRP)
    add_subdirectory(srp)
endif()

if(NOT OPENSSL_NO_CMAC)
    add_subdirectory(cmac)
endif()

if(NOT OPENSSL_NO_CT)
    add_subdirectory(ct)
endif()

if(NOT OPENSSL_NO_ASYNC)
    add_subdirectory(async)
endif()

if(NOT OPENSSL_NO_KDF)
    add_subdirectory(kdf)
endif()

add_subdirectory(store)

if(NOT OPENSSL_NO_SM2)
    add_subdirectory(sm2)
endif()
if(NOT OPENSSL_NO_SM3)
    add_subdirectory(sm3)
endif()
if(NOT OPENSSL_NO_SM4)
    add_subdirectory(sm4)
endif()
if(NOT OPENSSL_NO_SIPHASH)
    add_subdirectory(siphash)
endif()

set(CSOURCES
    cryptlib.c mem.c mem_dbg.c cversion.c ex_data.c cpt_err.c
    ebcdic.c uid.c o_time.c o_str.c o_dir.c o_fopen.c
    threads_pthread.c threads_win.c threads_none.c
    o_init.c o_fips.c mem_sec.c init.c getenv.c ctype.c
)

if(NOT WIN32)
    set(GEN_ASM_CMD_PREFIX "CC=\"${CMAKE_C_COMPILER}\"")
endif()

if(I386_ONLY OR OPENSSL_NO_ASM)
    set(CSOURCES ${CSOURCES} mem_clr.c)
else()
    if(ANDROID_ARMV4 OR IOS_ARM32)
        generate_asm1(armv4cpuid)
        set(CSOURCES ${CSOURCES} armcap.c)
    # no asm elseif(ANDROID_MIPS32)
    elseif(ANDROID_AARCH64 OR IOS_ARM64)
        generate_asm1(arm64cpuid)
        set(CSOURCES ${CSOURCES} armcap.c)
    # no asm elseif(ANDROID_MIPS64)
    elseif(HOST_X64)
        # Generate asm file from x86_64cpuid
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/x86_64cpuid.s
            COMMAND ${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/x86_64cpuid.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/x86_64cpuid.s
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/x86_64cpuid.pl
            COMMENT "Generate cpuid for PERLASM_SCHEME ${PERLASM_SCHEME}"
        )
        set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/x86_64cpuid.s)
    else()
        # Generate asm file from x86cpuid
        add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/x86cpuid.s
            COMMAND "${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/x86cpuid.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/x86cpuid.s"
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/x86cpuid.pl
            COMMENT "Generate cpuid for PERLASM_SCHEME ${PERLASM_SCHEME}"
        )
        set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/x86cpuid.s)
    endif()

endif()

if(MSVC)
    # Uplink
    set(CSOURCES ${CSOURCES}
        ${CMAKE_SOURCE_DIR}/ms/applink.c
        ${CMAKE_SOURCE_DIR}/ms/uplink.c
    )

    add_definitions(-DOPENSSL_USE_APPLINK)

    if(NOT OPENSSL_NO_ASM)
        if(HOST_X64)
            add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/uplink-x86_64.${ASM_FILE_EXT}
                COMMAND ${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_SOURCE_DIR}/ms/uplink-x86_64.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/uplink-x86_64.${ASM_FILE_EXT}
                DEPENDS ${CMAKE_SOURCE_DIR}/ms/uplink-x86_64.pl
            )
            set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/uplink-x86_64.${ASM_FILE_EXT})
        else()
            add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/uplink-x86.${ASM_FILE_EXT}
                COMMAND ${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_SOURCE_DIR}/ms/uplink-x86.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/uplink-x86.${ASM_FILE_EXT}
                DEPENDS ${CMAKE_SOURCE_DIR}/ms/uplink-x86.pl
            )
            set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/uplink-x86.${ASM_FILE_EXT})
        endif()
    endif()

    set(CSOURCES ${CSOURCES} dllmain.c)
endif()

set(TARGET_NAME crypto)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
