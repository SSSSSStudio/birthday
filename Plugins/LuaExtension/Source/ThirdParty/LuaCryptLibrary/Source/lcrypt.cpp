#include "lcrypt.h"
#include "openssl/sha.h"
#include "openssl/evp.h"
#include "openssl/crypto.h"
#include "openssl/md5.h"
#include "openssl/aes.h"
#include "openssl/rand.h"
#include "openssl/srp.h"

//sha
#define DEF_SHA1_DIGEST_LENGTH     20
#define DEF_SHA224_DIGEST_LENGTH   28
#define DEF_SHA256_DIGEST_LENGTH   32
#define DEF_SHA384_DIGEST_LENGTH   48
#define DEF_SHA512_DIGEST_LENGTH   64

static void crypt_sha1(const void* data, size_t len, uint8_t* digest)
{
    SHA_CTX ctx;
	SHA1_Init(&ctx);
	SHA1_Update(&ctx, data, len);
	SHA1_Final(digest,&ctx);
}

static void crypt_sha224(const void* data, size_t len, uint8_t* digest)
{
    SHA256_CTX ctx;
	SHA224_Init(&ctx);
	SHA224_Update(&ctx, data, len);
	SHA224_Final(digest,&ctx);
}

static void crypt_sha256(const void* data, size_t len, uint8_t* digest)
{
    SHA256_CTX ctx;
	SHA256_Init(&ctx);
	SHA256_Update(&ctx, data, len);
	SHA256_Final(digest,&ctx);
}

static void crypt_sha384(const void* data, size_t len, uint8_t* digest)
{
    SHA512_CTX ctx;
	SHA384_Init(&ctx);
	SHA384_Update(&ctx, data, len);
	SHA384_Final(digest,&ctx);
}

static void crypt_sha512(const void* data, size_t len, uint8_t* digest)
{
    SHA512_CTX ctx;
	SHA512_Init(&ctx);
	SHA512_Update(&ctx, data, len);
	SHA512_Final(digest,&ctx);
}

//base64
static int32_t crypt_base64Encode(const uint8_t* data, int32_t n, uint8_t* out)
{
	return EVP_EncodeBlock(out,data,n);
}

static int32_t crypt_base64Decode(const uint8_t* data, int32_t n, uint8_t* out)
{
	return EVP_DecodeBlock(out,data,n);
}

//md5
#define DEF_MD5_DIGEST_LENGTH   16

static void crypt_md5(const void* data, size_t len, uint8_t* digest)
{
	MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, data, len);
    MD5_Final(digest, &ctx);
}

//aes
#define DEF_AES_BLOCK_SIZE   16

static void crypt_aes_cbc_encrypt(const uint8_t* key, const uint8_t* data, size_t len, uint8_t* out)
{
	AES_KEY aes;
	uint8_t ivec[16];
	memset(ivec,0,16);
	AES_set_encrypt_key(key,128,&aes);
	AES_cbc_encrypt(data,out,len,&aes,ivec,AES_ENCRYPT);
}

static void crypt_aes_cbc_decrypt(const uint8_t* key, const uint8_t* data, size_t len, uint8_t* out)
{
	AES_KEY aes;
	uint8_t ivec[16];
	memset(ivec,0,16);
	AES_set_decrypt_key(key,128,&aes);
	AES_cbc_encrypt(data,out,len,&aes,ivec,AES_DECRYPT);
}

//rand
static int32_t crypt_rand_bytes(uint8_t* key, int32_t len)
{
	return RAND_bytes(key,len);
}

//srp
static int32_t crypt_srp_create_verifier(const char* id, const char* user,const char* password, uint8_t* salt, int32_t* saltLen, uint8_t* verifier, int32_t* verifierLen)
{
	BIGNUM* s = NULL;
	BIGNUM* v = NULL;

	const SRP_gN* GN = SRP_get_default_gN(id);

	if(!SRP_create_verifier_BN(user, password, &s, &v, GN->N, GN->g)) 
	{
		return -1;
	}

	int32_t n = BN_num_bytes(s);
	if(n > *saltLen)
	{
		BN_clear_free(s);
		BN_clear_free(v);
		return -1;
	}
	
	*saltLen = BN_bn2bin(s, salt);

	n = BN_num_bytes(v);
	if(n > *verifierLen)
	{
		BN_clear_free(s);
		BN_clear_free(v);
		return -1;
	}

	*verifierLen = BN_bn2bin(v, verifier);

	BN_clear_free(s);
	BN_clear_free(v);
	return 0;
}

