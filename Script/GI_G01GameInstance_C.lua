require("Config.Debugger")
local LuaHelper = require("Utility.LuaHelper")
local EventLoop = require("Core.EventLoop")
local UIManager = require("UI.Core.UIManager")
local UIConfig = require("UI.Core.UIConfig")

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
	UIManager.Initialize(self);
	UIManager.StateOpen(UIConfig.Main.Name);
end

return M