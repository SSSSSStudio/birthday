--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIManager
local UIManager = require("UI.UIManager")
---@type EventDispatcher
local EventDispatcher = require("Core.EventDispatcher")
---@type ProtoDispatcher
local ProtoDispatcher = require("Core.ProtoDispatcher")
---@type NetManager
local NetManager = require("Net.NetManager")
---@type EventLoop
local EventLoop = require("Core.EventLoop")
---@type JsonFile
local JsonFile = require("Utility.JsonFile")

local function SelectRole(self)
	local CGSelectRoleBuf = {
		roleUUID = self.roleUUID,
		timestamp = EventLoop.ClockMonotonic(),
	}
	NetManager.Send("CGSelectRoleBuf", CGSelectRoleBuf)
end

---@class BP_NetworkPlayerController_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
	self.bShowMouseCursor = true
	UE.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, nil, UE.EMouseLockMode.DoNotLock)
	
	self.controller = UIManager.State_Open("NetworkMain")
	EventDispatcher.AddEvent("AccountLoginSuccess", self.OnAccountLoginSuccess, self)
	EventDispatcher.AddEvent("ReconnectSuccess", self.OnReconnectSuccess,self)
	EventDispatcher.AddEvent("ReconnectFail",  self.OnReconnectFail,self)
	
	ProtoDispatcher.AddDispatch("GCCreateRoleSuccessBuf", self, self.OnCreateRoleSuccess)
	ProtoDispatcher.AddDispatch("GCCreateRoleFailBuf", self, self.OnCreateRoleFail)
	ProtoDispatcher.AddDispatch("GCSceneInfoBuf", self, self.OnSceneInfo)
	ProtoDispatcher.AddDispatch("GCEnterSceneBuf", self, self.OnEnterScene)

	
	self.accounInfo = JsonFile.ReadFromSandbox("AccountInfo.json")
	if not self.accounInfo then
		self.accounInfo = {
			username = "test",
            password = "123456",
		}
	end
	self.controller:SetAccount(self.accounInfo.username,self.accounInfo.password)
	self.roleUUID = nil
	self.token = nil
	self.sceneId = nil
end

function M:ReceiveEndPlay()
	UIManager.CloseAll()
end
 
-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:OnAccountLoginSuccess(proto)
    print("[BP_NetworkPlayerController_C] OnAccountLoginSuccess ====================================")
    local userName,password = self.controller:GetAccount()
	if self.accounInfo.username ~= userName then
	    self.accounInfo.username = userName
	    self.accounInfo.password = password
	    JsonFile.WriteToSandbox("AccountInfo.json", self.accounInfo)
	end
    	
    if proto == nil then
    	print("[BP_NetworkPlayerController_C] NeedCreateRole ====================================")
    	self.controller:OpenCreateRole()	
	else
    	self.roleUUID = proto.roleUUID
    	UIManager.Toast_Open(nil, "帐号登录成功")
    	SelectRole(self)
    end
end

function M:OnCreateRoleSuccess(proto)
    print("[BP_NetworkPlayerController_C] OnCreateRoleSuccess ====================================")
    self.roleUUID = proto.roleUUID
    UIManager.Toast_Open(nil, "创建角色成功")
    SelectRole(self)
end
function M:OnCreateRoleFail(proto)
    print("[BP_NetworkPlayerController_C] OnCreateRoleFail ====================================")
    UIManager.Toast_Open(nil, "创建角色失败")
end
function M:OnSceneInfo(proto)
    print("[BP_NetworkPlayerController_C] OnSceneInfo ====================================")
    	local CGEnterSceneBuf = {
    		timestamp = EventLoop.ClockMonotonic(),
    	}
    	NetManager.Send("CGEnterSceneBuf", CGEnterSceneBuf)
end
function M:OnEnterScene(proto)
    print("[BP_NetworkPlayerController_C] OnEnterScene ====================================")
	self.token = proto.token
	self.sceneId = proto.sceneId
    UIManager.Toast_Open(nil, "进入场景")
    self.controller:SetToken(self.token)
end

function M:OnReconnectSuccess(token)
    print("[BP_NetworkPlayerController_C] OnReconnectSuccess ====================================")
    UIManager.Toast_Open(nil, "重连成功")
    self.token = token
    self.controller:SetToken(self.token)
end
function M:OnReconnectFail(proto)
    print("[BP_NetworkPlayerController_C] OnReconnectFail ====================================")
    UIManager.Toast_Open(nil, "重连失败")
    NetManager.Close()
end

return M
