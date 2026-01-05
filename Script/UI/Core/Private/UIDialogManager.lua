-- UIDialogManager.lua
-- Dialog 层级 UI 管理器，支持多 Dialog 堆叠显示

local UILayerManager = require("Script.UI.Core.Private.UILayerManager")
local UIConfig = require("Script.UI.Core.UIConfig")
local Log = require("Utility.Log")

---@class UIDialogManager
local M = {
    dialogCache = {},      -- Dialog 缓存
    dialogStack = {},      -- Dialog 栈（管理显示顺序）
    isInitialized = false
}

--- 初始化
function M:Initialize()
    if self.isInitialized then return end
    self.dialogCache = {}
    self.dialogStack = {}
    self.isInitialized = true
end

--- 显示 Dialog
---@param uiName string UI 名称
---@param params table|nil 参数
---@return UIControllerBase|nil
function M:Show(uiName, params)
    if not uiName or uiName == "" then
        Log.Error("UIDialogManager", "Invalid uiName")
        return nil
    end
    
    if params ~= nil and type(params) ~= "table" then
        Log.Error("UIDialogManager", "Invalid params type: " .. type(params))
        return nil
    end
    
    self:Initialize()
    
    -- 确保 UILayerManager 已初始化
    if not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIDialogManager", "UI config not found: " .. uiName)
        return nil
    end
    
    -- 获取或创建 Controller
    local controller = self.dialogCache[uiName]
    if not controller then
        controller = self:CreateDialog(uiName, config)
        if not controller then return nil end
        self.dialogCache[uiName] = controller
    end
    
    -- 更新参数
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    -- 从栈中移除（避免重复）
    for i, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then
            table.remove(self.dialogStack, i)
            break
        end
    end
    
    -- 添加到栈顶
    table.insert(self.dialogStack, {
        uiName = uiName,
        controller = controller
    })
    
    -- 显示
    local success, err = pcall(function()
        if controller.Show then
            controller:Show(UILayerManager.LayerType.Dialog)
        end
    end)
    
    if not success then
        Log.Error("UIDialogManager", "Failed to show: " .. uiName .. ", " .. tostring(err))
        table.remove(self.dialogStack)
        return nil
    end
    
    self:UpdateDialogZOrder()
    return controller
end

--- 更新 Dialog ZOrder（栈顶在最上层）
function M:UpdateDialogZOrder()
    for i, info in ipairs(self.dialogStack) do
        local view = info.controller and info.controller.GetView and info.controller:GetView()
        if view and view.Slot and view.Slot.SetZOrder then
            view.Slot:SetZOrder(i)
        end
    end
end

--- 关闭指定 Dialog
---@param uiName string
---@return boolean
function M:Close(uiName)
    if not self.isInitialized then return false end
    
    for i, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then
            if info.controller and info.controller.Hide then
                info.controller:Hide()
            end
            table.remove(self.dialogStack, i)
            self:UpdateDialogZOrder()
            return true
        end
    end
    return false
end

--- 关闭顶层 Dialog
function M:CloseTop()
    if #self.dialogStack > 0 then
        self:Close(self.dialogStack[#self.dialogStack].uiName)
    end
end

--- 关闭所有 Dialog
function M:CloseAll()
    for i = #self.dialogStack, 1, -1 do
        local info = self.dialogStack[i]
        if info.controller and info.controller.Hide then
            info.controller:Hide()
        end
    end
    self.dialogStack = {}
end

--- 创建 Dialog
---@param uiName string
---@param config table
---@return UIControllerBase|nil
function M:CreateDialog(uiName, config)
    local ViewClass, ControllerClass, ModelData = config[1], config[2], config[3] or {}
    
    if not ViewClass or not ControllerClass then
        Log.Error("UIDialogManager", "Invalid config: " .. uiName)
        return nil
    end
    
    local world = UE.GetWorld()
    if not world then
        Log.Error("UIDialogManager", "Failed to get world")
        return nil
    end

    local view = UE.UWidgetBlueprintLibrary.Create(world, ViewClass, nil)
    if not view then
        Log.Error("UIDialogManager", "Failed to create view: " .. uiName)
        return nil
    end
    
    local controller = ControllerClass.new(view, ModelData)
    if not controller then
        Log.Error("UIDialogManager", "Failed to create controller: " .. uiName)
        return nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

--- 获取 Controller
---@param uiName string
---@return UIControllerBase|nil
function M:GetController(uiName)
    return self.dialogCache[uiName]
end

--- 获取顶层 Controller
---@return UIControllerBase|nil
function M:GetTopController()
    local top = self.dialogStack[#self.dialogStack]
    return top and top.controller or nil
end

--- 是否正在显示
---@param uiName string
---@return boolean
function M:IsShowing(uiName)
    for _, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then return true end
    end
    return false
end

--- 获取显示数量
---@return number
function M:GetCount()
    return #self.dialogStack
end

--- 获取所有显示中的 Dialog 名称
---@return table
function M:GetShowingDialogs()
    local dialogs = {}
    for _, info in ipairs(self.dialogStack) do
        table.insert(dialogs, info.uiName)
    end
    return dialogs
end

--- 预加载（创建但不显示）
---@param uiName string
---@return UIControllerBase|nil
function M:Preload(uiName)
    self:Initialize()
    
    if self.dialogCache[uiName] then
        return self.dialogCache[uiName]
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIDialogManager", "UI config not found: " .. uiName)
        return nil
    end
    
    local controller = self:CreateDialog(uiName, config)
    if controller then
        self.dialogCache[uiName] = controller
    end
    return controller
end

--- 卸载（从缓存移除）
---@param uiName string
function M:Unload(uiName)
    local controller = self.dialogCache[uiName]
    if controller then
        if controller.Destroy then
            controller:Destroy()
        end
        self.dialogCache[uiName] = nil
    end
end

--- 清空缓存
function M:ClearCache()
    self:CloseAll()
    for uiName, controller in pairs(self.dialogCache) do
        if controller and controller.Destroy then
            controller:Destroy()
        end
    end
    self.dialogCache = {}
end

--- 销毁
function M:Destroy()
    self:ClearCache()
    self.dialogStack = {}
    self.isInitialized = false
end

return M