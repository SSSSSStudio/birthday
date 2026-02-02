--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIConfigSystem
local UIConfigSystem = require("UI.UIConfigSystem")

---@type GM_DevelopGameMode_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end
 function M:ReceiveBeginPlay()
	 print("[GM_DevelopGameMode_C] ReceiveBeginPlay ====================================")
	 UIConfigSystem.Register("DevelopMain","UI.Develop.DevelopMainController","/Game/UI/Develop/WBP_DevelopMain.WBP_DevelopMain_C")
	 UIConfigSystem.Register("TestMain","Test.UI.TestMainController","/Game/Test/UI/WBP_TestMain.WBP_TestMain_C")
 end

 function M:ReceiveEndPlay()
	 print("[GM_DevelopGameMode_C] ReceiveEndPlay ====================================")
 end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

return M
