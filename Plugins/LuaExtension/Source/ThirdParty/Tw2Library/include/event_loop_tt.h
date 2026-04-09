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

#include "utility_tt.h"
#include "address_tt.h"
#include "ringbuf_tt.h"
#include "async_tt.h"

struct tw2_timer_s;
struct tw2_listener_s;
struct tw2_watcher_s;
struct tw2_asyncbuf_s;
struct tw2_connection_s;

typedef struct tw2_timer_s tw2_timer_t;
typedef struct tw2_listener_s tw2_listener_t;
typedef struct tw2_watcher_s tw2_watcher_t;
typedef struct tw2_asyncbuf_s tw2_asyncbuf_t;
typedef struct tw2_connection_s tw2_connection_t;

struct tw2_event_loop_s;

typedef struct tw2_event_loop_s tw2_event_loop_t;

#ifdef __cplusplus
extern "C" {
#endif

tw2_API tw2_event_loop_t* tw2_event_loop_new();

tw2_API void tw2_event_loop_addref(tw2_event_loop_t* pHandle);

tw2_API void tw2_event_loop_release(tw2_event_loop_t* pHandle);

tw2_API void tw2_event_loop_set_concurrent_threads(tw2_event_loop_t* pHandle, uint32_t concurrentThreads);

tw2_API uint32_t tw2_event_loop_get_concurrent_threads(tw2_event_loop_t* pHandle);

tw2_API bool tw2_event_loop_start(tw2_event_loop_t* pHandle);

tw2_API void tw2_event_loop_stop(tw2_event_loop_t* pHandle);

tw2_API void tw2_event_loop_dispatch(tw2_event_loop_t* pHandle);

tw2_API bool tw2_event_loop_is_inloop_thread(tw2_event_loop_t* pHandle);

tw2_API void tw2_event_loop_run_inloop(tw2_event_loop_t* pHandle, tw2_async_t* pAsync, void (*work)(tw2_async_t*), void (*cancel)(tw2_async_t*));

tw2_API void tw2_event_loop_queue_inloop(tw2_event_loop_t* pHandle, tw2_async_t* pAsync, void (*work)(tw2_async_t*), void (*cancel)(tw2_async_t*));

tw2_API int32_t tw2_event_loop_idle_threads(tw2_event_loop_t* pHandle);

//tw2_timer_t
tw2_API tw2_timer_t* tw2_timer_new(tw2_event_loop_t* pEventLoop, void (*fn)(tw2_timer_t*,void*), bool bOnce, uint32_t intervalMS, void* pUserData);

tw2_API void tw2_timer_set_stop_cb(tw2_timer_t* pHandle, void (*fn)(tw2_timer_t*,void*));

tw2_API void tw2_timer_addref(tw2_timer_t* pHandle);

tw2_API void tw2_timer_release(tw2_timer_t* pHandle);

tw2_API bool tw2_timer_start(tw2_timer_t* pHandle);

tw2_API void tw2_timer_stop(tw2_timer_t* pHandle);

tw2_API bool tw2_timer_is_once(tw2_timer_t* pHandle);

tw2_API bool tw2_timer_is_running(tw2_timer_t* pHandle);

//tw2_listener_t
tw2_API tw2_listener_t* tw2_listener_new(tw2_event_loop_t* pEventLoop, const tw2_address_t* pListenAddr, bool bStream);

tw2_API void tw2_listener_set_accept_cb(tw2_listener_t* pHandle, void (*fn)(const tw2_listener_t*,tw2_connection_t*,const char*,uint32_t,void*));

tw2_API void tw2_listener_set_accept_filter_cb(tw2_listener_t* pHandle, bool (*fn)(const tw2_listener_t*,const tw2_address_t*,const char*,uint32_t,void*));

tw2_API void tw2_listener_addref(tw2_listener_t* pHandle);

tw2_API void tw2_listener_release(tw2_listener_t* pHandle);

tw2_API bool tw2_listener_start(tw2_listener_t* pHandle,void* pUserData, void(*userFree)(void*));

tw2_API void tw2_listener_stop(tw2_listener_t* pHandle);

tw2_API bool tw2_listener_post_accept(tw2_listener_t* pHandle);

//tw2_watcher_t
tw2_API tw2_watcher_t* tw2_watcher_new(tw2_event_loop_t* pEventLoop, bool bManualReset, void (*fn)(tw2_watcher_t*,void*), void* pUserData, void(*userFree)(void*));

tw2_API void tw2_watcher_addref(tw2_watcher_t* pHandle);

tw2_API void tw2_watcher_release(tw2_watcher_t* pHandle);

tw2_API bool tw2_watcher_start(tw2_watcher_t* pHandle);

tw2_API void tw2_watcher_stop(tw2_watcher_t* pHandle);

tw2_API bool tw2_watcher_is_running(tw2_watcher_t* pHandle);

tw2_API bool tw2_watcher_notify(tw2_watcher_t* pHandle);

tw2_API void tw2_watcher_reset(tw2_watcher_t* pHandle);

//tw2_asyncbuf_t
tw2_API tw2_asyncbuf_t* tw2_asyncbuf_new(const char* pBuffer, int32_t length, void (*fn)(tw2_connection_t*,void*,bool,uintptr_t), uintptr_t writeUser);

tw2_API tw2_asyncbuf_t* tw2_asyncbuf_new_move(tw2_iovec_t* pBufVec, int32_t count, void (*fn)(tw2_connection_t*,void*,bool,uintptr_t), uintptr_t writeUser);

tw2_API void tw2_asyncbuf_release(tw2_asyncbuf_t* pHandle);

//tw2_connection_t
tw2_API tw2_connection_t* tw2_connection_new(tw2_event_loop_t* pEventLoop, const tw2_address_t* pRemoteAddr, bool bStream);

tw2_API void tw2_connection_set_connector_cb(tw2_connection_t* pHandle, void (*fn)(tw2_connection_t*,void*));

tw2_API void tw2_connection_set_receive_cb(tw2_connection_t* pHandle, bool (*fn)(tw2_connection_t*,tw2_ringbuf_t*,void*));

tw2_API void tw2_connection_set_disconnect_cb(tw2_connection_t* pHandle, void (*fn)(tw2_connection_t*,void*));

tw2_API void tw2_connection_set_close_cb(tw2_connection_t* pHandle, void (*fn)(tw2_connection_t*,void*));

tw2_API void tw2_connection_addref(tw2_connection_t* pHandle);

tw2_API void tw2_connection_release(tw2_connection_t* pHandle);

tw2_API bool tw2_connection_bind(tw2_connection_t* pHandle, bool bKeepAlive, bool bTcpNoDelay, void* pUserData, void(*userFree)(void*));

tw2_API bool tw2_connection_connect(tw2_connection_t* pHandle, void* pUserData, void(*userFree)(void*));

tw2_API void tw2_connection_close(tw2_connection_t* pHandle);

tw2_API void tw2_connection_forceclose(tw2_connection_t* pHandle);

tw2_API void tw2_connection_get_remote_address(tw2_connection_t* pHandle, tw2_address_t* pRemoteAddr);

tw2_API void tw2_connection_get_local_address(tw2_connection_t* pHandle, tw2_address_t* pLocalAddr);

tw2_API bool tw2_connection_is_connected(tw2_connection_t* pHandle);

tw2_API bool tw2_connection_is_connecting(tw2_connection_t* pHandle);

tw2_API bool tw2_connection_is_stream(tw2_connection_t* pHandle);

tw2_API int32_t tw2_connection_send(tw2_connection_t* pHandle, tw2_asyncbuf_t* pBuf);

tw2_API int32_t tw2_connection_get_write_pending_count(tw2_connection_t* pHandle);

tw2_API size_t tw2_connection_get_write_pending_bytes(tw2_connection_t* pHandle);

tw2_API size_t tw2_connection_get_receive_capacity(tw2_connection_t* pHandle);

#ifdef __cplusplus
}
#endif