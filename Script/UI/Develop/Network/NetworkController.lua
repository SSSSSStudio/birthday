---
--- Created by hebo.pb.
--- DateTime: 2026/3/18 16:46
---

local LuaHelper = require("Utility.LuaHelper")
local UEHelper = require("Core.UEHelper")

---@type ProtoDispatcher
local ProtoDispatcher = require("Core.ProtoDispatcher")
---@type NetManager
local NetManager = require("Net.NetManager")
---@type EventLoop
local EventLoop = require("Core.EventLoop")

local IP<const> = "30.245.44.56"
local PORT<const> = 7001

---@class NetworkController : UIControllerBase
local M = LuaHelper.LuaClass("UI.UIControllerBase")

function M:__OnNew(name, view, model)
	self.Super.__OnNew(self, name, view, model)
	self.view:SubscribeEvent("OnLoginClick", self.OnLoginClick, self)
	self.view:SubscribeEvent("OnCloseClick", self.OnCloseClick, self)
	self.view:SubscribeEvent("OnCreateRoleClick", self.OnCreateRoleClick, self)
	self.view:SetAddress(IP,PORT)
end

function M:SetAccount(account,password)
    self.view:SetAccount(account,password)
end

function M:GetAccount()
    return self.view:GetUserName(),self.view:GetPassword()
end

function M:OnLoginClick()
    print("OnLoginClick")
    NetManager.ConnectToServer(self.view:GetUserName(),self.view:GetPassword(),self.view:GetAddress())
end
function M:OnCloseClick()
	UE.UGameplayStatics.OpenLevel(UEHelper.GetGameInstance(),"/Game/Maps/L_DevelopEntry")
end



function M:OnCreateRoleClick()
	local CGCreateRoleBuf = {
		roleName = self.view:GetRoleName(),
		timestamp = EventLoop.ClockMonotonic(),
		roleBodyData = {}
	}
	 NetManager.Send("CGCreateRoleBuf", CGCreateRoleBuf)
end

function M:OpenCreateRole()
    -- 随机生成 8-16 个数字和字母的字符串
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = math.random(8, 16)
    local roleName = ""
    for i = 1, length do
        local index = math.random(1, #chars)
        roleName = roleName .. string.sub(chars, index, index)
    end
    self.view:OpenCreateRole(roleName)
end


return M