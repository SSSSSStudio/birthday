-- LockController.lua
-- 锁定界面控制器
local LuaHelper = require("Utility.LuaHelper")

---@class LockController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
function M:__OnNew(view, model)
	self.Super.__OnNew(self, view, model)
end

--- 绑定 View 事件
function M:BindViewEvents()
	-- Lock 界面通常不需要绑定事件
end

--- 更新 View 显示
function M:UpdateView()
	if not self.model then
		self:SetText("Textblock_Tips", "加载中...")
		return
	end
	
	-- 检查 model 是否有 Get 方法
	if self.model.Get then
		self:SetText("Textblock_Tips", self.model:Get("message", "加载中..."))
	else
		self:SetText("Textblock_Tips", "加载中...")
	end
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
end

return M
