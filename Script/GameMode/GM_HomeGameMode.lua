--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
---@type EventDispatcher
local EventDispatcher = require("Core.EventDispatcher")

---@type GM_HomeGameMode_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
	print("[Home] ReceiveBeginPlay ====================================")
	EventDispatcher.AddEvent("ACEnterHome", self.EnterHome, self)
	
end

function M:ReceiveEndPlay()
end

function M:OnStartPlay()
	 --self.Overridden.StartPlay(self)
	 print("[Home] StartPlay ====================================")
	EventDispatcher.Dispatch("CAEnterHome")
end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end


function M:EnterHome(data)
	print("[Home] EnterHome ====================================")
end

return M
