// Copyright Guy (Drakynfly) Lundvall. All Rights Reserved.


#include "UMG/HotPatcherWidgetBase.h"
#include "IPlatformFilePak.h"

void UHotPatcherWidgetBase::NativeConstruct()
{
	Super::NativeConstruct();
#if PLATFORM_ANDROID
	TargetPlatform = TP_Android;
#elif PLATFORM_IOS
#else
#endif
	FTSTicker::GetCoreTicker().RemoveTicker(TickDelegateHandler);
	TickDelegateHandler.Reset();
	TickDelegateHandler = FTSTicker::GetCoreTicker().AddTicker(FTickerDelegate::CreateUObject(this, &UHotPatcherWidgetBase::WidgetTick),0.5f);
}

void UHotPatcherWidgetBase::NativeDestruct()
{
	FTSTicker::GetCoreTicker().RemoveTicker(TickDelegateHandler);
	TickDelegateHandler.Reset();
	HttpRequest->CancelRequest();
	Super::NativeConstruct();
}

void UHotPatcherWidgetBase::BeginDownload()
{
	HttpRequest->CancelRequest();
	HttpRequest = FHttpModule::Get().CreateRequest();
	// 先下载版本表
	SendHttpRequestAndDownloadVersionFile();
}

bool UHotPatcherWidgetBase::WidgetTick(float deltaSeconds)
{
	int64 deltaBt = UpdateProgressInfo.DownloadedBt - lastTickBt;
	lastTickBt = UpdateProgressInfo.DownloadedBt;
	//下载中才刷新进度数据
	if(UpdateState == EProgressUpdateState::Downloading&&deltaBt>0)
	{
		//deltaSeconds 不是0.5f  不知道为啥。那就写死 0.5f
		int sec = (UpdateProgressInfo.TotalBt-UpdateProgressInfo.DownloadedBt)/deltaBt*0.5f;
		//UE_LOG(LogTemp, Log, TEXT("WidgetTick : %d   %d   %d   %d   %f  %d"), UpdateProgressInfo.TotalBt,UpdateProgressInfo.DownloadedBt,UpdateProgressInfo.TotalBt-UpdateProgressInfo.DownloadedBt,deltaBt,deltaSeconds,sec);
		if(sec<0)
		{
			sec = 0;
		}
		UpdateProgressInfo.DownloadReleaseTime = sec;
		OnProgressUpdate.Broadcast(UpdateProgressInfo);
	}
	
	return true;
}

