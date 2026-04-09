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
using std::atomic_flag;
using std::memory_order_acquire;
using std::memory_order_release;
#else
#include <stdatomic.h>
#endif

#include "thread_tt.h"

typedef struct tw2_spinlock_s
{
    atomic_flag flag;
} tw2_spinlock_t;

static _decl_forceinline void tw2_spinlock_init(tw2_spinlock_t* pHandle)
{
    atomic_flag_clear(&pHandle->flag);
}

static _decl_forceinline void tw2_spinlock_lock(tw2_spinlock_t* pHandle)
{
    uint32_t spinCount = 0;
    uint32_t backoff = 1;
    while (atomic_flag_test_and_set_explicit(&pHandle->flag, memory_order_acquire))
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

static _decl_forceinline void tw2_spinlock_unlock(tw2_spinlock_t* pHandle)
{
    atomic_flag_clear_explicit(&pHandle->flag,memory_order_release);
}

static _decl_forceinline bool tw2_spinlock_trylock(tw2_spinlock_t* pHandle)
{
    return !atomic_flag_test_and_set_explicit(&pHandle->flag,memory_order_acquire);
}