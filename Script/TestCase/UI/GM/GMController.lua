-- GMController.lua
-- GM 工具控制器
local LuaHelper = require("Utility.LuaHelper")

---@class GMController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

---创建控制器实例
---@param view UUserWidget View 实例
---@param model GMModel|nil Model 实例（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

---更新 View 显示
function M:UpdateView()
    if not self.model then
        self:SetText("TextBlock_Tips", "GM工具")
        return
    end
    
    local tips = self.model:Get("tips", "GM工具")
    self:SetText("TextBlock_Tips", tips)
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
