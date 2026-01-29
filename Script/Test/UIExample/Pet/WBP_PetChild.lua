--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
---@type WBP_PetChild_C
local M = UnLua.Class("UI.UIViewBase")


 function M:Construct()
	 self.Super.Construct(self)
	 self.ButtonCallMain.OnClicked:Add(self,self:CreateEvent("OnButtonCallMain"))
	 self.ButtonCallFuncMain.OnClicked:Add(self,self:CreateEvent("OnButtonCallFuncMain"))
 end

return M
