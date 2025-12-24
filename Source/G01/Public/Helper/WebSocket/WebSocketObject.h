// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "WebSocketObject.generated.h"

class IWebSocket;

UCLASS()
class G01_API UWebSocketObject : public UObject
{
	GENERATED_BODY()

public:
	virtual void BeginDestroy() override;

	void Connect(const FString& Url);

	void Close();

	void SendStringMessage(const FString& Data);

	void SendMessage(const void* Data, int64_t Length);
	
	bool IsConnected();

	void SetLuaSetCallback(int32_t OnMessage, int32_t OnConnected, int32_t OnError, int32_t OnClosed, int32_t OnBinaryMessage);

	void OnConnected();

	void OnClosed(int32 StatusCode, const FString& Reason, bool bWasClean);

	void OnMessage(const FString& Message);

	void OnBinaryMessage(const void* Data, SIZE_T Size, bool bIsLastFragment);

	void OnError(const FString& Error);

private:
	TSharedPtr<IWebSocket> NativeSocket = nullptr;
	int32_t refOnMessage = -1;
	int32_t refOnConnected = -1;
	int32_t refOnClosed = -1;
	int32_t refOnError = -1;
	int32_t refOnBinaryMessage = -1;	
};
