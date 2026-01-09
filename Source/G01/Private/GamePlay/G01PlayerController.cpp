// Fill out your copyright notice in the Description page of Project Settings.


#include "GamePlay/G01PlayerController.h"
#include "GamePlay/G01GameInstance.h"

void AG01PlayerController::BeginPlay()
{
	UG01GameInstance* GameInstance = Cast<UG01GameInstance>(GetGameInstance());
	if (GameInstance)    {
		GameInstance->PreControllerBeginPlay.Broadcast();
    }
	Super::BeginPlay();
}
