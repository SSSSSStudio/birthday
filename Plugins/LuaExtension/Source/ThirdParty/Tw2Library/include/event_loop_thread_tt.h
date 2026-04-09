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

#include "event_loop_tt.h"

struct tw2_event_loop_thread_s;

typedef struct tw2_event_loop_thread_s tw2_event_loop_thread_t;

#ifdef __cplusplus
extern "C" {
#endif

tw2_API tw2_event_loop_thread_t* tw2_event_loop_thread_new(tw2_event_loop_t* pEventLoop);

tw2_API void tw2_event_loop_thread_addref(tw2_event_loop_thread_t* pHandle);

tw2_API void tw2_event_loop_thread_release(tw2_event_loop_thread_t* pHandle);

tw2_API bool tw2_event_loop_thread_start(tw2_event_loop_thread_t* pHandle, bool bWaitThreadStarted, bool (*pre)(tw2_event_loop_thread_t*), void (*post)(tw2_event_loop_thread_t*));

tw2_API void tw2_event_loop_thread_stop(tw2_event_loop_thread_t* pHandle, bool bWaitThreadExit);

tw2_API void tw2_event_loop_thread_join(tw2_event_loop_thread_t* pHandle);

tw2_API bool tw2_event_loop_thread_is_running(tw2_event_loop_thread_t* pHandle);

tw2_API bool tw2_event_loop_thread_is_stopped(tw2_event_loop_thread_t* pHandle);

tw2_API bool tw2_event_loop_thread_is_stopping(tw2_event_loop_thread_t* pHandle);

tw2_API tw2_event_loop_t* tw2_event_loop_thread_get_event_loop(tw2_event_loop_thread_t* pHandle);

#ifdef __cplusplus
}
#endif