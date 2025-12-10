
#include "CryptLibraryModule.h"
#include "lcrypt.h"

int32 FCryptLibraryModule::Setup(lua_State* L)
{
	return luaopen_lcrypt(L);
}

IMPLEMENT_MODULE(FCryptLibraryModule, CryptLibrary);
