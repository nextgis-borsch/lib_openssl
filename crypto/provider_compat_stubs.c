/*
 * Compatibility stubs for builds without provider subtree linkage.
 */

#include <stddef.h>
#include <openssl/crypto.h>
#include "crypto/rand.h"

void ossl_set_error_state(const char *type)
{
    (void)type;
}

void *ossl_prov_drbg_nonce_ctx_new(OSSL_LIB_CTX *libctx)
{
    (void)libctx;
    return NULL;
}

void ossl_prov_drbg_nonce_ctx_free(void *vdngbl)
{
    (void)vdngbl;
}

int ossl_rand_pool_init(void)
{
    return 1;
}

void ossl_rand_pool_cleanup(void)
{
}

void ossl_rand_pool_keep_random_devices_open(int keep)
{
    (void)keep;
}

size_t ossl_pool_acquire_entropy(RAND_POOL *pool)
{
    (void)pool;
    return 0;
}

int ossl_pool_add_nonce_data(RAND_POOL *pool)
{
    (void)pool;
    return 0;
}

int ossl_err_load_PROV_strings(void)
{
    return 1;
}
