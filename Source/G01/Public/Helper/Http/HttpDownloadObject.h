// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Helper/Http/HttpObject.h"
#include "HttpDownloadObject.generated.h"

/**
 * 
 */
UCLASS()
class G01_API UHttpDownloadObject : public UObject, public IUnLuaInterface
{
	GENERATED_BODY()
	
public:
	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	static UHttpDownloadObject* HttpAsyncAction(const FString& URL, EHttpVerb Verb, EHttpContentType ContentType, const FString& ContentString, const FString& Token, const FString& SavePath);

	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	void Request();

	UFUNCTION(BlueprintImplementableEvent)
	void OnCompleted(const FString& Result, int32 Code);

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
	FString SavePath;
};
