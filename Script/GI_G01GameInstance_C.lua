require("Config.Debugger")
local LuaHelper = require("Utility.LuaHelper")
local EventLoop = require("Core.EventLoop")

---@type GI_G01GameInstance_C
local M = UnLua.Class()

function M:ReceiveInit()
	LuaHelper.DisableGlobalVariable()
	EventLoop.Startup();
end

function M:ReceiveShutdown()
	EventLoop.Shutdown();
end

function M:RunTest()
	local test = require("TestCase.UnluaTest.RunAllTests")
end

return M