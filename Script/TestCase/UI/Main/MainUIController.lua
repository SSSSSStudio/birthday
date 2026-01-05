-- MainUIController.lua
-- Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")

---@class MainUIController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
--- @param view UUserWidget View 实例
--- @param model table|nil Model 数据（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

--- 绑定 View 事件
function M:BindViewEvents()
    -- 绑定按钮点击事件
    self:BindButtonClick("ButtonClose", self.OnButtonCloseClick)
    self:BindButtonClick("CloseButton", self.OnCloseButtonClick)
end

--- 初始化 Model 数据
function M:InitializeModel()
    self.model.title = "Main UI"
    self.model.count = 0
end

--- 更新 View 显示
function M:UpdateView()
    self:SetText("TitleText", self.model.title)
    self:SetText("CountText", "Count: " .. tostring(self.model.count))
end

--- 打开按钮点击事件
function M:OnButtonCloseClick()
    print("Open button clicked")
    self.model.count = self.model.count + 1
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
