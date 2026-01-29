// Fill out your copyright notice in the Description page of Project Settings.

#include "Subsystems/AssetSubsystem.h"
#include "Engine/AssetManager.h"
#include "GamePlay/G01GameInstance.h"

void UAssetSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
	Super::Initialize(Collection);
	UG01GameInstance* GameInstance = Cast<UG01GameInstance>(GetGameInstance());
	if (GameInstance)    {
		GameInstance->AssetSubsystemInitialized.Broadcast();
	}
}

void UAssetSubsystem::Deinitialize()
{
	ClearAllCachedAssets();
	Super::Deinitialize();
}

void UAssetSubsystem::RequestAsyncLoadAsset(const FString& AssetPath, bool bCacheAsset)
{
	if (AssetPath.IsEmpty())
	{
		UE_LOG(LogTemp, Error, TEXT("RequestAsyncLoadAsset: AssetPath is empty"));
		OnAssetLoaded.Broadcast(AssetPath, false);
		return;
	}

	if (LoadingAssets.Contains(AssetPath))
	{
		UE_LOG(LogTemp, Warning, TEXT("RequestAsyncLoadAsset: Asset is already loading - %s"), *AssetPath);
		return;
	}

	if (CachedAssets.Contains(AssetPath))
	{
		UE_LOG(LogTemp, Log, TEXT("RequestAsyncLoadAsset: Asset already cached - %s"), *AssetPath);
		OnAssetLoaded.Broadcast(AssetPath, true);
		return;
	}

	FSoftObjectPath AssetPathObj(AssetPath);
	TSoftObjectPtr<UObject> SoftAsset(AssetPathObj);
	if (SoftAsset.IsNull())
	{
		UE_LOG(LogTemp, Error, TEXT("RequestAsyncLoadAsset: Invalid asset path - %s"), *AssetPath);
		LoadingAssets.Remove(AssetPath);
		OnAssetLoaded.Broadcast(AssetPath, false);
		return;
	}
	
	FStreamableManager& StreamableManager = UAssetManager::Get().GetStreamableManager();
	TSharedPtr<FStreamableHandle> StreamableHandle = StreamableManager.RequestAsyncLoad(
		SoftAsset.ToSoftObjectPath(),
		FStreamableDelegate::CreateLambda([this, AssetPath, bCacheAsset]()
		{
			this->OnAsyncLoadCompleted(AssetPath, bCacheAsset);
		})
	,FStreamableManager::DefaultAsyncLoadPriority, true,true);
	LoadingAssets.Add(AssetPath, StreamableHandle);
	StreamableHandle->StartStalledHandle();

	UE_LOG(LogTemp, Log, TEXT("RequestAsyncLoadAsset: Started loading - %s"), *AssetPath);
}

void UAssetSubsystem::OnAsyncLoadCompleted(const FString& AssetPath, bool bCacheAsset)
{
	LoadingAssets.Remove(AssetPath);
	FSoftObjectPath AssetPathObj(AssetPath);
	TSoftObjectPtr<UObject> SoftAsset(AssetPathObj);
	bool bSuccess = SoftAsset.IsValid() && SoftAsset.Get() != nullptr;
	if (!bSuccess)
	{
		UE_LOG(LogTemp, Error, TEXT("OnAsyncLoadCompleted: Failed to load asset - %s"), *AssetPath);
		OnAssetLoaded.Broadcast(AssetPath, false);
		return;
	}

	UE_LOG(LogTemp, Log, TEXT("OnAsyncLoadCompleted: Successfully loaded asset - %s"), *AssetPath);

	if (bCacheAsset)
	{
		CachedAssets.Add(AssetPath, SoftAsset);
		UE_LOG(LogTemp, Log, TEXT("OnAsyncLoadCompleted: Asset cached - %s"), *AssetPath);
	}

	OnAssetLoaded.Broadcast(AssetPath, true);
}

void UAssetSubsystem::ClearCachedAsset(const FString& AssetPath)
{
	if (const TSharedPtr<FStreamableHandle>* FoundAsset = LoadingAssets.Find(AssetPath))
	{
		if (FoundAsset->IsValid())
		{
			FoundAsset->Get()->CancelHandle();
		}
		LoadingAssets.Remove(AssetPath);
	}
	
	if (CachedAssets.Contains(AssetPath))
	{
		CachedAssets.Remove(AssetPath);
	}
}

void UAssetSubsystem::ClearAllCachedAssets()
{
	if (LoadingAssets.Num() > 0)
    {
		for (auto It = LoadingAssets.CreateIterator(); It; ++It)
        {
	        if (It.Value().IsValid())
	        {
				It.Value()->CancelHandle();
	        }
        }
		LoadingAssets.Empty();
    }
	
	if (CachedAssets.Num() > 0)
	{
		UE_LOG(LogTemp, Log, TEXT("ClearAllCachedAssets: Clearing %d cached assets"), CachedAssets.Num());
		CachedAssets.Empty();
	}
}

bool UAssetSubsystem::IsAssetCached(const FString& AssetPath) const
{
	return CachedAssets.Contains(AssetPath);
}

UObject* UAssetSubsystem::GetCachedAsset(const FString& AssetPath) const
{
	if (const TSoftObjectPtr<UObject>* FoundAsset = CachedAssets.Find(AssetPath))
	{
		return FoundAsset->Get();
	}
	return nullptr;
}