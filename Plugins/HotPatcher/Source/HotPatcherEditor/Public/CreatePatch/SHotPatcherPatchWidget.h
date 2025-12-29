// Copyright 1998-2016 Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Model/FPatchersModeContext.h"
#include "CreatePatch/FExportPatchSettings.h"
#include "SHotPatcherInformations.h"
#include "SHotPatcherWidgetBase.h"
#include "FPatchVersionDiff.h"
#include "CreatePatch/FExportPatchSettings.h"

// engine header
#include "Interfaces/ITargetPlatformManagerModule.h"
#include "Interfaces/ITargetPlatform.h"
#include "Templates/SharedPointer.h"
#include "IDetailsView.h"
#include "PropertyEditorModule.h"
#include "Widgets/Text/SMultiLineEditableText.h"
#include "IStructureDetailsView.h"
#include "Interfaces/IHttpRequest.h"


/**
 * Implements the cooked platforms panel.
 */
class SHotPatcherPatchWidget
	: public SHotPatcherWidgetBase
{
public:

	SLATE_BEGIN_ARGS(SHotPatcherPatchWidget) { }
	SLATE_END_ARGS()

public:

	/**
	 * Constructs the widget.
	 *
	 * @param InArgs The Slate argument list.
	 */
	void Construct(	const FArguments& InArgs,TSharedPtr<FHotPatcherContextBase> InCreateModel);

// IPatchableInterface
public:
	virtual void ImportConfig();
	virtual void ExportConfig()const;
	virtual void ResetConfig();
	virtual void DoGenerate();
	virtual FString GetMissionName() override{return TEXT("Patch");}
protected:
	void CreateExportFilterListView();
	bool CanExportPatch()const;
	FReply DoExportPatch();
	virtual FText GetGenerateTooltipText() const override;
	
	bool CanPreviewPatch()const;
	FReply DoPreviewPatch();
	
	FReply DoAddToPreset()const;
	FReply DoDiff()const;
	bool CanDiff()const;
	FReply DoClearDiff()const;
	EVisibility VisibilityDiffButtons()const;

	FReply DoPreviewChunk()const;
	bool CanPreviewChunk()const;
	EVisibility VisibilityPreviewChunkButtons()const;

	bool InformationContentIsVisibility()const;
	void SetInformationContent(const FString& InContent)const;
	void SetInfomationContentVisibility(EVisibility InVisibility)const;

	virtual FExportPatchSettings* GetConfigSettings() override{return ExportPatchSetting.Get();}

	virtual void ImportProjectConfig() override;

	virtual void UploadPackage() override;

	void CreateAndRunBatchScript(const FString& SourceDir, const FString& OutputDir);
	
	/**
	 * 刷新win本地版本表
	 */
	void FlushWindowsVersionJson();
	
	/**
	 * 刷新安卓本地版本表
	 */
	void FlushAndroidVersionJson();

	/**
	 * 字符串对比
	 * @param VersionId1 
	 * @param VersionId2 
	 * @return 
	 */
	bool CompareVersionIds(const FString& VersionId1, const FString& VersionId2);

	/**
	 * 未使用
	 * @param ArchiveName 
	 * @param ProjectFolder 
	 */
	void SendUploadRequest(const FString& ArchiveName, const FString& ProjectFolder);

protected:

	void ShowMsg(const FString& InMsg)const;

private:

	// TSharedPtr<FHotPatcherCreatePatchModel> mCreatePatchModel;

	/** Settings view ui element ptr */
	TSharedPtr<IStructureDetailsView> SettingsView;

	TSharedPtr<FExportPatchSettings> ExportPatchSetting;

	TSharedPtr<SHotPatcherInformations> DiffWidget;
};