# define RANDOM_SIZE 32         /* use 256 bits on each side */

static int32_t crypt_srp_create_key_server(const char* id, const uint8_t* verifier, int32_t verifierLen, uint8_t* privKey, int32_t* privKeyLen, uint8_t* pubKey, int32_t* pubKeyLen)
{
	BIGNUM* priv = NULL;
	BIGNUM* pub = NULL;
	uint8_t key[RANDOM_SIZE];

	const SRP_gN* GN = SRP_get_default_gN(id);

	BIGNUM* v = BN_bin2bn(verifier, verifierLen, NULL);

	RAND_bytes(key, RANDOM_SIZE);
	priv = BN_bin2bn(key, RANDOM_SIZE, NULL);
	pub = SRP_Calc_B(priv, GN->N, GN->g,v);
	if(!SRP_Verify_B_mod_N(pub, GN->N))
	{
		BN_clear_free(v);
		BN_clear_free(priv);
		BN_free(pub);
		return -1;
	}

	int32_t n = BN_num_bytes(priv);
	if(n > *privKeyLen)
	{
		BN_clear_free(v);
		BN_clear_free(priv);
		BN_free(pub);
		return -1;
	}

	*privKeyLen = BN_bn2bin(priv, privKey);

	n = BN_num_bytes(pub);
	if(n > *pubKeyLen)
	{
		BN_clear_free(v);
		BN_clear_free(priv);
		BN_free(pub);
		return -1;
	}

	*pubKeyLen = BN_bn2bin(pub, pubKey);

	BN_clear_free(v);
	BN_clear_free(priv);
	BN_free(pub);
	return 0;
}

static int32_t crypt_srp_create_key_client(const char* id, uint8_t* privKey, int32_t* privKeyLen, uint8_t* pubKey, int32_t* pubKeyLen)
{
	BIGNUM* priv = NULL;
	BIGNUM* pub = NULL;
	uint8_t key[RANDOM_SIZE];

	const SRP_gN* GN = SRP_get_default_gN(id);

	RAND_bytes(key, RANDOM_SIZE);
	priv = BN_bin2bn(key, RANDOM_SIZE, NULL);
	pub = SRP_Calc_A(priv, GN->N, GN->g);
	if(!SRP_Verify_A_mod_N(pub, GN->N))
	{
		BN_clear_free(priv);
		BN_free(pub);
		return -1;
	}

	int32_t n = BN_num_bytes(priv);
	if(n > *privKeyLen)
	{
		BN_clear_free(priv);
		BN_free(pub);
		return -1;
	}

	*privKeyLen = BN_bn2bin(priv, privKey);

	n = BN_num_bytes(pub);
	if(n > *pubKeyLen)
	{
		BN_clear_free(priv);
		BN_free(pub);
		return -1;
	}

	*pubKeyLen = BN_bn2bin(pub, pubKey);

	BN_clear_free(priv);
	BN_free(pub);
	return 0;
}

static int32_t crypt_srp_create_session_key_server(const char* id, const uint8_t* verifier, int32_t verifierLen, const uint8_t* serverPrivKey, int32_t serverPrivKeyLen, const uint8_t* serverPubKey, int32_t serverPubKeyLen, const uint8_t* clientPubKey, int32_t clientPubKeyLen, uint8_t* sessionKey, int32_t* sessionKeyLen)
{
	const SRP_gN* GN = SRP_get_default_gN(id);
	BIGNUM* v = BN_bin2bn(verifier, verifierLen, NULL);
	BIGNUM* priv = BN_bin2bn(serverPrivKey, serverPrivKeyLen, NULL);
	BIGNUM* pub = BN_bin2bn(serverPubKey, serverPubKeyLen, NULL);
	BIGNUM* clientPub = BN_bin2bn(clientPubKey, clientPubKeyLen, NULL);

	BIGNUM* u = SRP_Calc_u(clientPub, pub, GN->N);
	BIGNUM* K = SRP_Calc_server_key(clientPub, v, u, priv, GN->N);

	int32_t n = BN_num_bytes(K);
	if(n > *sessionKeyLen)
	{
		BN_clear_free(priv);
		BN_clear_free(pub);
		BN_clear_free(clientPub);
		BN_clear_free(K);
		BN_clear_free(v);
		BN_free(u);
		return -1;
	}
	*sessionKeyLen = BN_bn2bin(K, sessionKey);

	BN_clear_free(priv);
	BN_clear_free(pub);
	BN_clear_free(clientPub);
	BN_clear_free(K);
	BN_clear_free(v);
	BN_free(u);

	return 0;
}

