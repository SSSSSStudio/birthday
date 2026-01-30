-- MainUIController.lua
-- Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")
local UIManager = require("UI.UIManager")
local UEHelper = require("Core.UEHelper")

local index = 0

---@class MainUIController : UIControllerBase
local M = LuaHelper.LuaClass("UI.UIControllerBase")

--- 创建控制器实例
--- @param name string UI名称
--- @param view UUserWidget View 实例
--- @param model MainUIModel|nil Model 实例（可选）
function M:__OnNew(name, view, model)
    -- 正确调用父类构造函数
    self.Super.__OnNew(self, name, view, model)
    
    -- 确保view已正确初始化后再订阅事件
    if self.view then
        self.view:SubscribeEvent("OnButtonCloseClick", self.OnButtonCloseClick, self)
        self.view:SubscribeEvent("OnButtonExpClick", self.OnButtonExpClick, self)
        self.view:SubscribeEvent("OnButtonEventClick", self.OnButtonEventClick, self)
        self.view:SubscribeEvent("OnButtonPetClick", self.OnButtonPetClick, self)
        self.view:SubscribeEvent("OnButtonDialog", self.OnButtonDialog, self)
        self.view:SubscribeEvent("OnButtonToast", self.OnButtonToast, self)
        self.view:SubscribeEvent("OnButtonMsgBox", self.OnButtonMsgBox, self)
        
        self.view:SubscribeEvent("OnButtonLock", self.OnButtonLock, self)
        self.view:SubscribeEvent("OnButtonTop", self.OnButtonTop, self)

        self.view:SubscribeEvent("OnButtonAllTest", self.OnButtonAllTest, self)
        self.view:SubscribeEvent("OnButtonOther", self.OnButtonOther, self)
        self.view:SubscribeEvent("OnButtonGuideTest1", self.OnButtonGuideTest1, self)
        self.view:SubscribeEvent("OnButtonGuideTest2", self.OnButtonGuideTest2, self)
        self.view:SubscribeEvent("OnButtonChangeMap", self.OnButtonChangeMap, self)
    else
        print("Error: view is nil in MainUIController.__OnNew")
    end
end

function M:OnInitModel(model)
	self.Super.OnInitModel(self,model)
	if self.model then
		self.model:SubscribeEvent("UpdateAttr", self.UpdateAttr, self)
	end
end

--- 打开按钮点击事件
function M:OnButtonCloseClick()
	print("Open button clicked")
	UIManager.State_CloseAndReopen()
end

--- 经验按钮点击事件
function M:OnButtonExpClick()
	print("Exp button clicked")
	--模拟服务器下发
	self.model:AddExp(30)
end

--- 更新属性
function M:UpdateAttr(level, exp, hp)
	self.view:UpdateAttr(level, exp, hp)
end

function M:OnButtonEventClick()
	print("Event button clicked")
	self.model:EventTest( { su=12,gen={1,2,"sugen"} })
end

function M:OnButtonPetClick()
	print("Pet button clicked")
	UIManager.State_Open("PetMain",self.model:GetPetMainData())
end

function M:OnButtonDialog()
	print("OnButtonDialog") 
	UIManager.Dialog_Open("Activity",self.model:GetActivity())
end

function M:OnButtonToast()
	print("Toast button clicked")
	index = index + 1
	UIManager.Toast_Open(nil,"这是一条飘字,可设置类容和持续时间 +"..index, 3.0)
end

function M:OnButtonMsgBox()
	print("MsgBox button clicked")
	local msgBoxController = UIManager.MsgBox_OpenAlert(nil,"提示", "这是一个消息框\n能修改标题和类容")
	msgBoxController:SetConfirmText("确认")
	msgBoxController:SetCancelText("取消")
	msgBoxController:SetConfirmCallback(function()
        print("Confirm clicked")
		UIManager.MsgBox_Close(msgBoxController:GetName())
    end)
end

function M:OnButtonLock()
	print("Lock button clicked")
	UIManager.Lock_OpenWithTimeout(nil,"加载中，5秒后自动关闭...", 5)
end

function M:OnButtonTop()
	print("Top button clicked")
	UIManager.Top_Open("GM",self.model:GetGMModel())
end

function M:TestTopClose()
	UIManager.Top_Open("GM",self.model:GetGMModel())
	UIManager.Top_Close("GM")
end

function M:OnButtonOther()
	print("Other button clicked")
	UIManager.Dialog_Open("Bag",self.model:GetBagModel())
end

function M:OnButtonAllTest()
	
	-- 1. Dialog 层 - 对话框
	print("1. 打开 Dialog 层 - Activity")
	UIManager.Dialog_Open("Activity",self.model:GetActivity())
	UIManager.Dialog_Open("Bag",self.model:GetBagModel())

	-- 2. Toast 层 - 提示
	print("2. 打开 Toast 层")
	UIManager.Toast_Open(nil,"六层级测试：所有层级都已打开", 3.0)

	-- 3. MsgBox 层 - 消息框
	print("3. 打开 MsgBox 层")
	local msgBoxController = UIManager.MsgBox_OpenAlert(nil,"提示", "这是一个消息框\n能修改标题和类容")
	msgBoxController:SetConfirmText("确认")
	msgBoxController:SetCancelText("取消")
	msgBoxController:SetConfirmCallback(function()
		print("Confirm clicked")
		UIManager.MsgBox_Close(msgBoxController:GetName())
	end)

	-- 4. Lock 层 - 锁定界面
	print("4. 打开 Lock 层")
	UIManager.Lock_OpenWithTimeout(nil,"加载中，5秒后自动关闭...", 5)

	-- 5. Top 层 - GM工具
	print("5. 打开 Top 层 - GM")
	UIManager.Top_Open("GM",self.model:GetGMModel())

	-- 1. State 层 - 主界面
	print("6. 打开 State 层 - Main")
	UIManager.State_Open("PetMain",self.model:GetPetMainData())
end

function M:OnButtonGuideTest1()
	self.view:OpenGuideToast()
end

function M:OnButtonGuideTest2()
	self.view:OpenGuidePet()
end

function M:OnButtonChangeMap()
	UE.UGameplayStatics.OpenLevel(UEHelper.GetGameInstance(),"/Game/Test/UITest/UIMap2")
end

return M