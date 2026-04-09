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

#include "utility_tt.h"

typedef enum 
{
	TW2_LOG_LEVEL_INFO,
	TW2_LOG_LEVEL_WARNING,
	TW2_LOG_LEVEL_ERROR,
	TW2_LOG_LEVEL_FATAL
} tw2_log_level_t;

typedef void (*log_custom_print_cb) (tw2_log_level_t e, const char* s);

#ifdef __cplusplus
extern "C" {
#endif

tw2_API void tw2_set_log_stderr(tw2_log_level_t e);

tw2_API void tw2_set_log_dir(const char* dir);

tw2_API void tw2_set_log_custom_print(log_custom_print_cb fn);

tw2_API void tw2_log_print(tw2_log_level_t e, const char* fileName, int32_t line, const char* fmt, ...);

#ifdef __cplusplus
}
#endif

#define tw2_check(__v) do { if (!(__v)) { tw2_log_print(TW2_LOG_LEVEL_FATAL, __FILE__, __LINE__, #__v); } } while(0)

#define tw2_log(__l, __s, ...) tw2_log_print(__l, __FILE__, __LINE__, __s, ##__VA_ARGS__)

#ifdef _DEBUG
#   define tw2_log_d(__l, __s, ...) tw2_log_print(__l, __FILE__, __LINE__, __s, ##__VA_ARGS__)
#else
#   define tw2_log_d(__l, __s, ...) 
#endif