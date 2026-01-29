-- WBP_Activity.lua
-- Activity View 层

---@type WBP_Activity_C
local M = UnLua.Class("UI.UIViewBase")

function M:Construct()
	self.Super.Construct(self)
    -- 绑定按钮事件
	self.Button_Close.OnClicked:Add(self,self:CreateEvent("OnButtonCloseClick"))
end

---设置活动内容
---@param content string
function M:SetActivityContent(content)
	if self.TextBlock_Content then
		if content then
			self.TextBlock_Content:SetText(content)
		else
			self.TextBlock_Content:SetText("")
		end
	end
end

return M