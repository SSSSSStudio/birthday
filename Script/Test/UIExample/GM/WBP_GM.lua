-- WBP_GM.lua
-- GM View 层

---@type WBP_GM_C
local M = UnLua.Class("UI.UIViewBase")

function M:Construct()
	self.Super.Construct(self)
    -- 绑定关闭按钮事件
    self.Button_Close.OnClicked:Add(self, self:CreateEvent("OnButtonCloseClick"))
end

function M:SetTips(tips)
    if self.TextBlock_Tips then
        self.TextBlock_Tips:SetText(tips)
    end
end

return M
