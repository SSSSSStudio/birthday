#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef lmsgpack_EXPORTS
		#define LMSGPACK_API __declspec(dllexport)
	#else
		#define LMSGPACK_API __declspec(dllimport)
	#endif
#else
	#ifdef lmsgpack_EXPORTS
		#define LMSGPACK_API __attribute__((__visibility__("default")))
	#else
		#define LMSGPACK_API extern
	#endif
#endif

extern "C" 
{
	struct lua_State;

	LMSGPACK_API int32_t luaopen_lmsgpack(struct lua_State* L);
}
