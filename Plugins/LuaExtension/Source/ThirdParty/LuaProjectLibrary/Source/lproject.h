#pragma once

#include "lua.hpp"

int32_t luaopen_lproject(struct lua_State *L);

bool lproject_tick(struct lua_State *L, float DeltaTime);
