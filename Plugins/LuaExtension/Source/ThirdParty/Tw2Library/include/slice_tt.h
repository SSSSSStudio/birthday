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

#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>

#include "utility_tt.h"

typedef struct tw2_slice_s
{
	const char*	data;
	size_t      length;
} tw2_slice_t;

static _decl_forceinline void tw2_slice_clear(tw2_slice_t* pSlice)
{
	pSlice->data = NULL;
	pSlice->length = 0;
}

static _decl_forceinline void tw2_slice_set(tw2_slice_t* pSlice, const char* data /*=""*/, size_t n /*=0*/ )
{
	pSlice->data = data;
	pSlice->length = n;
}

static _decl_forceinline const char* tw2_slice_data(const tw2_slice_t* pSlice)
{
	return pSlice->data;
}

static _decl_forceinline size_t tw2_slice_length(const tw2_slice_t* pSlice)
{
	return pSlice->length;
}

static _decl_forceinline bool tw2_slice_empty(const tw2_slice_t* pSlice)
{
	return pSlice->length == 0;
}

static _decl_forceinline int32_t tw2_slice_cmp(const tw2_slice_t* pSlice, const tw2_slice_t* pRhs)
{
	const size_t minLen = (pSlice->length < pRhs->length) ? pSlice->length : pRhs->length;
	int32_t r = memcmp(pSlice->data, pRhs->data, minLen);
	if (r == 0) 
	{
		if (pSlice->length < pRhs->length)
		{
			r = -1;
		} 
		else if (pSlice->length > pRhs->length) 
		{
			r = 1;
		}
	}
	return r;
}

static _decl_forceinline void tw2_slice_remove_suffix(tw2_slice_t* pSlice, size_t n)
{
	assert(n <= pSlice->length);
	pSlice->length -= n;
}

static _decl_forceinline void tw2_slice_read_skip(tw2_slice_t* pSlice, size_t offset) 
{
	assert(offset <= pSlice->length);
	pSlice->data += offset;
	pSlice->length -= offset;
}

static _decl_forceinline bool tw2_slice_read(tw2_slice_t* pSlice, void* pOutBytes, size_t maxLengthToRead, bool bPeek /*= false*/ )
{
	size_t bytesToRead = pSlice->length < maxLengthToRead ? pSlice->length : maxLengthToRead;
	if (bytesToRead == 0)
	{
		return false;
	}
	memcpy(pOutBytes,pSlice->data,bytesToRead);
	if (!bPeek)
	{
		pSlice->data += bytesToRead;
		pSlice->length -= bytesToRead;
	}
	return true;
}