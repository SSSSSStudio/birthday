// Copyright Guy (Drakynfly) Lundvall. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "FHotPatcherVersion.h"
#include "Interfaces/IHttpRequest.h"
#include "Interfaces/IHttpResponse.h"
#include "HttpModule.h"
#include "libzip/zip.h"
#include "HotPatcherWidgetBase.generated.h"

UENUM(BlueprintType, Blueprintable)
enum EProgressUpdateState
{
	Checking = 0 UMETA(DisplayName = "Checking"),
	VersionTooOld = 1 UMETA(DisplayName = "VersionTooOld"),
    Downloading = 2 UMETA(DisplayName = "Downloading"),
    Downloaded = 3 UMETA(DisplayName = "Downloaded"),
};

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FProgressUpdateStateDelegate, EProgressUpdateState, state, const FString, Message);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FProgressUpdateDelegate, FUpdateProgressInfo, ProgressInfo);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FNeedRestartDelegate, bool, NeedRestart);

UENUM(BlueprintType, Blueprintable)
enum EHotPatcherTargetPlatform
{
	TP_UNKNOWN = 0 UMETA(DisplayName = "Unknown"),
	TP_Windows = 1 UMETA(DisplayName = "Windows"),
    TP_Android = 2 UMETA(DisplayName = "Android"),
};


/**
 * 
 */
UCLASS()
class HOTPATCHERRUNTIME_API UHotPatcherWidgetBase : public UUserWidget
{
	GENERATED_BODY()
public:
	virtual void NativeConstruct() override;
	virtual void NativeDestruct() override;
	
	// 更新状态委托
	UPROPERTY(BlueprintAssignable, EditAnywhere, BlueprintReadWrite, Category = "HotPatcher")
	FProgressUpdateStateDelegate OnUpdateState;
	
	// 进度更新委托
	UPROPERTY(BlueprintAssignable, EditAnywhere, BlueprintReadWrite, Category = "HotPatcher")
	FProgressUpdateDelegate OnProgressUpdate;

	//是否需要重启
	UPROPERTY(BlueprintAssignable, EditAnywhere, BlueprintReadWrite, Category = "HotPatcher")
    FNeedRestartDelegate OnNeedRestart;

	// 进度更新信息
	FUpdateProgressInfo UpdateProgressInfo;

	FTSTicker::FDelegateHandle TickDelegateHandler;
	
	//上一帧已下载的byte,用于跟现在对比,从而计算下载速度
	int64 lastTickBt=0;

	//上一个下载帧已下载的Bt
	int64 lastReceivedBt=0;

	//是否需要重启
	bool NeedRestart = false;
	
	//当前更新状态
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "HotPatcher")
	TEnumAsByte<EProgressUpdateState> UpdateState = EProgressUpdateState::Checking;
	
	bool WidgetTick(float deltaSeconds);

	//唯一一个HTTP请求，需要在界面销毁时销毁
	TSharedRef<IHttpRequest, ESPMode::ThreadSafe> HttpRequest = FHttpModule::Get().CreateRequest();
	/**
	 * 开始流程
	 */
	UFUNCTION(BlueprintCallable)
	void BeginDownload();

	/**
	 * 读取本地文件和开始下载
	 */
	UFUNCTION(BlueprintCallable)
	void ReadVersionInfo();
	
	/**
	 * 比较两个版本ID
	 * 0: 不用更新
     * 1: LastVersion大 可更新
     * -1:大版本号落后,需要更新apk
	 */
	int CompareVersionIds(const FString& LastVersion, const FString& LocalVersion);

	// 查找需要下载的版本信息
	void FindNeedDownloadVersions(TMap<FString, FHotPatcherVersionInfo>& VersionInfos,
								  FHotPatcherAllVersion& AllVersionsStructData, FString Version, FString LastVersion);

	// 发送HTTP请求并下载文件
	UFUNCTION(BlueprintCallable, Category = "Heart|GraphNode")
	void SendHttpRequestAndDownloadFile(const FString& ArchiveName, const FString& ProjectFolder,
										TMap<FString, FHotPatcherVersionInfo>& AllNeedVersions);
	
	/**
	 * 下载版本文件
	 */
	void SendHttpRequestAndDownloadVersionFile();

	// 复制文件
	void CopyFile(const FString& SourceFilePath, const FString& DestinationFilePath);

	UFUNCTION(BlueprintCallable)
	FString GetLocalVersion();

	//删除本地已下载文件
	UFUNCTION(BlueprintCallable)
	bool DeleteLocalPak();

	bool MountPakByFilePath(FString FilePath);
	bool MountPak(const FString& PakPath, int32 PakOrder, const FString& InMountPoint);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "HotPatcher")
	TEnumAsByte<EHotPatcherTargetPlatform> TargetPlatform = TP_Windows;
	
};
