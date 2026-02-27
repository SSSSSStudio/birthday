#pragma once

#if defined(_WINDOWS) || defined(_WIN32)
	#define LPEG_API __declspec(dllimport)
#else
	#define LPEG_API extern
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct lua_State;

LPEG_API int luaopen_lpeg(struct lua_State *L);

#ifdef __cplusplus
}
#endif
