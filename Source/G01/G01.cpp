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

#include "ljson.h"
#include "lxml.h"
#include "lpeg.h"

#include "ThirdParty/LuaProjectLibrary/LuaProjectLibraryModule.h"
#include "ThirdParty/LuaTlsLibrary/LuaTlsLibraryModule.h"
#include "ThirdParty/LuaCryptLibrary/LuaCryptLibraryModule.h"

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
		Env.AddBuiltInLoader(TEXT("lproject"),FLuaProjectLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("ltls"),FLuaTlsLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("Lcrypt"),FLuaCryptLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("ljson"),luaopen_ljson);
		Env.AddBuiltInLoader(TEXT("lxml"),luaopen_lxml);
		Env.AddBuiltInLoader(TEXT("lpeg"),luaopen_lpeg);
		
	}

	static void OnLuaEnvDestroyed(UnLua::FLuaEnv& Env) 
	{
		FLuaProjectLibraryModule::EndPlay(Env.GetMainState());
	}
	
	bool Tick(float DeltaTime) const
	{
		if (bIsTicking)
		{
            FLuaProjectLibraryModule::Tick(UnLua::GetState(),DeltaTime);
		}
		return true;
	}
	
private:
	FTickerDelegate TickDelegate;
	FTSTicker::FDelegateHandle TickDelegateHandle;
	bool bIsTicking = false;
};


IMPLEMENT_PRIMARY_GAME_MODULE( FDefaultGameModuleImpl, G01, "G01" );
