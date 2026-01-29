// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/StreamableManager.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "AssetSubsystem.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnAssetLoaded, const FString&, AssetPath, bool, bSuccess);

UCLASS()
class G01_API UAssetSubsystem : public UGameInstanceSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;

	virtual void Deinitialize() override;

	UFUNCTION(BlueprintCallable, Category = "Asset")
	void RequestAsyncLoadAsset(const FString& AssetPath, bool bCacheAsset = true);

	UFUNCTION(BlueprintCallable, Category = "Asset")
	void ClearAllCachedAssets();

	UFUNCTION(BlueprintCallable, Category = "Asset")
	void ClearCachedAsset(const FString& AssetPath);

	UFUNCTION(BlueprintCallable, Category = "Asset")
	bool IsAssetCached(const FString& AssetPath) const;

	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	UObject* GetCachedAsset(const FString& AssetPath) const;

	UPROPERTY(BlueprintAssignable, Category = "Asset")
	FOnAssetLoaded OnAssetLoaded;

private:
	void OnAsyncLoadCompleted(const FString& AssetPath, bool bCacheAsset);

	TMap<FString, TSharedPtr<FStreamableHandle>> LoadingAssets;
	
	UPROPERTY()
	TMap<FString, TSoftObjectPtr<UObject>> CachedAssets;
};