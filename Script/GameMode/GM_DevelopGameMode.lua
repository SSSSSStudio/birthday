--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type SimulationServer
local SimulationServer = require("Development.SimulationServer")

---@type UIManager
local UIManager = require("UI.UIManager")

---@type TcpClient
local TcpClient = require("Net.TcpClient")

---@type GM_DevelopGameMode_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end
function M:ReceiveBeginPlay()
	print("[GM_DevelopGameMode_C] ReceiveBeginPlay ====================================")
	SimulationServer.Initialize()
	UIManager.Initialize()
end

function M:ReceiveEndPlay()
	print("[GM_DevelopGameMode_C] ReceiveEndPlay ====================================")
	SimulationServer.Shutdown()
end

function M:OnStartPlay()
	print("[GM_DevelopGameMode_C] OnStartPlay ====================================")
end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

--function M:NetTest()
--	self.tcpClient = TcpClient()
--	self.tcpClient:SetDisconnectCallback(function()
--		print("disconnect")
--	end)
--	self.tcpClient:Connect("test1","123456","30.245.44.40:18888")
--end

return M
