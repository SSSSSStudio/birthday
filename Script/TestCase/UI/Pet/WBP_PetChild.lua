--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local EventDispatcher = require("Core.EventDispatcher")

---@type WBP_PetChild_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

 function M:Construct()
	 self.ButtonCallMain.OnClicked:Add(self, self.OnButtonCallMain)
	 self.ButtonCallFuncMain.OnClicked:Add(self, self.OnButtonCallFuncMain)
 end

local num = 0
function M:OnButtonCallMain()
    print("OnButtonCallMain")
	num = num + 1
	EventDispatcher.Dispatch("Pet.ChangeTitle",  "宠物属性 已被子界面的操作修改+"..num)
end

function M:OnButtonCallFuncMain()
    print("OnButtonCallFuncMain")
end

return M
