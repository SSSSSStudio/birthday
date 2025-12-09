#pragma once

#include "CoreMinimal.h"
#include "Modules/ModuleManager.h"

struct lua_State;

class PROJECTLIBRARY_API FProjectLibraryModule : public IModuleInterface
{
public:
	static int32 Setup(lua_State* L);

	static bool Tick(lua_State *L,float DeltaTime);

	static bool EndPlay(lua_State *L);
};
