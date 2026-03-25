--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--


---@class WBP_Network_C: UIViewBase
local M = UnLua.Class("UI.UIViewBase")

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
	self.Super.Construct(self)
	self.Button_1.OnClicked:Add(self,self:CreateEvent("OnLoginClick"))
	self.Button_2.OnClicked:Add(self,self:CreateEvent("OnCloseClick"))
	self.Button.OnClicked:Add(self,self:CreateEvent("OnCreateRoleClick"))
end

function M:SetAccount(userName,password)
    self.EditableTextBox_2:SetText(userName)
    self.EditableTextBox_3:SetText(password)
end
function M:SetAddress(ip,port)
    self.EditableTextBox:SetText(ip)
    self.EditableTextBox_1:SetText(port)
end
function M:GetUserName()
    return self.EditableTextBox_2:GetText()
end
function M:GetPassword()
    return self.EditableTextBox_3:GetText()
end
function M:GetAddress()
    return self.EditableTextBox:GetText() .. ":" .. self.EditableTextBox_1:GetText()
end

function M:OpenCreateRole(roleName)
    self.VerticalBox_212:SetVisibility(UE.ESlateVisibility.Visible)
    self.VerticalBox_56:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.EditableTextBox_4:SetText(roleName)
end
function M:GetRoleName()
    return self.EditableTextBox_4:GetText()
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

return M
