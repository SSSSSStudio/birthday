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

---@type GM_HomeGameMode_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
	print("[Home] ReceiveBeginPlay ====================================")
	SimulationServer.Initialize()
	EventDispatcher.AddEvent("ACEnterHome", self.EnterHome, self)
	EventDispatcher.AddEvent("ACLeaveHome", self.LeaveHome, self)
	EventDispatcher.AddEvent("ACEnterHomeEditMode", self.EnterHomeEditMode, self)
	EventDispatcher.AddEvent("ACLeaveHomeEditMode", self.LeaveHomeEditMode, self)
	
end

function M:ReceiveEndPlay()
	SimulationServer.Shutdown()
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

function M:LeaveHome(data)
    print("[Home] LeaveHome ====================================")
end

function M:EnterHomeEditMode(data)
    print("[Home] EnterHomeEditMode ====================================")
end

function M:LeaveHomeEditMode(data)
    print("[Home] LeaveHomeEditMode ====================================")
end


return M
