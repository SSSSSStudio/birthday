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
#include <assert.h>

#include "utility_tt.h"

typedef struct tw2_ringbuf_s
{
	char*	pBytes;
	size_t	capacity;
	size_t	readIndex;
	size_t	writeIndex;
} tw2_ringbuf_t;

#ifdef __cplusplus
extern "C" {
#endif

tw2_API void tw2_ringbuf_init(tw2_ringbuf_t* pBuf, size_t capacity);

tw2_API void tw2_ringbuf_clear(tw2_ringbuf_t* pBuf);

tw2_API void tw2_ringbuf_write(tw2_ringbuf_t* pBuf, const void* pInBytes, size_t length);

tw2_API void tw2_ringbuf_write_ch(tw2_ringbuf_t* pBuf, const char c);

tw2_API bool tw2_ringbuf_read(tw2_ringbuf_t* pBuf, void* pOutBytes, size_t maxLengthToRead, bool bPeek);

tw2_API void tw2_ringbuf_reset(tw2_ringbuf_t* pBuf);

tw2_API void tw2_ringbuf_reserve(tw2_ringbuf_t* pBuf,size_t capacity);

#ifdef __cplusplus
}
#endif

static _decl_forceinline void tw2_ringbuf_swap_to_reset(tw2_ringbuf_t* pBuf, tw2_ringbuf_t* pRhs)
{
	char* pBytes = pBuf->pBytes;
	size_t capacity = pBuf->capacity;
	pBuf->pBytes = pRhs->pBytes;
	pBuf->readIndex = pRhs->readIndex;
	pBuf->writeIndex = pRhs->writeIndex;
	pBuf->capacity = pRhs->capacity;
	pRhs->pBytes = pBytes;
	pRhs->capacity = capacity;
	pRhs->readIndex = 0;
	pRhs->writeIndex = 0;
}

static _decl_forceinline void tw2_ringbuf_swap_buffer(tw2_ringbuf_t* pBuf, char** ppBuffer, size_t* pCapacity)
{
	char* pBytes = pBuf->pBytes;
	size_t capacity = pBuf->capacity;
	pBuf->pBytes = *ppBuffer;
	pBuf->readIndex = 0;
	pBuf->writeIndex = 0;
	pBuf->capacity = *pCapacity;
	*ppBuffer = pBytes;
	*pCapacity = capacity;
}

static _decl_forceinline bool tw2_ringbuf_empty(const tw2_ringbuf_t* pBuf)
{
	return pBuf->readIndex == pBuf->writeIndex;
}

static _decl_forceinline size_t tw2_ringbuf_readable_bytes(const tw2_ringbuf_t* pBuf)
{
	if (_unlikely(pBuf->capacity == 0)) return 0;
	return (pBuf->writeIndex - pBuf->readIndex) & (pBuf->capacity - 1);
}

static _decl_forceinline size_t tw2_ringbuf_writable_bytes(const tw2_ringbuf_t* pBuf)
{
	if (_unlikely(pBuf->capacity == 0)) return 0;
	return (pBuf->readIndex - pBuf->writeIndex - 1) & (pBuf->capacity - 1);
}

static _decl_forceinline size_t tw2_ringbuf_capacity(const tw2_ringbuf_t* pBuf)
{
	return pBuf->capacity;
}

static _decl_forceinline const char* tw2_ringbuf_bytes(const tw2_ringbuf_t* pBuf)
{
	return pBuf->pBytes;
}

static _decl_forceinline char* tw2_ringbuf_peek_contiguous_read(tw2_ringbuf_t* pBuf, size_t* pReadableBytes)
{
	size_t readableBytes = tw2_ringbuf_readable_bytes(pBuf);
	size_t toEnd = pBuf->capacity - pBuf->readIndex;
	*pReadableBytes = readableBytes < toEnd ? readableBytes : toEnd;
	return pBuf->pBytes + pBuf->readIndex;
}

static _decl_forceinline char* tw2_ringbuf_peek_contiguous_write(tw2_ringbuf_t* pBuf, size_t* pWritableBytes)
{
	size_t writableBytes = tw2_ringbuf_writable_bytes(pBuf);
	size_t toEnd = pBuf->capacity - pBuf->writeIndex;
	*pWritableBytes = writableBytes < toEnd ? writableBytes : toEnd;
	return pBuf->pBytes + pBuf->writeIndex;
}

static _decl_forceinline void tw2_ringbuf_read_skip(tw2_ringbuf_t* pBuf, size_t offset)
{
	size_t readable = tw2_ringbuf_readable_bytes(pBuf);
	assert(readable >= offset);
	if (_unlikely(readable == offset))
	{
		pBuf->readIndex = pBuf->writeIndex = 0;
	}
	else
	{
		pBuf->readIndex = (pBuf->readIndex + offset) & (pBuf->capacity - 1);
	}
}

static _decl_forceinline void tw2_ringbuf_write_skip(tw2_ringbuf_t* pBuf, size_t offset)
{
	assert((offset != 0) && (tw2_ringbuf_writable_bytes(pBuf) >= offset));
	pBuf->writeIndex = (pBuf->writeIndex + offset) & (pBuf->capacity - 1);
}