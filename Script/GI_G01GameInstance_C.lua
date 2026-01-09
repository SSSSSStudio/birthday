require("Config.Debugger")
local LuaHelper = require("Utility.LuaHelper")
local EventLoop = require("Core.EventLoop")
local UIManager = require("UI.Core.UIManager")

---@type GI_G01GameInstance_C
local M = UnLua.Class()

function M:ReceiveInit()
	LuaHelper.DisableGlobalVariable()
	EventLoop.Startup()
end

function M:OnPreControllerBeginPlay()
	UIManager.Destroy()
	UIManager.Initialize(self)
end

function M:ReceiveShutdown()
	EventLoop.Shutdown()
end

function M:RunTest()
	
end

return M