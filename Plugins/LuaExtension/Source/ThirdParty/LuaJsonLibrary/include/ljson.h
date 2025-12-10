#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef ljson_EXPORTS
		#define LJSON_API __declspec(dllexport)
	#else
		#define LJSON_API __declspec(dllimport)
	#endif
#else
	#ifdef ljson_EXPORTS
		#define LJSON_API __attribute__((__visibility__("default")))
	#else
		#define LJSON_API extern
	#endif
#endif

extern "C" 
{
	struct lua_State;

	LJSON_API int32_t luaopen_ljson(struct lua_State* L);
}
