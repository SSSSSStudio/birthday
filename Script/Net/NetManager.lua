---
--- Created by hebo.pb.
--- DateTime: 2026/3/18 14:27
---

---@type TcpClient
local TcpClient = require("Net.TcpClient")
---@type EventDispatcher
local EventDispatcher = require("Core.EventDispatcher")


local CSConnection = nil

local function ProtoToEvent(_,name,proto)
    EventDispatcher.Dispatch(name,proto)
end

---@class NetManager
local M = {}

function M.ConnectToServer(userName,password,address)
	CSConnection = TcpClient()
	CSConnection:SetDisconnectCallback(function()
    	CSConnection:Close()
    	CSConnection = nil
    	EventDispatcher.Dispatch("Disconnection")
	end)
	CSConnection:Connect(userName,password,address)
end

function M.Close(timeoutMs)
    if CSConnection then
        CSConnection:Close(timeoutMs)
        CSConnection = nil
    end
end

function M.Send(name,proto)
    if CSConnection then
        CSConnection:Send(name,proto)
    end
end

return M

