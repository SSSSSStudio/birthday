// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "G01PlayerController.generated.h"

/**
 * 
 */
UCLASS()
class AG01PlayerController : public APlayerController
{
	GENERATED_BODY()
	
	virtual void BeginPlay() override;

	virtual void EndPlay(const EEndPlayReason::Type EndPlayReason) override;
};
