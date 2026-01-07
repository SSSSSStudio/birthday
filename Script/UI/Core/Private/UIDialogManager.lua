-- UIDialogManager.lua
-- Dialog 层管理器：支持多层堆叠

local UILayerManager = require("UI.Core.Private.UILayerManager")
local UIConfig = require("UI.Core.UIConfig")
local Log = require("Utility.Log")

---@class UIDialogManager
local M = {
    dialogCache = {},
    dialogStack = {},
    isInitialized = false
}

function M:Initialize()
    if self.isInitialized then return end
    self.dialogCache = {}
    self.dialogStack = {}
    self.isInitialized = true
end

---显示 Dialog
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
    
    if not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIDialogManager", "UI config not found: " .. uiName)
        return nil
    end
    
    local controller = self.dialogCache[uiName]
    if not controller then
        controller = self:CreateDialog(uiName, config)
        if not controller then return nil end
        self.dialogCache[uiName] = controller
    end
    
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    -- 避免重复
    for i, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then
            table.remove(self.dialogStack, i)
            break
        end
    end
    
    table.insert(self.dialogStack, {
        uiName = uiName,
        controller = controller
    })
    
    local success, err = pcall(function()
        if controller.Show then
            controller:Show(UILayerManager.LayerType.Dialog)
        end
    end)
    
    if not success then
        Log.Error("UIDialogManager", "Failed to show: " .. uiName .. ", " .. tostring(err))
        table.remove(self.dialogStack)
        pcall(function() 
            if controller.Hide then controller:Hide() end
        end)
        return nil
    end
    
    self:BringDialogToFront(controller)
    return controller
end

---将 Dialog 置于最前
---@param controller UIControllerBase
function M:BringDialogToFront(controller)
    if not controller then return end
    
    local view = controller.GetView and controller:GetView() or controller.view
    if not view then return end
    
    local layer = UILayerManager:GetLayer(UILayerManager.LayerType.Dialog)
    if not layer then return end
    
    -- 先从层中移除，再重新添加，确保在最上层
    pcall(function()
        layer:RemoveChild(view)
        layer:AddChildToOverlay(view)
        -- 恢复对齐方式
        if view.Slot then
            view.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
            view.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
        end
    end)
end

---关闭指定 Dialog
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
            return true
        end
    end
    return false
end

---关闭顶层 Dialog
function M:CloseTop()
    if #self.dialogStack > 0 then
        self:Close(self.dialogStack[#self.dialogStack].uiName)
    end
end

---关闭所有 Dialog
function M:CloseAll()
    for i = #self.dialogStack, 1, -1 do
        local info = self.dialogStack[i]
        if info.controller and info.controller.Hide then
            info.controller:Hide()
        end
    end
    self.dialogStack = {}
end

---创建 Dialog
---@param uiName string
---@param config table
---@return UIControllerBase|nil
function M:CreateDialog(uiName, config)
    local ViewClass = config.ViewClass
    
    -- 如果 ViewClass 不是 UClass，从 ViewPath 加载
    if type(ViewClass) == "table" or not ViewClass then
        if config.ViewPath then
            ViewClass = UE.UClass.Load(config.ViewPath)
            if not ViewClass then
                Log.Error("UIDialogManager", "Failed to load ViewPath: " .. config.ViewPath)
                return nil
            end
        end
    end
    
    if not ViewClass or not config.ControllerClass then
        Log.Error("UIDialogManager", "Invalid config: " .. uiName)
        return nil
    end
    
    local world = UILayerManager.gameInstance and UILayerManager.gameInstance:GetWorld()
    if not world then
        Log.Error("UIDialogManager", "Failed to get world")
        return nil
    end

    local success, view = pcall(function()
        return UE.UWidgetBlueprintLibrary.Create(world, ViewClass, nil)
    end)
    
    if not success or not view then
        Log.Error("UIDialogManager", "Failed to create view: " .. uiName .. ", " .. tostring(view))
        return nil
    end
    
    local model = nil
    if config.ModelClass then
        model = config.ModelClass.New(config.ModelClass)
    end
    
    local success2, controller = pcall(function()
        return config.ControllerClass.New(config.ControllerClass, view, model)
    end)
    
    if not success2 or not controller then
        Log.Error("UIDialogManager", "Failed to create controller: " .. uiName .. ", " .. tostring(controller))
        return nil
    end
    
    if controller.Initialize then
        local success3, err = pcall(function()
            controller:Initialize()
        end)
        if not success3 then
            Log.Error("UIDialogManager", "Failed to initialize controller: " .. uiName .. ", " .. tostring(err))
            return nil
        end
    end
    
    return controller
end

---获取 Controller
---@param uiName string
---@return UIControllerBase|nil
function M:GetController(uiName)
    return self.dialogCache[uiName]
end

---获取顶层 Controller
---@return UIControllerBase|nil
function M:GetTopController()
    local top = self.dialogStack[#self.dialogStack]
    return top and top.controller or nil
end

---是否正在显示
---@param uiName string
---@return boolean
function M:IsShowing(uiName)
    for _, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then return true end
    end
    return false
end

---获取显示数量
---@return number
function M:GetCount()
    return #self.dialogStack
end

---获取所有显示中的 Dialog 名称
---@return table
function M:GetShowingDialogs()
    local dialogs = {}
    for _, info in ipairs(self.dialogStack) do
        table.insert(dialogs, info.uiName)
    end
    return dialogs
end

---预加载（创建但不显示）
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

---卸载（从缓存移除）
---@param uiName string
function M:Unload(uiName)
    if self:IsShowing(uiName) then
        self:Close(uiName)
    end
    
    local controller = self.dialogCache[uiName]
    if controller then
        if controller.Destroy then
            controller:Destroy()
        end
        self.dialogCache[uiName] = nil
    end
end

---清空缓存
function M:ClearCache()
    self:CloseAll()
    for uiName, controller in pairs(self.dialogCache) do
        if controller and controller.Destroy then
            controller:Destroy()
        end
    end
    self.dialogCache = {}
end

---销毁
function M:Destroy()
    self:ClearCache()
    self.dialogStack = {}
    self.isInitialized = false
end

return M