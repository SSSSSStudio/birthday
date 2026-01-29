// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UnLuaInterface.h"
#include "Engine/GameInstance.h"
#include "G01GameInstance.generated.h"

/**
 * 
 */
UCLASS()
class G01_API UG01GameInstance : public UGameInstance
{
	GENERATED_BODY()

public:
	virtual void Init() override;
	virtual void Shutdown() override;

	static bool Tick(float DeltaTime);
	
	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "OnPreControllerBeginPlay"))
    void OnPreControllerBeginPlay();

	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "OnPostControllerEndPlay"))
    void OnPostControllerEndPlay();

	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "OnAssetSubsystemInitialized"))
	void OnAssetSubsystemInitialized();
	
	DECLARE_MULTICAST_DELEGATE(FOnPreControllerBeginPlay);
	FOnPreControllerBeginPlay PreControllerBeginPlay;

	DECLARE_MULTICAST_DELEGATE(FOnPostControllerEndPlay);
	FOnPostControllerEndPlay PostControllerEndPlay;

	DECLARE_MULTICAST_DELEGATE(FOnAssetSubsystemInitialized);
	FOnAssetSubsystemInitialized AssetSubsystemInitialized;
	
private:
	FTSTicker::FDelegateHandle TickDelegateHandle;
};
