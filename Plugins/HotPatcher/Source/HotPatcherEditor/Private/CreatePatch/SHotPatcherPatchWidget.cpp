// Copyright 1998-2016 Epic Games, Inc. All Rights Reserved.

// #include "HotPatcherPrivatePCH.h"
#include "CreatePatch/SHotPatcherPatchWidget.h"
#include "CreatePatch/FExportPatchSettings.h"
#include "CreatePatch/PatcherProxy.h"
#include "CreatePatch/ScopedSlowTaskContext.h"

#include "FlibHotPatcherCoreHelper.h"
#include "FlibPatchParserHelper.h"
#include "FHotPatcherVersion.h"
#include "FlibAssetManageHelper.h"
#include "FPakFileInfo.h"
#include "ThreadUtils/FThreadUtils.hpp"
#include "HotPatcherLog.h"
#include "HotPatcherEditor.h"

// engine header
#include "FlibHotPatcherEditorHelper.h"
#include "HttpModule.h"
#include "Misc/FileHelper.h"
#include "Widgets/Input/SHyperlink.h"
#include "Widgets/Layout/SSeparator.h"
#include "Widgets/Text/SMultiLineEditableText.h"
#include "Kismet/KismetStringLibrary.h"
#include "Kismet/KismetSystemLibrary.h"
#include "Misc/SecureHash.h"
#include "HAL/FileManager.h"
#include "PakFileUtilities.h"
#include "Interfaces/IHttpResponse.h"
#include "Kismet/KismetTextLibrary.h"
#include "Misc/EngineVersionComparison.h"

#if !UE_VERSION_OLDER_THAN(5, 1, 0)
typedef FAppStyle FEditorStyle;
#endif

#define LOCTEXT_NAMESPACE "SHotPatcherCreatePatch"

void SHotPatcherPatchWidget::Construct(const FArguments& InArgs, TSharedPtr<FHotPatcherContextBase> InCreatePatchModel)
{
	ExportPatchSetting = MakeShareable(new FExportPatchSettings);
	GPatchSettings = ExportPatchSetting.Get();
	CreateExportFilterListView();
	mContext = InCreatePatchModel;

	ChildSlot
	[
		SNew(SVerticalBox)
		+ SVerticalBox::Slot()
		.AutoHeight()
		.Padding(FEditorStyle::GetMargin("StandardDialog.ContentPadding"))
		[
			SNew(SHorizontalBox)
			+ SHorizontalBox::Slot()
			.VAlign(VAlign_Center)
			[
				SettingsView->GetWidget()->AsShared()
			]
		]
		+ SVerticalBox::Slot()
		.AutoHeight()
		.HAlign(HAlign_Right)
		.Padding(4, 4, 10, 4)
		[
			SNew(SHorizontalBox)
			+ SHorizontalBox::Slot()
			.HAlign(HAlign_Right)
			.AutoWidth()
			.Padding(0, 0, 4, 0)
			[
				SNew(SButton)
				.Text(LOCTEXT("AddToPreset", "AddToPreset"))
				.OnClicked(this, &SHotPatcherPatchWidget::DoAddToPreset)
			]
			+ SHorizontalBox::Slot()
			.HAlign(HAlign_Right)
			.AutoWidth()
			.Padding(0, 0, 4, 0)
			[
				SNew(SButton)
				.Text(LOCTEXT("PreviewChunk", "PreviewChunk"))
				.IsEnabled(this, &SHotPatcherPatchWidget::CanPreviewChunk)
				.OnClicked(this, &SHotPatcherPatchWidget::DoPreviewChunk)
				.Visibility(this, &SHotPatcherPatchWidget::VisibilityPreviewChunkButtons)
			]
			+ SHorizontalBox::Slot()
			.HAlign(HAlign_Right)
			.AutoWidth()
			.Padding(0, 0, 4, 0)
			[
				SNew(SButton)
				.Text(LOCTEXT("Diff", "Diff"))
				.IsEnabled(this, &SHotPatcherPatchWidget::CanDiff)
				.OnClicked(this, &SHotPatcherPatchWidget::DoDiff)
				.Visibility(this, &SHotPatcherPatchWidget::VisibilityDiffButtons)
			]
			+ SHorizontalBox::Slot()
			.HAlign(HAlign_Right)
			.AutoWidth()
			.Padding(0, 0, 4, 0)
			[
				SNew(SButton)
				.Text(LOCTEXT("ClearDiff", "ClearDiff"))
				.IsEnabled(this, &SHotPatcherPatchWidget::CanDiff)
				.OnClicked(this, &SHotPatcherPatchWidget::DoClearDiff)
				.Visibility(this, &SHotPatcherPatchWidget::VisibilityDiffButtons)
			]
			+ SHorizontalBox::Slot()
			.HAlign(HAlign_Right)
			.AutoWidth()
			.Padding(0, 0, 4, 0)
			[
				SNew(SButton)
				.Text(LOCTEXT("PreviewPatch", "PreviewPatch"))
				.IsEnabled(this, &SHotPatcherPatchWidget::CanPreviewPatch)
				.OnClicked(this, &SHotPatcherPatchWidget::DoPreviewPatch)
				.ToolTipText(this, &SHotPatcherPatchWidget::GetGenerateTooltipText)
			]
			+ SHorizontalBox::Slot()
			.HAlign(HAlign_Right)
			.AutoWidth()
			.Padding(0, 0, 4, 0)
			[
				SNew(SButton)
				.Text(LOCTEXT("GeneratePatch", "GeneratePatch"))
				.ToolTipText(this, &SHotPatcherPatchWidget::GetGenerateTooltipText)
				.IsEnabled(this, &SHotPatcherPatchWidget::CanExportPatch)
				.OnClicked(this, &SHotPatcherPatchWidget::DoExportPatch)
			]
		]
		+ SVerticalBox::Slot()
		.AutoHeight()
		.HAlign(HAlign_Fill)
		.VAlign(VAlign_Fill)
		.Padding(4, 4, 10, 4)
		[
			SAssignNew(DiffWidget, SHotPatcherInformations)
			.Visibility(EVisibility::Collapsed)
		]

	];
}

