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
#include <stdlib.h>

#define DEF_PLATFORM_UNKNOWN	0
#define DEF_PLATFORM_WINDOWS	1
#define DEF_PLATFORM_LINUX		2
#define DEF_PLATFORM_MACOS		3
#define DEF_PLATFORM_ANDROID	4
#define DEF_PLATFORM_IOS		5

#if defined(_WINDOWS)|| defined(_WIN32)
	#define DEF_PLATFORM  DEF_PLATFORM_WINDOWS
#elif defined(__APPLE__)
	#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ >= 30000 || __IPHONE_OS_VERSION_MIN_REQUIRED > 30000
		#define DEF_PLATFORM DEF_PLATFORM_IOS
	#else
		#define DEF_PLATFORM DEF_PLATFORM_MACOS
	#endif
#elif defined(__ANDROID__)
	#define DEF_PLATFORM DEF_PLATFORM_ANDROID
#elif defined(__linux__)
	#define DEF_PLATFORM DEF_PLATFORM_LINUX
#else
	#define DEF_PLATFORM DEF_PLATFORM_UNKNOWN
#endif

#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
	#if defined(_WIN64)
		#define DEF_PLATFORM_64BITS
	#endif
#elif DEF_PLATFORM == DEF_PLATFORM_ANDROID
	#if defined(__LP64__)
		#define DEF_PLATFORM_64BITS
	#endif
#elif DEF_PLATFORM == DEF_PLATFORM_IOS
	#if defined(__LP64__)
		#define DEF_PLATFORM_64BITS
	#endif
#elif DEF_PLATFORM == DEF_PLATFORM_MACOS
	#define DEF_PLATFORM_64BITS
#elif DEF_PLATFORM == DEF_PLATFORM_LINUX
	#if defined(_LINUX64) || defined(_LP64)
		#define DEF_PLATFORM_64BITS
	#endif
#endif

#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
	#ifdef tw2_EXPORTS
		#define tw2_API __declspec(dllexport)
		#define tw2_DEF __declspec(dllexport) extern
	#else
		#define tw2_API __declspec(dllimport)
		#define tw2_DEF __declspec(dllimport) extern
	#endif
#else
	#ifdef tw2_EXPORTS
		#define tw2_API __attribute__((__visibility__("default")))
		#define tw2_DEF __attribute__((__visibility__("default"))) extern
	#else
		#define tw2_API extern
		#define tw2_DEF extern
	#endif
#endif

#if DEF_PLATFORM != DEF_PLATFORM_WINDOWS
	#include <strings.h>
#endif

typedef struct tw2_iovec_s
{
	char*	pBuf;
	size_t	length;
} tw2_iovec_t;

#define container_of(ptr, type, member) ((type *) ((char *) (ptr) - offsetof(type, member)))

#if defined(__clang__) || defined(__GNUC__)
	#define _decl_forceinline inline __attribute__((__always_inline__))
#elif defined(_MSC_VER)
	#define _decl_forceinline __forceinline
#else
	#define _decl_forceinline inline
#endif

#if defined(__clang__) || defined(__GNUC__)
#	define _decl_noinline __attribute__((__noinline__))
#elif defined(_MSC_VER)
#	define _decl_noinline __declspec(noinline)
#else
#	define _decl_noinline
#endif

#if defined(__clang__) || (defined(__GNUC__) && (__GNUC__ >= 4))
	#define _decl_nodiscard __attribute__((warn_unused_result))
#elif defined(_MSC_VER) && (_MSC_VER >= 1700)
	#define _decl_nodiscard _Check_return_
#else
	#define _decl_nodiscard
#endif

#if defined(__clang__) || defined(__GNUC__)
	#define _decl_unused __attribute__((unused))
#else
	#define _decl_unused 
#endif

#if defined(__clang__) || defined(__GNUC__)
	#define _decl_thread_local __thread
#else
	#define _decl_thread_local __declspec(thread)
#endif

#define CPU_CACHE_LINE	64

#if defined(__clang__) || defined(__GNUC__)
	#define _decl_cpu_cache_align	__attribute__((aligned(CPU_CACHE_LINE)))
#elif defined(_MSC_VER)
	#define _decl_cpu_cache_align	__declspec(align(CPU_CACHE_LINE))
#else
	#define _decl_cpu_cache_align
#endif

#if defined(__clang__) || defined(__has_builtin)
	#define DEF_CLANG_BUILTIN(v) __has_builtin(v)
