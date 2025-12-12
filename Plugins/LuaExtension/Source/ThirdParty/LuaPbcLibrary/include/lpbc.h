#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef lpbc_EXPORTS
		#define LPBC_API __declspec(dllexport)
	#else
		#define LPBC_API __declspec(dllimport)
	#endif
#else
	#ifdef lpbc_EXPORTS
		#define LPBC_API __attribute__((__visibility__("default")))
	#else
		#define LPBC_API extern
	#endif
#endif

extern "C" 
{
	struct lua_State;

	LPBC_API int32_t luaopen_lpbc(struct lua_State* L);
}
