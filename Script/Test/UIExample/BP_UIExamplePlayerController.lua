--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local UIManager = require("UI.UIManager")
local MainUIModel = require("Test.UIExample.Main.MainUIModel")

---@type BP_UIExamplePlayerController_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
	self.bShowMouseCursor = true
	UE.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, nil, UE.EMouseLockMode.DoNotLock)
	print("[PC_UI_C] ReceiveBeginPlay ====================================")


	UIManager.RegisterConfig("Activity","Test.UIExample.Activity.ActivityController","/Game/Test/UIExample/WBP_Activity.WBP_Activity_C")
	UIManager.RegisterConfig("Bag","Test.UIExample.Bag.BagController","/Game/Test/UIExample/WBP_Bag.WBP_Bag_C")
	UIManager.RegisterConfig("GM","Test.UIExample.GM.GMController","/Game/Test/UIExample/WBP_GM.WBP_GM_C")
	UIManager.RegisterConfig("Main","Test.UIExample.Main.MainUIController","/Game/Test/UIExample/Main/WBP_Main.WBP_Main_C")
	UIManager.RegisterConfig("PetMain","Test.UIExample.Pet.PetMainController","/Game/Test/UIExample/Pet/WBP_PetMain.WBP_PetMain_C")

	UIManager.Start()
	
	self.main = MainUIModel:New()
	UIManager.State_Open("Main", self.main)
end

function M:ReceiveEndPlay()
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
