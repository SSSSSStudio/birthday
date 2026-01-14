require("Config.Debugger")
---@type LuaHelper
local LuaHelper = require("Utility.LuaHelper")
---@type EventLoop
local EventLoop = require("Core.EventLoop")
---@type ProtoDispatcher
local ProtoDispatcher = require("Core.ProtoDispatcher")
---@type NetPack
local NetPack = require("Net.NetPack")
---@type TcpClient
local TcpClient = require("Net.TcpClient")

local verifierPassword<const> = "25d55ad283aa400af464c76d713c07ad"

local protoFileList = {
	"common_message_desc.proto",
	"base_message_desc.proto",
	"agent_message_desc.proto",
	"player_message_desc.proto",
}

---@type GI_G01GameInstance_C
local M = UnLua.Class()

function M:ReceiveInit()
	LuaHelper.DisableGlobalVariable()
	EventLoop.Startup();

	--网络协议环境
	--ProtoDispatcher.Init("Config/ProtoFiles")
	--ProtoDispatcher.ImportProtoFile(protoFileList)
	--NetPack.Init("Config/ProtoFiles/message_id.json")
	
end

function M:ReceiveShutdown()
	ProtoDispatcher.Cleanup()
	EventLoop.Shutdown();
end

function M:RunTest()
	local test = require("TestCase.UnluaTest.RunAllTests")
end

function M:NetTest()
	self.tcpClient = TcpClient()
	self.tcpClient:SetDisconnectCallback(function()
		print("disconnect")
	end)
	self.tcpClient:Connect("test1","123456","30.245.44.40:18888")
end

return M