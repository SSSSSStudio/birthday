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

typedef struct tw2_rng_s
{
	uint64_t state[4];
} tw2_rng_t;

tw2_API void tw2_rng_random_seed(tw2_rng_t* pRNG, uint64_t seed/* = 1234567890*/);

tw2_API uint64_t tw2_rng_random(tw2_rng_t* pRNG);

tw2_API uint64_t tw2_rng_random_distribution(tw2_rng_t* pRNG, uint64_t low, uint64_t up);
