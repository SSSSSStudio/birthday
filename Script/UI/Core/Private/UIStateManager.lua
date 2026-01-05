-- UIStateManager.lua
-- UI 状态管理器，负责根据配置切换界面，并使用 LRU 缓存管理界面实例

local LRUCache = require("UI.Core.Private.LRUCache")
local UILayerManager = require("UI.Core.Private.UILayerManager")
local UIConfig = require("UI.Core.UIConfig")

---@class UIStateManager
local M = {
    uiCache = nil,           -- UI 实例缓存
    currentUI = nil,         -- 当前显示的 UI
    isInitialized = false    -- 是否已初始化
}

--- 初始化 UI 状态管理器
--- @param cacheCapacity integer 缓存容量（默认 10）
function M:Initialize(cacheCapacity)
    if self.isInitialized then
        return
    end
    
    -- 初始化 LRU 缓存，设置淘汰回调
    self.uiCache = LRUCache(cacheCapacity or 10, function(uiName, controller)
        -- 当 UI 被淘汰时，销毁控制器
        if controller and controller.Destroy then
            controller:Destroy()
        end
    end)
    
    self.isInitialized = true
end

--- 打开指定 UI（如果当前有 UI，先关闭它）
--- @param uiName string UI 名称（对应 UIConfig 中的键名）
--- @param params table|nil 传递给 UI 的参数（可选）
--- @return UIControllerBase|nil 控制器实例
function M:OpenUI(uiName, params)
    if not self.isInitialized then
        self:Initialize()
    end
    
    -- 如果当前有 UI，先关闭它
    if self.currentUI and self.currentUI ~= uiName then
        self:CloseCurrentUI()
    end
    
    -- 检查配置是否存在
    local config = UIConfig[uiName]
    if not config then
        error("UI config not found: " .. tostring(uiName))
        return nil
    end
    
    -- 从缓存中获取或创建 UI
	---@type UIControllerBase
    local controller = self.uiCache:get(uiName)
    
    if not controller then
        -- 创建新的 UI 实例
        controller = self:CreateUI(uiName, config)
        if not controller then
            return nil
        end
        
        -- 添加到缓存
        self.uiCache:put(uiName, controller)
    end
    
    -- 更新参数
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    -- 显示 UI
    if controller.Show then
        controller:Show(UILayerManager.LayerType.State)
    end
    
    -- 更新当前 UI
    self.currentUI = uiName
    
    return controller
end

--- 关闭指定 UI
--- @param uiName string UI 名称
function M:CloseUI(uiName)
    if not self.isInitialized then
        return
    end
    
    local controller = self.uiCache:get(uiName)
    if controller and controller.Hide then
        controller:Hide()
    end
    
    -- 如果关闭的是当前 UI，清空当前 UI
    if self.currentUI == uiName then
        self.currentUI = nil
    end
end

--- 关闭当前 UI
function M:CloseCurrentUI()
    if self.currentUI then
        self:CloseUI(self.currentUI)
    end
end

--- 创建 UI 实例
--- @param uiName string UI 名称
--- @param config UIConfig UI 配置
--- @return UIControllerBase|nil 控制器实例
function M:CreateUI(uiName, config)
    -- config[1] 是 View 类，config[2] 是 Controller 类，config[3] 是 Model 数据
    local ViewClass = UE.UClass.Load(config.ViewPath)
    local ControllerClass =  config[2]
    local ModelData = config[3] or {}
    
    if not ViewClass or not ControllerClass then
        error("Invalid UI config for: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 View 实例
    local view = NewObject(ViewClass)
    if not view then
        error("Failed to create View for: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 Controller 实例
    local controller = ControllerClass:New(view, ModelData)
    if not controller then
        error("Failed to create Controller for: " .. tostring(uiName))
        return nil
    end
    
    -- 初始化控制器
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

--- 获取当前 UI 的控制器
--- @return UIControllerBase|nil 控制器实例
function M:GetCurrentController()
    if not self.currentUI or not self.uiCache then
        return nil
    end
    return self.uiCache:get(self.currentUI)
end

--- 获取指定 UI 的控制器
--- @param uiName string UI 名称
--- @return UIControllerBase|nil 控制器实例
function M:GetController(uiName)
    if not self.uiCache then
        return nil
    end
    return self.uiCache:get(uiName)
end

--- 检查 UI 是否已打开
--- @param uiName string UI 名称
--- @return boolean true 如果已打开，false 否则
function M:IsUIOpen(uiName)
    local controller = self:GetController(uiName)
    return controller ~= nil and controller:IsActive()
end

--- 预加载 UI（提前创建并缓存，但不显示）
--- @param uiName string UI 名称
function M:PreloadUI(uiName)
    if not self.isInitialized then
        self:Initialize()
    end
    
    -- 检查是否已在缓存中
    if self.uiCache:get(uiName) then
        return
    end
    
    -- 检查配置是否存在
    local config = UIConfig[uiName]
    if not config then
        error("UI config not found: " .. tostring(uiName))
        return
    end
    
    -- 创建 UI 实例并缓存
    local controller = self:CreateUI(uiName, config)
    if controller then
        self.uiCache:put(uiName, controller)
    end
end

--- 清空所有 UI 缓存
function M:ClearCache()
    if self.uiCache then
        self.uiCache:clear()
    end
    self.currentUI = nil
end

--- 销毁 UI 状态管理器
function M:Destroy()
    -- 清空缓存
    self:ClearCache()
    
    -- 销毁层管理器
    if UILayerManager.Destroy then
        UILayerManager:Destroy()
    end
    
    self.uiCache = nil
    self.isInitialized = false
end

return M