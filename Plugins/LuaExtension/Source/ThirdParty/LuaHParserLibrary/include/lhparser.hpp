#pragma once

#include <stdint.h>

#if defined(_WIN32) || defined(_WINDOWS)
	#ifdef lhparser_EXPORTS
		#define LHPARSER_API __declspec(dllexport)
	#else
		#define LHPARSER_API __declspec(dllimport)
	#endif
#else
	#ifdef lhparser_EXPORTS
		#define LHPARSER_API __attribute__((__visibility__("default")))
	#else
		#define LHPARSER_API extern
	#endif
#endif

extern "C" 
{
	struct lua_State;
	
	LHPARSER_API int32_t luaopen_lhparser(struct lua_State* L);
}