static int32_t crypt_srp_create_session_key_client(const char* id, const char* user, const char* password, const uint8_t* salt, int32_t saltLen,const uint8_t* clientPrivKey, int32_t clientPrivKeyLen, const uint8_t* clientPubKey, int32_t clientPubKeyLen, const uint8_t* serverPubKey, int32_t serverPubKeyLen, uint8_t* sessionKey, int32_t* sessionKeyLen)
{
	const SRP_gN* GN = SRP_get_default_gN(id);
	BIGNUM* s = BN_bin2bn(salt, saltLen, NULL);
	BIGNUM* priv = BN_bin2bn(clientPrivKey, clientPrivKeyLen, NULL);
	BIGNUM* pub = BN_bin2bn(clientPubKey, clientPubKeyLen, NULL);
	BIGNUM* serverPub = BN_bin2bn(serverPubKey, serverPubKeyLen, NULL);

	BIGNUM* u = SRP_Calc_u(pub, serverPub, GN->N);
	BIGNUM* x = SRP_Calc_x(s, user, password);
	BIGNUM* K = SRP_Calc_client_key (GN->N, serverPub, GN->g, x, priv, u);

	int32_t n = BN_num_bytes(K);
	if(n > *sessionKeyLen)
	{
		BN_clear_free(priv);
		BN_clear_free(pub);
		BN_clear_free(serverPub);
		BN_clear_free(K);
		BN_clear_free(s);
		BN_free(u);
		return -1;
	}
	*sessionKeyLen = BN_bn2bin(K, sessionKey);

	BN_clear_free(priv);
	BN_clear_free(pub);
	BN_clear_free(serverPub);
	BN_clear_free(K);
	BN_clear_free(s);
	BN_free(u);

	return 0;
}


static int32_t lsha1(lua_State *L) 
{
	size_t sz = 0;
	const void* pBuffer = luaL_checklstring(L, 1, &sz);
	uint8_t digest[DEF_SHA1_DIGEST_LENGTH];
	crypt_sha1(pBuffer,sz,digest);
	lua_pushlstring(L, (const char *)digest, DEF_SHA1_DIGEST_LENGTH);
	return 1;
}

static int32_t lmd5(lua_State *L) 
{
	size_t sz = 0;
	const void* pBuffer = luaL_checklstring(L, 1, &sz);
	uint8_t digest[DEF_MD5_DIGEST_LENGTH];
	crypt_md5(pBuffer,sz,digest);
	lua_pushlstring(L, (const char *)digest, DEF_MD5_DIGEST_LENGTH);
	return 1;
}

static int32_t lbase64_encode(lua_State *L)
{
	size_t sz = 0;
	const uint8_t* pBuffer = (const uint8_t*)luaL_checklstring(L, 1, &sz);
	int32_t iEncodeLength = sz*2;
	uint8_t tmpBuffer[128];
	memset(tmpBuffer,0,128);
	uint8_t* pEncodeBuffer = tmpBuffer;
	if (iEncodeLength > 128) 
	{
		pEncodeBuffer = (uint8_t*)lua_newuserdatauv(L, iEncodeLength,0);
	}
	int32_t iLength = crypt_base64Encode(pBuffer,sz,pEncodeBuffer);
	if(iLength < 0)
	{
		return luaL_error(L, "base64encode error");
	}
	lua_pushlstring(L, (const char *)pEncodeBuffer, iLength);
	return 1;
}

