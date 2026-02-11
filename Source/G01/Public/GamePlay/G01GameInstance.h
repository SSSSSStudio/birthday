// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
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
	
	UFUNCTION(BlueprintImplementableEvent)
	void OnStartPlay();

protected:
	virtual void OnStart() override;
	
private:
	static bool Tick(float DeltaTime);

private:
	FTSTicker::FDelegateHandle TickDelegateHandle;
};
