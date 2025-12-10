#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef lxml_EXPORTS
		#define LXML_API __declspec(dllexport)
	#else
		#define LXML_API __declspec(dllimport)
	#endif
#else
	#ifdef lxml_EXPORTS
		#define LXML_API __attribute__((__visibility__("default")))
	#else
		#define LXML_API extern
	#endif
#endif

extern "C" 
{
	struct lua_State;

	LXML_API int32_t luaopen_lxml(struct lua_State* L);
}
