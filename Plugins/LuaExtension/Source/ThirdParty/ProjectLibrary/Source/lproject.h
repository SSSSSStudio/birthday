#pragma once

#include "lua.hpp"

int32 luaopen_lproject(struct lua_State *L);

bool lproject_tick(struct lua_State *L, float DeltaTime);

bool lproject_endplay(struct lua_State *L);