void UHotPatcherWidgetBase::ReadVersionInfo()
{
	FString PlatformVersionName;
	switch (TargetPlatform)
	{
	case TP_UNKNOWN:
		break;
	case TP_Windows:
		PlatformVersionName = "WindowsVersion.json";
		break;
	case TP_Android:
		PlatformVersionName = "AndroidVersion.json";
		break;
	}
	
	//读取本地版本
	const FString NormalizedPath = FConfigCacheIni::NormalizeConfigIniPath(*FPaths::Combine(FPaths::ProjectConfigDir(), TEXT("VersionRecord.ini")));
	GConfig->Flush(false, *NormalizedPath);
	// Version获取方式
	FString Version;
	GConfig->GetString(TEXT("VersionInfo"), TEXT("Version"), Version, *NormalizedPath);


	// 加载本地版本表JSON文件
	const FString VersionJsonPath = FPaths::ProjectDir() + PlatformVersionName;
	FString VersionJsonString;
	if (!FFileHelper::LoadFileToString(VersionJsonString, *VersionJsonPath))
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to load file: %s"), *VersionJsonPath);
		return;
	}
	// 解析 JSON 字符串为 JSON 对象
	TSharedPtr<FJsonObject> VersionJsonObject;
	TSharedRef<TJsonReader<>> VersionReader = TJsonReaderFactory<>::Create(VersionJsonString);
	if (!FJsonSerializer::Deserialize(VersionReader, VersionJsonObject) || !VersionJsonObject.IsValid())
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to deserialize JSON"));
		return;
	}

	if (!VersionJsonObject.IsValid())
	{
		return;
	}
	
	TSharedPtr<FJsonObject> LastVersionStructObject = VersionJsonObject->GetObjectField("LastVersion");
	FHotPatcherLastVersionInfo LastVersionStructData;
	FJsonObjectConverter::JsonObjectToUStruct(LastVersionStructObject.ToSharedRef(), &LastVersionStructData);
	
	if (LastVersionStructData.LastVersion == Version)
	{
		UE_LOG(LogTemp, Error, TEXT("Is Last version now"));
	}

	int CompareResult = CompareVersionIds(LastVersionStructData.LastVersion, Version);
	if (CompareResult==0)//不需要更新
	{
		UE_LOG(LogTemp, Error, TEXT("need not update"));
		OnUpdateState.Broadcast(EProgressUpdateState::Downloaded,"");
		return;
	}
	else if(CompareResult==-1)//需要下载新的apk
	{
		UE_LOG(LogTemp, Error, TEXT("need new apk"));
		OnUpdateState.Broadcast(EProgressUpdateState::VersionTooOld,"");
		return;
	}

	//寻找应该下载的所有包体
	TSharedPtr<FJsonObject> AllVersionsStructObject = VersionJsonObject->GetObjectField("AllVersions");
	FHotPatcherAllVersion AllVersionsStructData;
	FJsonObjectConverter::JsonObjectToUStruct(AllVersionsStructObject.ToSharedRef(), &AllVersionsStructData);

	//找到应该下载的包体
	TMap<FString,FHotPatcherVersionInfo> AllNeedVersions;
	FindNeedDownloadVersions(AllNeedVersions, AllVersionsStructData, Version,LastVersionStructData.LastVersion);
	//开始具体包体下载
	if (!AllNeedVersions.IsEmpty())
	{
		//计算总体下载大小
		int64 TotalSize = 0;
		int TotalPakNum = 0;
		NeedRestart = false;
		for (auto VersionInfo : AllNeedVersions)
		{
			for (FHotPatcherFileInfo& FileInfo : VersionInfo.Value.FileInfos)
			{
				TotalSize += FileInfo.FileSize;
				TotalPakNum = TotalPakNum+1;
			}
			if(VersionInfo.Value.needRestart == true)
			{
				NeedRestart = true;
			}
		}
		
		OnUpdateState.Broadcast(EProgressUpdateState::Downloading,"");
		UpdateState = EProgressUpdateState::Downloading;
		UpdateProgressInfo.LastVersion = LastVersionStructData.LastVersion;
		UpdateProgressInfo.TotalPakNum = TotalPakNum;
		UpdateProgressInfo.CurPakIndex = 1;
		UpdateProgressInfo.TotalBt = TotalSize;
		UpdateProgressInfo.DownloadedBt = 0;
		UpdateProgressInfo.DownloadReleaseTime = -1;
		OnProgressUpdate.Broadcast(UpdateProgressInfo);
		lastReceivedBt = 0;
		
		FString BackInfo = AllNeedVersions.Array()[0].Value.FileInfos[0].FileName;
		SendHttpRequestAndDownloadFile(BackInfo, FPaths::ProjectSavedDir()+"Paks/", AllNeedVersions);
		return;
	}
	OnUpdateState.Broadcast(EProgressUpdateState::Downloaded,"");
	UpdateState = EProgressUpdateState::Downloaded;
}

int UHotPatcherWidgetBase::CompareVersionIds(const FString& LastVersion, const FString& LocalVersion)
{
	// 使用 '.' 进行分割
	TArray<FString> Parts1;
	LastVersion.ParseIntoArray(Parts1, TEXT("."));

	TArray<FString> Parts2;
	LocalVersion.ParseIntoArray(Parts2, TEXT("."));

	// 确保两个版本号都有相同数量的部分
	int NumParts = FMath::Min(Parts1.Num(), Parts2.Num());

	for (int i = 0; i < NumParts; ++i)
	{
		int32 Part1Value = FCString::Atoi(*Parts1[i]);
		int32 Part2Value = FCString::Atoi(*Parts2[i]);

		//大版本号
		if (i==0)
        {
            if (Part1Value > Part2Value)
            {
                return -1;
            }
        }
		if (Part1Value < Part2Value)
		{
			return 0;
		}
		else if (Part1Value > Part2Value)
		{
			return 1;
		}
	}

	// 如果所有部分都相等，则比较剩余的部分
	if (Parts1.Num() < Parts2.Num())
	{
		return 0;
	}
	else if (Parts1.Num() > Parts2.Num())
	{
		return 1;
	}

	// 版本号完全相等
	return 0;
}

