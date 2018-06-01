/**********************************************************************
 *                        params.c                                    *
 *             Copyright (c) 2005-2013 Cryptocom LTD                  *
 *         This file is distributed under the same license as OpenSSL *
 *                                                                    *
 * Definitions of GOST R 34.10 parameter sets, defined in RFC 4357    *
 *         OpenSSL 1.0.0+ libraries required to compile and use       *
 *                              this code                             *
 **********************************************************************/
#include "gost_lcl.h"
#include <openssl/objects.h>
/* Parameters of GOST 34.10 */

R3410_ec_params R3410_2001_paramset[] = {
    /* 1.2.643.2.2.35.0 */
    {NID_id_GostR3410_2001_TestParamSet,
     "7",
     "5FBFF498AA938CE739B8E022FBAFEF40563F6E6A3472FC2A514C0CE9DAE23B7E",
     "8000000000000000000000000000000000000000000000000000000000000431",
     "8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3",
     "2",
     "08E2A8A0E65147D4BD6316030E16D19C85C97F0A9CA267122B96ABBCEA7E8FC8"}
    ,
    /*
     * 1.2.643.2.2.35.1
     */
    {NID_id_GostR3410_2001_CryptoPro_A_ParamSet,
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD94",
     "a6",
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97",
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C611070995AD10045841B09B761B893",
     "1",
     "8D91E471E0989CDA27DF505A453F2B7635294F2DDF23E3B122ACC99C9E9F1E14"}
    ,
    /*
     * 1.2.643.2.2.35.2
     */
    {NID_id_GostR3410_2001_CryptoPro_B_ParamSet,
     "8000000000000000000000000000000000000000000000000000000000000C96",
     "3E1AF419A269A5F866A7D3C25C3DF80AE979259373FF2B182F49D4CE7E1BBC8B",
     "8000000000000000000000000000000000000000000000000000000000000C99",
     "800000000000000000000000000000015F700CFFF1A624E5E497161BCC8A198F",
     "1",
     "3FA8124359F96680B83D1C3EB2C070E5C545C9858D03ECFB744BF8D717717EFC"}
    ,
    /*
     * 1.2.643.2.2.35.3
     */
    {NID_id_GostR3410_2001_CryptoPro_C_ParamSet,
     "9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D7598",
     "805a",
     "9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D759B",
     "9B9F605F5A858107AB1EC85E6B41C8AA582CA3511EDDFB74F02F3A6598980BB9",
     "0",
     "41ECE55743711A8C3CBF3783CD08C0EE4D4DC440D4641A8F366E550DFDB3BB67"}
    ,
    /*
     * 1.2.643.2.2.36.0
     */
    {NID_id_GostR3410_2001_CryptoPro_XchA_ParamSet,
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD94",
     "a6",
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97",
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C611070995AD10045841B09B761B893",
     "1",
     "8D91E471E0989CDA27DF505A453F2B7635294F2DDF23E3B122ACC99C9E9F1E14"}
    ,
    /*
     * 1.2.643.2.2.36.1
     */
    {NID_id_GostR3410_2001_CryptoPro_XchB_ParamSet,
     "9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D7598",
     "805a",
     "9B9F605F5A858107AB1EC85E6B41C8AACF846E86789051D37998F7B9022D759B",
     "9B9F605F5A858107AB1EC85E6B41C8AA582CA3511EDDFB74F02F3A6598980BB9",
     "0",
     "41ECE55743711A8C3CBF3783CD08C0EE4D4DC440D4641A8F366E550DFDB3BB67"}
    ,
    {NID_undef, NULL, NULL, NULL, NULL, NULL, NULL}
};

/* Parameters of GOST 34.10-2012 */

R3410_ec_params *R3410_2012_256_paramset = R3410_2001_paramset;

R3410_ec_params R3410_2012_512_paramset[] = {
    {NID_id_tc26_gost_3410_2012_512_paramSetA,
     /* a */
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDC4",
     /* b */
     "E8C2505DEDFC86DDC1BD0B2B6667F1DA34B82574761CB0E879BD081CFD0B6265"
     "EE3CB090F30D27614CB4574010DA90DD862EF9D4EBEE4761503190785A71C760",
     /* p */
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDC7",
     /* q */
     "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
     "27E69532F48D89116FF22B8D4E0560609B4B38ABFAD2B85DCACDB1411F10B275",
     /* x */
     "3",
     /* y */
     "7503CFE87A836AE3A61B8816E25450E6CE5E1C93ACF1ABC1778064FDCBEFA921DF16"
     "26BE4FD036E93D75E6A50E3A41E98028FE5FC235F5B889A589CB5215F2A4"}
    ,
    {NID_id_tc26_gost_3410_2012_512_paramSetB,
     /* a */
     "8000000000000000000000000000000000000000000000000000000000000000"
     "000000000000000000000000000000000000000000000000000000000000006C",
     /* b */
     "687D1B459DC841457E3E06CF6F5E2517B97C7D614AF138BCBF85DC806C4B289F"
     "3E965D2DB1416D217F8B276FAD1AB69C50F78BEE1FA3106EFB8CCBC7C5140116",
     /* p */
     "8000000000000000000000000000000000000000000000000000000000000000"
     "000000000000000000000000000000000000000000000000000000000000006F",
     /* q */
     "8000000000000000000000000000000000000000000000000000000000000001"
     "49A1EC142565A545ACFDB77BD9D40CFA8B996712101BEA0EC6346C54374F25BD",
     /* x */
     "2",
     /* y */
     "1A8F7EDA389B094C2C071E3647A8940F3C123B697578C213BE6DD9E6C8EC7335"
     "DCB228FD1EDF4A39152CBCAAF8C0398828041055F94CEEEC7E21340780FE41BD"}
    ,
    {NID_undef, NULL, NULL, NULL, NULL, NULL, NULL}
};
