-- UIControllerBase.lua
-- UI 控制器基类，MVC 结构中的 Controller
-- View 直接使用 Unlua 覆盖的 UMG，不需要额外的基类

local LuaHelper = require("Utility.LuaHelper")
local Log = require("Utility.Log")

---@class UIControllerBase
local M = LuaHelper.LuaClass()

--- 创建控制器实例
--- @param view UUserWidget View 实例（Unlua 覆盖的 UMG Widget）
--- @param model UIModelBase|table|nil Model 实例或数据（可选）
function M:__OnNew(view, model)
    self.view = view           -- View 实例
	self.model = model         -- Model 实例或数据
	self.isActive = false      -- 是否激活
	self.layerType = nil       -- 所属层级
	self.isInitialized = false  -- 是否已初始化
	
	-- 将 Controller 引用设置到 View 上，方便 View 访问 Controller
	if view then
		view.Controller = self
		view.Model = self.model
	end
	
	-- 将 Controller 引用设置到 Model 上，方便 Model 通知 Controller 更新 View
	if model and model.SetController then
		model:SetController(self)
	end
end

--- 初始化控制器（子类可以重写）
function M:Initialize()
    if self.isInitialized then
        return
    end
	
    -- 初始化 Model 数据
    self:InitializeModel()
    
    self.isInitialized = true
end

--- 初始化 Model 数据（子类可以重写）
function M:InitializeModel()
    -- 如果 Model 有 Initialize 方法，调用它
    if self.model and self.model.Initialize then
        self.model:Initialize()
    end
end

--- 显示 UI
--- @param layerType integer|nil 显示的层级（可选）
function M:Show(layerType)
    if self.isActive then
        return
    end
    
    -- 设置层级
    if layerType then
        self.layerType = layerType
    end
    
    -- 添加到层级
    if self.layerType and self.view then
        local UILayerManager = require "UI.Core.Private.UILayerManager"
        UILayerManager:AddToLayer(self.view, self.layerType)
    end
    
    -- 设置可见性
    if self.view then
        self.view:SetVisibility(UE.ESlateVisibility.Visible)
    end
    
    -- 调用显示回调
    self:OnShow()
    
    self.isActive = true
end

--- 隐藏 UI
function M:Hide()
    if not self.isActive then
        return
    end
    
    -- 调用隐藏回调
    self:OnHide()
    
    -- 设置可见性
    if self.view then
        self.view:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    
    self.isActive = false
end

--- 销毁控制器
function M:Destroy()
    -- 调用销毁回调
    self:OnDestroy()
    
    -- 从层级移除
    if self.layerType and self.view then
        local UILayerManager = require "UI.Core.Private.UILayerManager"
        UILayerManager:RemoveFromLayer(self.view, self.layerType)
    end
    
    -- 清理 View
    if self.view then
        self.view:RemoveFromParent()
        self.view = nil
    end
    
    -- 销毁 Model
    if self.model then
        if self.model.Destroy then
            self.model:Destroy()
        end
        self.model = nil
    end
    
    self.isActive = false
    self.isInitialized = false
end

--- 获取 View 实例
--- @return UUserWidget View 实例
function M:GetView()
    return self.view
end

--- 获取 Model 数据
--- @return table Model 数据
function M:GetModel()
    return self.model
end

--- 检查是否激活
--- @return boolean true 如果激活，false 否则
function M:IsActive()
    return self.isActive
end

--- 获取所属层级
--- @return integer|nil 层级类型
function M:GetLayerType()
    return self.layerType
end

--- 设置所属层级
--- @param layerType integer 层级类型
function M:SetLayerType(layerType)
    self.layerType = layerType
end

-- ========== 生命周期回调（子类可以重写） ==========

--- UI 显示时调用
function M:OnShow()
    -- 子类可以重写
end

--- UI 隐藏时调用
function M:OnHide()
    -- 子类可以重写
end

--- UI 销毁时调用
function M:OnDestroy()
    -- 子类可以重写此
end

--- UI 每帧更新时调用（可选）
--- @param deltaTime number 帧间隔时间
function M:OnTick(deltaTime)
    -- 子类可以重写
end

-- ========== 便捷方法 ==========

--- 获取 View 中的控件
--- @param widgetName string 控件名称
--- @return UWidget|nil 控件实例
function M:GetWidget(widgetName)
    if not self.view then
        return nil
    end
    return self.view[widgetName]
end

--- 绑定按钮点击事件
--- @param buttonName string 按钮名称
--- @param callback function 回调函数
function M:BindButtonClick(buttonName, callback)
	if callback == nil then
		Log.Error("BindButtonClick: button:"..buttonName.." callback cannot be nil ")
        return
    end
	
    local button = self:GetWidget(buttonName)
    if button and button.OnClicked then
        button.OnClicked:Add(self.view, callback)
    end
end

--- 绑定文本变化事件
--- @param textBlockName string 文本块名称
--- @param callback function 回调函数
function M:BindTextChanged(textBlockName, callback)
    local textBlock = self:GetWidget(textBlockName)
    if textBlock and textBlock.OnTextChanged then
        textBlock.OnTextChanged:Add(self, callback)
    end
end

--- 设置文本内容
--- @param textBlockName string 文本块名称
--- @param text string|nil 文本内容
function M:SetText(textBlockName, text)
    local textBlock = self:GetWidget(textBlockName)
    if textBlock then
        textBlock:SetText(text or "")
    end
end

--- 获取文本内容
--- @param textBlockName string 文本块名称
--- @return string 文本内容
function M:GetText(textBlockName)
    local textBlock = self:GetWidget(textBlockName)
    if textBlock then
        return textBlock:GetText()
    end
    return ""
end

--- 设置控件可见性
--- @param widgetName string 控件名称
--- @param visible boolean 是否可见
function M:SetWidgetVisible(widgetName, visible)
    local widget = self:GetWidget(widgetName)
    if widget then
        widget:SetVisibility(visible and UE.ESlateVisibility.Visible or UE.ESlateVisibility.Collapsed)
    end
end

--- 设置控件启用状态
--- @param widgetName string 控件名称
--- @param enabled boolean 是否启用
function M:SetWidgetEnabled(widgetName, enabled)
    local widget = self:GetWidget(widgetName)
    if widget then
        widget:SetIsEnabled(enabled)
    end
end



return M