--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class WBP_TestMain_C: UIViewBase
local M = UnLua.Class("UI.UIViewBase")

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

 function M:Construct()
	 self.Super.Construct(self)
	 self.Button.OnClicked:Add(self,self:CreateEvent("OnUIExample"))
	 self.Button_1.OnClicked:Add(self,self:CreateEvent("OnRunLuaTestCase"))
	 self.Button_2.OnClicked:Add(self,self:CreateEvent("OnClose"))
 end

--function M:Tick(MyGeometry, InDeltaTime)
--end

return M
