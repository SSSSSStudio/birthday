-- GMController.lua
-- GM 工具控制器
local LuaHelper = require("Utility.LuaHelper")
local UIManager = require("UI.UIManager")

---@class GMController : UIControllerBase
local M = LuaHelper.LuaClass("UI.UIControllerBase")

---创建控制器实例
---@param view UUserWidget View 实例
---@param model GMModel|nil Model 实例（可选）
function M:__OnNew(name, view, model)
    self.Super.__OnNew(self, name, view, model)
	self.view:SubscribeEvent("OnButtonCloseClick", self.OnButtonCloseClick, self)
	self:UpdateView()
end

---更新 View 显示
function M:UpdateView()
    if not self.model then
        self.view:SetTips("GM工具")
        return
    end
    
    local tips = self.model:Get("tips", "GM工具")
	self.view:SetTips(tips)
end

function M:OnButtonCloseClick()
	UIManager.Top_Close(self.name)	
end

return M
