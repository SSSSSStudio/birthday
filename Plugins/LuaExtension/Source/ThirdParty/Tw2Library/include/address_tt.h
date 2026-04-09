/*  tw2
 *  Copyright (C) 2019  Peng Bo <pengbo@twtwo.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as published
 *  by the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#pragma once

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>

#if defined( _WINDOWS ) || defined( _WIN32 ) 
	#include <ws2tcpip.h>
#else
	#include <netinet/in.h>
	#include <arpa/inet.h>  
	#include <sys/socket.h>
#endif

#include "utility_tt.h"
#include "hash_tt.h"

typedef struct tw2_address_s
{
	union
	{
		struct sockaddr_in  in;
		struct sockaddr_in6 in6;
	};
} tw2_address_t;

#ifdef __cplusplus
extern "C" {
#endif

tw2_API bool tw2_address_init(tw2_address_t* pAddress, const char* addr, uint16_t port, bool bInV6);

tw2_API void tw2_address_init_any(tw2_address_t* pAddress, uint16_t port, bool bInV6);

tw2_API void tw2_address_init_v4(tw2_address_t* pAddress, struct sockaddr_in in);

tw2_API void tw2_address_init_v6(tw2_address_t* pAddress, struct sockaddr_in6 in6);

tw2_API bool tw2_address_init_from(tw2_address_t* pAddress, const char* format);

tw2_API bool tw2_address_addr_port_to_string(const tw2_address_t* pAddress, char* pStr, size_t length);

tw2_API bool tw2_address_addr_to_string(const tw2_address_t* pAddress, char* pStr, size_t length);

#ifdef __cplusplus
}
#endif

static _decl_forceinline
#if defined( _WINDOWS ) || defined( _WIN32 )
ADDRESS_FAMILY
#else
sa_family_t
#endif
tw2_address_family(const tw2_address_t* pAddress)
{
	return pAddress->in.sin_family;
}

static _decl_forceinline bool tw2_address_is_v4(const tw2_address_t* pAddress)
{
	 return pAddress->in.sin_family == AF_INET;
}

static _decl_forceinline bool tw2_address_is_v6(const tw2_address_t* pAddress)
{
	 return pAddress->in.sin_family == AF_INET6;
}

static _decl_forceinline uint16_t tw2_address_port(const tw2_address_t* pAddress)
{
	return ntohs(pAddress->in.sin_port);
}

static _decl_forceinline uint32_t tw2_address_ip4_raw_addr(const tw2_address_t* pAddress)
{
	return pAddress->in.sin_addr.s_addr;
}

static _decl_forceinline struct in6_addr tw2_address_ip6_raw_addr(const tw2_address_t* pAddress)
{
	return pAddress->in6.sin6_addr;
}

static _decl_forceinline uint16_t tw2_address_raw_port(const tw2_address_t* pAddress)
{
	return pAddress->in.sin_port;
}

static _decl_forceinline struct sockaddr* tw2_address_sockaddr(const tw2_address_t* pAddress)
{
	return (struct sockaddr*)(&pAddress->in);
}

static _decl_forceinline socklen_t tw2_address_socklen(const tw2_address_t* pAddress)
{
	return pAddress->in.sin_family == AF_INET6 ? sizeof(struct sockaddr_in6) : sizeof(struct sockaddr_in);
}

static _decl_forceinline uint64_t tw2_address_hash(const tw2_address_t* pAddress)
{
	return pAddress->in.sin_family == AF_INET6 ? fnv64_buf(&pAddress->in6,sizeof(struct sockaddr_in6),FNV_64_HASH_START) : fnv32_buf(&pAddress->in, offsetof(struct sockaddr_in, sin_zero),FNV_32_HASH_START);
}

static _decl_forceinline int32_t tw2_address_cmp(const tw2_address_t* pAddress,const tw2_address_t* pRhs)
{
	if (pAddress->in.sin_family != pRhs->in.sin_family)
		return (int32_t)pAddress->in.sin_family - (int32_t)pRhs->in.sin_family;
	return pAddress->in.sin_family == AF_INET6 ? memcmp(&pAddress->in6,&pRhs->in6,sizeof(struct sockaddr_in6)) : memcmp(&pAddress->in,&pRhs->in,offsetof(struct sockaddr_in, sin_zero));
}