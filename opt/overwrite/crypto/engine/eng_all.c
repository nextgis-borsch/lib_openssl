/*
 * Copyright 2001-2016 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the OpenSSL license (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

#include "internal/cryptlib.h"
#include "eng_int.h"

#include "engines/gost/gost.h"

void ENGINE_load_builtin_engines(void)
{
    /* Some ENGINEs need this */
    OPENSSL_cpuid_setup();

    OPENSSL_init_crypto(OPENSSL_INIT_ENGINE_ALL_BUILTIN, NULL);

    #ifndef OPENSSL_NO_GOST
        ENGINE_load_gost();
        gost_set_default_param(0, "id-Gost28147-89-CryptoPro-A-ParamSet");
    #endif
}

#if (defined(__OpenBSD__) || defined(__FreeBSD__) || defined(HAVE_CRYPTODEV)) && !defined(OPENSSL_NO_DEPRECATED)
void ENGINE_setup_bsd_cryptodev(void)
{
    static int bsd_cryptodev_default_loaded = 0;
    if (!bsd_cryptodev_default_loaded) {
        OPENSSL_init_crypto(OPENSSL_INIT_ENGINE_CRYPTODEV, NULL);
        ENGINE_register_all_complete();
    }
    bsd_cryptodev_default_loaded = 1;
}
#endif
