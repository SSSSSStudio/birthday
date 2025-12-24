// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UnLuaInterface.h"
#include "Interfaces/IHttpRequest.h"
#include "Interfaces/IHttpResponse.h"
#include "HttpObject.generated.h"


UENUM(BlueprintType)
enum class EHttpVerb : uint8
{
	Get UMETA(DisplayName = "GET"),
	Post UMETA(DisplayName = "POST"),
	Put UMETA(DisplayName = "PUT"),
	Delete UMETA(DisplayName = "DELETE"),
	Patch UMETA(DisplayName = "PATCH"),
	Head UMETA(DisplayName = "HEAD"),
	Options UMETA(DisplayName = "OPTIONS"),
	Trace UMETA(DisplayName = "TRACE"),
};

UENUM(BlueprintType)
enum class EHttpContentType : uint8
{
	None UMETA(DisplayName = "None"),
	Form_Urlencoded UMETA(DisplayName = "application/x-www-form-urlencoded"),
	Form_Data UMETA(DisplayName = "multipart/form-data"),
	Application_Json UMETA(DisplayName = "application/json"),
	Application_XML UMETA(DisplayName = "application/xml"),
	Application_JS UMETA(DisplayName = "application/javascript"),
	Text_Plain UMETA(DisplayName = "text/plain"),
	Text_Html UMETA(DisplayName = "text/html"),
};

USTRUCT(BlueprintType)
struct FHttpRequestParam
{
	GENERATED_BODY()

	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	TMap<FString, FString> Params;
};

class FHttpHelperUnit
{
public:
	static FString GetVerbString(EHttpVerb Verb)
	{
		switch (Verb)
		{
		case EHttpVerb::Get:
			return TEXT("GET");
		case EHttpVerb::Post:
			return TEXT("Post");
		case EHttpVerb::Put:
			return TEXT("Put");
		case EHttpVerb::Delete:
			return TEXT("DELETE");
		case EHttpVerb::Patch:
			return TEXT("PATCH");
		case EHttpVerb::Head:
			return TEXT("HEAD");
		case EHttpVerb::Options:
			return TEXT("OPTIONS");
		case EHttpVerb::Trace:
			return TEXT("TRACE");
		}
		return "";
	}

	static FString GetContentType(EHttpContentType Type)
	{
		switch (Type)
		{
		case EHttpContentType::Form_Urlencoded:
			return TEXT("application/x-www-form-urlencoded");
		case EHttpContentType::Form_Data:
			return TEXT("multipart/form-data");
		case EHttpContentType::Application_Json:
			return TEXT("application/json");
		case EHttpContentType::Application_XML:
			return TEXT("application/xml");
		case EHttpContentType::Application_JS:
			return TEXT("application/javascript");
		case EHttpContentType::Text_Plain:
			return TEXT("text/plain");
		case EHttpContentType::Text_Html:
			return TEXT("text/html");
		}
		return "";
	}

	static FString GetToken(const FString& Token)
	{
		FString RealToken = Token;

		//以Json格式解析string
		TSharedPtr<FJsonObject> JsonObject;
		TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(Token);
		if (FJsonSerializer::Deserialize(Reader, JsonObject))
		{
			if (JsonObject->HasField(TEXT("token")))
			{
				RealToken = JsonObject->GetStringField(TEXT("token"));
			}
		}

		return "Bearer " + RealToken;
	}
};


DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FHttpResultDelegate, const FString&, Result, int32, Code);


UCLASS()
class G01_API UHttpObject : public UObject, public IUnLuaInterface
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	static UHttpObject* HttpAsyncAction(const FString& URL, EHttpVerb Verb, EHttpContentType ContentType, const FString& ContentString, FString Token);

	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	void Request();

	UPROPERTY(BlueprintAssignable)
	FHttpResultDelegate OnCompleted;

	UFUNCTION(BlueprintImplementableEvent)
	void OnCompletedimplementation(const FString& Result, int32 Code);

	virtual FString GetModuleName_Implementation() const override
	{
		return TEXT("Helper.HttpObject");
	}

private:
	void OnHttpRequestCompleted(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bSuccess);

private:
	FString SendURL;
	EHttpVerb SendVerb;
	EHttpContentType SendContentType;
	FString SendContentString;
	FString SendToken;	
};
