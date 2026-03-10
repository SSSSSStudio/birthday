#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef lwsproto_EXPORTS
		#define LWSPROTO_API __declspec(dllexport)
	#else
		#define LWSPROTO_API __declspec(dllimport)
	#endif
#else
	#ifdef lwsproto_EXPORTS
		#define LWSPROTO_API __attribute__((__visibility__("default")))
	#else
		#define LWSPROTO_API extern
	#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct lua_State;

LWSPROTO_API int32_t luaopen_lwsproto(struct lua_State* L);

#ifdef __cplusplus
}
#endif
