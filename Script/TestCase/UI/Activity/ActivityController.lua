-- ActivityController.lua
-- Activity UI 控制器
local LuaHelper = require("Utility.LuaHelper")

---@class ActivityController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

---创建控制器实例
---@param view UUserWidget View 实例
---@param model ActivityModel|nil Model 实例（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

---更新 View 显示
function M:UpdateView()
    if not self.model then
        self:SetText("TextBlock_Content", "这是一个Activity测试界面")
        return
    end
    
    -- 从 Model 获取数据并更新 View
    local activityName = self.model:Get("activityName", "活动")
    local isActive = self.model:Get("isActive", false)
    local status = isActive and "进行中" or "未开始"
    
    self:SetText("TextBlock_Content", string.format("%s - %s", activityName, status))
end

---UI 显示时调用
function M:OnShow()
    self:UpdateView()
end

---UI 隐藏时调用
function M:OnHide()
end

---UI 销毁时调用
function M:OnDestroy()
end

return M
