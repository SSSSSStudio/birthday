-- PetMainController.lua
-- Pet Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")
local EventDispatcher = require("Core.EventDispatcher")

---@class PetMainController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
--- @param view UUserWidget View 实例
--- @param model PetMainModel|nil Model 实例（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

--- 绑定 View 事件
function M:BindViewEvents()
    -- 绑定按钮点击事件
    self:BindButtonClick("ButtonClose", self.OnButtonCloseClick)
    self:BindButtonClick("ButtonMain", self.OnButtonMainClick)
	self:BindButtonClick("ButtonExp", self.OnButtonExpClick)
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
    UIManager.HideUI("PetMain")
end

--- 打开子界面按钮点击事件
function M:OnButtonOpenChildClick()
    print("PetMain: Open Child button clicked")
    local UIManager = require("UI.Core.UIManager")
    UIManager.ShowUI("PetChild", { petId = self.model:Get("petId", 0) })
end

function M:OnButtonMainClick()
	print("PetMain: Open Main button clicked")
	local UIManager = require("UI.Core.UIManager")
    UIManager.ShowUI("Main")
end

--- 玩耍按钮点击事件
function M:OnButtonPlayClick()
    print("PetMain: Play button clicked")
    if self.model then
        self.model:Play()
    end
end

--- 更新 View 显示
function M:UpdateView()
    if not self.model then
        return
    end
    
    -- 从 Model 获取数据并更新 View
    self:SetText("PetNameText", self.model:Get("petName", "Unknown"))
    self:SetText("PetLevelText", "Level: " .. tostring(self.model:Get("level", 1)))
    self:SetText("PetHungerText", "Hunger: " .. tostring(self.model:Get("hunger", 100)))
    self:SetText("PetHappinessText", "Happiness: " .. tostring(self.model:Get("happiness", 100)))
    
    -- 更新进度条
    local hungerPercent = self.model:GetHungerPercent()
    local happinessPercent = self.model:GetHappinessPercent()
    
    -- 假设有进度条控件
    -- self:SetProgressBar("HungerProgressBar", hungerPercent)
    -- self:SetProgressBar("HappinessProgressBar", happinessPercent)
end

--- UI 显示时调用
function M:OnShow()
    print("PetMainController: OnShow")
    self:UpdateView()
end

--- UI 隐藏时调用
function M:OnHide()
    print("PetMainController: OnHide")
end

--- UI 销毁时调用
function M:OnDestroy()
    print("PetMainController: OnDestroy")
end

return M
