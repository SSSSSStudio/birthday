
#include "LuaTlsLibraryModule.h"
#include "ltls.h"

int32 FLuaTlsLibraryModule::Setup(lua_State* L)
{
	return luaopen_ltls(L);
}

IMPLEMENT_MODULE(FLuaTlsLibraryModule, LuaTlsLibrary);
