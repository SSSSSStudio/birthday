#pragma once

#include "CoreMinimal.h"
#include "Modules/ModuleManager.h"

struct lua_State;

class LUAPROJECTLIBRARY_API FLuaProjectLibraryModule : public IModuleInterface
{
public:
	static int32 Setup(lua_State* L);

	static bool Tick(lua_State *L,float DeltaTime);
};
