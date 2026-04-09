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

#ifdef __cplusplus
#include <atomic>
using std::atomic_int;
using std::memory_order_relaxed;
using std::memory_order_acquire;
using std::memory_order_release;
using std::memory_order_acq_rel;
#else
#include <stdatomic.h>
#endif

#include "utility_tt.h"
#include "thread_tt.h"

#ifdef __cplusplus
static constexpr int TW2_RW_WRITER = 1;
static constexpr int TW2_RW_UPGRADED = 2;
static constexpr int TW2_RW_READER = 4;
#else
enum 
{
    TW2_RW_WRITER = 1,
    TW2_RW_UPGRADED = 2, 
    TW2_RW_READER = 4
};
#endif

typedef struct tw2_rw_spinlock_s
{
    atomic_int  bits;
} tw2_rw_spinlock_t;

static _decl_forceinline void tw2_rw_spinlock_init(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_rdlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline bool tw2_rw_spinlock_tryrdlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_rdunlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_wrlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline bool tw2_rw_spinlock_trywrlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_wrunlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_wrunlock_rdlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_uplock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upunlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline bool tw2_rw_spinlock_tryuplock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upunlock_wrlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upunlock_rdlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_wrunlock_uplock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline bool tw2_rw_spinlock_tryupunlock_wrlock(tw2_rw_spinlock_t* pHandle);

//internal
static _decl_forceinline bool _tw2_tryrdlock(tw2_rw_spinlock_t* pHandle)
{
    int32_t v = atomic_load_explicit(&pHandle->bits, memory_order_relaxed);
    if (_unlikely(v & (TW2_RW_WRITER | TW2_RW_UPGRADED)))
    {
        return false;
    }
    v = atomic_fetch_add_explicit(&pHandle->bits, (int32_t)TW2_RW_READER, memory_order_acquire);
    if (_unlikely(v & (TW2_RW_WRITER | TW2_RW_UPGRADED))) 
    {
        atomic_fetch_add_explicit(&pHandle->bits, (int32_t)-TW2_RW_READER, memory_order_release);
        return false;
    }
    return true;
}

static _decl_forceinline bool _tw2_tryuplock(tw2_rw_spinlock_t* pHandle) 
{
    int32_t v = atomic_fetch_or_explicit(&pHandle->bits,(int32_t)TW2_RW_UPGRADED, memory_order_acquire);
    return ((v& (TW2_RW_UPGRADED | TW2_RW_WRITER)) == 0);
}

static _decl_forceinline bool _tw2_trywrlock(tw2_rw_spinlock_t* pHandle)
{
    int32_t expect = 0;
    return atomic_compare_exchange_strong_explicit(&pHandle->bits,&expect,(int32_t)TW2_RW_WRITER,memory_order_acq_rel,memory_order_relaxed);
} 

static _decl_forceinline bool _tw2_tryupunlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    int32_t expect = TW2_RW_UPGRADED;
    return atomic_compare_exchange_strong_explicit(&pHandle->bits,&expect,(int32_t)TW2_RW_WRITER,memory_order_acq_rel,memory_order_relaxed);
}

//---------------------------------------------------------------------------------------------------------------------------------

static _decl_forceinline void tw2_rw_spinlock_init(tw2_rw_spinlock_t* pHandle)
{
    atomic_init(&pHandle->bits,0);
}

static _decl_forceinline void tw2_rw_spinlock_rdlock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    uint32_t backoff = 1;
    while (_unlikely(!_tw2_tryrdlock(pHandle))) 
    {
        for (uint32_t i = 0; i < backoff; ++i)
        {
            tw2_thread_pause();
        }
        if (++spinCount > 1024) 
        {
            tw2_thread_yield();
            backoff = 1;
        }
        else
        {
            backoff = (backoff * 2 < 256) ? backoff * 2 : 256;
        }
    }
}

static _decl_forceinline bool tw2_rw_spinlock_tryrdlock(tw2_rw_spinlock_t* pHandle)
{
    return _tw2_tryrdlock(pHandle);
}

static _decl_forceinline void tw2_rw_spinlock_rdunlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,(int32_t)-TW2_RW_READER,memory_order_release);
}

static _decl_forceinline void tw2_rw_spinlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    uint32_t backoff = 1;
    while (_unlikely(!_tw2_trywrlock(pHandle)))
    {
        for (uint32_t i = 0; i < backoff; ++i)
        {
            tw2_thread_pause();
        }
        if (++spinCount > 1024)
        {
            tw2_thread_yield();
            backoff = 1;
        }
        else
        {
            backoff = (backoff * 2 < 256) ? backoff * 2 : 256;
        }
    }
}

static _decl_forceinline bool tw2_rw_spinlock_trywrlock(tw2_rw_spinlock_t* pHandle)
{
    return _tw2_trywrlock(pHandle);
}

static _decl_forceinline void tw2_rw_spinlock_wrunlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_and_explicit(&pHandle->bits,(int32_t)~(TW2_RW_WRITER | TW2_RW_UPGRADED),memory_order_release);
}

static _decl_forceinline void tw2_rw_spinlock_wrunlock_rdlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,(int32_t)TW2_RW_READER,memory_order_acquire);
    atomic_fetch_and_explicit(&pHandle->bits,(int32_t)~(TW2_RW_WRITER | TW2_RW_UPGRADED),memory_order_release);
}

static _decl_forceinline void tw2_rw_spinlock_uplock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    uint32_t backoff = 1;
    while (_unlikely(!_tw2_tryuplock(pHandle))) 
    {
        for (uint32_t i = 0; i < backoff; ++i)
        {
            tw2_thread_pause();
        }
        if (++spinCount > 1024) 
        {
            tw2_thread_yield();
            backoff = 1;
        }
        else
        {
            backoff = (backoff * 2 < 256) ? backoff * 2 : 256;
        }
    }
}

static _decl_forceinline void tw2_rw_spinlock_upunlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,(int32_t)-TW2_RW_UPGRADED,memory_order_acq_rel);
}

static _decl_forceinline bool tw2_rw_spinlock_tryuplock(tw2_rw_spinlock_t* pHandle)
{
    return _tw2_tryuplock(pHandle);
}

static _decl_forceinline void tw2_rw_spinlock_upunlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    uint32_t backoff = 1;
    while (_unlikely(!_tw2_tryupunlock_wrlock(pHandle))) 
    {
        for (uint32_t i = 0; i < backoff; ++i)
        {
            tw2_thread_pause();
        }
        if (++spinCount > 1024) 
        {
            tw2_thread_yield();
            backoff = 1;
        }
        else
        {
            backoff = (backoff * 2 < 256) ? backoff * 2 : 256;
        }
    }
}

static _decl_forceinline void tw2_rw_spinlock_upunlock_rdlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,(int32_t)(TW2_RW_READER - TW2_RW_UPGRADED),memory_order_acq_rel);
}

static _decl_forceinline void tw2_rw_spinlock_wrunlock_uplock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_or_explicit(&pHandle->bits,(int32_t)TW2_RW_UPGRADED, memory_order_acquire);
    atomic_fetch_add_explicit(&pHandle->bits,(int32_t)-TW2_RW_WRITER,memory_order_release);
}

static _decl_forceinline bool tw2_rw_spinlock_tryupunlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    return _tw2_tryupunlock_wrlock(pHandle);
}