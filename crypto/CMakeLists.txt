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


#[[
unless ($disabled{asm}) {
    $target{cpuid_asm_src}=$table{DEFAULTS}->{cpuid_asm_src} if ($config{processor} eq "386");
    $target{bn_asm_src} =~ s/\w+-gf2m.c// if (defined($disabled{ec2m}));

    # bn-586 is the only one implementing bn_*_part_words
    push @{$config{defines}}, "OPENSSL_BN_ASM_PART_WORDS" if ($target{bn_asm_src} =~ /bn-586/);
    push @{$config{defines}}, "OPENSSL_IA32_SSE2" if (!$no_sse2 && $target{bn_asm_src} =~ /86/);

    push @{$config{defines}}, "OPENSSL_BN_ASM_MONT" if ($target{bn_asm_src} =~ /-mont/);
    push @{$config{defines}}, "OPENSSL_BN_ASM_MONT5" if ($target{bn_asm_src} =~ /-mont5/);
    push @{$config{defines}}, "OPENSSL_BN_ASM_GF2m" if ($target{bn_asm_src} =~ /-gf2m/);

    if ($config{fips}) {
	push @{$config{openssl_other_defines}}, "OPENSSL_FIPS";
    }

    if ($target{sha1_asm_src}) {
	push @{$config{defines}}, "SHA1_ASM"   if ($target{sha1_asm_src} =~ /sx86/ || $target{sha1_asm_src} =~ /sha1/);
	push @{$config{defines}}, "SHA256_ASM" if ($target{sha1_asm_src} =~ /sha256/);
	push @{$config{defines}}, "SHA512_ASM" if ($target{sha1_asm_src} =~ /sha512/);
    }
    if ($target{rc4_asm_src} ne $table{DEFAULTS}->{rc4_asm_src}) {
	push @{$config{defines}}, "RC4_ASM";
    }
    if ($target{md5_asm_src}) {
	push @{$config{defines}}, "MD5_ASM";
    }
    $target{cast_asm_src}=$table{DEFAULTS}->{cast_asm_src} unless $disabled{pic}; # CAST assembler is not PIC
    if ($target{rmd160_asm_src}) {
	push @{$config{defines}}, "RMD160_ASM";
    }
    if ($target{aes_asm_src}) {
	push @{$config{defines}}, "AES_ASM" if ($target{aes_asm_src} =~ m/\baes-/);;
	# aes-ctr.fake is not a real file, only indication that assembler
	# module implements AES_ctr32_encrypt...
	push @{$config{defines}}, "AES_CTR_ASM" if ($target{aes_asm_src} =~ s/\s*aes-ctr\.fake//);
	# aes-xts.fake indicates presence of AES_xts_[en|de]crypt...
	push @{$config{defines}}, "AES_XTS_ASM" if ($target{aes_asm_src} =~ s/\s*aes-xts\.fake//);
	$target{aes_asm_src} =~ s/\s*(vpaes|aesni)-x86\.s//g if ($no_sse2);
	push @{$config{defines}}, "VPAES_ASM" if ($target{aes_asm_src} =~ m/vpaes/);
	push @{$config{defines}}, "BSAES_ASM" if ($target{aes_asm_src} =~ m/bsaes/);
    }
    if ($target{wp_asm_src} =~ /mmx/) {
        if ($config{processor} eq "386") {
	    $target{wp_asm_src}=$table{DEFAULTS}->{wp_asm_src};
	} elsif (!$disabled{"whirlpool"}) {
	    push @{$config{defines}}, "WHIRLPOOL_ASM";
	}
    }
    if ($target{modes_asm_src} =~ /ghash-/) {
	push @{$config{defines}}, "GHASH_ASM";
    }
    if ($target{ec_asm_src} =~ /ecp_nistz256/) {
	push @{$config{defines}}, "ECP_NISTZ256_ASM";
    }
    if ($target{poly1305_asm_src} ne "") {
	push @{$config{defines}}, "POLY1305_ASM";
    }
}
GENERATE[buildinf.h]=../util/mkbuildinf.pl "$(CC) $(CFLAGS_Q)" "$(PLATFORM)"

]]

set(CSOURCES
    cryptlib.c mem.c mem_dbg.c cversion.c ex_data.c cpt_err.c
    ebcdic.c uid.c o_time.c o_str.c o_dir.c o_fopen.c
    threads_pthread.c threads_win.c threads_none.c
    o_init.c o_fips.c mem_sec.c init.c
)

if(NOT WIN32)
    set(GEN_ASM_CMD_PREFIX "CC=\"${CMAKE_C_COMPILER}\"")
endif()

if(HOST_X64)
    # Generate asm file from x86_64cpuid
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/x86_64cpuid.s
        COMMAND "${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/x86_64cpuid.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/x86_64cpuid.s"
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/x86_64cpuid.pl
    )
    set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/x86_64cpuid.s)
else()
    # Generate asm file from x86cpuid
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/x86cpuid.s
        COMMAND "${GEN_ASM_CMD_PREFIX} ${PERL_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/x86cpuid.pl ${PERLASM_SCHEME} ${CMAKE_CURRENT_BINARY_DIR}/x86cpuid.s"
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/x86cpuid.pl
    )
    set(CSOURCES ${CSOURCES} ${CMAKE_CURRENT_BINARY_DIR}/x86cpuid.s)
endif()

if(MSVC)
    # Uplink
    set(CSOURCES ${CSOURCES}
        ${CMAKE_SOURCE_DIR}/ms/applink.c
        ${CMAKE_SOURCE_DIR}/ms/uplink.c
    )

    add_definitions(-DOPENSSL_USE_APPLINK)

    #[[
    x86_uplink => {
    inherit_from	=> [ "uplink_common" ],
    template	=> 1,
    uplink_aux_src	=> add("uplink-x86.s"),
    },
    x86_64_uplink => {
    inherit_from	=> [ "uplink_common" ],
    template	=> 1,
    uplink_aux_src	=> add("uplink-x86_64.s"),
    },
    ]]

    set(CSOURCES ${CSOURCES} dllmain.c)
endif()

set(TARGET_NAME crypto)

add_library(${TARGET_NAME} OBJECT ${CSOURCES})

set(TARGET_OBJECTS ${TARGET_OBJECTS} $<TARGET_OBJECTS:${TARGET_NAME}> PARENT_SCOPE)
