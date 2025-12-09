#include "lproject.h"
#include "Core.h"

static bool receive_beginplay(struct lua_State *L)
{
	bool bRunning = lua_isboolean(L, lua_upvalueindex(1));
	if (bRunning)
	{
		return false;
	}
	lua_rawgetp(L, LUA_REGISTRYINDEX, (const void *)receive_beginplay);
    int32_t rc = lua_pcall(L, 0, 0, 0);
	bRunning = rc == LUA_OK; 
	if(bRunning)
	{
		lua_pushboolean(L, 1);
		lua_replace(L, lua_upvalueindex(1));
	}
	return bRunning;
}

static int32_t lproject_set_beginplay_callback(lua_State *L) 
{
 	luaL_argcheck(L, lua_isfunction(L, 1), 1, "expected function");
	lua_settop(L,1);
	lua_rawsetp(L, LUA_REGISTRYINDEX, (const void *)receive_beginplay);
	return 0;
}

static int32_t lproject_set_endplay_callback(lua_State *L) 
{
 	luaL_argcheck(L, lua_isfunction(L, 1), 1, "expected function");
	lua_settop(L,1);
	lua_rawsetp(L, LUA_REGISTRYINDEX, (const void *)lproject_endplay);
	return 0;
}

static int32_t lproject_set_tick_callback(lua_State *L) 
{
 	luaL_argcheck(L, lua_isfunction(L, 1), 1, "expected function");
	lua_settop(L,1);
	lua_rawsetp(L, LUA_REGISTRYINDEX, (const void *)lproject_tick);
	return 0;
}

static int32_t lproject_startup(lua_State *L)
{
	lua_pushboolean(L, receive_beginplay(L));
	return 1;
}

static int32_t lproject_get_content_dir(lua_State *L) 
{
	lua_pushstring(L, TCHAR_TO_UTF8(*FPaths::ConvertRelativePathToFull(FPaths::ProjectContentDir())));
	return 1;
}

static int32_t lproject_get_app_external_dir(lua_State *L) 
{
	lua_pushstring(L, TCHAR_TO_UTF8(*IFileManager::Get().ConvertToAbsolutePathForExternalAppForWrite(*(FPaths::ProjectPersistentDownloadDir() + TEXT("/")))));
	return 1;
}

static int32_t lproject_get_app_sandboxes_dir(lua_State *L) 
{
	lua_pushstring(L, TCHAR_TO_UTF8(*IFileManager::Get().ConvertToAbsolutePathForExternalAppForWrite(*(FPaths::SandboxesDir() + TEXT("/")))));
	return 1;
}

bool lproject_tick(struct lua_State *L, float DeltaTime)
{
	bool bRunning = lua_isboolean(L, lua_upvalueindex(1));
	if (!bRunning)
	{
		return false;
	}
	
	int32_t type = lua_rawgetp(L, LUA_REGISTRYINDEX, (const void *)lproject_tick);
	check(type == LUA_TFUNCTION)
	lua_pushnumber(L,(lua_Number)DeltaTime);
	return lua_pcall(L, 1, 0, 0) == LUA_OK;
}

bool lproject_endplay(struct lua_State *L)
{
	bool bRunning = lua_isboolean(L, lua_upvalueindex(1));
	if (!bRunning)
	{
		return false;
	}
	
	lua_pushboolean(L, 0);
	lua_replace(L, lua_upvalueindex(1));
	
	int32_t type = lua_rawgetp(L, LUA_REGISTRYINDEX, (const void *)lproject_endplay);
	check(type == LUA_TFUNCTION)
	return lua_pcall(L, 0, 0, 0) == LUA_OK;
}

int32 luaopen_lproject(struct lua_State *L)
{    
	luaL_Reg lualib_project[] =
    {
        {"startup", lproject_startup},
		{"set_beginplay_callback", lproject_set_beginplay_callback},
        {"set_endplay_callback", lproject_set_endplay_callback},
        {"set_tick_callback", lproject_set_tick_callback},
		{"get_content_dir", lproject_get_content_dir},
        {"get_app_external_dir", lproject_get_app_external_dir},
        {"get_app_sandboxes_dir", lproject_get_app_sandboxes_dir},
        {NULL, NULL}
    };

	luaL_checkversion(L);
	luaL_newlibtable(L,lualib_project);
	lua_pushboolean(L, 0);
 	luaL_setfuncs(L,lualib_project,1);
	return 1;
}