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
    -- 使用 View 脚本接口，不再直接操作控件
    if self.view and self.view.SetMessage then
        local msg = "加载中..."
        if self.model and self.model.Get then
            msg = self.model:Get("message", "加载中...")
        end
        self.view:SetMessage(msg)
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