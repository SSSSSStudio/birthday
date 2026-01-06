--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_Main_C
local M = UnLua.Class()

function M:Initialize(Initializer)
	print("Initialize",self.ButtonClose)
end

function M:PreConstruct(IsDesignTime)
	print("PreConstruct",self.ButtonClose)
end

 function M:Construct()
	 print("Construct",self.ButtonClose,self.Controller.UpdateView,self.Model.sugen)
	 
 end

--function M:Tick(MyGeometry, InDeltaTime)
--end

return M
