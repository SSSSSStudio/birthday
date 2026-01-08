// Fill out your copyright notice in the Description page of Project Settings.


#include "GamePlay/G01GameInstance.h"
#include "UnLua.h"

#include "ThirdParty/LuaProjectLibrary/LuaProjectLibraryModule.h"

void UG01GameInstance::Init()
{
	Super::Init();
	
	TickDelegateHandle = FTSTicker::GetCoreTicker().AddTicker(FTickerDelegate::CreateStatic(&UG01GameInstance::Tick));
	
	UGameViewportClient::OnViewportCreated().AddUObject(this, &UG01GameInstance::OnViewportCreated);
}

void UG01GameInstance::Shutdown()
{
	FTSTicker::GetCoreTicker().RemoveTicker(TickDelegateHandle);
	Super::Shutdown();
}

bool UG01GameInstance::Tick(float DeltaTime)
{
	lua_State* L = UnLua::GetState();
	if (L)
	{
		FLuaProjectLibraryModule::Tick(L,DeltaTime);
	}
	return true;
}

// void UG01GameInstance::OnViewportCreated()
// {
// 	UE_LOG(LogTemp, Warning, TEXT("OnViewportCreated"));
// }
