---
--- Created by hebo.pb.
--- DateTime: 2026/3/18 14:27
---

---@type TcpClient
local TcpClient = require("Net.TcpClient")
---@type EventDispatcher
local EventDispatcher = require("Core.EventDispatcher")

local CSConnection = nil

---@class NetManager
local M = {}
function M.Initialize()
	CSConnection = TcpClient()
	CSConnection:SetDisconnectCallback(function()
    	CSConnection:Close()
    	EventDispatcher.Dispatch("Disconnection")
	end)
end
function M.Shutdown()
    if CSConnection then
        CSConnection:Close()
        CSConnection = nil
    end
end
function M.ConnectToServer(userName,password,address)
	if CSConnection then
        CSConnection:Connect(userName,password,address)
    end
end

function M.ReconnectToServer(token)
    if CSConnection then
        CSConnection:Reconnect(token)
    end
end
function M.Close(timeoutMs)
    if CSConnection then
        CSConnection:Close(timeoutMs)
    end
end
function M.Send(name,proto)
    if CSConnection then
        CSConnection:Send(name,proto)
    end
end

return M

