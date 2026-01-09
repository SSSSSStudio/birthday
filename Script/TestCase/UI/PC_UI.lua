--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local UIManager = require("UI.Core.UIManager")
---@type PC_UI_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

 function M:ReceiveBeginPlay()
	 self.bShowMouseCursor = true
	 UE.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, nil, UE.EMouseLockMode.DoNotLock)
	 print("[PC_UI_C] ReceiveBeginPlay ====================================")
	 UIManager.State_Open("Main")
 end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

return M
