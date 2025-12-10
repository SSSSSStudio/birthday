#pragma once

#include "CoreMinimal.h"
#include "Modules/ModuleManager.h"

struct lua_State;

class TLSLIBRARY_API FTlsLibraryModule : public IModuleInterface
{
public:
	static int32 Setup(lua_State* L);
};
