-- UIToastManager.lua
-- Toast 管理器：支持多个提示同时显示

local UILayerManager = require("UI.Core.Private.UILayerManager")
local UIConfig = require("UI.Core.UIConfig")
local Log = require("Utility.Log")
local EventLoop = require("Core.EventLoop")

local DEFAULT_DURATION = 2.0
local TOAST_SPACING = 10
local MAX_TOAST_COUNT = 3
local DEFAULT_TOAST_HEIGHT = 20
local TOAST_START_Y = 20
local MAX_POOL_SIZE = 3

---@class UIToastManager
local M = {
    toastCache = {},
    toastList = {},
    toastQueue = {},
    nextToastId = 1,
    isInitialized = false,
}

function M:Initialize()
    if self.isInitialized then return end
    
    self.toastCache = {}
    self.toastList = {}
    self.toastQueue = {}
    self.nextToastId = 1
    self.isInitialized = true
end

---显示 Toast
---@param uiName string UI 名称
---@param params table|nil 参数
---@param duration number|nil 显示时长（秒，默认 2.0）
---@return number Toast ID（失败返回 0）
function M:Show(uiName, params, duration)
    if type(uiName) ~= "string" or uiName == "" then
        Log.Error("UIToastManager", "Invalid uiName")
        return 0
    end
    
    if duration ~= nil and type(duration) ~= "number" then
        Log.Error("UIToastManager", "Invalid duration")
        return 0
    end
    
    if params ~= nil and type(params) ~= "table" then
        Log.Error("UIToastManager", "Invalid params")
        return 0
    end
    
    self:Initialize()

    if UILayerManager.Initialize and not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIToastManager", "UI config not found: " .. tostring(uiName))
        return 0
    end

    -- 达到最大数量，加入等待队列
    if #self.toastList >= MAX_TOAST_COUNT then
        local toastId = self.nextToastId
        self.nextToastId = self.nextToastId + 1
        
        table.insert(self.toastQueue, {
            toastId = toastId,
            uiName = uiName,
            params = params,
            duration = duration or DEFAULT_DURATION,
        })
        return toastId
    end
    
    local pool = self.toastCache[uiName]
    if not pool then
        pool = {}
        self.toastCache[uiName] = pool
    end
    
    local controller = table.remove(pool)
    if not controller then
        controller = self:CreateToast(uiName, config)
        if not controller then return 0 end
    else
        if controller.Reset then
            pcall(function() controller:Reset() end)
        end
    end
    
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    if not controller.Show then
        Log.Error("UIToastManager", "Controller has no Show method")
        return 0
    end
    
    local layerType = UILayerManager.LayerType and UILayerManager.LayerType.Toast or nil
    controller:Show(layerType)

    local toastId = self.nextToastId
    self.nextToastId = self.nextToastId + 1
    
    local toastInfo = {
        toastId = toastId,
        uiName = uiName,
        controller = controller,
        duration = duration or DEFAULT_DURATION,
    }
    
    table.insert(self.toastList, toastInfo)
    self:UpdateToastPositions()
    self:StartAutoCloseTimer(toastInfo)
    
    return toastId
end

---创建 Toast 实例
---@param uiName string UI 名称
---@param config table UI 配置
---@return UIControllerBase|nil
function M:CreateToast(uiName, config)
    local ViewClass = UE.UClass.Load(config.ViewPath)
    
    if not ViewClass or not config.ControllerClass then
        Log.Error("UIToastManager", "Invalid config: " .. tostring(uiName))
        return nil
    end
    
    local world = UILayerManager.gameInstance:GetWorld()
    if not world then
        Log.Error("UIToastManager", "Failed to get world")
        return nil
    end
    
    local playerController = UE.UGameplayStatics.GetPlayerController(world, 0)
    if not playerController then
        Log.Error("UIToastManager", "Failed to get PlayerController")
        return nil
    end

    local view = UE.UWidgetBlueprintLibrary.Create(world, ViewClass, playerController)
    if not view then
        Log.Error("UIToastManager", "Failed to create View: " .. tostring(uiName))
        return nil
    end
    
    local controller = config.ControllerClass.New(config.ControllerClass, view, config.ModelClass or {})
    if not controller then
        Log.Error("UIToastManager", "Failed to create Controller: " .. tostring(uiName))
        return nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

---启动自动关闭定时器
---@param toastInfo table
function M:StartAutoCloseTimer(toastInfo)
    local durationMs = math.floor((toastInfo.duration or DEFAULT_DURATION) * 1000)
    local toastId = toastInfo.toastId
    
    toastInfo.timer = EventLoop.Timeout(durationMs, function()
        if self:IsShowing(toastId) then
            self:Close(toastId)
            -- 关闭后尝试显示队列中的下一个 Toast
            self:ShowNextFromQueue()
        end
    end, false)
