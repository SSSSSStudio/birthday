// Fill out your copyright notice in the Description page of Project Settings.


#include "Helper/LoadPackageAsync/LoadPackageAsync.h"

void ULoadPackageAsync::LoadPackage(const FString& PackagePath)
{
	LoadPackagePath = PackagePath;
	LoadingDone = false;
	LoadPackageAsync(
		PackagePath,
		FLoadPackageAsyncDelegate::CreateLambda([=,this](const FName& PackageName, UPackage* LoadedPackage, EAsyncLoadingResult::Type Result)
		{
			if (Result == EAsyncLoadingResult::Failed)
			{
				UE_LOG(LogTemp, Error, TEXT("Load Package Failed"));
				LoadingDone = false;
			}
			if (Result == EAsyncLoadingResult::Succeeded)
			{
				UE_LOG(LogTemp, Error, TEXT("Load Package Succeeded"));
				LoadPackageAsyncResult.Broadcast(true);
				LoadingDone = true;
			}
		}), 0, PKG_ContainsMap
	);
}

float ULoadPackageAsync::GetLoadProgress()
{
	if (LoadingDone)
	{
		return 100;
	}
	else
	{
		if (LoadPackagePath.Len() != 0)
		{
			return GetAsyncLoadPercentage(*LoadPackagePath);
		}
	}

	return 0;
}
