// Fill out your copyright notice in the Description page of Project Settings.


#include "GamePlay/G01GameModeBase.h"

void AG01GameModeBase::StartPlay()
{
	Super::StartPlay();
	OnStartPlay();
}

