// Fill out your copyright notice in the Description page of Project Settings.


#include "Helper/Http/HttpUploadObject.h"
#include "HttpModule.h"


UHttpUploadObject* UHttpUploadObject::HttpAsyncAction(const FString& URL, EHttpVerb Verb, EHttpContentType ContentType, const FString& ContentString, const FString& Token, const FString& FilePath)
{
	UHttpUploadObject* Node = NewObject<UHttpUploadObject>();
	Node->SendURL = URL;
	Node->SendVerb = Verb;
	Node->SendContentType = ContentType;
	Node->SendContentString = ContentString;
	Node->FilePath = FilePath;
	Node->SendToken = Token;
	Node->AddToRoot();
	return Node;
}

void UHttpUploadObject::Request()
{
	TSharedRef<IHttpRequest, ESPMode::ThreadSafe> HttpRequest = FHttpModule::Get().CreateRequest();
	HttpRequest->SetVerb(FHttpHelperUnit::GetVerbString(SendVerb));
	HttpRequest->SetURL(SendURL);
	static FString Boundary = TEXT("----WebKitFormBoundary7MA4YWxkTrZu0gW");
	HttpRequest->SetHeader("Content-Type", FString::Printf(TEXT("%s;boundary=%s"), *FHttpHelperUnit::GetContentType(SendContentType), *Boundary));
	if (SendToken != "")
	{
		HttpRequest->SetHeader("Authorization", SendToken);
	}
	if (!FilePath.IsEmpty())
	{
		TArray<uint8> OutArray;
		// 使用FFileHelper::LoadFileToArray函数读取文件
		if (FFileHelper::LoadFileToArray(OutArray, *FilePath))
		{
			TArray<uint8> Payload;

			// 添加文件部分头
			FString Header = TEXT("--") + Boundary + TEXT("\r\n");
			Header += FString::Printf(TEXT("Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n"), *FPaths::GetCleanFilename(FilePath));
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

			// 添加其他字段（示例）
			FString OtherFields;
			//FString OtherFields = FString::Printf(TEXT("--%s\r\nContent-Disposition: form-data; name=\"projectId\"\r\n\r\n\r\n--%s\r\n"), *Boundary, *Boundary);
			//OtherFields += FString::Printf(TEXT("Content-Disposition: form-data; name=\"pid\"\r\n\r\n%s\r\n"), *Pid);

			OtherFields += FString::Printf(TEXT("--%s--\r\n"), *Boundary); // 结束边界

			TArray<uint8> OtherFieldsData;
			OtherFieldsData.Append((const uint8*)TCHAR_TO_UTF8(*OtherFields), OtherFields.Len());
			Payload.Append(OtherFieldsData);

			// 使用HTTP请求发送Payload
			HttpRequest->SetHeader(TEXT("Content-Type"), FString::Printf(TEXT("multipart/form-data; boundary=%s"), *Boundary));
			HttpRequest->SetContent(Payload);
		}
	}
	// 设置请求完成时的回调函数
	HttpRequest->OnProcessRequestComplete().BindUObject(this, &UHttpUploadObject::OnHttpRequestCompleted);
	HttpRequest->ProcessRequest();
}

void UHttpUploadObject::OnHttpRequestCompleted(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bSuccess)
{
	if (bSuccess && Response.IsValid())
	{
		FString ResponseStr = Response->GetContentAsString();
		int32 RespomseCode = Response->GetResponseCode();
		OnCompletedimplementation(ResponseStr, RespomseCode);
		//删除文件
		if (FilePath.Len() > 0)
		{
			FString FolderPath = FPaths::GetPath(FilePath);
			IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();

			if (PlatformFile.DirectoryExists(*FolderPath))
			{
				PlatformFile.DeleteDirectoryRecursively(*FolderPath);
			}
		}
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("HTTP Request failed"));
	}
	RemoveFromRoot();
}
