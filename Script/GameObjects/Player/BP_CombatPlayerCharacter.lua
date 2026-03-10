--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIManager
local UIManager = require("UI.UIManager")


---@type BP_CombatPlayerCharacter_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()

end

function M:ReceiveEndPlay()
	UIManager.CloseAll()
end


-- function M:ReceiveTick(DeltaSeconds)
-- end

return M
