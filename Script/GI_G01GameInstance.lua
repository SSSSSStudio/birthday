require("Config.Debugger")
---@type LuaHelper
local LuaHelper = require("Utility.LuaHelper")
---@type EventLoop
local EventLoop = require("Core.EventLoop")

---@type UIManager
local UIManager = require("UI.UIManager")

---@type UEHelper
local UEHelper = require("Core.UEHelper")

---@type ProtoDispatcher
local ProtoDispatcher = require("Core.ProtoDispatcher")
---@type NetManager
local NetManager = require("Net.NetManager")

---@type GI_G01GameInstance_C
local M = UnLua.Class()

function M:ReceiveInit()
	LuaHelper.DisableGlobalVariable()
	EventLoop.Startup()
	UEHelper.Initialize(self)
	UIManager.Initialize()
	NetManager.Initialize()
end


function M:OnStartPlay()
    print("[GI_G01GameInstance] OnStartPlay ====================================")
end


function M:ReceiveShutdown()
    print("[GI_G01GameInstance] ReceiveShutdown ====================================")
    NetManager.Shutdown()
	UIManager.Destroy()
	ProtoDispatcher.Cleanup()
	EventLoop.Shutdown();
	UEHelper.Shutdown()
end

return M