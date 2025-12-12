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
	eLogLevelInfo,
	eLogLevelWarning,
	eLogLevelError,
	eLogLevelFatal
} enLogLevel;

typedef void (*log_custom_print_cb) (enLogLevel e, const char* s);

tw2_API void tw2_set_log_stderr(enLogLevel e);

tw2_API void tw2_set_log_custom_print(log_custom_print_cb fn);

tw2_API void tw2_log_print(enLogLevel e, const char* fileName, int32_t line, const char* fmt, ...);

#define tw2_check(__v) if (!(__v)) { tw2_log_print(eLogLevelFatal,__FILE__, __LINE__, #__v); }

#define tw2_log(__l, __s, ...) tw2_log_print(__l,__FILE__, __LINE__,__s, ##__VA_ARGS__)

#ifdef _DEBUG
#   define tw2_log_d(__l, __s, ...) tw2_log_print(__l,__FILE__, __LINE__,__s, ##__VA_ARGS__)
#else
#   define tw2_log_d(__l, __s, ...) 
#endif
