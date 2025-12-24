// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "LoadPackageAsync.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FLoadPackageAsyncResult, bool, Result);

UCLASS(BlueprintType)
class G01_API ULoadPackageAsync : public UObject
{
	GENERATED_BODY()
	
public:
	UFUNCTION(BlueprintCallable)
	void LoadPackage(const FString& PackagePath);

	UFUNCTION(BlueprintCallable)
	float GetLoadProgress();

	UPROPERTY()
	FLoadPackageAsyncResult LoadPackageAsyncResult;

private:
	FString LoadPackagePath;

	bool LoadingDone;
};
