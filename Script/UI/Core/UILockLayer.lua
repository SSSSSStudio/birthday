-- UILockLayer.lua
-- Lock 层管理器：显示加载动画、转菊花等锁定界面
local Interface = require("Utility.Interface")
---@type UEHelper
local UEHelper = require("Core.UEHelper")
---@type Log
local Log = require("Utility.Log")
---@type EventLoop
local EventLoop = require("Core.EventLoop")
---@type UILayerSystem
local UILayerSystem = require "UI.Core.UILayerSystem"
---@type UIConfigSystem
local UIConfigSystem = require("UI.UIConfigSystem")

local DEFAULT_TIMEOUT<const> = 30

---@class UILockLayer
local M = Interface("UILockLayer")

function M:__init()
	self.lockController = nil
	self.lockTimer = nil
end

function M:__gc()
	self:Close()
end

---@param name string
---@param model ModelBase
---@param timeout integer|nil 超时时间（秒），nil=默认30秒，0=不超时
---@return UIControllerBase
function M:Open(name, model, message, timeout)
	self:Close()
	local config = UIConfigSystem.Get(name)
	if not config then
		Log.Error("UIConfigSystem", "UIConfig not found: " .. name)
		return nil
	end

	local viewClass = UE.UClass.Load(config.viewPath)
	if not viewClass then
		Log.Error("Failed to load View class for: " .. name)
		return nil
	end

	local view = UE.UWidgetBlueprintLibrary.Create(UEHelper.GetWorld(),viewClass)
	UILayerSystem.AddToLayer(view, "Lock")
	self.lockController = config.controllerClass:New(name,view,model,message)

	timeout = timeout or DEFAULT_TIMEOUT
	if timeout ~= 0 then
		local timeoutMs = timeout * 1000
		self.lockTimer = EventLoop.Timeout(timeoutMs, function()
				self.lockTimer = nil
				self:Close()
		end, false)	
	end
	
	return self.lockController
end

function M:Close()
	if self.lockTimer then
		self.lockTimer:stop()
        self.lockTimer = nil
	end
	if self.lockController then
        self.lockController:Destroy()
        self.lockController = nil
    end
end

function M:IsLocked()
	return self.lockController ~= nil
end

return M