void SHotPatcherPatchWidget::ImportConfig()
{
	UE_LOG(LogHotPatcher, Log, TEXT("Patch Import Config"));
	TArray<FString> Files = this->OpenFileDialog();
	if (!Files.Num()) return;

	FString LoadFile = Files[0];

	FString JsonContent;
	if (UFlibAssetManageHelper::LoadFileToString(LoadFile, JsonContent))
	{
		THotPatcherTemplateHelper::TDeserializeJsonStringAsStruct(JsonContent, *ExportPatchSetting);
		// adaptor old version config
		UFlibHotPatcherCoreHelper::AdaptorOldVersionConfig(ExportPatchSetting->GetAssetScanConfigRef(), JsonContent);
		SettingsView->GetDetailsView()->ForceRefresh();
	}
}

void SHotPatcherPatchWidget::ExportConfig() const
{
	UE_LOG(LogHotPatcher, Log, TEXT("Patch Export Config"));
	TArray<FString> Files = this->SaveFileDialog();

	if (!Files.Num()) return;

	FString SaveToFile = Files[0].EndsWith(TEXT(".json")) ? Files[0] : Files[0].Append(TEXT(".json"));

	if (ExportPatchSetting)
	{
		if (ExportPatchSetting->IsSaveConfig())
		{
			FString SerializedJsonStr;
			THotPatcherTemplateHelper::TSerializeStructAsJsonString(*ExportPatchSetting, SerializedJsonStr);
			if (FFileHelper::SaveStringToFile(SerializedJsonStr, *SaveToFile))
			{
				FText Msg = LOCTEXT("SavedPatchConfigMas", "Successd to Export the Patch Config.");
				UFlibHotPatcherEditorHelper::CreateSaveFileNotify(Msg, SaveToFile);
			}
		}
	}
}

void SHotPatcherPatchWidget::ResetConfig()
{
	UE_LOG(LogHotPatcher, Log, TEXT("Patch Clear Config"));
	FString DefaultSettingJson;
	THotPatcherTemplateHelper::TSerializeStructAsJsonString(*FExportPatchSettings::Get(), DefaultSettingJson);
	THotPatcherTemplateHelper::TDeserializeJsonStringAsStruct(DefaultSettingJson, *ExportPatchSetting);
	SettingsView->GetDetailsView()->ForceRefresh();
}

void SHotPatcherPatchWidget::DoGenerate()
{
	DoExportPatch();
}


bool SHotPatcherPatchWidget::InformationContentIsVisibility() const
{
	return DiffWidget->GetVisibility() == EVisibility::Visible;
}

void SHotPatcherPatchWidget::SetInformationContent(const FString& InContent) const
{
	DiffWidget->SetContent(InContent);
}

void SHotPatcherPatchWidget::SetInfomationContentVisibility(EVisibility InVisibility) const
{
	DiffWidget->SetVisibility(InVisibility);
}

void SHotPatcherPatchWidget::ImportProjectConfig()
{
	SHotPatcherWidgetBase::ImportProjectConfig();
	bool bUseIoStore = false;
	bool bAllowBulkDataInIoStore = false;

	GConfig->GetBool(TEXT("/Script/UnrealEd.ProjectPackagingSettings"),TEXT("bUseIoStore"), bUseIoStore, GGameIni);
	GConfig->GetBool(TEXT("Core.System"),TEXT("AllowBulkDataInIoStore"), bAllowBulkDataInIoStore, GEngineIni);

	GetConfigSettings()->IoStoreSettings.bIoStore = bUseIoStore;
	GetConfigSettings()->IoStoreSettings.bAllowBulkDataInIoStore = bAllowBulkDataInIoStore;

#if ENGINE_MAJOR_VERSION > 4
	bool bMakeBinaryConfig = false;
	GConfig->GetBool(TEXT("/Script/UnrealEd.ProjectPackagingSettings"),TEXT("bMakeBinaryConfig"), bMakeBinaryConfig,
	                 GEngineIni);
	GetConfigSettings()->bMakeBinaryConfig = bMakeBinaryConfig;
#endif

	FString PakFileCompressionFormats;
	GConfig->GetString(TEXT("/Script/UnrealEd.ProjectPackagingSettings"),TEXT("PakFileCompressionFormats"),
	                   PakFileCompressionFormats, GGameIni);
	if (!PakFileCompressionFormats.IsEmpty())
	{
		PakFileCompressionFormats = FString::Printf(TEXT("-compressionformats=%s"), *PakFileCompressionFormats);
		GetConfigSettings()->DefaultCommandletOptions.AddUnique(PakFileCompressionFormats);
	}
	FString PakFileAdditionalCompressionOptions;
	GConfig->GetString(TEXT("/Script/UnrealEd.ProjectPackagingSettings"),TEXT("PakFileAdditionalCompressionOptions"),
	                   PakFileAdditionalCompressionOptions, GGameIni);

	if (!PakFileAdditionalCompressionOptions.IsEmpty())
		GetConfigSettings()->DefaultCommandletOptions.AddUnique(PakFileAdditionalCompressionOptions);
}

void SHotPatcherPatchWidget::UploadPackage()
{
	//拉取服务器最新版本表

	//更新本地版本表
	FlushWindowsVersionJson();

	FlushAndroidVersionJson();

	//上传包体和版本表
	// SendUploadRequest("0.1.0-0.2.0.zip", FString("F:/WorkSpace/AIHuman/Saved/HotPatcher"));
}

void SHotPatcherPatchWidget::CreateAndRunBatchScript(const FString& SourceDir, const FString& OutputDir)
{
	FString CurVersionId = ExportPatchSetting->GetVersionId();

	// 生成压缩文件名

	FString ArchiveName = CurVersionId + ".zip";

	// 完整的输出路径
	FString FullOutputPath = OutputDir + "\\" + ArchiveName;

	// 定义批处理脚本内容
	FString WorkingDirectory = FPaths::ProjectDir();
	// 定义批处理脚本内容
	FString BatchContent = FString::Printf(
		TEXT("@echo off\n"
			"cd \"%s\"\n"
			"if not exist \"%s\" mkdir \"%s\"\n"
			"\"C:\\Program Files\\7-Zip\\7z.exe\" a -tzip \"%s\" \"%s\" -r -mx0"),
		*WorkingDirectory, *OutputDir, *OutputDir, *FullOutputPath, *SourceDir
	);

	// 写入临时批处理文件
	FString TempBatchFileName = FPaths::Combine(FPaths::ProjectDir(), TEXT("temp_compress.bat"));
	FFileHelper::SaveStringToFile(BatchContent, *TempBatchFileName);

	// 启动批处理脚本
	// 创建进程

	FProcHandle ProcessHandle = FPlatformProcess::CreateProc(*TempBatchFileName, nullptr, true, false, false, nullptr,
	                                                         0, *WorkingDirectory, nullptr);

	// 检查进程是否启动成功
	if (ProcessHandle.IsValid())
	{
		UE_LOG(LogTemp, Log, TEXT("Batch file executed successfully."));
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to execute batch file."));
	}

	// 删除临时批处理文件
	IFileManager::Get().Delete(*TempBatchFileName, false, true);
}