/**
 * @param VersionInfos: 找到的包体(返回结果)
 * @param AllVersionsStructData:表里记录的所有可下载版本的信息
 * @param Version:客户端当前版本
 */
void UHotPatcherWidgetBase::FindNeedDownloadVersions(TMap<FString, FHotPatcherVersionInfo>& VersionInfos,
	FHotPatcherAllVersion& AllVersionsStructData, FString Version, FString LastVersion)
{
	// 先找到所有衔接合适的包体
	TMap<FString,FHotPatcherVersionInfo> NextVersions;
	for (const auto& VersionData : AllVersionsStructData.Versions)
	{
		if (VersionData.Value.MinVersion == Version && VersionData.Value.MaxVersion <= LastVersion)
		{
			NextVersions.Add(VersionData);
		}
	}

	if (NextVersions.IsEmpty())
	{
		return;
	}
	
	//找到max版本最大的一个包
	FHotPatcherVersionInfo CurVersionInfo;
	FString CurKey;
	for (const auto& VersionData : NextVersions)
	{
		if (VersionData.Value.MaxVersion > CurVersionInfo.MaxVersion)
		{
			CurVersionInfo = VersionData.Value;
			CurKey = VersionData.Key;
		}
	}
	
	VersionInfos.Add(CurKey,CurVersionInfo);

	FindNeedDownloadVersions(VersionInfos, AllVersionsStructData, CurVersionInfo.MaxVersion,LastVersion);

	
}

