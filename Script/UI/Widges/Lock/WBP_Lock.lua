--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class WBP_Lock_C : UIViewBase
local M = UnLua.Class("UI.UIViewBase")

function M:Construct()
	self.Super.Construct(self)
	self:SetVisibility(UE.ESlateVisibility.Visible)
end

---@param message string
function M:SetTips(message)
	if self.Textblock_Tips  then
		if message then
			self.Textblock_Tips:SetText(message)
		else
			self.Textblock_Tips:SetText("")
		end
	end
end

return M
