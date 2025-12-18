
#include "LuaProjectLibraryModule.h"
#include "lproject.h"

int32 FLuaProjectLibraryModule::Setup(lua_State* L)
{
	return luaopen_lproject(L);
}

bool FLuaProjectLibraryModule::Tick(lua_State *L,float DeltaTime)
{
	return lproject_tick(L,DeltaTime);
}

IMPLEMENT_MODULE(FLuaProjectLibraryModule, LuaProjectLibrary);