void UHotPatcherWidgetBase::SendHttpRequestAndDownloadFile(const FString& ArchiveName,
	const FString& PakSavePath, TMap<FString,FHotPatcherVersionInfo>& AllNeedVersions)
{

	FString Platform;
	FString PlatformVersionName;
	switch (TargetPlatform)
	{
	case TP_UNKNOWN:
		break;
	case TP_Windows:
		PlatformVersionName = "WindowsVersion.json";
		Platform = "Windows";
		break;
	case TP_Android:
		PlatformVersionName = "AndroidVersion.json";
		Platform = "Android";
		break;
	}
	
	// FHttpModule* Http = &FHttpModule::Get();
	FString BodyJson = "{ \"k1\": \"v1\", \"k2\": \"v2\" }";

	// 第一步：获取签名信息
	// HttpRequest = Http->CreateRequest();
	HttpRequest->SetVerb("Get");
	HttpRequest->SetURL("https://pre-aihuman.youku.com/api/oss/generateSignature");
	HttpRequest->OnProcessRequestComplete().BindLambda(
		[this, ArchiveName, PakSavePath, AllNeedVersions, Platform](FHttpRequestPtr Req, FHttpResponsePtr Res, bool bWasSuccessful)
		{
			if (Res && bWasSuccessful)
			{
				FString ResponseContent = Res->GetContentAsString();
				TSharedPtr<FJsonObject> JsonObject;
				TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(ResponseContent);
				if (FJsonSerializer::Deserialize(Reader, JsonObject))
				{
					// FString OSSAccessKeyId = JsonObject->GetStringField("data.OSSAccessKeyId");
					// FString Policy = JsonObject->GetStringField("data.policy");
					// FString Signature = JsonObject->GetStringField("data.signature");
					// FString Dir = JsonObject->GetStringField("data.dir");
					// FString Host = JsonObject->GetStringField("data.host");

					// 第二步：获取预签名URL
					HttpRequest->SetVerb("GET");
					HttpRequest->SetURL(FString::Printf(
						TEXT("https://pre-aihuman.youku.com/api/oss/generatePresignedUrlV2?key=ganqu/Paks/%s/%s"),
						*Platform, *ArchiveName));
					HttpRequest->OnProcessRequestComplete().BindLambda(
						[this , PakSavePath, ArchiveName, AllNeedVersions, Platform](FHttpRequestPtr DownLoadReq, FHttpResponsePtr DownloadRes, bool bDowloadWasSuccessful)
						{
							if (DownloadRes && bDowloadWasSuccessful)
							{
								FString FileResponseContent = DownloadRes->GetContentAsString();
								TSharedPtr<FJsonObject> OutObject;
								TSharedRef<TJsonReader<>> JsonReader = TJsonReaderFactory<>::Create(FileResponseContent);
								if (FJsonSerializer::Deserialize(JsonReader, OutObject))
								{
									TSharedPtr<FJsonObject> NewData = OutObject->GetObjectField(TEXT("data"));
									FString DownloadURL = NewData->GetStringField("url");
									UE_LOG(LogTemp, Log, TEXT("Downloading from URL: %s"), *DownloadURL);

									// 下载文件到指定目录
									HttpRequest->SetVerb("GET");
									HttpRequest->SetURL(DownloadURL);
									HttpRequest->OnRequestProgress64().BindLambda(
										[this, PakSavePath, ArchiveName, AllNeedVersions, DownloadURL, Platform](FHttpRequestPtr Request, uint64 BytesSent, uint64 BytesReceived)
										{
											//UE_LOG(LogTemp, Log, TEXT("Downloading : %d   %d   %d"), BytesReceived,lastReceivedBt,UpdateProgressInfo.DownloadedBt);
											UpdateProgressInfo.DownloadedBt = UpdateProgressInfo.DownloadedBt+BytesReceived - lastReceivedBt;
											lastReceivedBt = BytesReceived;
										});
									HttpRequest->OnProcessRequestComplete().BindLambda(
										[this, PakSavePath, ArchiveName, AllNeedVersions, DownloadURL, Platform](FHttpRequestPtr FileReq, FHttpResponsePtr FileRes, bool bFileWasSuccessful)
										{
											if (FileRes && bFileWasSuccessful)
											{
												FString FilePath = FPaths::Combine(PakSavePath, ArchiveName);
												FFileHelper::SaveArrayToFile(FileRes->GetContent(), *FilePath);
												UE_LOG(LogTemp, Log, TEXT("Downloaded successfully: %s"), *FilePath);
												lastReceivedBt = 0;
												if(UpdateProgressInfo.CurPakIndex<UpdateProgressInfo.TotalPakNum)
												{
													UpdateProgressInfo.CurPakIndex = UpdateProgressInfo.CurPakIndex +1;
												}

												
												MountPakByFilePath(FilePath);
									
												TMap<FString, FHotPatcherVersionInfo> NeoAllNeedVersions =
													AllNeedVersions;
												FString RemoveKey = NeoAllNeedVersions.Array()[0].Key;
												TArray<FHotPatcherFileInfo>& FileInfos = NeoAllNeedVersions.Find(RemoveKey)->FileInfos;//[0].Value.FileInfos;
												if(FileInfos.Num()>1)
												{
													FileInfos.RemoveAt(0);
												}
												else
												{
													NeoAllNeedVersions.Remove(RemoveKey);
												}
												if (!NeoAllNeedVersions.IsEmpty())
												{
													FString BackInfo = NeoAllNeedVersions.Array()[0].Value.FileInfos[0].FileName;
													SendHttpRequestAndDownloadFile(
														BackInfo, FPaths::ProjectSavedDir()+"Paks/", NeoAllNeedVersions);
												}
												else
												{
													OnUpdateState.Broadcast(EProgressUpdateState::Downloaded,UpdateProgressInfo.LastVersion);
													OnNeedRestart.Broadcast(NeedRestart);
													UpdateState = EProgressUpdateState::Downloaded;
													UpdateProgressInfo.DownloadReleaseTime = 0;
													OnProgressUpdate.Broadcast(UpdateProgressInfo);
													UE_LOG(LogTemp, Log, TEXT("Downloaded successfully: %s"), *FilePath);
												}
											}
											else
											{
												UE_LOG(LogTemp, Error, TEXT("Download failed for URL: %s"),
												       *DownloadURL);
											}
										});

									HttpRequest->ProcessRequest();
								}
							}
						});

					HttpRequest->ProcessRequest();
				}
			}
		});

	HttpRequest->ProcessRequest();
}