void SHotPatcherPatchWidget::FlushWindowsVersionJson()
{
	if (!ExportPatchSetting) return;

	FString CurVersionId = ExportPatchSetting->GetVersionId();

	FHotPatcherVersionInfo Data;

	TArray<FString> Parts;
	CurVersionId.ParseIntoArray(Parts, TEXT("-"));
	if (Parts.Num() == 2)
	{
		Data.MinVersion = Parts[0];
		Data.MaxVersion = Parts[1];
	}

	// 加载版本表JSON 文件
	const FString VersionJsonPath = FPaths::ProjectDir() + TEXT("Saved/HotPatcher/WindowsVersion.json");
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

	TSharedPtr<FJsonObject> StructObject = VersionJsonObject->GetObjectField("LastVersion");
	FHotPatcherLastVersionInfo StructData;
	FJsonObjectConverter::JsonObjectToUStruct(StructObject.ToSharedRef(), &StructData);
	FString OldVersion = StructData.LastVersion;

	TSharedPtr<FJsonObject> AllVersionsStructObject = VersionJsonObject->GetObjectField("AllVersions");
	FHotPatcherAllVersion AllVersionsStructData;
	FJsonObjectConverter::JsonObjectToUStruct(AllVersionsStructObject.ToSharedRef(), &AllVersionsStructData);

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	const FString PakFileInfoJsonPath = FPaths::ProjectDir() + TEXT("Saved/HotPatcher/") + CurVersionId + TEXT("/")
		+ CurVersionId + TEXT("_") + TEXT("PakFilesInfo.json");
	FString PakFileInfoJsonString;
	if (!FFileHelper::LoadFileToString(PakFileInfoJsonString, *PakFileInfoJsonPath))
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to load file: %s"), *PakFileInfoJsonPath);
		return;
	}

	// 解析当前选中包体版本文件
	TSharedPtr<FJsonObject> PakFileInfoJsonObject;
	TSharedRef<TJsonReader<>> PakFileInfoReader = TJsonReaderFactory<>::Create(PakFileInfoJsonString);
	if (!FJsonSerializer::Deserialize(PakFileInfoReader, PakFileInfoJsonObject) || !PakFileInfoJsonObject.IsValid())
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to deserialize JSON"));
		return;
	}

	if (PakFileInfoJsonObject.IsValid())
	{
		// Access the nested structure
		const TSharedPtr<FJsonObject>* PakFilesMapObj;
		if (!PakFileInfoJsonObject->TryGetObjectField("pakFilesMap", PakFilesMapObj))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to find 'pakFilesMap' field in JSON"));
			return;
		}

		const TSharedPtr<FJsonObject>* WindowsObj;
		if (!(*PakFilesMapObj)->TryGetObjectField("Windows", WindowsObj))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to find 'Windows' field in pakFilesMap"));
			return;
		}

		const TArray<TSharedPtr<FJsonValue>>* PakFileInfosArr;
		if (!(*WindowsObj)->TryGetArrayField("pakFileInfos", PakFileInfosArr))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to find 'pakFileInfos' array in Windows"));
			return;
		}

		for (int32 i = 0; i < PakFileInfosArr->Num(); i++)
		{
			const TSharedPtr<FJsonObject>* PakFileInfoObj;
			(*PakFileInfosArr)[i]->TryGetObject(PakFileInfoObj);
			FString FileName;
			if ((*PakFileInfoObj)->TryGetStringField("fileName", FileName))
			{
				UE_LOG(LogTemp, Log, TEXT("FileName: %s"), *FileName);
			}
			int64 FileSize = (*PakFileInfoObj)->GetIntegerField("fileSize");

			FHotPatcherFileInfo FileInfo;
			FileInfo.FileName = FileName;
			FileInfo.FileSize = FileSize;
			Data.FileInfos.Add(FileInfo);
		}
	}


	FHotPatcherLastVersionInfo LastVersionInfo;
	LastVersionInfo.LastVersion = Data.MaxVersion;

	//更新最新版本
	if (CompareVersionIds(LastVersionInfo.LastVersion, OldVersion))
	{
		TSharedPtr<FJsonObject> LastVersionInfoJsonStruct = FJsonObjectConverter::UStructToJsonObject<
			FHotPatcherLastVersionInfo>(LastVersionInfo);
		VersionJsonObject->SetObjectField("LastVersion", LastVersionInfoJsonStruct);
	}

	AllVersionsStructData.Versions.Add(CurVersionId, Data);

	// TSharedPtr<FJsonObject> DataJsonStruct = FJsonObjectConverter::UStructToJsonObject<FHotPatcherVersionInfo>(Data);
	// VersionJsonObject->SetObjectField(CurVersionId, DataJsonStruct);

	TSharedPtr<FJsonObject> AllVersionInfoJsonStruct = FJsonObjectConverter::UStructToJsonObject<FHotPatcherAllVersion>(
		AllVersionsStructData);
	VersionJsonObject->SetObjectField("AllVersions", AllVersionInfoJsonStruct);


	FString OutputString;
	const TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
	FJsonSerializer::Serialize(VersionJsonObject.ToSharedRef(), Writer);

	// 保存到文件
	const FString FilePath = VersionJsonPath;
	FFileHelper::SaveStringToFile(OutputString, *FilePath);
}

