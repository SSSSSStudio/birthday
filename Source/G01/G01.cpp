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
#include "lpbc.h"
#include "lcore.h"
#include "levent.h"

#include "lmsgpack.h"
#include "lwsproto.h"
#include "lhparser.h"
#include "lfixed.h"

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
	}

	virtual void ShutdownModule() override
	{
	}

	static void OnLuaEnvCreated(UnLua::FLuaEnv& Env)
	{
		Env.AddBuiltInLoader(TEXT("lproject"),FLuaProjectLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("ltls"),FLuaTlsLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("Lcrypt"),FLuaCryptLibraryModule::Setup);
		Env.AddBuiltInLoader(TEXT("ljson"),luaopen_ljson);
		Env.AddBuiltInLoader(TEXT("lxml"),luaopen_lxml);
		Env.AddBuiltInLoader(TEXT("lpeg"),luaopen_lpeg);
		Env.AddBuiltInLoader(TEXT("lpbc"),luaopen_lpbc);
		Env.AddBuiltInLoader(TEXT("lfixed"),luaopen_lfixed);
		Env.AddBuiltInLoader(TEXT("lmsgpack"),luaopen_lmsgpack);
		Env.AddBuiltInLoader(TEXT("lwsproto"),luaopen_lwsproto);
		Env.AddBuiltInLoader(TEXT("lhparser"),luaopen_lhparser);
		Env.AddBuiltInLoader(TEXT("ltw2.core"),luaopen_ltw2_core);
		Env.AddBuiltInLoader(TEXT("ltw2.event"),luaopen_ltw2_event);
	}

	static void OnLuaEnvDestroyed(UnLua::FLuaEnv& Env) 
	{
	}
};


IMPLEMENT_PRIMARY_GAME_MODULE( FG01GameModule, G01, "G01" );
