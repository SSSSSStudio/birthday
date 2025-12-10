
#include "LuaCryptLibraryModule.h"
#include "lcrypt.h"

int32 FLuaCryptLibraryModule::Setup(lua_State* L)
{
	return luaopen_lcrypt(L);
}

IMPLEMENT_MODULE(FLuaCryptLibraryModule, LuaCryptLibrary);
