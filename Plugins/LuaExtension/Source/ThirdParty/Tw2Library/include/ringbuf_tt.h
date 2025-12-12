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

tw2_API void tw2_ringbuf_init(tw2_ringbuf_t* pBuf, size_t capacity);

tw2_API void tw2_ringbuf_clear(tw2_ringbuf_t* pBuf);

tw2_API void tw2_ringbuf_write(tw2_ringbuf_t* pBuf, const void* pInBytes, size_t length);

tw2_API void tw2_ringbuf_write_ch(tw2_ringbuf_t* pBuf, const char c);

tw2_API bool tw2_ringbuf_read(tw2_ringbuf_t* pBuf, void* pOutBytes, size_t maxLengthToRead, bool bPeek);

tw2_API void tw2_ringbuf_reset(tw2_ringbuf_t* pBuf);

tw2_API void tw2_ringbuf_reserve(tw2_ringbuf_t* pBuf,size_t capacity);

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
	pRhs->readIndex = capacity;
	pRhs->writeIndex = capacity;
}

static _decl_forceinline void tw2_ringbuf_swap_buffer(tw2_ringbuf_t* pBuf, char** ppBuffer, size_t* pCapacity)
{
	char* pBytes = pBuf->pBytes;
	size_t capacity = pBuf->capacity;
	pBuf->pBytes = *ppBuffer;
	pBuf->readIndex = *pCapacity;
	pBuf->writeIndex = *pCapacity;
	pBuf->capacity = *pCapacity;
	*ppBuffer = pBytes;
	*pCapacity = capacity;
}

static _decl_forceinline bool tw2_ringbuf_empty(tw2_ringbuf_t* pBuf)
{
	return pBuf->readIndex == pBuf->capacity;
}

static _decl_forceinline size_t tw2_ringbuf_readable_bytes(tw2_ringbuf_t* pBuf)
{
	if (pBuf->writeIndex > pBuf->readIndex)
	{
		return pBuf->writeIndex - pBuf->readIndex;
	}
	else
	{
		return pBuf->writeIndex + (pBuf->capacity - pBuf->readIndex);
	}
}

static _decl_forceinline size_t tw2_ringbuf_writable_bytes(tw2_ringbuf_t* pBuf)
{
	if (pBuf->readIndex >= pBuf->writeIndex)
	{
		return pBuf->readIndex - pBuf->writeIndex;
	}
	else
	{
		return pBuf->readIndex + (pBuf->capacity - pBuf->writeIndex);
	}
}

static _decl_forceinline size_t tw2_ringbuf_capacity(tw2_ringbuf_t* pBuf)
{
	return pBuf->capacity;
}

static _decl_forceinline char* tw2_ringbuf_bytes(tw2_ringbuf_t* pBuf)
{
	return pBuf->pBytes;
}

static _decl_forceinline char* tw2_ringbuf_peek_contiguous_read(tw2_ringbuf_t* pBuf, size_t* pReadableBytes)
{
	if (pBuf->writeIndex > pBuf->readIndex)
	{
		*pReadableBytes = pBuf->writeIndex - pBuf->readIndex;
	}
	else
	{
		*pReadableBytes = pBuf->capacity - pBuf->readIndex;
	}
	return pBuf->pBytes + pBuf->readIndex;
}

static _decl_forceinline char* tw2_ringbuf_peek_contiguous_write(tw2_ringbuf_t* pBuf, size_t* pWritableBytes)
{
	if (pBuf->readIndex >= pBuf->writeIndex)
	{
		*pWritableBytes = pBuf->readIndex - pBuf->writeIndex;
	}
	else
	{
		*pWritableBytes = pBuf->capacity - pBuf->writeIndex;
	}
	return pBuf->pBytes + pBuf->writeIndex;
}

static _decl_forceinline void tw2_ringbuf_read_skip(tw2_ringbuf_t* pBuf, size_t offset)
{
	assert(tw2_ringbuf_readable_bytes(pBuf) >= offset);
	if (tw2_ringbuf_readable_bytes(pBuf) == offset)
	{
		pBuf->readIndex = pBuf->capacity;
		pBuf->writeIndex = 0;
	}
	else
	{
		pBuf->readIndex = (pBuf->readIndex + offset) % pBuf->capacity;
	}
}

static _decl_forceinline void tw2_ringbuf_write_skip(tw2_ringbuf_t* pBuf, size_t offset)
{
	assert((offset != 0) && (tw2_ringbuf_writable_bytes(pBuf) >= offset));
	pBuf->writeIndex = (pBuf->writeIndex + offset) % pBuf->capacity;
	if (pBuf->readIndex == pBuf->capacity)
	{
		pBuf->readIndex = 0;
	}
}