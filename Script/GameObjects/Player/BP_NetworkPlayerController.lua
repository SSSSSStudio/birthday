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
	
	ProtoDispatcher.AddDispatch("GCCreateRoleSuccessBuf", self, self.OnCreateRoleSuccess)
	ProtoDispatcher.AddDispatch("GCCreateRoleFailBuf", self, self.OnCreateRoleFail)
	ProtoDispatcher.AddDispatch("GCSceneInfoBuf", self, self.OnSceneInfo)
	
	self.accounInfo = JsonFile.ReadFromSandbox("AccountInfo.json")
	if not self.accounInfo then
		self.accounInfo = {
			username = "test",
            password = "123456",
		}
	end
	self.controller:SetAccount(self.accounInfo.username,self.accounInfo.password)
	self.roleUUID = nil
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
    UIManager.Toast_Open(nil, "进入场景")
end

return M
