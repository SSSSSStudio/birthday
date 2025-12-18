require "Utility.Debugger"
local LuaHelper = require "Utility.LuaHelper"
local EventLoop = require "Utility.EventLoop"

---@type GI_G01GameInstance_C
local M = UnLua.Class()

function M:ReceiveInit()
	LuaHelper.DisableGlobalVariable()
	EventLoop.Startup();
end

function M:ReceiveShutdown()
	EventLoop.Shutdown();
end

return M