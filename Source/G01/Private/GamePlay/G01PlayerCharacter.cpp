// Fill out your copyright notice in the Description page of Project Settings.


#include "GamePlay/G01PlayerCharacter.h"

// Sets default values
AG01PlayerCharacter::AG01PlayerCharacter()
{
 	// Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = false;

}

// Called when the game starts or when spawned
void AG01PlayerCharacter::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void AG01PlayerCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

// Called to bind functionality to input
void AG01PlayerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

}

