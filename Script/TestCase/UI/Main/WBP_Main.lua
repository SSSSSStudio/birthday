--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local EventDispatcher = require("Core.EventDispatcher")
---@type WBP_Main_C
local M = UnLua.Class()

function M:Initialize(Initializer)
end

function M:PreConstruct(IsDesignTime)
end

 function M:Construct()
	 self.ButtonClose.OnClicked:Add(self, self.OnButtonCloseClick)
	 self.ButtonExp.OnClicked:Add(self, self.OnButtonExpClick)
	 self.ButtonEvent.OnClicked:Add(self, self.OnButtonEventClick)
	 self.ButtonPet.OnClicked:Add(self, self.OnButtonPetClick)
	 
	 ---@type WBP_Attribute_C
	 self.AttrView = self.WBP_Attribute_97;
	 self.AttrView.Title:SetText("主角属性")
	 
	 ---@type MainUIModel
	 self.uiModel = self.Model
	 print("Construct",self.ButtonClose,self.Controller.UpdateView,self.Model.sugen)
 end
	
--- 打开按钮点击事件
function M:OnButtonCloseClick()
	print("Open button clicked")
	local UIManager = require("UI.Core.UIManager")
	UIManager.StateClose()
end

--- 经验按钮点击事件
function M:OnButtonExpClick()
	print("Exp button clicked")
	--模拟服务器下发
	EventDispatcher.Dispatch("Character.AddExp",  20)
	self:UpdateAttr()
end

function M:OnButtonEventClick()
	print("Event button clicked")
	EventDispatcher.Dispatch("Main.EventTest", { su=12,gen={1,2,"sugen"} })

	print("OnClicked ",self.ButtonClose.OnClicked:Broadcast())
end

function M:OnButtonPetClick()
	print("Pet button clicked")
	local UIManager = require("UI.Core.UIManager")
	UIManager.StateOpen("PetMain")
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:UpdateAttr()
	self.AttrView:UpdateView(self.uiModel:GetAttrData())
end

return M
