-- WBP_Bag.lua
-- Bag View 层

---@type WBP_Bag_C
local M = UnLua.Class("UI.UIViewBase")

function M:Construct()
	self.Super.Construct(self)
	self.Button_Close.OnClicked:Add(self,self:CreateEvent("OnButtonCloseClick"))
end



return M
