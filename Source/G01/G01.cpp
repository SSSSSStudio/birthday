// Copyright Epic Games, Inc. All Rights Reserved.

#include "G01.h"
#include "Modules/ModuleManager.h"

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "UnLuaDelegates.h"
#include "LuaCore.h"
#include "UnLua.h"

#include "ThirdParty/ProjectLibrary/ProjectLibraryModule.h"
#include "ThirdParty/TlsLibrary/TlsLibraryModule.h"

class FG01GameModule : public FDefaultGameModuleImpl
{
public:
	virtual void StartupModule() override
	{
		UnLua::FLuaEnv::OnCreated.AddStatic(&FG01GameModule::OnLuaEnvCreated);
		UnLua::FLuaEnv::OnDestroyed.AddStatic(&FG01GameModule::OnLuaEnvDestroyed);
		
		TickDelegate = FTickerDelegate::CreateRaw(this,&FG01GameModule::Tick);
		TickDelegateHandle = FTSTicker::GetCoreTicker().AddTicker(TickDelegate);

		bIsTicking = true;
	}

	virtual void ShutdownModule() override
	{
		bIsTicking = false;
		FTSTicker::GetCoreTicker().RemoveTicker(TickDelegateHandle);
	}

	static void OnLuaEnvCreated(UnLua::FLuaEnv& Env)
	{
		Env.AddBuiltInLoader(TEXT("lproject"),FProjectLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("ltls"),FTlsLibraryModule::Setup);
	}

	static void OnLuaEnvDestroyed(UnLua::FLuaEnv& Env) 
	{
		FProjectLibraryModule::EndPlay(Env.GetMainState());
	}
	
	bool Tick(float DeltaTime) const
	{
		if (bIsTicking)
		{
            FProjectLibraryModule::Tick(UnLua::GetState(),DeltaTime);
		}
		return true;
	}
	
private:
	FTickerDelegate TickDelegate;
	FTSTicker::FDelegateHandle TickDelegateHandle;
	bool bIsTicking = false;
};


IMPLEMENT_PRIMARY_GAME_MODULE( FDefaultGameModuleImpl, G01, "G01" );
