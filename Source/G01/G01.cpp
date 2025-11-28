// Copyright Epic Games, Inc. All Rights Reserved.

#include "G01.h"
#include "Modules/ModuleManager.h"


class FG01GameModule : public FDefaultGameModuleImpl
{
public:
	virtual void StartupModule() override
	{
		TickDelegate = FTickerDelegate::CreateRaw(this,&FG01GameModule::Tick);
		TickDelegateHandle = FTSTicker::GetCoreTicker().AddTicker(TickDelegate);

		bIsTicking = true;
	}

	virtual void ShutdownModule() override
	{
		bIsTicking = false;
		FTSTicker::GetCoreTicker().RemoveTicker(TickDelegateHandle);
	}

	bool Tick(float DeltaTime)
	{
		if (bIsTicking)
		{
		}
		return true;
	}
	
private:
	FTickerDelegate TickDelegate;
	FTSTicker::FDelegateHandle TickDelegateHandle;
	bool bIsTicking = false;
};


IMPLEMENT_PRIMARY_GAME_MODULE( FDefaultGameModuleImpl, G01, "G01" );
