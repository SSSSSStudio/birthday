-- BagController.lua
-- Bag UI 控制器
local LuaHelper = require("Utility.LuaHelper")
local UIManager = require("UI.UIManager")

---@class BagController : UIControllerBase
local M = LuaHelper.LuaClass("UI.UIControllerBase")

---创建控制器实例
---@param view UUserWidget View 实例
---@param model BagModel|nil Model 实例（可选）
function M:__OnNew(name, view, model)
    self.Super.__OnNew(self, name, view, model)
	self.view:SubscribeEvent("OnButtonCloseClick", self.OnButtonCloseClick, self)
	--self:UpdateView()
end

---更新 View 显示
function M:UpdateView()
    if not self.model then
        self:SetText("TextBlock_Content", "这是一个Bag Dialog测试界面")
        return
    end
    
    -- 从 Model 获取数据并更新 View
    local capacity = self.model:Get("capacity", 50)
    local usedSlots = self.model:Get("usedSlots", 0)
    local freeSlots = self.model:GetFreeSlots()
    
    self:SetText("TextBlock_Content", string.format("背包 %d/%d (剩余: %d)", usedSlots, capacity, freeSlots))
end

---关闭按钮点击事件
function M:OnButtonCloseClick()
	UIManager.Dialog_Close(self.name)
end

return M