static int32_t lbase64_decode(lua_State *L)
{
	size_t sz = 0;
	const uint8_t* pBuffer = (const uint8_t*)luaL_checklstring(L, 1, &sz);

    int32_t iDecodeLength = (sz / 4) * 3;
	uint8_t tmpBuffer[128];
	memset(tmpBuffer,0,128);
	uint8_t* pDecodeBuffer = tmpBuffer;
	if (iDecodeLength > 128) 
	{
		pDecodeBuffer = (uint8_t*)lua_newuserdatauv(L, iDecodeLength,0);
	}

	int32_t iLength = crypt_base64Decode(pBuffer,sz,pDecodeBuffer);
	if(iLength < 0)
	{
		return luaL_error(L, "base64decode error");
	}

	int32_t i = 0;
    while (pBuffer[--sz] == '=') 
	{
        --iLength;
        if (++i > 2)
		{
			return luaL_error(L, "base64decode error");
		}
    }

	lua_pushlstring(L, (const char *)pDecodeBuffer, iLength);
	return 1;
}

static int32_t laes_encrypt(lua_State *L)
{
	const uint8_t* szKey = (const uint8_t*)luaL_checkstring (L, 1);
	size_t sz = 0;
	const uint8_t* pBuffer = (const uint8_t*)luaL_checklstring(L, 2, &sz);
	
	size_t nEncryptLength = (sz % DEF_AES_BLOCK_SIZE) == 0 ?  sz : sz + (DEF_AES_BLOCK_SIZE - (sz % DEF_AES_BLOCK_SIZE));

	uint8_t tmpBuffer[128];
	memset(tmpBuffer,0,128);
	uint8_t* pEncryptBuffer = tmpBuffer;
	if (nEncryptLength > 128) 
	{
		pEncryptBuffer = (uint8_t*)lua_newuserdatauv(L, nEncryptLength,0);
	}
	crypt_aes_cbc_encrypt(szKey,pBuffer,sz,pEncryptBuffer);
	lua_pushlstring(L, (const char *)pEncryptBuffer, nEncryptLength);
	return 1;
}

static int32_t laes_decrypt(lua_State *L)
{
	const uint8_t* szKey = (const uint8_t*)luaL_checkstring (L, 1);
	size_t sz = 0;
	const uint8_t* pBuffer = (const uint8_t*)luaL_checklstring(L, 2, &sz);

	uint8_t tmpBuffer[128];
	memset(tmpBuffer,0,128);
	uint8_t* pDecryptBuffer = tmpBuffer;
	if (sz > 128) 
	{
		pDecryptBuffer = (uint8_t*)lua_newuserdatauv(L, sz,0);
	}

	crypt_aes_cbc_decrypt(szKey,pBuffer,sz,pDecryptBuffer);
	lua_pushlstring(L, (const char *)pDecryptBuffer, sz);
	return 1;
}

static int32_t lrand_bytes(lua_State *L)
{
	int32_t len = (int32_t)luaL_checkinteger(L, 1);
	uint8_t tmpBuffer[64];
	memset(tmpBuffer,0,64);

	uint8_t* pBuffer = tmpBuffer;
	if (len > 64) 
	{
		pBuffer = (uint8_t*)lua_newuserdatauv(L, len,0);
	}
	crypt_rand_bytes(pBuffer,len);
	lua_pushlstring(L,(const char*)pBuffer,len);
	return 1;
}

#define SRP_RANDOM_SALT_LEN 20

static int32_t lsrp_create_verifier(lua_State *L)
{
	const char* szUser = luaL_checkstring(L, 1);
	const char* szPassword = luaL_checkstring(L, 2);
	uint8_t salt[SRP_RANDOM_SALT_LEN];
	int32_t saltLen = SRP_RANDOM_SALT_LEN;
	uint8_t verifier[256];
	int32_t verifierLen = 256;
	if(crypt_srp_create_verifier("1024",szUser,szPassword,salt,&saltLen,verifier,&verifierLen) == 0)
	{
		lua_pushlstring(L, (const char*)salt,saltLen);
		lua_pushlstring(L, (const char*)verifier,verifierLen);
		return 2;
	}
	return 0;
}


static int32_t lsrp_create_key_server(lua_State *L)
{
	size_t sz = 0;
	const uint8_t* verifier = (const uint8_t*)luaL_checklstring(L, 1, &sz);

	uint8_t privKey[32];
	int32_t privKeyLen = 32;
	uint8_t pubKey[256];
	int32_t pubKeyLen = 256;

	if(crypt_srp_create_key_server("1024",verifier,(int32_t)sz,privKey,&privKeyLen,pubKey,&pubKeyLen) == 0)
	{
		lua_pushlstring(L, (const char*)privKey,privKeyLen);
		lua_pushlstring(L, (const char*)pubKey,pubKeyLen);
		return 2;
	}
	return 0;
}

