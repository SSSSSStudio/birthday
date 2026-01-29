--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local UICommon = require("UI.UICommon")

---@class WBP_Main_C : UIViewBase
local M = UnLua.Class("UI.UIViewBase")

function M:Construct()
	self.Super.Construct(self)
	self.ButtonClose.OnClicked:Add(self,self:CreateEvent("OnButtonCloseClick"))
	self.ButtonExp.OnClicked:Add(self,self:CreateEvent("OnButtonExpClick"))
	self.ButtonEvent.OnClicked:Add(self,self:CreateEvent("OnButtonEventClick"))
	self.ButtonPet.OnClicked:Add(self,self:CreateEvent("OnButtonPetClick"))
	self.ButtonDialog.OnClicked:Add(self,self:CreateEvent("OnButtonDialog"))
	self.ButtonToast.OnClicked:Add(self,self:CreateEvent("OnButtonToast"))
	self.ButtonMsgBox.OnClicked:Add(self,self:CreateEvent("OnButtonMsgBox"))
	self.ButtonLock.OnClicked:Add(self, self:CreateEvent("OnButtonLock"))
	self.ButtonTop.OnClicked:Add(self, self:CreateEvent("OnButtonTop"))
	self.ButtonAllTest.OnClicked:Add(self, self:CreateEvent("OnButtonAllTest"))
	self.ButtonOther.OnClicked:Add(self, self:CreateEvent("OnButtonOther"))
	self.ButtonGuideTest1.OnClicked:Add(self, self:CreateEvent("OnButtonGuideTest1"))
	self.ButtonGuideTest2.OnClicked:Add(self, self:CreateEvent("OnButtonGuideTest2"))
	self.ButtonChangeMap.OnClicked:Add(self, self:CreateEvent("OnButtonChangeMap"))

	 ---@type WBP_Attribute_C
	 self.AttrView = self.WBP_Attribute_97;
	 self.AttrView.Title:SetText("主角属性")
 end

function M:UpdateAttr(Level, Exp, HP)
	if not self.AttrView then
        return
    end
	self.AttrView:UpdateAttr(Level, Exp, HP)
end

function M:OpenGuideToast()
	if self.ButtonToast then
		UICommon.GuideToButton(self,self.Overlay_35, self.ButtonToast, "OnButtonToast")
	end
end

function M:OpenGuidePet()
	if self.ButtonPet then
		UICommon.GuideToButton(self,self.Overlay_35, self.ButtonPet, "OnButtonPetClick")
	end
end

return M
