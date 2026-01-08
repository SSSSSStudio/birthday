-- ToastController.lua
-- Toast UI 控制器 (测试用)
local LuaHelper = require("Utility.LuaHelper")

---@class ToastController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
    -- 初始化消息内容
    self.message = "Toast消息"
end

--- 更新模型数据（UIToastManager 会调用此方法传递参数）
function M:UpdateModel(data)
    if data then
        -- 支持直接传字符串或 table
        if type(data) == "string" then
            self.message = data
        elseif type(data) == "table" then
            self.message = data.message or data.content or "Toast消息"
        end
    end
    self:UpdateView()
end

--- 绑定 View 事件
function M:BindViewEvents()
    -- Toast 通常不需要绑定按钮，自动消失
end

--- 更新 View 显示
function M:UpdateView()
    if self.view and self.view.SetContent then
        self.view:SetContent(self.message)
    end
end

--- 重置状态（对象池复用前调用）
function M:Reset()
    self.message = "Toast消息"
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