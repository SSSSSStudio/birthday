-- UIToastManager.lua
-- Toast 提示管理器，负责管理 Toast 层级的 UI
-- 支持多个 Toast 同时显示，自动消失

local UILayerManager = require("Script.UI.Core.Private.UILayerManager")
local UIConfig = require("Script.UI.Core.UIConfig")
local Log = require("Utility.Log")
local EventLoop = require("Script.Core.EventLoop")

---@class UIToastManager
local M = {
    toastCache = {},         -- Toast 对象池（按 uiName 分组的空闲实例列表）
    toastList = {},          -- 当前显示的 Toast 列表
    nextToastId = 1,         -- 下一个 Toast ID
    isInitialized = false,   -- 是否已初始化
}

--- Toast 配置
local DEFAULT_DURATION = 2.0  -- 默认显示时长（秒）
local TOAST_SPACING = 10      -- Toast 之间的间距（像素）
local MAX_TOAST_COUNT = 3     -- 最大 Toast 堆叠数量
local DEFAULT_TOAST_HEIGHT = 60  -- 默认 Toast 高度（像素）
local TOAST_START_Y = 50      -- Toast 起始 Y 坐标（像素）
local MAX_POOL_SIZE = 5       -- 每种 Toast 最多缓存数量

--- 初始化 Toast 管理器
function M:Initialize()
    if self.isInitialized then return end
    self.toastCache = {}
    self.toastList = {}
    self.nextToastId = 1
    self.isInitialized = true
end

--- 显示 Toast
--- @param uiName string UI 名称（对应 UIConfig 中的键名）
--- @param params table|nil 传递给 UI 的参数（可选）
--- @param duration number|nil 显示时长（秒），默认 2.0 秒
--- @return number toastId Toast ID，用于手动关闭（失败时返回 0）
function M:Show(uiName, params, duration)
    -- 参数类型检查
    if type(uiName) ~= "string" or uiName == "" then
        Log.Error("UIToastManager", "Invalid uiName: expected non-empty string")
        return 0
    end
    
    if duration ~= nil and type(duration) ~= "number" then
        Log.Error("UIToastManager", "Invalid duration: expected number")
        return 0
    end
    
    self:Initialize()

    -- 确保 UILayerManager 已初始化
    if UILayerManager.Initialize and not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIToastManager", "UI config not found: " .. tostring(uiName))
        return 0
    end

    -- 移除多余的 Toast（防止死循环）
    local maxAttempts = MAX_TOAST_COUNT + 1
    local attempts = 0
    while #self.toastList >= MAX_TOAST_COUNT and attempts < maxAttempts do
        if not self:Close(self.toastList[1].toastId, true) then
            Log.Error("UIToastManager", "Failed to close oldest toast")
            break
        end
        attempts = attempts + 1
    end
    
    -- 从对象池获取或创建 Toast
    local pool = self.toastCache[uiName]
    if not pool then
        pool = {}
        self.toastCache[uiName] = pool
    end
    
    -- 尝试从池中取一个空闲实例
    local controller = table.remove(pool)
    if not controller then
        -- 池中没有空闲实例，创建新的
        controller = self:CreateToast(uiName, config)
        if not controller then return 0 end
    end
    
    -- 更新参数
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    -- 显示 Toast
    if controller.Show then
        local layerType = UILayerManager.LayerType and UILayerManager.LayerType.Toast or nil
        local status, err = pcall(function() 
            controller:Show(layerType) 
        end)
        if not status then
            Log.Error("UIToastManager", "Show failed: " .. tostring(err))
            return 0
        end
    else
        return 0
    end

    -- 创建 Toast 信息
    local toastId = self.nextToastId
    self.nextToastId = self.nextToastId + 1
    
    local toastInfo = {
        toastId = toastId,
        uiName = uiName,
        controller = controller,
        duration = duration or DEFAULT_DURATION,
    }
    
    table.insert(self.toastList, toastInfo)
    
    -- 更新位置并启动定时器
    self:UpdateToastPositions()
    self:StartAutoCloseTimer(toastInfo)
    
    return toastId
end

--- 创建 Toast 实例
--- @param uiName string UI 名称
--- @param config table UI 配置
--- @return UIControllerBase|nil 控制器实例
function M:CreateToast(uiName, config)
    local ViewClass = config[1]
    local ControllerClass = config[2]
    local ModelData = config[3] or {}
    
    if not ViewClass or not ControllerClass then
        Log.Error("UIToastManager", "Invalid config: " .. tostring(uiName))
        return nil
    end
    
    local world = UE.GetWorld()
    if not world then
        Log.Error("UIToastManager", "Failed to get world")
        return nil
    end

    local view = UE.UWidgetBlueprintLibrary.Create(world, ViewClass, nil)
    if not view then
        Log.Error("UIToastManager", "Failed to create View: " .. tostring(uiName))
        return nil
    end
    
    local controller = ControllerClass.new(view, ModelData)
    if not controller then
        Log.Error("UIToastManager", "Failed to create Controller: " .. tostring(uiName))
        return nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

