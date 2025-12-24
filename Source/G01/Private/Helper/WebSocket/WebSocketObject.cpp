// Fill out your copyright notice in the Description page of Project Settings.


#include "Helper/WebSocket/WebSocketObject.h"

#include "IWebSocket.h"
#include "WebSocketsModule.h"
#include "Serialization/BufferArchive.h"

#include "LuaCore.h"
#include "UnLua.h"
#include "UnLuaEx.h"

void UWebSocketObject::Close()
{
	if (IsConnected())
	{
		NativeSocket->Close();
		NativeSocket = nullptr;
	}
}

void UWebSocketObject::SendStringMessage(const FString& Data)
{
	if (!IsConnected())
	{
		return;
	}
	if (Data.Len() <= 0)
	{
		return;
	}
	NativeSocket->Send(Data);
}

void UWebSocketObject::SendMessage(const void* Data, int64_t Length)
{
	if (!IsConnected())
	{
		return;
	}
	if (Length <= 0)
	{
		return;
	}
	NativeSocket->Send(Data, Length, true);
}

void UWebSocketObject::Connect(const FString& Url)
{
	if (!Url.IsEmpty())
	{
		NativeSocket = FWebSocketsModule::Get().CreateWebSocket(Url);
		NativeSocket->OnConnected().AddUObject(this, &UWebSocketObject::OnConnected);
		NativeSocket->OnClosed().AddUObject(this, &UWebSocketObject::OnClosed);
		NativeSocket->OnMessage().AddUObject(this, &UWebSocketObject::OnMessage);
		NativeSocket->OnBinaryMessage().AddUObject(this, &UWebSocketObject::OnBinaryMessage);
		NativeSocket->OnConnectionError().AddUObject(this, &UWebSocketObject::OnError);
		NativeSocket->Connect();
	}
}

bool UWebSocketObject::IsConnected()
{
	if (nullptr == NativeSocket)
	{
		return false;
	}
	return NativeSocket->IsConnected();
}

void UWebSocketObject::BeginDestroy()
{
	Super::BeginDestroy();
	if (refOnMessage != -1)
	{
		lua_State* L = UnLua::GetState();
		if (L)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnMessage);
		}
		refOnMessage = -1;
	}

	if (refOnConnected != -1)
	{
		lua_State* L = UnLua::GetState();
		if (L)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnConnected);
		}
		refOnConnected = -1;
	}

	if (refOnClosed != -1)
	{
		lua_State* L = UnLua::GetState();
		if (L)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnClosed);
		}
		refOnClosed = -1;
	}


	if (refOnError != -1)
	{
		lua_State* L = UnLua::GetState();
		if (L)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnError);
		}
		refOnError = -1;
	}
}

void UWebSocketObject::SetLuaSetCallback(int32_t OnMessage, int32_t OnConnected, int32_t OnError, int32_t OnClosed, int32_t OnBinaryMessage)
{
	if (OnMessage != -1)
	{
		lua_State* L = UnLua::GetState();
		if (refOnMessage != -1)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnMessage);
		}
		refOnMessage = OnMessage;
	}
	if (OnConnected != -1)
	{
		lua_State* L = UnLua::GetState();
		if (refOnConnected != -1)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnConnected);
		}
		refOnConnected = OnConnected;
	}

	if (OnError != -1)
	{
		lua_State* L = UnLua::GetState();
		if (refOnError != -1)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnError);
		}
		refOnError = OnError;
	}

	if (OnClosed != -1)
	{
		lua_State* L = UnLua::GetState();
		if (refOnClosed != -1)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnClosed);
		}
		refOnClosed = OnClosed;
	}

	if (OnBinaryMessage != -1)
	{
		lua_State* L = UnLua::GetState();
		if (refOnBinaryMessage != -1)
		{
			luaL_unref(L,LUA_REGISTRYINDEX, refOnBinaryMessage);
		}
		refOnBinaryMessage = OnBinaryMessage;
	}
}


void UWebSocketObject::OnConnected()
{
	if (refOnConnected != -1)
	{
		lua_State* L = UnLua::GetState();
		lua_rawgeti(L,LUA_REGISTRYINDEX, refOnConnected);
		check(lua_isfunction(L, -1));
		lua_pcall(L, 0, 0, 0);
	}
}

void UWebSocketObject::OnClosed(int32 StatusCode, const FString& Reason, bool bWasClean)
{
	if (refOnClosed != -1)
	{
		lua_State* L = UnLua::GetState();
		lua_rawgeti(L,LUA_REGISTRYINDEX, refOnClosed);
		check(lua_isfunction(L, -1));
		lua_pushinteger(L, StatusCode);
		lua_pushstring(L, TCHAR_TO_UTF8(*Reason));
		lua_pushboolean(L, bWasClean);
		lua_pcall(L, 3, 0, 0);
	}
}

void UWebSocketObject::OnMessage(const FString& Message)
{
	if (refOnMessage != -1)
	{
		lua_State* L = UnLua::GetState();
		lua_rawgeti(L,LUA_REGISTRYINDEX, refOnMessage);
		check(lua_isfunction(L, -1));
		lua_pushstring(L, TCHAR_TO_UTF8(*Message));
		lua_pcall(L, 1, 0, 0);
	}
}

