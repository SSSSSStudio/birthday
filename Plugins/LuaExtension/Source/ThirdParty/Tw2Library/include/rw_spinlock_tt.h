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

#include <stdatomic.h>

#include "utility_tt.h"
#include "thread_tt.h"

enum 
{
    RW_WRITER = 1,
    RW_UPGRADED = 2, 
    RW_READER = 4
};

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

static _decl_forceinline void t2_rw_spinlock_wrunlock_rdlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upLock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upunLock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline bool tw2_rw_spinlock_tryuplock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upunlock_wrlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_upunlock_rdlock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline void tw2_rw_spinlock_wrunlock_uplock(tw2_rw_spinlock_t* pHandle);

static _decl_forceinline bool tw2_rw_spinlock_tryupunlock_wrlock(tw2_rw_spinlock_t* pHandle);

//internal
static _decl_forceinline bool tryrdlock(tw2_rw_spinlock_t* pHandle)
{
    int32_t v = atomic_fetch_add_explicit(&pHandle->bits,RW_READER,memory_order_acquire);
    if (_unlikely(v & (RW_WRITER | RW_UPGRADED))) 
    {
        atomic_fetch_add_explicit(&pHandle->bits,-RW_READER,memory_order_release);
        return false;
    }
    return true;
}

static _decl_forceinline bool tryuplock(tw2_rw_spinlock_t* pHandle) 
{
    int32_t v = atomic_fetch_or_explicit(&pHandle->bits,RW_UPGRADED, memory_order_acquire);
    return ((v& (RW_UPGRADED | RW_WRITER)) == 0);
}

static _decl_forceinline bool trywrlock(tw2_rw_spinlock_t* pHandle)
{
    int32_t expect = 0;
    return atomic_compare_exchange_strong_explicit(&pHandle->bits,&expect,RW_WRITER,memory_order_acq_rel,memory_order_relaxed);
} 

static _decl_forceinline bool tryupunlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    int32_t expect = RW_UPGRADED;
    return atomic_compare_exchange_strong_explicit(&pHandle->bits,&expect,RW_WRITER,memory_order_acq_rel,memory_order_relaxed);
}

//---------------------------------------------------------------------------------------------------------------------------------

static _decl_forceinline void tw2_rw_spinlock_init(tw2_rw_spinlock_t* pHandle)
{
    atomic_init(&pHandle->bits,0);
}

static _decl_forceinline void tw2_rw_spinlock_rdlock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    while (!_likely(tryrdlock(pHandle))) 
    {
        if (++spinCount > 1024) 
        {
            tw2_thread_yield();
        }
    }
}

static _decl_forceinline bool tw2_rw_spinlock_tryrdlock(tw2_rw_spinlock_t* pHandle)
{
    return tryrdlock(pHandle);
}

static _decl_forceinline void tw2_rw_spinlock_rdunlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,-RW_READER,memory_order_release);
}

static _decl_forceinline void tw2_rw_spinlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    while (!_likely(trywrlock(pHandle)))
    {
        if (++spinCount > 1024)
        {
            tw2_thread_yield();
        }
    }
}

static _decl_forceinline bool tw2_rw_spinlock_trywrlock(tw2_rw_spinlock_t* pHandle)
{
    return trywrlock(pHandle);
}

static _decl_forceinline void tw2_rw_spinlock_wrunlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_and_explicit(&pHandle->bits,~(RW_WRITER | RW_UPGRADED),memory_order_release);
}

static _decl_forceinline void tw2_rw_spinlock_wrunlock_rdlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,RW_READER,memory_order_acquire);
    atomic_fetch_and_explicit(&pHandle->bits,~(RW_WRITER | RW_UPGRADED),memory_order_release);
}

static _decl_forceinline void tw2_rw_spinlock_upLock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    while (!tryuplock(pHandle)) 
    {
        if (++spinCount > 1024) 
        {
            tw2_thread_yield();
        }
    }
}

static _decl_forceinline void tw2_rw_spinlock_upunLock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits,-RW_UPGRADED,memory_order_acq_rel);
}

static _decl_forceinline bool tw2_rw_spinlock_tryuplock(tw2_rw_spinlock_t* pHandle)
{
    return tryuplock(pHandle);
}

static _decl_forceinline void tw2_rw_spinlock_upunlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    while (!tryupunlock_wrlock(pHandle)) 
    {
        if (++spinCount > 1024) 
        {
            tw2_thread_yield();
        }
    }
}

static _decl_forceinline void tw2_rw_spinlock_upunlock_rdlock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_add_explicit(&pHandle->bits, RW_READER - RW_UPGRADED,memory_order_acq_rel);
}

static _decl_forceinline void tw2_rw_spinlock_wrunlock_uplock(tw2_rw_spinlock_t* pHandle)
{
    atomic_fetch_or_explicit(&pHandle->bits,RW_UPGRADED, memory_order_acquire);
    atomic_fetch_add_explicit(&pHandle->bits, -RW_WRITER,memory_order_release);
}

static _decl_forceinline bool tw2_rw_spinlock_tryupunlock_wrlock(tw2_rw_spinlock_t* pHandle)
{
    return tryupunlock_wrlock(pHandle);
}