void SHotPatcherPatchWidget::FlushAndroidVersionJson()
{
	if (!ExportPatchSetting) return;

	FString CurVersionId = ExportPatchSetting->GetVersionId();

	FHotPatcherVersionInfo Data;

	TArray<FString> Parts;
	CurVersionId.ParseIntoArray(Parts, TEXT("-"));
	if (Parts.Num() == 2)
	{
		Data.MinVersion = Parts[0];
		Data.MaxVersion = Parts[1];
	}

	// 加载版本表JSON 文件
	const FString VersionJsonPath = FPaths::ProjectDir() + TEXT("Saved/HotPatcher/AndroidVersion.json");
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

	TSharedPtr<FJsonObject> StructObject = VersionJsonObject->GetObjectField("LastVersion");
	FHotPatcherLastVersionInfo StructData;
	FJsonObjectConverter::JsonObjectToUStruct(StructObject.ToSharedRef(), &StructData);
	FString OldVersion = StructData.LastVersion;

	TSharedPtr<FJsonObject> AllVersionsStructObject = VersionJsonObject->GetObjectField("AllVersions");
	FHotPatcherAllVersion AllVersionsStructData;
	FJsonObjectConverter::JsonObjectToUStruct(AllVersionsStructObject.ToSharedRef(), &AllVersionsStructData);

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	const FString PakFileInfoJsonPath = FPaths::ProjectDir() + TEXT("Saved/HotPatcher/") + CurVersionId + TEXT("/")
		+ CurVersionId + TEXT("_") + TEXT("PakFilesInfo.json");
	FString PakFileInfoJsonString;
	if (!FFileHelper::LoadFileToString(PakFileInfoJsonString, *PakFileInfoJsonPath))
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to load file: %s"), *PakFileInfoJsonPath);
		return;
	}

	// 解析当前选中包体版本文件
	TSharedPtr<FJsonObject> PakFileInfoJsonObject;
	TSharedRef<TJsonReader<>> PakFileInfoReader = TJsonReaderFactory<>::Create(PakFileInfoJsonString);
	if (!FJsonSerializer::Deserialize(PakFileInfoReader, PakFileInfoJsonObject) || !PakFileInfoJsonObject.IsValid())
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to deserialize JSON"));
		return;
	}

	if (PakFileInfoJsonObject.IsValid())
	{
		// Access the nested structure
		const TSharedPtr<FJsonObject>* PakFilesMapObj;
		if (!PakFileInfoJsonObject->TryGetObjectField("pakFilesMap", PakFilesMapObj))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to find 'pakFilesMap' field in JSON"));
			return;
		}

		const TSharedPtr<FJsonObject>* WindowsObj;
		if (!(*PakFilesMapObj)->TryGetObjectField("Android", WindowsObj))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to find 'Windows' field in pakFilesMap"));
			return;
		}

		const TArray<TSharedPtr<FJsonValue>>* PakFileInfosArr;
		if (!(*WindowsObj)->TryGetArrayField("pakFileInfos", PakFileInfosArr))
		{
			UE_LOG(LogTemp, Error, TEXT("Failed to find 'pakFileInfos' array in Windows"));
			return;
		}

		for (int32 i = 0; i < PakFileInfosArr->Num(); i++)
		{
			const TSharedPtr<FJsonObject>* PakFileInfoObj;
			(*PakFileInfosArr)[i]->TryGetObject(PakFileInfoObj);
			FString FileName;
			if ((*PakFileInfoObj)->TryGetStringField("fileName", FileName))
			{
				UE_LOG(LogTemp, Log, TEXT("FileName: %s"), *FileName);
			}
			int64 FileSize = (*PakFileInfoObj)->GetIntegerField("fileSize");

			FHotPatcherFileInfo FileInfo;
			FileInfo.FileName = FileName;
			FileInfo.FileSize = FileSize;
			Data.FileInfos.Add(FileInfo);
		}
	}


	FHotPatcherLastVersionInfo LastVersionInfo;
	LastVersionInfo.LastVersion = Data.MaxVersion;

	//更新最新版本
	if (CompareVersionIds(LastVersionInfo.LastVersion, OldVersion))
	{
		TSharedPtr<FJsonObject> LastVersionInfoJsonStruct = FJsonObjectConverter::UStructToJsonObject<
			FHotPatcherLastVersionInfo>(LastVersionInfo);
		VersionJsonObject->SetObjectField("LastVersion", LastVersionInfoJsonStruct);
	}

	AllVersionsStructData.Versions.Add(CurVersionId, Data);

	// TSharedPtr<FJsonObject> DataJsonStruct = FJsonObjectConverter::UStructToJsonObject<FHotPatcherVersionInfo>(Data);
	// VersionJsonObject->SetObjectField(CurVersionId, DataJsonStruct);

	TSharedPtr<FJsonObject> AllVersionInfoJsonStruct = FJsonObjectConverter::UStructToJsonObject<FHotPatcherAllVersion>(
		AllVersionsStructData);
	VersionJsonObject->SetObjectField("AllVersions", AllVersionInfoJsonStruct);


	FString OutputString;
	const TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
	FJsonSerializer::Serialize(VersionJsonObject.ToSharedRef(), Writer);

	// 保存到文件
	const FString FilePath = VersionJsonPath;
	FFileHelper::SaveStringToFile(OutputString, *FilePath);
}




bool SHotPatcherPatchWidget::CompareVersionIds(const FString& VersionId1, const FString& VersionId2)
{
	// 使用 '.' 进行分割
	TArray<FString> Parts1;
	VersionId1.ParseIntoArray(Parts1, TEXT("."));

	TArray<FString> Parts2;
	VersionId2.ParseIntoArray(Parts2, TEXT("."));

	// 确保两个版本号都有相同数量的部分
	int NumParts = FMath::Min(Parts1.Num(), Parts2.Num());

	for (int i = 0; i < NumParts; ++i)
	{
		int32 Part1Value = FCString::Atoi(*Parts1[i]);
		int32 Part2Value = FCString::Atoi(*Parts2[i]);

		if (Part1Value < Part2Value)
		{
			return false; // VersionId1 < VersionId2
		}
		else if (Part1Value > Part2Value)
		{
			return true; // VersionId1 > VersionId2
		}
	}

	// 如果所有部分都相等，则比较剩余的部分
	if (Parts1.Num() < Parts2.Num())
	{
		return false; // VersionId1 < VersionId2
	}
	else if (Parts1.Num() > Parts2.Num())
	{
		return true; // VersionId1 > VersionId2
	}

	// 版本号完全相等
	return false;
}

