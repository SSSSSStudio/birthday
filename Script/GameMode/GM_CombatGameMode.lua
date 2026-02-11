--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
---@type EventDispatcher
local EventDispatcher = require("Core.EventDispatcher")
---@type GM_CombatGameMode_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
	print("[Combat] ReceiveBeginPlay ====================================")
	EventDispatcher.AddEvent("ACEnterCombat", self.EnterCombat, self)
end

function M:ReceiveEndPlay()
end

 function M:OnStartPlay()
     print("[Combat] StartPlay ====================================")
	 EventDispatcher.Dispatch("CAEnterCombat")
 end


function M:EnterCombat(data)
	print("[Combat] EnterCombat ====================================")
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
