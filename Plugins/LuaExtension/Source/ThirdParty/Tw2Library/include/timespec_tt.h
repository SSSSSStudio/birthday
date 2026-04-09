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

typedef struct tw2_timespec_s
{
	int64_t	sec;
	int32_t	nsec;
} tw2_timespec_t;

#define	tw2_timespec_reset(pTs) ((pTs)->sec = 0, (pTs)->nsec = 0)

#define	tw2_timespec_cmp(ts, rhs, cmp) (((ts).sec == (rhs).sec) ? ((ts).nsec cmp (rhs).nsec) : ((ts).sec cmp (rhs).sec))

static _decl_forceinline tw2_timespec_t tw2_timespec_add(const tw2_timespec_t ts, const tw2_timespec_t rhs)
{
	tw2_timespec_t rc = {ts.sec + rhs.sec, ts.nsec + rhs.nsec};

	if (rc.nsec >= 1000000000)
	{
		++rc.sec;
		rc.nsec -= 1000000000;
	}
	return rc;
}

static _decl_forceinline tw2_timespec_t tw2_timespec_sub(const tw2_timespec_t ts, const tw2_timespec_t rhs)
{
	tw2_timespec_t rc = {ts.sec - rhs.sec, ts.nsec - rhs.nsec};
	
	if (rc.nsec < 0)
	{
		--rc.sec;
		rc.nsec += 1000000000;
	}
	return rc;
}

static _decl_forceinline bool tw2_timespec_empty(const tw2_timespec_t ts)
{
	return (ts.sec == 0) && (ts.nsec ==0);
}

static _decl_forceinline int64_t tw2_timespec_to_msec(const tw2_timespec_t ts)
{
	return (int64_t)ts.sec * 1000 + (ts.nsec + 999999)/1000000;
}

static _decl_forceinline int64_t tw2_timespec_to_nsec(const tw2_timespec_t ts)
{
	return (int64_t)ts.sec * 1000000000 + ts.nsec;
}

static _decl_forceinline int64_t tw2_timespec_add_to_nsec(const tw2_timespec_t ts, const tw2_timespec_t rhs)
{
	return tw2_timespec_to_nsec(tw2_timespec_add(ts,rhs));
}

static _decl_forceinline int64_t tw2_timespec_sub_to_nsec(const tw2_timespec_t ts, const tw2_timespec_t rhs)
{
	return tw2_timespec_to_nsec(tw2_timespec_sub(ts,rhs));
}

static _decl_forceinline int64_t tw2_timespec_add_to_msec(const tw2_timespec_t ts, const tw2_timespec_t rhs)
{
	return tw2_timespec_to_msec(tw2_timespec_add(ts,rhs));
}

static _decl_forceinline int64_t tw2_timespec_sub_to_msec(const tw2_timespec_t ts, const tw2_timespec_t rhs)
{
	return tw2_timespec_to_msec(tw2_timespec_sub(ts,rhs));
}

static _decl_forceinline tw2_timespec_t tw2_nsec_to_timespec(const int64_t ns)
{
	int64_t s = ns / 1000000000;
	tw2_timespec_t rc = {s,(int32_t)(ns - s * 1000000000)};
	return rc;
}

static _decl_forceinline tw2_timespec_t tw2_msec_to_timespec(const int64_t ms)
{
	int64_t s = ms / 1000;
	tw2_timespec_t rc = {s,(int32_t)((ms - s * 1000) * 1000000)};
	return rc;
}

#ifdef __cplusplus
extern "C" {
#endif

tw2_API tw2_timespec_t tw2_clock_realtime();

tw2_API tw2_timespec_t tw2_clock_monotonic();

#ifdef __cplusplus
}
#endif