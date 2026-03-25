--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIManager
local UIManager = require("UI.UIManager")

---@type ProtoDispatcher
local ProtoDispatcher = require("Core.ProtoDispatcher")
---@type NetPack
local NetPack = require("Net.NetPack")

local protoFileList = {
	"common_message_desc.proto",
	"base_message_desc.proto",
	"agent_message_desc.proto",
	"player_message_desc.proto",
}

---@type GM_DevelopGameMode_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end
function M:ReceiveBeginPlay()
	print("[GM_DevelopGameMode_C] ReceiveBeginPlay ====================================")
	UIManager.RegisterConfig("DevelopMain","UI.Develop.DevelopMainController","/Game/Development/UI/WBP_DevelopMain.WBP_DevelopMain_C")
	UIManager.RegisterConfig("TestMain","Test.UI.TestMainController","/Game/Test/UI/WBP_TestMain.WBP_TestMain_C")
	UIManager.RegisterConfig("NetworkMain","UI.Develop.Network.NetworkController","/Game/Development/UI/WBP_Network.WBP_Network_C")

	UIManager.Start()
	--网络协议环境
	ProtoDispatcher.Init("Development/ProtoFiles")
	ProtoDispatcher.ImportProtoFile(protoFileList)
	NetPack.Init("Development/ProtoFiles/message_id.json")
end


function M:ReceiveEndPlay()
	print("[GM_DevelopGameMode_C] ReceiveEndPlay ====================================")
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
