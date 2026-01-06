--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_Main_C
local M = UnLua.Class()

function M:Initialize(Initializer)
end

function M:PreConstruct(IsDesignTime)
end

 function M:Construct()
	 ---@type WBP_Attribute_C
	 self.AttrView = self.WBP_Attribute_97;
	 self.AttrView.Title:SetText("主角属性")
	 
	 ---@type MainUIModel
	 self.uiModel = self.Model
	 print("Construct",self.ButtonClose,self.Controller.UpdateView,self.Model.sugen)
	 
 end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:UpdateAttr()
	self.AttrView:UpdateView(self.uiModel:GetAttrData())
end

return M
