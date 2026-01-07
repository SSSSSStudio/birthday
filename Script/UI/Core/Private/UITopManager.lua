-- UITopManager.lua
-- Top 层管理器：管理始终在最上层的 UI（如调试面板、GM 工具），支持多个共存

local UILayerManager = require("UI.Core.Private.UILayerManager")
local UIConfig = require("UI.Core.UIConfig")
local Log = require("Utility.Log")

---@class UITopManager
local M = {
    topCache = {},
    topList = {},
    isInitialized = false
}

function M:Initialize()
    if self.isInitialized then return end
    self.topCache = {}
    self.topList = {}
    self.isInitialized = true
end

---显示 Top UI
---@param uiName string UI 名称
---@param params table|nil 参数
---@return UIControllerBase|nil
function M:Show(uiName, params)
    if not uiName or uiName == "" then
        Log.Error("UITopManager", "Invalid uiName")
        return nil
    end
    
    if params ~= nil and type(params) ~= "table" then
        Log.Error("UITopManager", "Invalid params type: " .. type(params))
        return nil
    end
    
    self:Initialize()
    
    if not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UITopManager", "UI config not found: " .. uiName)
        return nil
    end
    
    -- 已显示则更新参数并置顶
    for i, info in ipairs(self.topList) do
        if info.uiName == uiName then
            if params and info.controller.UpdateModel then
                info.controller:UpdateModel(params)
            end
            
            self:BringTopToFront(info.controller)
            table.remove(self.topList, i)
            table.insert(self.topList, info)
            return info.controller
        end
    end
    
    -- 获取或创建 Controller
    local controller = self.topCache[uiName]
    if not controller then
        controller = self:CreateTop(uiName, config)
        if not controller then return nil end
        self.topCache[uiName] = controller
    end
    
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    table.insert(self.topList, {
        uiName = uiName,
        controller = controller
    })
    
    local success, err = pcall(function()
        if controller.Show then
            controller:Show(UILayerManager.LayerType.Top)
        end
    end)
    
    if not success then
        Log.Error("UITopManager", "Failed to show: " .. uiName .. ", " .. tostring(err))
        table.remove(self.topList)
        pcall(function() 
            if controller.Hide then controller:Hide() end
        end)
        return nil
    end
    
    return controller
end

---将 Top UI 置于最前
---@param controller UIControllerBase
function M:BringTopToFront(controller)
    if not controller then return end
    
    local view = controller.GetView and controller:GetView() or controller.view
    if not view then return end
    
    local layer = UILayerManager:GetLayer(UILayerManager.LayerType.Top)
    if not layer then return end
    
    pcall(function()
        if view.RemoveFromParent then
            view:RemoveFromParent()
        else
            layer:RemoveChild(view)
        end
        
        layer:AddChildToOverlay(view)
        
        if view.Slot then
            view.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
            view.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
        end
    end)
end

---关闭指定 Top UI
---@param uiName string
---@return boolean
function M:Close(uiName)
    if not self.isInitialized then return false end
    
    for i, info in ipairs(self.topList) do
        if info.uiName == uiName then
            if info.controller and info.controller.Hide then
                info.controller:Hide()
            end
            
            local view = info.controller and (info.controller.GetView and info.controller:GetView() or info.controller.view)
            if view then
                local layer = UILayerManager:GetLayer(UILayerManager.LayerType.Top)
                if layer then
                    pcall(function()
                        if view.RemoveFromParent then
                            view:RemoveFromParent()
                        else
                            layer:RemoveChild(view)
                        end
                    end)
                end
            end
            
            table.remove(self.topList, i)
            return true
        end
    end
    return false
end

---关闭顶层 Top UI
function M:CloseTop()
    if #self.topList > 0 then
        self:Close(self.topList[#self.topList].uiName)
    end
end

---关闭所有 Top UI
function M:CloseAll()
    for i = #self.topList, 1, -1 do
        self:Close(self.topList[i].uiName)
    end
end

---创建 Top UI
---@param uiName string
---@param config table
---@return UIControllerBase|nil
function M:CreateTop(uiName, config)
    if not config.ViewPath or not config.ControllerClass then
        Log.Error("UITopManager", "Invalid config: " .. uiName)
        return nil
    end
    
    local world = UILayerManager.gameInstance and UILayerManager.gameInstance:GetWorld()
    if not world then
        Log.Error("UITopManager", "Failed to get world")
        return nil
    end

    local ViewClass = UE.UClass.Load(config.ViewPath)
    if not ViewClass then
        Log.Error("UITopManager", "Failed to load ViewClass: " .. tostring(config.ViewPath))
        return nil
    end

    local view = UE.UWidgetBlueprintLibrary.Create(world, ViewClass, nil)
    if not view then
        Log.Error("UITopManager", "Failed to create view: " .. uiName)
        return nil
    end
    
    local model = config.ModelClass and config.ModelClass.New(config.ModelClass) or nil
    local controller = config.ControllerClass.New(config.ControllerClass, view, model)
    if not controller then
        Log.Error("UITopManager", "Failed to create controller: " .. uiName)
        return nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

---获取 Controller
---@param uiName string
---@return UIControllerBase|nil
function M:GetController(uiName)
    return self.topCache[uiName]
end

---获取顶层 Controller
---@return UIControllerBase|nil
function M:GetTopController()
    local top = self.topList[#self.topList]
    return top and top.controller or nil
end

---是否正在显示
---@param uiName string
---@return boolean
function M:IsShowing(uiName)
    for _, info in ipairs(self.topList) do
        if info.uiName == uiName then return true end
    end
    return false
end

---获取显示数量
---@return number
function M:GetCount()
    return #self.topList
end

---获取所有显示中的 Top UI 名称
---@return table
function M:GetShowingTops()
    local tops = {}
    for _, info in ipairs(self.topList) do
        table.insert(tops, info.uiName)
    end
    return tops
end

---预加载（创建但不显示）
---@param uiName string
---@return UIControllerBase|nil
function M:Preload(uiName)
    self:Initialize()
    
    if not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    if self.topCache[uiName] then
        return self.topCache[uiName]
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UITopManager", "UI config not found: " .. uiName)
        return nil
    end
    
    local controller = self:CreateTop(uiName, config)
    if controller then
        self.topCache[uiName] = controller
    end
    return controller
end

---卸载（从缓存移除）
---@param uiName string
function M:Unload(uiName)
    if self:IsShowing(uiName) then
        self:Close(uiName)
    end
    
    local controller = self.topCache[uiName]
    if controller then
        if controller.Destroy then
            controller:Destroy()
        end
        self.topCache[uiName] = nil
    end
end

---清空缓存
function M:ClearCache()
    self:CloseAll()
    for uiName, controller in pairs(self.topCache) do
        if controller and controller.Destroy then
            controller:Destroy()
        end
    end
    self.topCache = {}
end

---销毁
function M:Destroy()
    self:ClearCache()
    self.topList = {}
    self.isInitialized = false
end

return M
