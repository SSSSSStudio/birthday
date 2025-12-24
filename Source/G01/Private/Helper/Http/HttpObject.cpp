// Fill out your copyright notice in the Description page of Project Settings.


#include "Helper/Http/HttpObject.h"

#include "HttpModule.h"


UHttpObject* UHttpObject::HttpAsyncAction(const FString& URL, EHttpVerb Verb, EHttpContentType ContentType, const FString& ContentString, FString Token)
{
	UHttpObject* Node = NewObject<UHttpObject>();
	Node->SendURL = URL;
	Node->SendVerb = Verb;
	Node->SendContentType = ContentType;
	Node->SendContentString = ContentString;
	Node->SendToken = Token;
	Node->AddToRoot();
	return Node;
}

void UHttpObject::Request()
{
	TSharedPtr<IHttpRequest, ESPMode::ThreadSafe> HttpRequest = FHttpModule::Get().CreateRequest();
	HttpRequest->SetURL(SendURL);

	HttpRequest->SetVerb(FHttpHelperUnit::GetVerbString(SendVerb));
	HttpRequest->SetHeader("Content-Type", FHttpHelperUnit::GetContentType(SendContentType));
	if (SendToken != "")
	{
		HttpRequest->SetHeader("Access-Token", SendToken);
	}
	if (!SendContentString.IsEmpty())
	{
		HttpRequest->SetContentAsString(SendContentString);
	}

	HttpRequest->OnProcessRequestComplete().BindUObject(this, &UHttpObject::OnHttpRequestCompleted);
	HttpRequest->ProcessRequest();
}

void UHttpObject::OnHttpRequestCompleted(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bSuccess)
{
	if (bSuccess && Response.IsValid())
	{
		FString ResponseStr = Response->GetContentAsString();
		int32 RespomseCode = Response->GetResponseCode();
		OnCompletedimplementation(ResponseStr, RespomseCode);
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("HTTP Request failed"));
	}
	RemoveFromRoot();
}