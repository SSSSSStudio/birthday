--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local EventDispatcher = require("Core.EventDispatcher")

---@type WBP_PetMain_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

 function M:Construct()
	 self.ButtonClose.OnClicked:Add(self, self.OnButtonCloseClick)
	 self.ButtonExp.OnClicked:Add(self, self.OnButtonExpClick)
	 self.ButtonMain.OnClicked:Add(self, self.OnButtonMainClick)
	 
	 ---@type WBP_Attribute_C
	 self.AttrView = self.WBP_Attribute;
	 self.AttrView.Title:SetText("宠物属性")

	 ---@type MainUIModel
	 self.uiModel = self.Model

	 EventDispatcher.AddEvent("Pet.ChangeTitle",  self.ChangeTitle,self)
 end

--- 经验按钮点击事件
function M:OnButtonExpClick()
	print("Exp button clicked")
	--模拟服务器下发
	EventDispatcher.Dispatch("Pet.Feed", {})
	self:UpdateAttr()
end

--- 关闭按钮点击事件
function M:OnButtonCloseClick()
	print("PetMain: Close button clicked")
	local UIManager = require("UI.Core.UIManager")
	UIManager.State_Close()
end

function M:OnButtonMainClick()
	print("PetMain: Open Main button clicked")
	local UIManager = require("UI.Core.UIManager")
	UIManager.State_Open("Main")
end

--修改标题
function M:ChangeTitle(title)
    self.TextTitle:SetText(title)
end

function M:UpdateAttr()
	self.AttrView:UpdateView(self.uiModel:GetAttrData())
end

return M