static int32_t lsrp_create_key_client(lua_State *L)
{
	uint8_t privKey[32];
	int32_t privKeyLen = 32;
	uint8_t pubKey[256];
	int32_t pubKeyLen = 256;

	if(crypt_srp_create_key_client("1024",privKey,&privKeyLen,pubKey,&pubKeyLen) == 0)
	{
		lua_pushlstring(L, (const char*)privKey,privKeyLen);
		lua_pushlstring(L, (const char*)pubKey,pubKeyLen);
		return 2;
	}
	return 0;
}

static int32_t lsrp_create_session_key_server(lua_State *L)
{
	size_t sz = 0;
	const uint8_t* verifier = (const uint8_t*)luaL_checklstring(L, 1, &sz);

	size_t serverPrivKeyLen = 0;
	const uint8_t* serverPrivKey = (const uint8_t*)luaL_checklstring(L, 2, &serverPrivKeyLen);

	size_t serverPubKeyLen = 0;
	const uint8_t* serverPubKey = (const uint8_t*)luaL_checklstring(L, 3, &serverPubKeyLen);

	size_t clientPubKeyLen = 0;
	const uint8_t* clientPubKey = (const uint8_t*)luaL_checklstring(L, 4, &clientPubKeyLen);

	uint8_t sessionKey[256];
	int32_t sessionKeyLen = 256;

	if(crypt_srp_create_session_key_server("1024",verifier,(int32_t)sz,serverPrivKey,(int32_t)serverPrivKeyLen,serverPubKey,(int32_t)serverPubKeyLen,clientPubKey,(int32_t)clientPubKeyLen,sessionKey,&sessionKeyLen) == 0)
	{
		lua_pushlstring(L, (const char*)sessionKey,sessionKeyLen);
		return 1;
	}
	return 0;
}

static int32_t lsrp_create_session_key_client(lua_State *L)
{
	const char* szUser = luaL_checkstring(L, 1);
	const char* szPassword = luaL_checkstring(L, 2);

	size_t sz = 0;
	const uint8_t* salt = (const uint8_t*)luaL_checklstring(L, 3, &sz);

	size_t clientPrivKeyLen = 0;
	const uint8_t* clientPrivKey = (const uint8_t*)luaL_checklstring(L, 4, &clientPrivKeyLen);

	size_t clientPubKeyLen = 0;
	const uint8_t* clientPubKey = (const uint8_t*)luaL_checklstring(L, 5, &clientPubKeyLen);

	size_t serverPubKeyLen = 0;
	const uint8_t* serverPubKey = (const uint8_t*)luaL_checklstring(L, 6, &serverPubKeyLen);

	uint8_t sessionKey[256];
	int32_t sessionKeyLen = 256;

	if(crypt_srp_create_session_key_client("1024", szUser, szPassword, salt,(int32_t)sz,clientPrivKey,(int32_t)clientPrivKeyLen,clientPubKey,(int32_t)clientPubKeyLen,serverPubKey,(int32_t)serverPubKeyLen,sessionKey,&sessionKeyLen) == 0)
	{
		lua_pushlstring(L, (const char*)sessionKey,sessionKeyLen);
		return 1;
	}
	return 0;
}

int luaopen_lcrypt(struct lua_State *L)
{
    luaL_Reg lualib_crypt[] =
    {
        {"sha1", 		 					lsha1},
        {"md5",  		 					lmd5},
        {"base64_encode", 					lbase64_encode},
        {"base64_decode", 					lbase64_decode},
        {"aes_encrypt",   					laes_encrypt},
        {"aes_decrypt",   					laes_decrypt},
        {"rand_bytes",    					lrand_bytes},
        {"srp_create_verifier",   			lsrp_create_verifier},
        {"srp_create_key_server",   		lsrp_create_key_server},
        {"srp_create_key_client",   		lsrp_create_key_client},
        {"srp_create_session_key_server",   lsrp_create_session_key_server},
        {"srp_create_session_key_client",   lsrp_create_session_key_client},
        {NULL, NULL}
    };
	luaL_newlib(L, lualib_crypt);
	return 1;
}
