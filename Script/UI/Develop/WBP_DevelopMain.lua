--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
---@class WBP_DevelopMain_C: UIViewBase
local M = UnLua.Class("UI.UIViewBase")

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

 function M:Construct()
	 self.Super.Construct(self)
	 self.Button.OnClicked:Add(self,self:CreateEvent("OnTestClick"))
	 self.Button_1.OnClicked:Add(self,self:CreateEvent("OnCustomCharacterClick"))
	 self.Button_2.OnClicked:Add(self,self:CreateEvent("OnHomeClick"))
	 self.Button_3.OnClicked:Add(self,self:CreateEvent("OnCombatClick"))
	 self.Button_4.OnClicked:Add(self,self:CreateEvent("OnNetworkClick"))
 end

--function M:Tick(MyGeometry, InDeltaTime)
--end

return M
