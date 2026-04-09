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

#include "utility_tt.h"
#include "timespec_tt.h"

#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
	#ifndef NOMINMAX
		#define NOMINMAX 1
	#endif
	#include <Windows.h> 
	#include <emmintrin.h> //_mm_pause

	typedef HANDLE				tw2_thread_t;
	typedef CRITICAL_SECTION 	tw2_mutex_t;
	#if _WIN32_WINNT >= 0x0600
		typedef SRWLOCK         tw2_rwlock_t;
	#else
		typedef struct tw2_rwlock_s
		{
			uint32_t 		 readersNum;
			CRITICAL_SECTION readersLock;
			HANDLE 			 hWriteSemaphore;
		} tw2_rwlock_t;
	#endif
	typedef HANDLE 				tw2_sem_t;
  	typedef CONDITION_VARIABLE 	tw2_cond_t;

	typedef struct tw2_once_flag_s 
	{
		HANDLE 	hEvent;
		bool 	bCall;
	} tw2_once_flag_t;

	#define ONCE_FLAG_INIT { NULL, false }
#else
	#if !defined(__MVS__)
		#include <semaphore.h>
		#include <sys/param.h> /* MAXHOSTNAMELEN on Linux and the BSDs */
	#endif
	#include <pthread.h>
	#include <signal.h>
	#if defined(__APPLE__) && defined(__MACH__)
		#include <mach/mach.h>
		#include <mach/task.h>
		#include <mach/semaphore.h>
		#include <TargetConditionals.h>
	#endif 

	typedef pthread_t			tw2_thread_t;
	typedef pthread_mutex_t		tw2_mutex_t;
	typedef pthread_rwlock_t	tw2_rwlock_t;
	#if defined(__APPLE__) && defined(__MACH__)
		typedef semaphore_t 	tw2_sem_t;
	#else
		typedef sem_t 			tw2_sem_t;
	#endif

	typedef pthread_cond_t 		tw2_cond_t;
	typedef pthread_once_t 		tw2_once_flag_t;
	
	#define ONCE_FLAG_INIT PTHREAD_ONCE_INIT
#endif

#ifdef __cplusplus
extern "C" {
#endif

//----------------thread----------------
enum 
{
	TW2_THREAD_SUCCESS	= 0,
	TW2_THREAD_NOMEM	= 1,
	TW2_THREAD_TIMEDOUT	= 2,
	TW2_THREAD_INVALID	= 3,
	TW2_THREAD_ERROR	= 4,
};

typedef void (*thread_cb)(void* pArg);

tw2_API int32_t tw2_thread_start(tw2_thread_t* pHandle, thread_cb cb, void* pArg);

tw2_API int32_t tw2_thread_join(tw2_thread_t handle, int32_t* pCode);

tw2_API int32_t tw2_thread_detach(tw2_thread_t handle);

tw2_API tw2_thread_t tw2_thread_self();

tw2_API uint64_t tw2_thread_id();

tw2_API bool tw2_thread_equal(const tw2_thread_t handle, const tw2_thread_t rhs);

tw2_API void tw2_thread_exit();

tw2_API uint32_t tw2_thread_hardware_concurrency();

tw2_API uint64_t tw2_thread_clock();

static _decl_forceinline void tw2_thread_yield()
{
#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
	SwitchToThread();
#else
	sched_yield();
#endif
}

static _decl_forceinline void tw2_thread_pause()
{
#ifdef _MSC_VER
	_mm_pause();
#elif defined(__clang__) || defined(__GNUC__)
	#if defined(__x86_64__) || defined(__i386__)
		asm volatile ("pause" ::: "memory");
	#elif defined(__arm__) || defined(__aarch64__)
		asm volatile("yield");
	#endif
#else
	tw2_thread_yield();
#endif
}

static _decl_forceinline void tw2_thread_sleep_for(const tw2_timespec_t duration)
{
	tw2_timespec_t zero = {0,0};
	if(tw2_timespec_cmp(duration,zero,<=))
	{
		return;
	}
	tw2_timespec_t now = tw2_clock_monotonic();
	tw2_timespec_t until = tw2_timespec_add(now,duration);
	tw2_timespec_t d = duration;

	do
	{
#if DEF_PLATFORM == DEF_PLATFORM_WINDOWS
		Sleep((unsigned long)tw2_timespec_to_msec(d));
#else
		struct timespec ts = {d.sec,d.nsec};
		nanosleep(&ts,0);
#endif
		d = tw2_timespec_sub(until, tw2_clock_monotonic());
	}
	while (tw2_timespec_cmp(d,zero, >));
}

//----------------call_once----------------
tw2_API void tw2_call_once(tw2_once_flag_t* pFlag, void (*fn)());

//----------------tls----------------
typedef void (*tls_cleanup_cb)(void* pArg);

tw2_API void tw2_set_tls_value(void const* pKey, tls_cleanup_cb cb, void* pTlsData, bool bExitCleanup);

tw2_API void* tw2_get_tls_value(void const* pKey);

//----------------mutex----------------
tw2_API bool tw2_mutex_init(tw2_mutex_t* pMutex);

tw2_API void tw2_mutex_destroy(tw2_mutex_t* pMutex);

tw2_API void tw2_mutex_lock(tw2_mutex_t* pMutex);

tw2_API bool tw2_mutex_trylock(tw2_mutex_t* pMutex);

tw2_API void tw2_mutex_unlock(tw2_mutex_t* pMutex);

//----------------rwlock----------------
tw2_API bool tw2_rwlock_init(tw2_rwlock_t* pRwlock);

tw2_API void tw2_rwlock_destroy(tw2_rwlock_t* pRwlock);

tw2_API void tw2_rwlock_rdlock(tw2_rwlock_t* pRwlock);

tw2_API bool tw2_rwlock_tryrdlock(tw2_rwlock_t* pRwlock);

tw2_API void tw2_rwlock_rdunlock(tw2_rwlock_t* pRwlock);

tw2_API void tw2_rwlock_wrlock(tw2_rwlock_t* pRwlock);

tw2_API bool tw2_rwlock_trywrlock(tw2_rwlock_t* pRwlock);

tw2_API void tw2_rwlock_wrunlock(tw2_rwlock_t* pRwlock);

//----------------semaphore----------------
tw2_API bool tw2_sem_init(tw2_sem_t* pSem, uint32_t v);

tw2_API void tw2_sem_destroy(tw2_sem_t* pSem);

tw2_API void tw2_sem_post(tw2_sem_t* pSem);

tw2_API void tw2_sem_wait(tw2_sem_t* pSem);

tw2_API bool tw2_sem_trywait(tw2_sem_t* pSem);

//----------------cond----------------
tw2_API bool tw2_cond_init(tw2_cond_t* pCond);

tw2_API void tw2_cond_destroy(tw2_cond_t* pCond);

tw2_API void tw2_cond_signal(tw2_cond_t* pCond);

tw2_API void tw2_cond_broadcast(tw2_cond_t* pCond);

tw2_API void tw2_cond_wait(tw2_cond_t* pCond, tw2_mutex_t* pMutex);

tw2_API int32_t tw2_cond_timedwait(tw2_cond_t* pCond, tw2_mutex_t* pMutex, uint64_t timeoutMS);

#ifdef __cplusplus
}
#endif