void UHotPatcherWidgetBase::SendHttpRequestAndDownloadVersionFile()
{
	OnUpdateState.Broadcast(EProgressUpdateState::Checking,"");
	UpdateState = EProgressUpdateState::Checking;
	FString PlatformVersionName;
	switch (TargetPlatform)
	{
	case TP_UNKNOWN:
		break;
	case TP_Windows:
		PlatformVersionName = "WindowsVersion.json";
		break;
	case TP_Android:
		PlatformVersionName = "AndroidVersion.json";
		break;
	}
	
	FString BodyJson = "{ \"k1\": \"v1\", \"k2\": \"v2\" }";

	// 第一步：获取签名信息
	HttpRequest->SetVerb("Get");
	HttpRequest->SetURL("https://pre-aihuman.youku.com/api/oss/generateSignature");
	HttpRequest->OnProcessRequestComplete().BindLambda(
		[this,  PlatformVersionName](FHttpRequestPtr Req, FHttpResponsePtr Res, bool bWasSuccessful)
		{
			if (Res && bWasSuccessful)
			{
				FString ResponseContent = Res->GetContentAsString();
				TSharedPtr<FJsonObject> JsonObject;
				TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(ResponseContent);
				if (FJsonSerializer::Deserialize(Reader, JsonObject))
				{
					// FString OSSAccessKeyId = JsonObject->GetStringField("data.OSSAccessKeyId");
					// FString Policy = JsonObject->GetStringField("data.policy");
					// FString Signature = JsonObject->GetStringField("data.signature");
					// FString Dir = JsonObject->GetStringField("data.dir");
					// FString Host = JsonObject->GetStringField("data.host");

					// 第二步：获取预签名URL
					HttpRequest->SetVerb("GET");
					HttpRequest->SetURL(FString::Printf(
						TEXT("https://pre-aihuman.youku.com/api/oss/generatePresignedUrlV2?key=ganqu/Paks/%s"),
						*PlatformVersionName));
					HttpRequest->OnProcessRequestComplete().BindLambda(
						[this, PlatformVersionName](FHttpRequestPtr Req, FHttpResponsePtr Res, bool bWasSuccessful)
						{
							if (Res && bWasSuccessful)
							{
								FString ResponseContent = Res->GetContentAsString();
								TSharedPtr<FJsonObject> JsonObject;
								TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(ResponseContent);
								if (FJsonSerializer::Deserialize(Reader, JsonObject))
								{
									TSharedPtr<FJsonObject> NewData = JsonObject->GetObjectField(TEXT("data"));
									FString DownloadURL = NewData->GetStringField("url");
									UE_LOG(LogTemp, Log, TEXT("Downloading from URL: %s"), *DownloadURL);

									// 下载 Version 文件到指定目录 格式如下
									/*
									* {
										"LastVersion":
										{
											"lastVersion": "0.1.0"
										},
										"AllVersions":
										{
											"versions":
											{
												"0.0.0-0.1.0":
												{
													"fileInfos": [
														{
															"fileName": "0.0.0-0.1.0_Windows_001_P.pak",
															"fileSize": 457412842
														}
													],
													"minVersion": "0.0.0",
													"maxVersion": "0.1.0"
												}
											}
										}
									}
									 */
									HttpRequest->SetVerb("GET");
									HttpRequest->SetURL(DownloadURL);
									HttpRequest->OnProcessRequestComplete().BindLambda(
										[this, DownloadURL, PlatformVersionName](FHttpRequestPtr Req, FHttpResponsePtr Res, bool bWasSuccessful)
										{
											if (Res && bWasSuccessful)
											{
												FString FilePath = FPaths::Combine(FPaths::ProjectDir(), *PlatformVersionName);
												FFileHelper::SaveArrayToFile(Res->GetContent(), *FilePath);
												UE_LOG(LogTemp, Log, TEXT("Downloaded successfully: %s"), *FilePath);
									
												//开始下载包体
												ReadVersionInfo();
												
											}
											else
											{
												UE_LOG(LogTemp, Error, TEXT("Download failed for URL: %s"),
												       *DownloadURL);
											}
										});

									HttpRequest->ProcessRequest();
								}
							}
						});

					HttpRequest->ProcessRequest();
				}
			}
		});

	HttpRequest->ProcessRequest();
}