--- 启动自动关闭定时器
--- @param toastInfo table Toast 信息
function M:StartAutoCloseTimer(toastInfo)
    local durationMs = math.floor((toastInfo.duration or DEFAULT_DURATION) * 1000)
    local toastId = toastInfo.toastId
    
    toastInfo.timer = EventLoop.Timeout(durationMs, function()
        if self:IsShowing(toastId) then
            self:Close(toastId)
        end
    end, false)
end

--- 关闭指定 Toast
--- @param toastId number Toast ID
--- @param silent boolean|nil 是否静默关闭（不触发重排），用于批量操作
--- @return boolean true 如果成功关闭，false 如果 Toast 不存在
function M:Close(toastId, silent)
    if not self.isInitialized then return false end
    
    for i, info in ipairs(self.toastList) do
        if info.toastId == toastId then
            -- 清理定时器
            if info.timer and info.timer.stop then
                pcall(function() info.timer:stop() end)
                info.timer = nil
            end
            
            -- 隐藏并放回对象池
            if info.controller then
                if info.controller.Hide then
                    pcall(function() info.controller:Hide() end)
                end
                
                if info.uiName then
                    local pool = self.toastCache[info.uiName]
                    if pool and #pool < MAX_POOL_SIZE then
                        table.insert(pool, info.controller)
                    elseif info.controller.Destroy then
                        pcall(function() info.controller:Destroy() end)
                    end
                end
            end
            
            table.remove(self.toastList, i)
            if not silent then
                self:UpdateToastPositions()
            end
            
            return true
        end
    end
    
    return false
end

--- 关闭所有 Toast
function M:CloseAll()
    if not self.isInitialized then return end
    
    for i = #self.toastList, 1, -1 do
        self:Close(self.toastList[i].toastId, true)
    end
    
    self:UpdateToastPositions()
end

--- 更新所有 Toast 的位置（从上到下堆叠）
function M:UpdateToastPositions()
    local currentY = TOAST_START_Y
    
    for _, info in ipairs(self.toastList) do
        if info.controller then
            local widget = (info.controller.GetView and info.controller:GetView()) or info.controller.view
            if widget then
                if widget.ForceLayoutPrepass then
                    widget:ForceLayoutPrepass()
                end

                local slot = widget.Slot
                if slot and slot.IsA and slot:IsA(UE.UCanvasPanelSlot) then
                    slot:SetPosition(UE.FVector2D(0, currentY))
                end
                
                local height = 0
                if widget.GetDesiredSize then
                    height = widget:GetDesiredSize().Y
                end
                if height <= 0 and slot and slot.GetSize then
                    height = slot:GetSize().Y
                end
                
                currentY = currentY + (height > 0 and height or DEFAULT_TOAST_HEIGHT) + TOAST_SPACING
            end
        end
    end
end

--- 获取当前显示的 Toast 数量
--- @return number Toast 数量
function M:GetCount()
    return #self.toastList
end

--- 检查指定 Toast 是否正在显示
--- @param toastId number Toast ID
--- @return boolean true 如果正在显示，false 否则
function M:IsShowing(toastId)
    for _, info in ipairs(self.toastList) do
        if info.toastId == toastId then return true end
    end
    return false
end

--- 预加载 Toast（提前创建并放入对象池，但不显示）
--- @param uiName string UI 名称
--- @param count number|nil 预加载数量，默认 1
--- @return boolean true 如果成功预加载
function M:Preload(uiName, count)
    self:Initialize()
    
    count = math.max(1, math.min(count or 1, MAX_POOL_SIZE))
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIToastManager", "UI config not found: " .. tostring(uiName))
        return false
    end
    
    local pool = self.toastCache[uiName]
    if not pool then
        pool = {}
        self.toastCache[uiName] = pool
    end
    
    -- 检查池中现有数量，避免重复创建
    local currentCount = #pool
    local needCreate = math.max(0, count - currentCount)
    
    for i = 1, needCreate do
        local controller = self:CreateToast(uiName, config)
        if controller then
            table.insert(pool, controller)
        else
            Log.Error("UIToastManager", "Failed to preload toast: " .. tostring(uiName))
            return false
        end
    end
    
    return true
end

--- 手动卸载指定 Toast（从对象池中移除并销毁）
--- @param uiName string UI 名称
function M:Unload(uiName)
    local pool = self.toastCache[uiName]
    if pool then
        for _, controller in ipairs(pool) do
            if controller and controller.Destroy then
                controller:Destroy()
            end
        end
        self.toastCache[uiName] = nil
    end
end

--- 清空对象池
function M:ClearCache()
    self:CloseAll()
    
    for uiName, pool in pairs(self.toastCache) do
        if pool then
            for _, controller in ipairs(pool) do
                if controller and controller.Destroy then
                    controller:Destroy()
                end
            end
        end
    end
    
    self.toastCache = {}
end

--- 销毁 Toast 管理器
function M:Destroy()
    self:ClearCache()
    self.toastList = {}
    self.isInitialized = false
end

return M