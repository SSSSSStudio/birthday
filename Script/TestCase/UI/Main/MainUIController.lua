-- MainUIController.lua
-- Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")
local EventDispatcher = require("Core.EventDispatcher")

---@class MainUIController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
--- @param view UUserWidget View 实例
--- @param model MainUIModel|nil Model 实例（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

--- 绑定 View 事件
function M:BindViewEvents()
    -- 绑定按钮点击事件
    self:BindButtonClick("ButtonClose", self.OnButtonCloseClick)
    self:BindButtonClick("ButtonExp", self.OnButtonExpClick)
	self:BindButtonClick("ButtonEvent", self.OnButtonEventClick)
	self:BindButtonClick("ButtonPet", self.OnButtonPetClick)
end

--- 打开按钮点击事件
function M:OnButtonCloseClick()
	print("Open button clicked")
	local UIManager = require("UI.Core.UIManager")
	UIManager.HideUI("Main")
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
end

function M:OnButtonPetClick()
    print("Pet button clicked")
    local UIManager = require("UI.Core.UIManager")
    UIManager.ShowUI("PetMain")
end

--- 更新 View 显示
function M:UpdateView()
    if not self.model then
        return
    end
    
    -- 从 Model 获取数据并更新 View
    self:SetText("TitleText", self.model:Get("title", "Main UI"))
    self:SetText("CountText", "Count: " .. tostring(self.model:Get("count", 0)))
    
    -- 如果有等级和经验相关的控件，也可以更新
    local level = self.model:Get("level", 1)
    local expPercent = 0
    if self.model.GetExpPercent then
        expPercent = self.model:GetExpPercent()
    end
    self:SetText("LevelText", "Level: " .. tostring(level))
    self:SetText("ExpText", "Exp: " .. string.format("%.1f%%", expPercent))
end

--- 关闭按钮点击事件
function M:OnCloseButtonClick()
    print("Close button clicked")
    self:Hide()
end

--- UI 显示时调用
function M:OnShow()
    print("MainUIController: OnShow")
    self:UpdateView()
end

--- UI 隐藏时调用
function M:OnHide()
    print("MainUIController: OnHide")
end

--- UI 销毁时调用
function M:OnDestroy()
    print("MainUIController: OnDestroy")
end

return M
