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
	 
	 self.ButtonDialog.OnClicked:Add(self, self.OnButtonDialog)
	 self.ButtonToast.OnClicked:Add(self, self.OnButtonToast)
	 self.ButtonMsgBox.OnClicked:Add(self, self.OnButtonMsgBox)
	 self.ButtonLock.OnClicked:Add(self, self.OnButtonLock)
	 self.ButtonTop.OnClicked:Add(self, self.OnButtonTop)
	 self.ButtonAllTest.OnClicked:Add(self, self.OnButtonAllTest)
	 self.ButtonOther.OnClicked:Add(self, self.OnButtonOther)
	 self.ButtonGuideTest1.OnClicked:Add(self, self.OnButtonGuideTest1)
	 self.ButtonGuideTest2.OnClicked:Add(self, self.OnButtonGuideTest2)
	 self.ButtonAddRedPoint.OnClicked:Add(self, self.OnButtonAddRedPoint)
	 self.ButtonRemoveRedPoint.OnClicked:Add(self, self.OnButtonRemoveRedPoint)
	 
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
	UIManager.State_Close()
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
	UIManager.State_Open("PetMain")
end

function M:OnButtonDialog()
    print("ReceiveBeginPlay")
	local UIManager = require("UI.Core.UIManager")
	UIManager.Dialog_Open("Activity", {title = "活动"})
end

function M:OnButtonToast()
    print("Toast button clicked")
    local UIManager = require("UI.Core.UIManager")
    UIManager.Toast_Open("六层级测试：所有层级都已打开", 3.0)
end

function M:OnButtonMsgBox()
    print("MsgBox button clicked")
    local UIManager = require("UI.Core.UIManager")
    UIManager.MsgBox_OpenAlert("提示", "这是一个六层级测试\n所有UI层都已显示")
end

function M:OnButtonLock()
    print("Lock button clicked")
    local UIManager = require("UI.Core.UIManager")
    UIManager.Lock_OpenWithTimeout("加载中，5秒后自动关闭...", 5)
end

function M:OnButtonTop()
    print("Top button clicked")
    local UIManager = require("UI.Core.UIManager")
    UIManager.Top_Open("GM")
end

function M.TestTopClose()
    local UIManager = require("UI.Core.UIManager")
    UIManager.Top_Open("GM")
    UIManager.Top_Close("GM")
end

function M:OnButtonAllTest()
	-- 运行UI测试
	local UIManagerTest = require("TestCase.UI.UIManagerTest")
	UIManagerTest.TestMultiLayer()
end

function M:OnButtonOther()
    print("Other button clicked")
end

function M:OnButtonGuideTest1()
	self.CanvasPanel_71:Setvisibility(UE.ESlateVisibility.Visible)
	local UITool = require("UI.Core.UITool")
	local NewWidget,Button = UITool.DuplicateWidgetToLayer(self.CanvasPanel_71, "Main", "ButtonToast")
	Button.OnClicked:Add(self, function() 
		print("NewWidget clicked")
		self:OnButtonToast()
		self.CanvasPanel_71:Setvisibility(UE.ESlateVisibility.Hidden)
		NewWidget:RemoveFromParent()
	end)
end

function M:OnButtonGuideTest2()
	self.CanvasPanel_71:Setvisibility(UE.ESlateVisibility.Visible)
	local UITool = require("UI.Core.UITool")
	local NewWidget,Button = UITool.DuplicateWidgetToLayer(self.CanvasPanel_71, "Main", "ButtonClose")
	Button.OnClicked:Add(self, function()
		print("NewWidget clicked")
		self:OnButtonCloseClick()
		self.CanvasPanel_71:Setvisibility(UE.ESlateVisibility.Hidden)
		NewWidget:RemoveFromParent()
	end)
end

function M:OnButtonAddRedPoint()
	local UITool = require("UI.Core.UITool")
	UITool.AddRedDotToButton(self.ButtonClose)
end

function M:OnButtonRemoveRedPoint()
    local UITool = require("UI.Core.UITool")
    UITool.RemoveRedDotFromButton(self.ButtonClose)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:UpdateAttr()
	self.AttrView:UpdateView(self.uiModel:GetAttrData())
end

return M