void UHotPatcherWidgetBase::CopyFile(const FString& SourceFilePath, const FString& DestinationFilePath)
{
	// 创建一个平台文件管理器
	IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();

	// 检查源文件是否存在
	if (PlatformFile.FileExists(*SourceFilePath))
	{
		FString Dir = FPaths::GetPath(DestinationFilePath);
		if (!FPaths::DirectoryExists(Dir))
		{
			IFileManager::Get().MakeDirectory(*Dir, true);
		}
		// 拷贝文件
		if (PlatformFile.CopyFile(*DestinationFilePath, *SourceFilePath))
		{
			UE_LOG(LogTemp, Log, TEXT("File copied from %s to %s"), *SourceFilePath, *DestinationFilePath);
		}
		else
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to copy file from %s to %s"), *SourceFilePath, *DestinationFilePath);
		}
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("Source file does not exist: %s"), *SourceFilePath);
	}
}

FString UHotPatcherWidgetBase::GetLocalVersion()
{
	//读取本地版本
	const FString NormalizedPath = FConfigCacheIni::NormalizeConfigIniPath(*FPaths::Combine(FPaths::ProjectConfigDir(), TEXT("VersionRecord.ini")));
	// Version获取方式
	FString Version;
	GConfig->GetString(TEXT("VersionInfo"), TEXT("Version"), Version, *NormalizedPath);
	return Version;
}

bool UHotPatcherWidgetBase::DeleteLocalPak()
{
	// 确保路径以斜杠结尾
	FString PathToDelete = FPaths::ProjectSavedDir()+"Paks/";
	// 创建 IFileManager 实例
	IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();

	// 检查目录是否存在
	if (PlatformFile.DirectoryExists(*PathToDelete))
	{
		// 删除目录及其所有内容
		if (!PlatformFile.DeleteDirectoryRecursively(*PathToDelete))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to delete directory: %s"), *PathToDelete);
		}
		else
		{
			UE_LOG(LogTemp, Log, TEXT("Successfully deleted directory: %s"), *PathToDelete);
		}
	}
	else
	{
		UE_LOG(LogTemp, Warning, TEXT("Directory does not exist: %s"), *PathToDelete);
	}
	return true;
}

bool UHotPatcherWidgetBase::MountPakByFilePath(FString FilePath)
{
	TArray<FString> Parts;
	FilePath.ParseIntoArray(Parts, TEXT("_"));
	int32 PakOrder = FCString::Atoi(*Parts[2]);
	FString InMountPoint = TEXT("");
	MountPak(FilePath, PakOrder, InMountPoint);
	return true;
}

bool UHotPatcherWidgetBase::MountPak(const FString& PakPath, int32 PakOrder, const FString& InMountPoint)
{
	bool bMounted = false;
#if !WITH_EDITOR
	FPakPlatformFile* PakFileMgr=(FPakPlatformFile*)FPlatformFileManager::Get().GetPlatformFile(FPakPlatformFile::GetTypeName());
	if (!PakFileMgr)
	{
		UE_LOG(LogTemp, Log, TEXT("GetPlatformFile(TEXT(\"PakFile\") is NULL"));
		return false;
	}
	
	PakOrder = FMath::Max(0, PakOrder);
	
	if (FPaths::FileExists(PakPath) && FPaths::GetExtension(PakPath) == TEXT("pak"))
	{
		const TCHAR* MountPount = InMountPoint.GetCharArray().GetData();
		if (PakFileMgr->Mount(*PakPath, PakOrder,MountPount))
		{
			UE_LOG(LogTemp, Log, TEXT("Mounted = %s, Order = %d, MountPoint = %s"), *PakPath, PakOrder, !MountPount ? TEXT("(NULL)") : MountPount);
			bMounted = true;
		}
		else {
			UE_LOG(LogTemp, Error, TEXT("Faild to mount pak = %s"), *PakPath);
			bMounted = false;
		}
	}

#endif
	return bMounted;
}









