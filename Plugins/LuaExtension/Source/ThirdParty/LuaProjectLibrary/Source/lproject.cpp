#include "lproject.h"
#include "Core.h"
static const int32_t s_iRunningKey = 0;

static bool receive_beginplay(struct lua_State *L)
{
	lua_rawgetp(L, LUA_REGISTRYINDEX, &s_iRunningKey);
	if (lua_isboolean(L, -1))
    {
        lua_pop(L, 1);
        return false;
    }
	
	int32_t type = lua_rawgetp(L, LUA_REGISTRYINDEX, receive_beginplay);
	check(type == LUA_TFUNCTION);
    int32_t rc = lua_pcall(L, 0, 0, 0);
	if (rc != LUA_OK)
	{
		lua_pop(L, 1);
		return false;
	}
	lua_pushboolean(L, 1);
	lua_rawsetp(L, LUA_REGISTRYINDEX, &s_iRunningKey);
	return true;
}


bool lproject_endplay(struct lua_State *L)
{
	lua_rawgetp(L, LUA_REGISTRYINDEX, &s_iRunningKey);
	if (!lua_isboolean(L, -1))
	{
		lua_pop(L, 1);
		return false;
	}
	
	lua_pushboolean(L, 0);
	lua_rawsetp(L, LUA_REGISTRYINDEX, &s_iRunningKey);
	
	int32_t type = lua_rawgetp(L, LUA_REGISTRYINDEX, lproject_endplay);
	check(type == LUA_TFUNCTION);
	return lua_pcall(L, 0, 0, 0) == LUA_OK;
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

static int32_t lproject_shutdown(lua_State *L)
{
	lua_pushboolean(L, lproject_endplay(L));
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
	lua_rawgetp(L, LUA_REGISTRYINDEX, &s_iRunningKey);
	if (!lua_isboolean(L, -1))
	{
		lua_pop(L, 1);
		return false;
	}
	
	int32_t type = lua_rawgetp(L, LUA_REGISTRYINDEX, lproject_tick);
	check(type == LUA_TFUNCTION);
	lua_pushnumber(L,(lua_Number)DeltaTime);
	return lua_pcall(L, 1, 0, 0) == LUA_OK;
}

int32_t luaopen_lproject(struct lua_State *L)
{    
	luaL_Reg lualib_project[] =
    {
        {"startup", lproject_startup},
        {"shutdown", lproject_shutdown},
		{"set_beginplay_callback", lproject_set_beginplay_callback},
        {"set_endplay_callback", lproject_set_endplay_callback},
        {"set_tick_callback", lproject_set_tick_callback},
		{"get_content_dir", lproject_get_content_dir},
        {"get_app_external_dir", lproject_get_app_external_dir},
        {"get_app_sandboxes_dir", lproject_get_app_sandboxes_dir},
        {NULL, NULL}
    };

	luaL_newlib(L,lualib_project);
	return 1;
}