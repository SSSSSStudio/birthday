--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
---@type UIManager
local UIManager = require("UI.UIManager")

---@type BP_DevelopPlayerController_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

 function M:ReceiveBeginPlay()
	 print("[PC_UI_C] ReceiveBeginPlay ====================================")
	 self.bShowMouseCursor = true
	 UE.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, nil, UE.EMouseLockMode.DoNotLock)

	 UIManager.RegisterConfig("DevelopMain","UI.Develop.DevelopMainController","/Game/UI/Develop/WBP_DevelopMain.WBP_DevelopMain_C")
	 UIManager.RegisterConfig("TestMain","Test.UI.TestMainController","/Game/Test/UI/WBP_TestMain.WBP_TestMain_C")

	 UIManager.State_Open("DevelopMain", nil)
 end

 function M:ReceiveEndPlay()
	 print("[PC_UI_C] ReceiveEndPlay ====================================")
	 UIManager.CloseAll()
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
