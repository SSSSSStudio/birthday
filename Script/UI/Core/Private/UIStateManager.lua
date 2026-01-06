-- UIStateManager.lua
-- UI 状态管理器，负责根据配置切换界面，并使用 LRU 缓存管理界面实例
local Stack = require("UI.Core.Private.Stack")
local UILayerManager = require("UI.Core.Private.UILayerManager")
local UIConfig = require("UI.Core.UIConfig")

---@class UIStateManager
local M = {
    uiRecordStack = nil, -- UI 名称缓存
    currentUI = nil,         -- 当前显示的 UI
	currentController = nil,  -- 当前显示的 UI 控制器
    isInitialized = false    -- 是否已初始化
}

--- 初始化 UI 状态管理器
--- @param cacheCapacity integer 缓存容量（默认 10）
function M:Initialize(cacheCapacity)
    if self.isInitialized then
        return
    end
    
    self.uiRecordStack = Stack(cacheCapacity or 10,false)
    self.isInitialized = true
end

--- 打开指定 UI（如果当前有 UI，先关闭它）
--- @param uiName string UI 名称（对应 UIConfig 中的键名）
--- @param params table|nil 传递给 UI 的参数（可选）
--- @param isCacheCurrent boolean|nil 是否使用 LRU 缓存（默认为 true）
--- @return UIControllerBase|nil 控制器实例
function M:OpenUI(uiName, params, isCacheCurrent)
    if not self.isInitialized then
        self:Initialize()
    end
	
	if self.currentUI == uiName then
		return
    end

	-- 默认使用缓存
	if isCacheCurrent == nil then
		isCacheCurrent = true
	end
    
    -- 如果当前有 UI，先关闭它
    if self.currentUI and isCacheCurrent then
		self.uiRecordStack:Push(self.currentUI)
        self:CloseCurrentUI()
    end
    
    -- 检查配置是否存在
    local config = UIConfig[uiName]
    if not config then
        error("UI config not found: " .. tostring(uiName))
        return nil
    end
    
    -- 创建新的 UI 实例
    local controller = self:CreateUI(uiName, config)
    if not controller then
        return nil
	end

	-- 更新参数
	if params and controller.UpdateModel then
		controller:UpdateModel(params)
	end
	
    -- 显示 UI
    if controller.Show then
        controller:Show(UILayerManager.LayerType.State)
    end

	-- 移除当前 UI
	self.uiRecordStack:Remove(uiName)
    -- 更新当前 UI
    self.currentUI = uiName
	self.currentController = controller
	
    return controller
end

--- 关闭当前 UI
function M:CloseCurrentUI()
    if self.currentController then
		self.currentController:Destroy()
		self.currentController = nil
		self.currentUI = nil
    end
end

--- 关闭当前 UI 并打开上一个ui(如无历史记录则打开)
function M:CloseCurrentUIAndReopen()
	if self.currentController then
		self.currentController:Destroy()
		self.currentController = nil
		self.currentUI = nil
		-- 返回上一个 UI
		self:GoBack()
	end
end

--- 创建 UI 实例
--- @param uiName string UI 名称
--- @param config UIConfig UI 配置
--- @return UIControllerBase|nil 控制器实例
function M:CreateUI(uiName, config)
    -- 加载 View 类
    local ViewClass = UE.UClass.Load(config.ViewPath)
    if not ViewClass then
        error("Failed to load View class for: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 View 实例
    local view = NewObject(ViewClass)
    if not view then
        error("Failed to create View for: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 Model 实例（如果配置了 ModelClass）
    local model = nil
    if config.ModelClass then
        model = config.ModelClass:New()
    end
    
    -- 创建 Controller 实例
    local controller = config.ControllerClass:New(view, model)
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
	return self.currentController
end


--- 检查 UI 是否已打开
--- @param uiName string UI 名称
--- @return boolean true 如果已打开，false 否则
function M:IsUIOpen(uiName)
	return self.currentUI == uiName
end

--- 返回上一个 UI
--- @return UIControllerBase|nil 控制器实例，如果没有历史记录则返回 nil
function M:GoBack()
    if not self.uiRecordStack or self.uiRecordStack:IsEmpty() then
        return nil
    end
    
    -- 获取上一个 UI 名称
    local previousUI = self.uiRecordStack:Pop()
    if not previousUI then
        return nil
    end
    
    -- 打开上一个 UI
    return self:OpenUI(previousUI, nil, true)
end

--- 获取导航历史记录
--- @return table UI 名称数组（从最新到最旧）
function M:GetHistory()
    if not self.uiRecordStack then
        return {}
    end
    return self.uiRecordStack:ToArray()
end

--- 清空导航历史记录
function M:ClearHistory()
    if self.uiRecordStack then
        self.uiRecordStack:Clear()
    end
end

--- 销毁 UI 状态管理器
function M:Destroy()
    -- 销毁层管理器
    if UILayerManager.Destroy then
        UILayerManager:Destroy()
    end
    
    self.isInitialized = false
	self.currentUI = nil
	self.currentController = nil
	self.uiRecordStack = nil
end

return M