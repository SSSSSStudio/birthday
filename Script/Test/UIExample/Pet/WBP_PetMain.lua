--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local num = 0

---@type WBP_PetMain_C
local M = UnLua.Class("UI.UIViewBase")


--function M:PreConstruct(IsDesignTime)
--end

 function M:Construct()
	 self.Super.Construct(self)
	 self.ButtonClose.OnClicked:Add(self,self:CreateEvent("OnButtonCloseClick"))
	 self.ButtonExp.OnClicked:Add(self,self:CreateEvent("OnButtonExpClick"))
	 self.ButtonMain.OnClicked:Add(self,self:CreateEvent("OnButtonMainClick"))
	 
	 ---@type WBP_Attribute_C
	 self.AttrView = self.WBP_Attribute;
	 self.AttrView.Title:SetText("宠物属性")

	 self.WBP_PetChild:SubscribeEvent("OnButtonCallMain", self.OnButtonCallMain, self)
	 self.WBP_PetChild:SubscribeEvent("OnButtonCallFuncMain", self.OnButtonCallFuncMain, self)
 end

--修改标题
function M:ChangeTitle(title)
    self.TextTitle:SetText(title)
end

function M:UpdateAttr(Level, Exp, HP)
	self.AttrView:UpdateAttr(Level, Exp, HP)
end

function M:OnButtonCallMain()
	print("OnButtonCallMain")
	num = num + 1

	self:ChangeTitle("宠物属性 已被子界面的操作修改+"..num)
end

function M:OnButtonCallFuncMain()
	print("OnButtonCallFuncMain")
end

function M:Destruct()
	self.Super.Destruct(self)
	self.ButtonClose.OnClicked:Clear()
	self.ButtonExp.OnClicked:Clear()
	self.ButtonMain.OnClicked:Clear()
	self.AttrView = nil;
	self.WBP_PetChild:RemoveAllEvent()
end


return M
