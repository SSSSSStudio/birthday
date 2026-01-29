-- ActivityController.lua
-- Activity UI 控制器
local LuaHelper = require("Utility.LuaHelper")
local UIManager = require("UI.UIManager")

---@class ActivityController : UIControllerBase
local M = LuaHelper.LuaClass("UI.UIControllerBase")

---创建控制器实例
---@param view UUserWidget View 实例
---@param model ActivityModel|nil Model 实例（可选）
function M:__OnNew(name, view, model)
    self.Super.__OnNew(self, name, view, model)
	
	self.view:SubscribeEvent("OnButtonCloseClick", self.OnButtonCloseClick, self)
	
	self:UpdateView()
end

---关闭按钮点击事件
function M:OnButtonCloseClick()
	UIManager.Dialog_Close(self.name)
end

---更新 View 显示
function M:UpdateView()
    local content = "这是一个Activity测试界面"
    if self.model then
        -- 从 Model 获取数据并更新 View
        local activityName = self.model:Get("activityName", "活动")
        local isActive = self.model:Get("isActive", false)
        local status = isActive and "进行中" or "未开始"
        content = string.format("%s - %s", activityName, status)
    end
    
    if self.view then
        self.view:SetActivityContent(content)
    end
end

return M