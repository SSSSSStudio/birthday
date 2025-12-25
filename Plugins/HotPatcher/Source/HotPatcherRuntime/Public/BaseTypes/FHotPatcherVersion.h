#pragma once
// project header
#include "AssetManager/FAssetDependenciesInfo.h"
#include "FPatcherSpecifyAsset.h"
#include "FExternFileInfo.h"
#include "ETargetPlatform.h"
#include "FPlatformExternFiles.h"
#include "FPlatformExternAssets.h"

// engine header
#include "CoreMinimal.h"
#include "UObject/ObjectMacros.h"

#include "FHotPatcherVersion.generated.h"



USTRUCT(BlueprintType)
struct FHotPatcherVersion
{
	GENERATED_USTRUCT_BODY()

public:
	FHotPatcherVersion()=default;
	
	UPROPERTY(EditAnywhere,BlueprintReadWrite)
	FString VersionId;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString BaseVersionId;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString Date;
	// UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<FString> IncludeFilter;
	// UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<FString> IgnoreFilter;
	// UPROPERTY(EditAnywhere, BlueprintReadWrite)
	bool bIncludeHasRefAssetsOnly;
	// UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<EAssetRegistryDependencyTypeEx> AssetRegistryDependencyTypes;
	// UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<FPatcherSpecifyAsset> IncludeSpecifyAssets;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FAssetDependenciesInfo AssetInfo;
	// UPROPERTY(EditAnywhere, BlueprintReadWrite)
	// TMap<FString, FExternFileInfo> ExternalFiles;
	UPROPERTY(EditAnywhere,BlueprintReadWrite)
	TMap<ETargetPlatform,FPlatformExternAssets> PlatformAssets;
};

USTRUCT(BlueprintType)
struct FHotPatcherFileInfo
{
	GENERATED_USTRUCT_BODY()
	
	/**
	 * 包体文件名
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString FileName;

	/**
	 * 包体大小
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int64 FileSize = 0;
	
};

USTRUCT(BlueprintType)
struct FHotPatcherVersionInfo
{
	GENERATED_USTRUCT_BODY()
	
	/**
	 * 当前版本所有包体信息
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<FHotPatcherFileInfo> FileInfos;
	
	/**
	 * 包体包含的最小版本
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString MinVersion;
	
	/**
	 * 包体包含的最大版本
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString MaxVersion;

	/**
     * 更新此包后是否需要重启
     */
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    bool needRestart = false;
	
};

USTRUCT(BlueprintType)
struct FHotPatcherLastVersionInfo
{
	GENERATED_USTRUCT_BODY()
	
	/**
	 * 最新版本
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString LastVersion;
};

USTRUCT(BlueprintType)
struct FHotPatcherAllVersion
{
	GENERATED_USTRUCT_BODY()
	
	/**
	 * 版本Hash表
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TMap<FString,FHotPatcherVersionInfo> Versions;
};

USTRUCT(BlueprintType)
struct FUpdateProgressInfo
{
	GENERATED_USTRUCT_BODY()

	/**
     * 最新版本
     */
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FString LastVersion = "1.0.0";
	/**
	 * 总共需要下载的包的数量
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int TotalPakNum = 0;

	/**
     * 当前正在下载的包的序号
     */
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int CurPakIndex = 0;

	/**
     * 总共需要下载的大小 kb
     */
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int64 TotalBt = 0;

	/**
	 * 已下载的包的大小 kb
	 */
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int64 DownloadedBt = 0;
	
	/**
     * 下载剩余时间 秒。 -1 表示没计算剩余时间 当前值不可用
     */
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int DownloadReleaseTime = 0;
};