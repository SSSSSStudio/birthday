// Copyright Epic Games, Inc. All Rights Reserved.

#include "LuaExtension.h"
#include "Misc/MessageDialog.h"
#include "Modules/ModuleManager.h"
#include "Interfaces/IPluginManager.h"
#include "Misc/Paths.h"
#include "HAL/PlatformProcess.h"

#define LOCTEXT_NAMESPACE "FLuaExtensionModule"

void FLuaExtensionModule::StartupModule()
{
	
}

void FLuaExtensionModule::ShutdownModule()
{

}

#undef LOCTEXT_NAMESPACE
	
IMPLEMENT_MODULE(FLuaExtensionModule, LuaExtension)
