-- MessageBoxController.lua
-- MessageBox UI 控制器 (测试用)
local LuaHelper = require("Utility.LuaHelper")

---@class MessageBoxController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
function M:__OnNew(view, model)
	self.Super.__OnNew(self, view, model)
	-- 初始化回调
	self.confirmCallback = nil
	self.cancelCallback = nil
	-- 初始化参数
	self.params = {
		title = "Title",
		content = "Content",
		confirmText = "确认",
		cancelText = "取消",
		showConfirmButton = true,
		showCancelButton = true
	}
end

--- 设置回调（UIMsgBoxManager 会调用此方法）
function M:SetCallbacks(confirmCallback, cancelCallback)
	self.confirmCallback = confirmCallback
	self.cancelCallback = cancelCallback
end

--- 更新模型数据（UIMsgBoxManager 会调用此方法传递参数）
function M:UpdateModel(data)
	if data then
		for k, v in pairs(data) do
			self.params[k] = v
		end
	end
	self:UpdateView()
end

--- 更新 View 显示
function M:UpdateView()
	-- 更新文本
	self:SetText("TextBlock_Title", self.params.title)
	self:SetText("TextBlock_Content", self.params.content)
	self:SetText("TextBlock_Confirm", self.params.confirmText)
	self:SetText("TextBlock_Cancel", self.params.cancelText)
	
	-- 控制按钮显示/隐藏
	self:SetWidgetVisible("Button_Confirm", self.params.showConfirmButton)
	self:SetWidgetVisible("Button_Cancel", self.params.showCancelButton)
end

--- UI 显示时调用
function M:OnShow()
	self:UpdateView()
end

--- UI 隐藏时调用
function M:OnHide()
end

--- UI 销毁时调用
function M:OnDestroy()
	-- 清理回调引用
	self.confirmCallback = nil
	self.cancelCallback = nil
end

return M
