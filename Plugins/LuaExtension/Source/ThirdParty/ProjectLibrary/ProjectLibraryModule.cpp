
#include "ProjectLibraryModule.h"
#include "lproject.h"

int32 FProjectLibraryModule::Setup(lua_State* L)
{
	return luaopen_lproject(L);
}

bool FProjectLibraryModule::Tick(lua_State *L,float DeltaTime)
{
	return lproject_tick(L,DeltaTime);
}

bool FProjectLibraryModule::EndPlay(lua_State *L)
{
	return lproject_endplay(L);
}

IMPLEMENT_MODULE(FProjectLibraryModule, ProjectLibrary);
