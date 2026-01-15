-- UILockManager.lua
-- Lock 层管理器：显示加载动画、转菊花等锁定界面

local UIConfig = require("UI.Core.UIConfig")
local Log = require("Utility.Log")
local EventLoop = require("Core.EventLoop")
local Interface = require("Utility.Interface")
local LayerType = require("UI.Core.Private.LayerType")
local DEFAULT_TIMEOUT<const> = 30

---@class UILockManager
local M = Interface("UILockManager")

function M:__init()
	self.lockController = nil
	self.lockTimer = nil
	self.showing = false
	self.defaultLockUI = "Lock"
end

---显示 Lock（手动关闭）
---@param message string|nil 提示信息
---@return boolean
function M:Show(message)
    return self:ShowWithTimeout(message, 0)
end

---显示 Lock（超时自动关闭）
---@param message string|nil 提示信息
---@param timeout number|nil 超时时间（秒），nil=默认30秒，0=不超时
---@return boolean
function M:ShowWithTimeout(message, timeout)
    if message ~= nil and type(message) ~= "string" then
        Log.Error("UILockManager", "Invalid message: expected string or nil")
        return false
    end
    
    if timeout ~= nil and type(timeout) ~= "number" then
        Log.Error("UILockManager", "Invalid timeout: expected number or nil")
        return false
    end
    -- 已显示时只更新消息和定时器
    if self.showing then
        if message and self.lockController and self.lockController.UpdateModel then
            self.lockController:UpdateModel({ message = message })
        end
        
        local timeoutSeconds = timeout or DEFAULT_TIMEOUT
        if timeoutSeconds > 0 then
            self:StartTimeoutTimer(timeoutSeconds)
        else
            self:ClearTimer()
        end
        
        return true
    end
    
    -- 每次都创建新实例
    local config = UIConfig[self.defaultLockUI]
    if not config then
        Log.Error("UILockManager", "UI config not found: " .. tostring(self.defaultLockUI))
        return false
    end
    
    self.lockController = self:CreateLock(self.defaultLockUI, config)
    if not self.lockController then
        return false
    end
    
    if message and self.lockController.UpdateModel then
        self.lockController:UpdateModel({ message = message })
    end
    
    if not self.lockController.Show then
        Log.Error("UILockManager", "Controller has no Show method")
        return false
    end
    
    local success, err = pcall(function()
        self.lockController:Show(LayerType.Lock)
    end)
    
    if not success then
        Log.Error("UILockManager", "Failed to show lock: " .. tostring(err))
        return false
    end
    
    self.showing = true
    
    local timeoutSeconds = timeout or DEFAULT_TIMEOUT
    if timeoutSeconds > 0 then
        self:StartTimeoutTimer(timeoutSeconds)
    end
    
    return true
end

---启动超时定时器
---@param timeout number 超时时间（秒）
function M:StartTimeoutTimer(timeout)
    self:ClearTimer()
    
    local timeoutMs = math.floor(timeout * 1000)
    local lockId = self.showing
    
    self.lockTimer = EventLoop.Timeout(timeoutMs, function()
        if self.showing and lockId then
            self:Hide()
        end
    end, false)
end

---清除定时器
function M:ClearTimer()
    if self.lockTimer then
        if self.lockTimer.stop then
            pcall(function() self.lockTimer:stop() end)
        end
        self.lockTimer = nil
    end
end

---隐藏 Lock
---@return boolean
function M:Hide()
    if not self.showing then
        return false
    end
    
    self:ClearTimer()
    
    if self.lockController then
        if self.lockController.Hide then
            local ok, err = pcall(function()
                self.lockController:Hide()
            end)
            
            if not ok then
                Log.Error("UILockManager", "Failed to hide lock: " .. tostring(err))
            end
        end
        
        -- 销毁实例
        if self.lockController.Destroy then
            pcall(function() self.lockController:Destroy() end)
        end
        self.lockController = nil
    end
    
    self.showing = false
    return true
end

---更新消息
---@param message string 提示信息
---@return boolean
function M:UpdateMessage(message)
    if type(message) ~= "string" then
        Log.Error("UILockManager", "Invalid message: expected string")
        return false
    end
    
    if not self.showing or not self.lockController then
        return false
    end
    
    if self.lockController.UpdateModel then
        self.lockController:UpdateModel({ message = message })
        return true
    end
    
    return false
end

---创建 Lock 实例
---@param uiName string UI 名称
---@param config table UI 配置
---@return UIControllerBase|nil
function M:CreateLock(uiName, config)
    if not config.ViewPath or not config.ControllerClass then
        Log.Error("UILockManager", "Invalid config: " .. tostring(uiName))
        return nil
    end
	

    local ViewClass = UE.UClass.Load(config.ViewPath)
    if not ViewClass then
        Log.Error("UILockManager", "Failed to load ViewClass: " .. tostring(config.ViewPath))
        return nil
    end

	-- 创建 View 实例
	local view = NewObject(ViewClass)
	if not view then
		error("Failed to create View for: " .. tostring(uiName))
		return nil
	end
    
    local model = config.ModelClass and config.ModelClass.New(config.ModelClass) or nil
    local controller = config.ControllerClass.New(config.ControllerClass, view, model)
    if not controller then
        Log.Error("UILockManager", "Failed to create Controller: " .. tostring(uiName))
        return nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

---检查是否正在显示
---@return boolean
function M:IsShowing()
    return self.showing
end

---销毁
function M:Destroy()
    self:ClearTimer()
    
    if self.lockController then
        if self.lockController.Hide then
            pcall(function() self.lockController:Hide() end)
        end
        if self.lockController.Destroy then
            pcall(function() self.lockController:Destroy() end)
        end
        self.lockController = nil
    end
    
    self.showing = false
end

return M
