#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef lfixed_EXPORTS
		#define LFIXED_API __declspec(dllexport)
	#else
		#define LFIXED_API __declspec(dllimport)
	#endif
#else
	#ifdef lfixed_EXPORTS
		#define LFIXED_API __attribute__((__visibility__("default")))
	#else
		#define LFIXED_API extern
	#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct lua_State;

LFIXED_API int32_t luaopen_lfixed(struct lua_State* L);

#ifdef __cplusplus
}
#endif
