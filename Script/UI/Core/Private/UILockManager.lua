-- UILockManager.lua
-- Lock 锁定层管理器，用于显示加载动画、转菊花等锁定界面

local UILayerManager = require("Script.UI.Core.Private.UILayerManager")
local UIConfig = require("Script.UI.Core.UIConfig")
local Log = require("Utility.Log")
local EventLoop = require("Script.Core.EventLoop")

---@class UILockManager
local M = {
    lockController = nil,
    lockTimer = nil,
    showing = false,
    isInitialized = false,
    defaultLockUI = "DefaultLock"
}

--- 默认超时时间（秒）
local DEFAULT_TIMEOUT = 30

--- 初始化
function M:Initialize()
    if self.isInitialized then return end
    
    self.lockController = nil
    self.lockTimer = nil
    self.showing = false
    self.isInitialized = true
end

--- 显示 Lock（手动关闭）
--- @param message string|nil 提示信息
--- @return boolean
function M:Show(message)
    return self:ShowWithTimeout(message, 0)
end

--- 显示 Lock（超时自动关闭）
--- @param message string|nil 提示信息
--- @param timeout number|nil 超时时间（秒），nil=默认30秒，0=不超时
--- @return boolean
function M:ShowWithTimeout(message, timeout)
    -- 参数校验
    if message ~= nil and type(message) ~= "string" then
        Log.Error("UILockManager", "Invalid message: expected string or nil")
        return false
    end
    
    if timeout ~= nil and type(timeout) ~= "number" then
        Log.Error("UILockManager", "Invalid timeout: expected number or nil")
        return false
    end
    
    self:Initialize()
    
    if UILayerManager.Initialize and not UILayerManager.isInitialized then
        UILayerManager:Initialize()
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
    
    -- 创建 Controller
    if not self.lockController then
        local config = UIConfig[self.defaultLockUI]
        if not config then
            Log.Error("UILockManager", "UI config not found: " .. tostring(self.defaultLockUI))
            return false
        end
        
        self.lockController = self:CreateLock(self.defaultLockUI, config)
        if not self.lockController then
            return false
        end
    end
    
    -- 更新消息
    if message and self.lockController.UpdateModel then
        self.lockController:UpdateModel({ message = message })
    end
    
    -- 显示
    local layerType = UILayerManager.LayerType and UILayerManager.LayerType.Lock or nil
    if not self.lockController.Show then
        Log.Error("UILockManager", "Controller has no Show method")
        return false
    end
    
    local success, err = pcall(function()
        self.lockController:Show(layerType)
    end)
    
    if not success then
        Log.Error("UILockManager", "Failed to show lock: " .. tostring(err))
        return false
    end
    
    self.showing = true
    
    -- 设置定时器
    local timeoutSeconds = timeout or DEFAULT_TIMEOUT
    if timeoutSeconds > 0 then
        self:StartTimeoutTimer(timeoutSeconds)
    end
    
    return true
end

--- 启动超时定时器
--- @param timeout number 超时时间（秒）
function M:StartTimeoutTimer(timeout)
    self:ClearTimer()
    
    local timeoutMs = math.floor(timeout * 1000)
    local lockId = self.showing  -- 捕获当前状态，防止定时器触发时状态已变
    
    self.lockTimer = EventLoop.Timeout(timeoutMs, function()
        if self.showing and lockId then
            Log.Warning("UILockManager", "Lock timeout after " .. timeout .. " seconds, auto hide")
            self:Hide()
        end
    end, false)
end

--- 清除定时器
function M:ClearTimer()
    if self.lockTimer then
        if self.lockTimer.stop then
            pcall(function() self.lockTimer:stop() end)
        end
        self.lockTimer = nil
    end
end

--- 隐藏 Lock
--- @return boolean
function M:Hide()
    if not self.showing then
        return false
    end
    
    self:ClearTimer()
    
    if self.lockController and self.lockController.Hide then
        local ok, err = pcall(function()
            self.lockController:Hide()
        end)
        
        if not ok then
            Log.Error("UILockManager", "Failed to hide lock: " .. tostring(err))
            -- Hide 失败时销毁 controller，确保下次 Show 能重建
            if self.lockController.Destroy then
                pcall(function() self.lockController:Destroy() end)
            end
            self.lockController = nil
            self.showing = false
            return false
        end
    end
    
    self.showing = false
    return true
end

--- 更新消息
--- @param message string 提示信息
--- @return boolean
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

--- 创建 Lock 实例
--- @param uiName string UI 名称
--- @param config table UI 配置
--- @return UIControllerBase|nil
function M:CreateLock(uiName, config)
    local ViewClass = config[1]
    local ControllerClass = config[2]
    local ModelData = config[3] or {}
    
    if not ViewClass or not ControllerClass then
        Log.Error("UILockManager", "Invalid config: " .. tostring(uiName))
        return nil
    end
    
    local world = UE.GetWorld()
    if not world then
        Log.Error("UILockManager", "Failed to get world")
        return nil
    end

    local view = UE.UWidgetBlueprintLibrary.Create(world, ViewClass, nil)
    if not view then
        Log.Error("UILockManager", "Failed to create View: " .. tostring(uiName))
        return nil
    end
    
    local controller = ControllerClass.new(view, ModelData)
    if not controller then
        Log.Error("UILockManager", "Failed to create Controller: " .. tostring(uiName))
        return nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

--- 检查是否正在显示
--- @return boolean
function M:IsShowing()
    return self.showing
end

--- 销毁
function M:Destroy()
    -- 清理定时器
    self:ClearTimer()
    
    -- 隐藏并销毁 controller
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
    self.isInitialized = false
end

return M