void SHotPatcherPatchWidget::SendUploadRequest(const FString& ArchiveName, const FString& ProjectFolder)
{
	FHttpModule* Http = &FHttpModule::Get();
	// 第一步：获取签名信息
	auto GenerateSignatureRequest = Http->CreateRequest();
	GenerateSignatureRequest->SetVerb("GET");
	GenerateSignatureRequest->SetURL("https://aihuaman.heyi.test/api/oss/generateSignature");
	GenerateSignatureRequest->OnProcessRequestComplete().BindLambda(
		[=](FHttpRequestPtr Req, FHttpResponsePtr Res, bool bWasSuccessful)
		{
			if (Res && bWasSuccessful)
			{
				FString ResponseContent = Res->GetContentAsString();
				TSharedPtr<FJsonObject> JsonObject;
				TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(ResponseContent);
				if (FJsonSerializer::Deserialize(Reader, JsonObject))
				{
					TSharedPtr<FJsonObject> Datas = JsonObject->GetObjectField("data");

					FString OSSAccessKeyId = Datas->GetStringField("OSSAccessKeyId");
					FString Policy = Datas->GetStringField("policy");
					FString Signature = Datas->GetStringField("signature");
					FString Host = Datas->GetStringField("host");


					TMap<FString, FString> FormData;
					FormData.Add(TEXT("Key"), *FString("ganqu/0.1.0-0.2.0.zip"));
					FormData.Add(TEXT("policy"), *Policy);
					FormData.Add(TEXT("ossAccessKeyId"), *OSSAccessKeyId);
					FormData.Add(TEXT("signature"), *Signature);

					auto UploadFileRequest = Http->CreateRequest();
					UploadFileRequest->SetVerb("POST");
					UploadFileRequest->SetURL(Host);
					UploadFileRequest->SetHeader("Content-Type", "multipart/form-data");
					static FString Boundary = TEXT("----WebKitFormBoundary7MA4YWxkTrZu0gW");

					TArray<uint8> Payload;
					// 遍历 FormData 添加到 Payload
					for (const auto& Entry : FormData)
					{
						FString FieldHeader = FString::Printf(TEXT("--%s\r\n"), *Boundary);
						FieldHeader += FString::Printf(
							TEXT("Content-Disposition: form-data; name=\"%s\"\r\n\r\n"), *Entry.Key);
						FieldHeader += Entry.Value + TEXT("\r\n");

						TArray<uint8> FieldHeaderData;
						FieldHeaderData.Append((const uint8*)TCHAR_TO_UTF8(*FieldHeader), FieldHeader.Len());
						Payload.Append(FieldHeaderData);
					}


					TArray<uint8> OutArray;
					// 使用FFileHelper::LoadFileToArray函数读取文件
					FFileHelper::LoadFileToArray(
						OutArray, *FString("F:/WorkSpace/AIHuman/Saved/HotPatcher/0.1.0-0.2.0.zip"));

					// 添加文件部分头
					FString Header = TEXT("--") + Boundary + TEXT("\r\n");
					Header += FString::Printf(
						TEXT("Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n"),
						*FPaths::GetCleanFilename(FString("F:/WorkSpace/AIHuman/Saved/HotPatcher/0.1.0-0.2.0.zip")));
					Header += TEXT("Content-Type: application/octet-stream\r\n");
					Header += TEXT("Content-Transfer-Encoding: binary\r\n\r\n");

					// 将Header转换为UTF-8并添加到Payload
					TArray<uint8> HeaderData;
					HeaderData.Append((const uint8*)TCHAR_TO_UTF8(*Header), Header.Len());
					Payload.Append(HeaderData);

					// 添加文件数据
					Payload.Append(OutArray);

					// 添加文件部分尾
					FString FilePartEnd = TEXT("\r\n");
					TArray<uint8> FilePartEndData;
					FilePartEndData.Append((const uint8*)TCHAR_TO_UTF8(*FilePartEnd), FilePartEnd.Len());
					Payload.Append(FilePartEndData);


					FString EndBoundary = FString::Printf(TEXT("--%s--\r\n"), *Boundary);
					TArray<uint8> EndBoundaryData;
					EndBoundaryData.Append((const uint8*)TCHAR_TO_UTF8(*EndBoundary), EndBoundary.Len());
					Payload.Append(EndBoundaryData);

					// 使用HTTP请求发送Payload
					UploadFileRequest->SetContent(Payload);

					// 设置请求完成时的回调函数
					UploadFileRequest->OnProcessRequestComplete().BindLambda(
						[](FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
						{
							if (bWasSuccessful && Response.IsValid())
							{
								UE_LOG(LogTemp, Log, TEXT("Response Code: %d"), Response->GetResponseCode());
								UE_LOG(LogTemp, Log, TEXT("Response Content: %s"), *Response->GetContentAsString());
							}
							else
							{
								UE_LOG(LogTemp, Error, TEXT("Request failed"));
							}
						});
					UploadFileRequest->ProcessRequest();
				}
			}
			else
			{
				// 处理获取签名信息失败的情况
				UE_LOG(LogTemp, Error, TEXT("Failed to generate signature!"));
			}
		});

	GenerateSignatureRequest->ProcessRequest();
}


void SHotPatcherPatchWidget::ShowMsg(const FString& InMsg) const
{
	auto ErrorMsgShowLambda = [this](const FString& InErrorMsg)-> bool
	{
		bool bHasError = false;
		if (!InErrorMsg.IsEmpty())
		{
			this->SetInformationContent(InErrorMsg);
			this->SetInfomationContentVisibility(EVisibility::Visible);
			bHasError = true;
		}
		else
		{
			if (this->InformationContentIsVisibility())
			{
				this->SetInformationContent(TEXT(""));
				this->SetInfomationContentVisibility(EVisibility::Collapsed);
			}
		}
		return bHasError;
	};

	ErrorMsgShowLambda(InMsg);
}

bool SHotPatcherPatchWidget::CanDiff() const
{
	bool bCanDiff = false;
	if (ExportPatchSetting)
	{
		bool bHasBase = !ExportPatchSetting->GetBaseVersion().IsEmpty() && FPaths::FileExists(
			ExportPatchSetting->GetBaseVersion());
		bool bHasVersionId = !ExportPatchSetting->GetVersionId().IsEmpty();
		bool bHasFilter = !!ExportPatchSetting->GetAssetIncludeFilters().Num();
		bool bHasSpecifyAssets = !!ExportPatchSetting->GetIncludeSpecifyAssets().Num();

		bCanDiff = bHasBase && bHasVersionId && (bHasFilter || bHasSpecifyAssets);
	}
	return bCanDiff;
}

FReply SHotPatcherPatchWidget::DoDiff() const
{
	FString BaseVersionContent;
	FHotPatcherVersion BaseVersion;

	bool bDeserializeStatus = false;

	if (ExportPatchSetting->IsByBaseVersion())
	{
		if (UFlibAssetManageHelper::LoadFileToString(ExportPatchSetting->GetBaseVersion(), BaseVersionContent))
		{
			bDeserializeStatus = THotPatcherTemplateHelper::TDeserializeJsonStringAsStruct(
				BaseVersionContent, BaseVersion);
		}
		if (!bDeserializeStatus)
		{
			UE_LOG(LogHotPatcher, Error, TEXT("Deserialize Base Version Faild!"));
			return FReply::Handled();
		}
	}
	ExportPatchSetting->Init();
	FHotPatcherVersion CurrentVersion;

	// UFlibPatchParserHelper::ExportReleaseVersionInfo(
	// 	ExportPatchSetting->GetVersionId(),
	// 	BaseVersion.VersionId,
	// 	FDateTime::UtcNow().ToString(),
	// 	UFlibAssetManageHelper::DirectoryPathsToStrings(ExportPatchSetting->GetAssetIncludeFilters()),
	// 		UFlibAssetManageHelper::DirectoryPathsToStrings(ExportPatchSetting->GetAssetIgnoreFilters()),
	// 	ExportPatchSetting->GetAllSkipContents(),
	// 	ExportPatchSetting->GetForceSkipClasses(),
	// 	ExportPatchSetting->GetAssetRegistryDependencyTypes(),
	// 	ExportPatchSetting->GetIncludeSpecifyAssets(),
	// 	ExportPatchSetting->GetAddExternAssetsToPlatform(),
	// 	ExportPatchSetting->IsIncludeHasRefAssetsOnly()
	// );
	CurrentVersion.VersionId = ExportPatchSetting->GetVersionId();
	CurrentVersion.BaseVersionId = BaseVersion.VersionId;
	CurrentVersion.Date = FDateTime::UtcNow().ToString();
	UFlibPatchParserHelper::RunAssetScanner(ExportPatchSetting->GetAssetScanConfig(), CurrentVersion);
	UFlibPatchParserHelper::ExportExternAssetsToPlatform(ExportPatchSetting->GetAddExternAssetsToPlatform(),
	                                                     CurrentVersion, true, ExportPatchSetting->GetHashCalculator());

	FPatchVersionDiff VersionDiffInfo = UFlibHotPatcherCoreHelper::DiffPatchVersionWithPatchSetting(
		*ExportPatchSetting, BaseVersion, CurrentVersion);

	bool bShowDeleteAsset = false;
	FString SerializeDiffInfo;
	THotPatcherTemplateHelper::TSerializeStructAsJsonString(VersionDiffInfo, SerializeDiffInfo);
	SetInformationContent(SerializeDiffInfo);
	SetInfomationContentVisibility(EVisibility::Visible);

	return FReply::Handled();
}

FReply SHotPatcherPatchWidget::DoClearDiff() const
{
	SetInformationContent(TEXT(""));
	SetInfomationContentVisibility(EVisibility::Collapsed);

	return FReply::Handled();
}

EVisibility SHotPatcherPatchWidget::VisibilityDiffButtons() const
{
	bool bHasBase = false;
	if (ExportPatchSetting && ExportPatchSetting->IsByBaseVersion())
	{
		FString BaseVersionFile = ExportPatchSetting->GetBaseVersion();
		bHasBase = !BaseVersionFile.IsEmpty() && FPaths::FileExists(BaseVersionFile);
	}

	if (bHasBase && CanExportPatch())
	{
		return EVisibility::Visible;
	}
	else
	{
		return EVisibility::Collapsed;
	}
}


FReply SHotPatcherPatchWidget::DoPreviewChunk() const
{
	FHotPatcherVersion BaseVersion;

	if (ExportPatchSetting->IsByBaseVersion() && !ExportPatchSetting->GetBaseVersionInfo(BaseVersion))
	{
		UE_LOG(LogHotPatcher, Error, TEXT("Deserialize Base Version Faild!"));
		return FReply::Handled();
	}
	else
	{
		// 在不进行外部文件diff的情况下清理掉基础版本的外部文件
		if (!ExportPatchSetting->IsEnableExternFilesDiff())
		{
			BaseVersion.PlatformAssets.Empty();
		}
	}
	ExportPatchSetting->Init();
	UFlibAssetManageHelper::UpdateAssetMangerDatabase(true);
	FChunkInfo NewVersionChunk = UFlibHotPatcherCoreHelper::MakeChunkFromPatchSettings(ExportPatchSetting.Get());

	FHotPatcherVersion CurrentVersion = UFlibPatchParserHelper::ExportReleaseVersionInfoByChunk(
		ExportPatchSetting->GetVersionId(),
		BaseVersion.VersionId,
		FDateTime::UtcNow().ToString(),
		NewVersionChunk,
		ExportPatchSetting->IsIncludeHasRefAssetsOnly(),
		ExportPatchSetting->AssetScanConfig.bAnalysisFilterDependencies,
		ExportPatchSetting->GetHashCalculator()
	);

	FString CurrentVersionSavePath = ExportPatchSetting->GetCurrentVersionSavePath();
	FPatchVersionDiff VersionDiffInfo = UFlibHotPatcherCoreHelper::DiffPatchVersionWithPatchSetting(
		*ExportPatchSetting, BaseVersion, CurrentVersion);

	TArray<FChunkInfo> PatchChunks = ExportPatchSetting->GetChunkInfos();

	// create default chunk
	if (ExportPatchSetting->IsCreateDefaultChunk())
	{
		FChunkInfo TotalChunk = UFlibPatchParserHelper::CombineChunkInfos(ExportPatchSetting->GetChunkInfos());

		FChunkAssetDescribe ChunkDiffInfo = UFlibHotPatcherCoreHelper::DiffChunkWithPatchSetting(
			*ExportPatchSetting,
			NewVersionChunk,
			TotalChunk
		);
		if (ChunkDiffInfo.HasValidAssets())
		{
			PatchChunks.Add(ChunkDiffInfo.AsChunkInfo(TEXT("Default")));
		}
	}

	FString ShowMsg;
	for (const auto& Chunk : PatchChunks)
	{
		FChunkAssetDescribe ChunkAssetsDescrible = UFlibPatchParserHelper::CollectFChunkAssetsDescribeByChunk(
			ExportPatchSetting.Get(), VersionDiffInfo, Chunk, ExportPatchSetting->GetPakTargetPlatforms());
		ShowMsg.Append(FString::Printf(TEXT("Chunk:%s\n"), *Chunk.ChunkName));
		auto AppendFilesToMsg = [&ShowMsg](const FString& CategoryName, const TArray<FName>& InFiles)
		{
			if (!!InFiles.Num())
			{
				ShowMsg.Append(FString::Printf(TEXT("%s:\n"), *CategoryName));
				for (const auto& File : InFiles)
				{
					ShowMsg.Append(FString::Printf(TEXT("\t%s\n"), *File.ToString()));
				}
			}
		};
		AppendFilesToMsg(TEXT("UE Assets"), ChunkAssetsDescrible.GetAssetsStrings());

		for (auto Platform : ExportPatchSetting->GetPakTargetPlatforms())
		{
			TArray<FName> PlatformExFiles;
			FString PlatformName = THotPatcherTemplateHelper::GetEnumNameByValue(Platform, false);
			PlatformExFiles.Append(ChunkAssetsDescrible.GetExternalFileNames(Platform));
			AppendFilesToMsg(PlatformName, PlatformExFiles);
		}
		AppendFilesToMsg(TEXT("Internal Files"), ChunkAssetsDescrible.GetInternalFileNames());
		ShowMsg.Append(TEXT("\n"));
	}


	if (!ShowMsg.IsEmpty())
	{
		this->ShowMsg(ShowMsg);
	}
	return FReply::Handled();
}

bool SHotPatcherPatchWidget::CanPreviewChunk() const
{
	return ExportPatchSetting->IsEnableChunk();
}

EVisibility SHotPatcherPatchWidget::VisibilityPreviewChunkButtons() const
{
	if (CanPreviewChunk())
	{
		return EVisibility::Visible;
	}
	else
	{
		return EVisibility::Collapsed;
	}
}

bool SHotPatcherPatchWidget::CanExportPatch() const
{
	return UFlibPatchParserHelper::IsValidPatchSettings(ExportPatchSetting.Get(),
	                                                    GetDefault<UHotPatcherSettings>()->bExternalFilesCheck);
}

FReply SHotPatcherPatchWidget::DoExportPatch()
{
	TSharedPtr<FExportPatchSettings> PatchSettings = MakeShareable(new FExportPatchSettings);
	*PatchSettings = *GetConfigSettings();
	FHotPatcherEditorModule::Get().CookAndPakByPatchSettings(PatchSettings, PatchSettings->IsStandaloneMode());

	return FReply::Handled();
}

FText SHotPatcherPatchWidget::GetGenerateTooltipText() const
{
	FString FinalString;
	if (GetMutableDefault<UHotPatcherSettings>()->bPreviewTooltips && ExportPatchSetting)
	{
		bool bHasBase = false;
		if (ExportPatchSetting->IsByBaseVersion())
			bHasBase = !ExportPatchSetting->GetBaseVersion().IsEmpty() && FPaths::FileExists(
				ExportPatchSetting->GetBaseVersion());
		else
			bHasBase = true;
		bool bHasVersionId = !ExportPatchSetting->GetVersionId().IsEmpty();
		bool bHasFilter = !!ExportPatchSetting->GetAssetIncludeFilters().Num();
		bool bHasSpecifyAssets = !!ExportPatchSetting->GetIncludeSpecifyAssets().Num();
		// bool bHasExternFiles = !!ExportPatchSetting->GetAddExternFiles().Num();
		// bool bHasExDirs = !!ExportPatchSetting->GetAddExternDirectory().Num();

		bool bHasExternFiles = true;
		if (GetDefault<UHotPatcherSettings>()->bExternalFilesCheck)
		{
			bHasExternFiles = !!ExportPatchSetting->GetAllPlatfotmExternFiles().Num();
		}
		bool bHasExDirs = !!ExportPatchSetting->GetAddExternAssetsToPlatform().Num();
		bool bHasSavePath = !ExportPatchSetting->GetSaveAbsPath().IsEmpty();
		bool bHasPakPlatfotm = !!ExportPatchSetting->GetPakTargetPlatforms().Num();

		bool bHasAnyPakFiles = (
			bHasFilter || bHasSpecifyAssets || bHasExternFiles || bHasExDirs ||
			ExportPatchSetting->IsIncludeEngineIni() ||
			ExportPatchSetting->IsIncludePluginIni() ||
			ExportPatchSetting->IsIncludeProjectIni()
		);
		struct FStatus
		{
			FStatus(bool InMatch, const FString& InDisplay): bMatch(InMatch)
			{
				Display = FString::Printf(TEXT("%s:%s"), *InDisplay, InMatch ? TEXT("true") : TEXT("false"));
			}

			FString GetDisplay() const { return Display; }
			bool bMatch;
			FString Display;
		};
		TArray<FStatus> AllStatus;
		AllStatus.Emplace(bHasBase,TEXT("BaseVersion"));
		AllStatus.Emplace(bHasVersionId,TEXT("HasVersionId"));
		AllStatus.Emplace(bHasAnyPakFiles,TEXT("HasAnyPakFiles"));
		AllStatus.Emplace(bHasPakPlatfotm,TEXT("HasPakPlatfotm"));
		AllStatus.Emplace(bHasSavePath,TEXT("HasSavePath"));

		for (const auto& Status : AllStatus)
		{
			FinalString += FString::Printf(TEXT("%s\n"), *Status.GetDisplay());
		}
	}
	return UKismetTextLibrary::Conv_StringToText(FinalString);
}

bool SHotPatcherPatchWidget::CanPreviewPatch() const
{
	bool bHasFilter = !!ExportPatchSetting->GetAssetIncludeFilters().Num();
	bool bHasSpecifyAssets = !!ExportPatchSetting->GetIncludeSpecifyAssets().Num();

	auto HasExFilesLambda = [this]()
	{
		bool result = false;
		const TMap<ETargetPlatform, FPlatformExternFiles>& ExFiles = ExportPatchSetting->
			GetAllPlatfotmExternFiles(false);
		if (!!ExFiles.Num())
		{
			TArray<ETargetPlatform> Platforms;
			ExFiles.GetKeys(Platforms);
			for (const auto& Platform : Platforms)
			{
				if (!!ExFiles.Find(Platform)->ExternFiles.Num())
				{
					result = true;
					break;
				}
			}
		}
		return result;
	};
	bool bHasExternFiles = true;
	if (GetDefault<UHotPatcherSettings>()->bExternalFilesCheck)
	{
		bHasExternFiles = HasExFilesLambda();
	}

	bool bHasAnyPakFiles = (
		bHasFilter || bHasSpecifyAssets || bHasExternFiles ||
		ExportPatchSetting->IsIncludeEngineIni() ||
		ExportPatchSetting->IsIncludePluginIni() ||
		ExportPatchSetting->IsIncludeProjectIni()
	);

	return bHasFilter || bHasSpecifyAssets || bHasExternFiles || bHasAnyPakFiles;
}


FReply SHotPatcherPatchWidget::DoPreviewPatch()
{
	ExportPatchSetting->Init();
	FChunkInfo DefaultChunk;
	FHotPatcherVersion BaseVersion;

	if (ExportPatchSetting->IsByBaseVersion())
	{
		ExportPatchSetting->GetBaseVersionInfo(BaseVersion);
		DefaultChunk = UFlibHotPatcherCoreHelper::MakeChunkFromPatchVerison(BaseVersion);
		if (!ExportPatchSetting->IsEnableExternFilesDiff())
		{
			BaseVersion.PlatformAssets.Empty();
		}
	}

	FChunkInfo NewVersionChunk = UFlibHotPatcherCoreHelper::MakeChunkFromPatchSettings(ExportPatchSetting.Get());

	FChunkAssetDescribe ChunkAssetsDescrible = UFlibHotPatcherCoreHelper::DiffChunkByBaseVersionWithPatchSetting(
		*ExportPatchSetting.Get(), NewVersionChunk, DefaultChunk, BaseVersion);

	TArray<FName> AllUnselectedAssets = ChunkAssetsDescrible.GetAssetsStrings();
	TArray<FName> UnSelectedInternalFiles = ChunkAssetsDescrible.GetInternalFileNames();

	FString TotalMsg;
	auto ChunkCheckerMsg = [&TotalMsg](const FString& Category, const TArray<FName>& InAssetList)
	{
		if (!!InAssetList.Num())
		{
			TotalMsg.Append(FString::Printf(TEXT("\n%s:\n"), *Category));
			for (const auto& Asset : InAssetList)
			{
				TotalMsg.Append(FString::Printf(TEXT("\t%s\n"), *Asset.ToString()));
			}
		}
	};
	ChunkCheckerMsg(TEXT("Unreal Asset"), AllUnselectedAssets);
	ChunkCheckerMsg(TEXT("External Files"), TArray<FName>{});
	for (auto Platform : ExportPatchSetting->GetPakTargetPlatforms())
	{
		TArray<FName> PlatformExFiles;
		FString PlatformName = THotPatcherTemplateHelper::GetEnumNameByValue(Platform, false);
		PlatformExFiles.Append(ChunkAssetsDescrible.GetExternalFileNames(Platform));
		PlatformExFiles.Append(ChunkAssetsDescrible.GetExternalFileNames(ETargetPlatform::AllPlatforms));
		ChunkCheckerMsg(PlatformName, PlatformExFiles);
	}

	ChunkCheckerMsg(TEXT("Internal Files"), UnSelectedInternalFiles);

	if (!TotalMsg.IsEmpty())
	{
		ShowMsg(FString::Printf(TEXT("Patch Assets:\n%s"), *TotalMsg));
		return FReply::Handled();
	}

	return FReply::Handled();
}

FReply SHotPatcherPatchWidget::DoAddToPreset() const
{
	UHotPatcherSettings* Settings = GetMutableDefault<UHotPatcherSettings>();
	Settings->PresetConfigs.Add(*const_cast<SHotPatcherPatchWidget*>(this)->GetConfigSettings());
	Settings->SaveConfig();
	return FReply::Handled();
}

void SHotPatcherPatchWidget::CreateExportFilterListView()
{
	// Create a property view
	FPropertyEditorModule& EditModule = FModuleManager::Get().GetModuleChecked<FPropertyEditorModule>("PropertyEditor");

	FDetailsViewArgs DetailsViewArgs;
	{
		DetailsViewArgs.bAllowSearch = true;
		DetailsViewArgs.bHideSelectionTip = true;
		DetailsViewArgs.bLockable = false;
		DetailsViewArgs.bSearchInitialKeyFocus = true;
		DetailsViewArgs.bUpdatesFromSelection = false;
		DetailsViewArgs.NotifyHook = nullptr;
		DetailsViewArgs.bShowOptions = true;
		DetailsViewArgs.bShowModifiedPropertiesOption = false;
		DetailsViewArgs.bShowScrollBar = false;
		DetailsViewArgs.bShowOptions = true;
	}

	FStructureDetailsViewArgs StructureViewArgs;
	{
		StructureViewArgs.bShowObjects = true;
		StructureViewArgs.bShowAssets = true;
		StructureViewArgs.bShowClasses = true;
		StructureViewArgs.bShowInterfaces = true;
	}

	SettingsView = EditModule.CreateStructureDetailView(DetailsViewArgs, StructureViewArgs, nullptr);
	FStructOnScope* Struct = new FStructOnScope(FExportPatchSettings::StaticStruct(), (uint8*)ExportPatchSetting.Get());
	SettingsView->SetStructureData(MakeShareable(Struct));
}


#undef LOCTEXT_NAMESPACE
