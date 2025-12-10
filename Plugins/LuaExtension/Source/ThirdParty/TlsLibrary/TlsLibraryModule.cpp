
#include "TlsLibraryModule.h"
#include "ltls.h"

int32 FTlsLibraryModule::Setup(lua_State* L)
{
	return luaopen_ltls(L);
}

IMPLEMENT_MODULE(FTlsLibraryModule, TlsLibrary);
