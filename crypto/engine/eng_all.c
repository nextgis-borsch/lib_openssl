/*
 * Copyright 2001-2018 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the Apache License 2.0 (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

#include "internal/cryptlib.h"
#include "eng_local.h"

#if !defined(OPENSSL_NO_GOST) && defined(OPENSSL_HAVE_STATIC_GOST_ENGINE)
/* Declared in engines/gost/gost_eng.c — do not include gost.h here (pulls gost_lcl.h and breaks eng_local). */
void ENGINE_load_gost(void);
#endif

void ENGINE_load_builtin_engines(void)
{
    OPENSSL_init_crypto(OPENSSL_INIT_ENGINE_ALL_BUILTIN, NULL);

#if !defined(OPENSSL_NO_GOST) && defined(OPENSSL_HAVE_STATIC_GOST_ENGINE)
    /*
     * NextGIS: load GOST engine and set default CryptoPro parameters (same as old 1.1.1 fork).
     * Requires GOST engine objects linked into libcrypto (BUILD_ENGINES / static engines).
     */
    ENGINE_load_gost();
    {
        ENGINE *e_gost = ENGINE_by_id("gost");

        if (e_gost != NULL) {
            if (ENGINE_init(e_gost)) {
                (void)ENGINE_set_default(e_gost, ENGINE_METHOD_ALL);
                (void)ENGINE_ctrl_cmd_string(e_gost, "CRYPT_PARAMS",
                                             "id-Gost28147-89-CryptoPro-A-ParamSet", 0);
            }
            ENGINE_free(e_gost);
        }
    }
#endif /* OPENSSL_HAVE_STATIC_GOST_ENGINE */
}

#ifndef OPENSSL_NO_DEPRECATED_1_1_0
#if (defined(__OpenBSD__) || defined(__FreeBSD__) || defined(__DragonFly__))
void ENGINE_setup_bsd_cryptodev(void)
{
}
#endif
#endif