void UWebSocketObject::OnBinaryMessage(const void* Data, SIZE_T Size, bool bIsLastFragment)
{
	if (Size > 0)
	{
		lua_State* L = UnLua::GetState();
		lua_rawgeti(L,LUA_REGISTRYINDEX, refOnBinaryMessage);
		check(lua_isfunction(L, -1));
		lua_pushlstring(L, (const char*)Data, Size);
		lua_pushboolean(L, bIsLastFragment);
		lua_pcall(L, 2, 0, 0);
	}
}

void UWebSocketObject::OnError(const FString& Error)
{
	if (refOnError != -1)
	{
		lua_State* L = UnLua::GetState();
		lua_rawgeti(L,LUA_REGISTRYINDEX, refOnError);
		check(lua_isfunction(L, -1));
		lua_pushstring(L, TCHAR_TO_UTF8(*Error));
		lua_pcall(L, 1, 0, 0);
	}
}

static int32 UWebSocketObject_SendMessage(lua_State* L)
{
	const int32 NumParams = lua_gettop(L);
	if (NumParams < 1)
	{
		return luaL_error(L, "invalid parameters");
	}

	UWebSocketObject* V = Cast<UWebSocketObject>(UnLua::GetUObject(L, 1));
	if (!V)
	{
		return luaL_error(L, "invalid UWebSocketObject");
	}

	const void* buffer = NULL;
	size_t length = 0;

	int32_t type = lua_type(L, 2);
	switch (type)
	{
	case LUA_TSTRING:
		{
			buffer = (const void*)lua_tolstring(L, 2, &length);
		}
		break;
	case LUA_TLIGHTUSERDATA:
		{
			buffer = (const void*)lua_touserdata(L, 2);
			length = luaL_checkinteger(L, 3);
		}
		break;
	default:
		luaL_error(L, "invalid param %s", lua_typename(L, lua_type(L, 2)));
	}

	V->SendMessage(buffer, length);
	return 0;
}

static FORCEINLINE void TArray_Guard(lua_State* L, FLuaArray* Array)
{
	if (!Array)
	{
		luaL_error(L, "invalid TArray");
	}

	if (!Array->Inner->IsValid())
	{
		luaL_error(L, TCHAR_TO_UTF8(*FString::Printf(TEXT("invalid TArray element type:%s"), *Array->Inner->GetName())));
	}
}

static int32 UWebSocketObject_SendArrayMessage(lua_State* L)
{
	const int32 NumParams = lua_gettop(L);
	if (NumParams < 1)
	{
		return luaL_error(L, "invalid parameters");
	}

	UWebSocketObject* V = Cast<UWebSocketObject>(UnLua::GetUObject(L, 1));
	if (!V)
	{
		return luaL_error(L, "invalid UWebSocketObject");
	}

	FLuaArray* Array = (FLuaArray*)(GetCppInstanceFast(L, 2));
	TArray_Guard(L, Array);

	V->SendMessage(Array->GetData(), Array->Num());
	return 0;
}

static int32 UWebSocketObject_New(lua_State* L)
{
	UWebSocketObject* Obj = NewObject<UWebSocketObject>();
	UnLua::PushUObject(L, Obj);
	return 1;
}

static int32 UWebSocketObject_SetCallback(lua_State* L)
{
	const int32 NumParams = lua_gettop(L);
	if (NumParams < 1)
	{
		return luaL_error(L, "invalid parameters");
	}

	UWebSocketObject* V = Cast<UWebSocketObject>(UnLua::GetUObject(L, 1));
	if (!V)
	{
		return luaL_error(L, "invalid UWebSocketObject");
	}

	if (NumParams >= 2)
	{
		int32_t OnMessageRef = -1;
		int32_t OnConnectedRef = -1;
		int32_t OnErrorRef = -1;
		int32_t OnClosedRef = -1;
		int32_t refOnBinaryMessage = -1;

		if (lua_isfunction(L, 2))
		{
			lua_pushvalue(L, 2);
			OnMessageRef = luaL_ref(L, LUA_REGISTRYINDEX);
		}
		if (lua_isfunction(L, 3))
		{
			lua_pushvalue(L, 3);
			OnConnectedRef = luaL_ref(L, LUA_REGISTRYINDEX);
		}
		if (lua_isfunction(L, 4))
		{
			lua_pushvalue(L, 4);
			OnErrorRef = luaL_ref(L, LUA_REGISTRYINDEX);
		}
		if (lua_isfunction(L, 5))
		{
			lua_pushvalue(L, 5);
			OnClosedRef = luaL_ref(L, LUA_REGISTRYINDEX);
		}
		if (lua_isfunction(L, 6))
		{
			lua_pushvalue(L, 6);
			refOnBinaryMessage = luaL_ref(L, LUA_REGISTRYINDEX);
		}
		V->SetLuaSetCallback(OnMessageRef, OnConnectedRef, OnErrorRef, OnClosedRef, refOnBinaryMessage);
	}
	return 0;
}


static const luaL_Reg UWebSocketObjectLib[] =
{
	{"__call", UWebSocketObject_New},
	{"SendMessage", UWebSocketObject_SendMessage},
	{"SendArrayMessage", UWebSocketObject_SendArrayMessage},
	{"SetCallback", UWebSocketObject_SetCallback},
	{nullptr, nullptr}
};

BEGIN_EXPORT_REFLECTED_CLASS(UWebSocketObject)
	ADD_LIB(UWebSocketObjectLib)
	ADD_FUNCTION(Connect)
	ADD_FUNCTION(Close)
	ADD_FUNCTION(IsConnected)
	ADD_FUNCTION(SendStringMessage)
END_EXPORT_CLASS()

IMPLEMENT_EXPORTED_CLASS(UWebSocketObject)
