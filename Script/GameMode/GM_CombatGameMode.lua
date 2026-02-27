--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
---@type SimulationServer
local SimulationServer = require("Development.SimulationServer")
---@type EventDispatcher
local EventDispatcher = require("Core.EventDispatcher")
---@type CombatSystem
local CombatSystem = require("GamePlay.Combat.GameLogic.CombatSystem")

---@type GM_CombatGameMode_C
local M = UnLua.Class()

function M:Initialize(Initializer)
	CombatSystem.Initialize()
end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
	print("[Combat] ReceiveBeginPlay ====================================")
	SimulationServer.Initialize()
	EventDispatcher.AddEvent("ACEnterCombat", self.EnterCombat, self)
	EventDispatcher.AddEvent("ACFinishCombat", self.FinishCombat, self)
end

function M:ReceiveEndPlay()
	SimulationServer.Shutdown()
	CombatSystem.Deinitialize()
end

 function M:OnStartPlay()
     print("[Combat] StartPlay ====================================")
	 EventDispatcher.Dispatch("CAEnterCombat")
 end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:EnterCombat(data)
	--开始进入战斗
	print("[Combat] EnterCombat ====================================")
	CombatSystem.BeginPlay(3457)
	
end

function M:FinishCombat(data)
	--结束战斗
	print("[Combat] FinishCombat ====================================")
	CombatSystem.EndPlay()
end

return M