end

---从队列显示下一个 Toast
function M:ShowNextFromQueue()
    if #self.toastQueue == 0 or #self.toastList >= MAX_TOAST_COUNT then
        return
    end
    
    local queuedToast = table.remove(self.toastQueue, 1)
    if not queuedToast then return end
    
    local config = UIConfig[queuedToast.uiName]
    if not config then
        Log.Error("UIToastManager", "UI config not found for queued toast: " .. tostring(queuedToast.uiName))
        return
    end
    
    local pool = self.toastCache[queuedToast.uiName]
    if not pool then
        pool = {}
        self.toastCache[queuedToast.uiName] = pool
    end
    
    local controller = table.remove(pool)
    if not controller then
        controller = self:CreateToast(queuedToast.uiName, config)
        if not controller then return end
    else
        if controller.Reset then
            pcall(function() controller:Reset() end)
        end
    end
    
    if queuedToast.params and controller.UpdateModel then
        controller:UpdateModel(queuedToast.params)
    end
    
    if not controller.Show then
        Log.Error("UIToastManager", "Controller has no Show method")
        return
    end
    
    local layerType = UILayerManager.LayerType and UILayerManager.LayerType.Toast or nil
    controller:Show(layerType)

    local toastInfo = {
        toastId = queuedToast.toastId,
        uiName = queuedToast.uiName,
        controller = controller,
        duration = queuedToast.duration,
    }
    
    table.insert(self.toastList, toastInfo)
    self:UpdateToastPositions()
    self:StartAutoCloseTimer(toastInfo)
end

---关闭指定 Toast
---@param toastId number Toast ID
---@param silent boolean|nil 是否静默关闭（不触发重排）
---@return boolean
function M:Close(toastId, silent)
    if not self.isInitialized then return false end
    
    for i, info in ipairs(self.toastList) do
        if info.toastId == toastId then
            if info.timer then
                if info.timer.stop then
                    pcall(function() info.timer:stop() end)
                end
                info.timer = nil
            end
            
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
                elseif info.controller.Destroy then
                    pcall(function() info.controller:Destroy() end)
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

---关闭所有 Toast
function M:CloseAll()
    if not self.isInitialized then return end
    
    for i = #self.toastList, 1, -1 do
        self:Close(self.toastList[i].toastId, true)
    end
    
    self.toastQueue = {}
    self:UpdateToastPositions()
end

---清空等待队列
function M:ClearQueue()
    if not self.isInitialized then return end
    self.toastQueue = {}
end

---更新所有 Toast 位置
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
                if slot and slot.IsA then
                    if slot:IsA(UE.UCanvasPanelSlot) then
                        slot:SetPosition(UE.FVector2D(0, currentY))
                    elseif slot:IsA(UE.UOverlaySlot) then
                        -- OverlaySlot 使用 Padding 进行定位
                        local margin = UE.FMargin()
                        margin.Top = currentY
                        slot:SetPadding(margin)
                        
                        -- 覆盖默认的 Fill 对齐，防止拉伸
                        slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Top)
                        slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
                    end
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

---获取当前显示数量
---@return number
function M:GetCount()
    return #self.toastList
end

---检查是否正在显示或在队列中
---@param toastId number Toast ID
---@return boolean
function M:IsShowing(toastId)
    for _, info in ipairs(self.toastList) do
        if info.toastId == toastId then return true end
    end
    for _, info in ipairs(self.toastQueue) do
        if info.toastId == toastId then return true end
    end
    return false
end

---预加载 Toast
---@param uiName string UI 名称
---@param count number|nil 预加载数量（默认 1）
---@return boolean
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
    
    local needCreate = math.max(0, count - #pool)
    
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

---卸载指定 Toast
---@param uiName string UI 名称
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

---清空对象池
function M:ClearCache()
    self:CloseAll()
    
    for uiName, pool in pairs(self.toastCache) do
        if pool then
            for _, controller in ipairs(pool) do
                if controller and controller.Destroy then
                    pcall(function() controller:Destroy() end)
                end
            end
        end
    end
    
    self.toastCache = {}
end

---销毁管理器
function M:Destroy()
    for _, info in ipairs(self.toastList) do
        if info.timer then
            if info.timer.stop then
                pcall(function() info.timer:stop() end)
            end
            info.timer = nil
        end
    end
    
    self:ClearCache()
    self.toastList = {}
    self.toastQueue = {}
    self.isInitialized = false
end

return M