#pragma once

#include <stdint.h>

#if defined(_WINDOWS) || defined(_WIN32)
	#ifdef ltw2_EXPORTS
		#define LTW2_API __declspec(dllexport)
	#else
		#define LTW2_API __declspec(dllimport)
	#endif
#else
	#ifdef ltw2_EXPORTS
		#define LTW2_API __attribute__((__visibility__("default")))
	#else
		#define LTW2_API extern
	#endif
#endif

extern "C" 
{
	struct lua_State;

	LTW2_API int32_t luaopen_ltw2_core(struct lua_State* L);
}
