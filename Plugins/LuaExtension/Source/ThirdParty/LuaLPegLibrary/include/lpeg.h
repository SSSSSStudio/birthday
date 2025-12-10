#pragma once

#include <stdint.h>

#if defined(_WINDOWS) || defined(_WIN32)
	#define LPEG_API __declspec(dllimport)
#else
	#define LPEG_API extern
#endif

extern "C" {
	struct lua_State;

	LPEG_API int32_t luaopen_lpeg(struct lua_State *L);
}
