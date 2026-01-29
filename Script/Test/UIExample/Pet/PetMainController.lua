-- PetMainController.lua
-- Pet Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")
local UIManager = require("UI.UIManager")

---@class PetMainController : UIControllerBase
local M = LuaHelper.LuaClass("UI.UIControllerBase")

--- 创建控制器实例
--- @param view UUserWidget View 实例
--- @param model PetMainModel|nil Model 实例（可选）
function M:__OnNew(name, view, model)
    self.Super.__OnNew(self, name, view, model)
	self.view:SubscribeEvent("OnButtonCloseClick", self.OnButtonCloseClick, self)
	self.view:SubscribeEvent("OnButtonExpClick", self.OnButtonExpClick, self)
	self.view:SubscribeEvent("OnButtonMainClick", self.OnButtonMainClick, self)
end

function M:OnInitModel(model)
	self.Super.OnInitModel(self,model)
	if self.model then
        self.model:SubscribeEvent("UpdateAttr", self.UpdateAttr, self)
    end
end

function M:OnChangeTitle(title)
    self.view:SetTitle(title)
end

--- 经验按钮点击事件
function M:OnButtonExpClick()
	print("Exp button clicked")
	--模拟服务器下发
	self.model:OnPetFeed({})
end

function M:UpdateAttr(Level, Exp, HP)
	self.view:UpdateAttr(Level, Exp, HP)
end

--- 关闭按钮点击事件
function M:OnButtonCloseClick()
	print("PetMain: Close button clicked")
	UIManager.State_CloseAndReopen()
end

function M:OnButtonMainClick()
	print("PetMain: Open Main button clicked")
	UIManager.State_CloseAndReopen()
end


return M