#else
	#define DEF_CLANG_BUILTIN(v) 0
#endif

#if defined(__clang__) || defined(__GNUC__)
	#define DEF_VARIABLE_LENGTH_ARRAY
#endif

#if (defined(__GNUC__) && (__GNUC__ >= 4)) || DEF_CLANG_BUILTIN(__builtin_expect)
	#define _likely(v)		(__builtin_expect(!!(v), 1))
	#define _unlikely(v)	(__builtin_expect(!!(v), 0))
#else
	#define _likely(v)		(v)
	#define _unlikely(v)	(v)
#endif

#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
	#define bzero(s,n)				memset(s,0,n)
	#define strcasecmp(s1,s2)		_stricmp(s1,s2)
	#define strncasecmp(s1,s2,n)	_strnicmp(s1,s2,n)

	#if !defined(__clang__)
		#include <intrin.h>

		_decl_forceinline int32_t __builtin_clz(uint32_t v)
		{
			unsigned long index;
			return _BitScanReverse(&index, (unsigned long)v) ? 31 - index : 32;
		}

		_decl_forceinline int32_t __builtin_ctz(uint32_t v)
		{
			unsigned long index;
			return _BitScanForward(&index, (unsigned long)v) ? index : 32;
		}

		_decl_forceinline int32_t __builtin_clzll(uint64_t v)
		{
			unsigned long index;
			return _BitScanReverse64(&index, (unsigned long long)v) ? 63 - index : 64;
		}

		_decl_forceinline int32_t __builtin_ctzll(uint64_t v)
		{
			unsigned long index;
			return _BitScanForward64(&index, (unsigned long long)v) ? index : 64;
		}
	#endif
#else 
	#define max(a,b)	({__typeof__ (a) _a = (a); __typeof__ (b) _b = (b); _a > _b ? _a : _b; })
	#define min(a,b)	({__typeof__ (a) _a = (a); __typeof__ (b) _b = (b); _a < _b ? _a : _b; })
	typedef int32_t SOCKET;
	#define INVALID_SOCKET (-1)
#endif

#ifdef __cplusplus
extern "C" {
#endif

tw2_API void tw2_set_mem_functions(void *(*userMalloc)(size_t), void *(*userRealloc)(void*, size_t), void (*userFree)(void*));

tw2_API void tw2_free(void* p);

_decl_nodiscard tw2_API void* tw2_malloc(size_t size);

_decl_nodiscard tw2_API void* tw2_realloc(void* p, size_t size);

_decl_nodiscard tw2_API char* tw2_strdup(const char* s); 

_decl_nodiscard tw2_API char* tw2_strndup(const char* s, size_t n);

#ifdef __cplusplus
}
#endif

#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
	#define tw2_strtok(s, d, pp)		strtok_s(s, d, pp)
#else 
	#define tw2_strtok(s, d, pp)		strtok_r(s, d, pp)
#endif

static _decl_forceinline size_t tw2_strlncat(char* pDst, size_t len, const char* src, size_t n)
{
	size_t slen;
	size_t dlen;
	size_t rlen;
	size_t ncpy;

	slen = strnlen(src, n);
	dlen = strnlen(pDst, len);

	if (_unlikely(slen + dlen >= len))
	{
		return 0;
	}

	if (_likely(dlen < len))
	{
		rlen = len - dlen;
		ncpy = slen < rlen ? slen : (rlen - 1);
		memcpy(pDst + dlen, src, ncpy);
		pDst[dlen + ncpy] = '\0';
	}
	return slen + dlen;
}

static _decl_forceinline float tw2_bits_to_float(const uint32_t v)
{
	return (float)(v >> 8) / 16777216.0f;
}

static _decl_forceinline double tw2_bits_to_double(const uint64_t v) 
{
	return (double)(v >> 11) / 9007199254740992.0;
}

static _decl_forceinline size_t tw2_align_size(size_t n, size_t alignment)
{
	return (n + alignment - 1) & ~(alignment - 1);
}

static _decl_forceinline size_t tw2_roundup_pow2(size_t n)
{
	if (n == 0)
	{
		return 1;
	}
	n--;
	n |= n >> 1;
	n |= n >> 2;
	n |= n >> 4;
	n |= n >> 8;
	n |= n >> 16;
#if SIZE_MAX > 0xFFFFFFFFUL
	n |= n >> 32;
#endif
	n++;
	return n;
}