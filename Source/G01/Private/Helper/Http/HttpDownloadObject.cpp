// Fill out your copyright notice in the Description page of Project Settings.


#include "Helper/Http/HttpDownloadObject.h"
#include "HttpModule.h"


UHttpDownloadObject* UHttpDownloadObject::HttpAsyncAction(const FString& URL, EHttpVerb Verb, EHttpContentType ContentType, const FString& ContentString, const FString& Token, const FString& SavePath)
{
	UHttpDownloadObject* Node = NewObject<UHttpDownloadObject>();
	Node->SendURL = URL;
	Node->SendVerb = Verb;
	Node->SendContentType = ContentType;
	Node->SendContentString = ContentString;
	Node->SavePath = SavePath;
	Node->SendToken = Token;
	Node->AddToRoot();
	return Node;
}

void UHttpDownloadObject::Request()
{
	TSharedPtr<IHttpRequest, ESPMode::ThreadSafe> HttpRequest = FHttpModule::Get().CreateRequest();
	HttpRequest->SetURL(SendURL);
	HttpRequest->SetVerb(FHttpHelperUnit::GetVerbString(SendVerb));
	HttpRequest->SetHeader("Content-Type", FHttpHelperUnit::GetContentType(SendContentType));
	if (SendToken != "")
	{
		HttpRequest->SetHeader("Authorization", SendToken);
	}
	if (!SendContentString.IsEmpty())
	{
		HttpRequest->SetContentAsString(SendContentString);
	}

	HttpRequest->OnProcessRequestComplete().BindUObject(this, &UHttpDownloadObject::OnHttpRequestCompleted);
	HttpRequest->ProcessRequest();
}

void UHttpDownloadObject::OnHttpRequestCompleted(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bSuccess)
{
	if (bSuccess && Response.IsValid())
	{
		if (SavePath.Len() > 0)
		{
			// 获取默认的文件管理器
			IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();

			// 确保目录存在
			PlatformFile.CreateDirectoryTree(*FPaths::GetPath(SavePath));
			// 将数据写入文件
			if (FFileHelper::SaveArrayToFile(Response->GetContent(), (*SavePath)))
			{
				FString ResponseStr = "true";
				int32 RespomseCode = Response->GetResponseCode();
				OnCompletedimplementation(ResponseStr, RespomseCode);
			}
		}
	}
	else
	{
		FString ResponseStr = "false";
		int32 RespomseCode = -1;
		OnCompletedimplementation(ResponseStr, RespomseCode);
	}
	RemoveFromRoot();
}
