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
	 ---@type WBP_Attribute_C
	 self.AttrView = self.WBP_Attribute;
	 self.AttrView.Title:SetText("宠物属性")

	 ---@type MainUIModel
	 self.uiModel = self.Model

	 EventDispatcher.AddEvent("Pet.ChangeTitle",  self.ChangeTitle,self)
 end

--修改标题
function M:ChangeTitle(title)
    self.TextTitle:SetText(title)
end
--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:UpdateAttr()
	self.AttrView:UpdateView(self.uiModel:GetAttrData())
end

return M
