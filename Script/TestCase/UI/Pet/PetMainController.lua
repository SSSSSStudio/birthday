-- PetMainController.lua
-- Pet Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")

---@class PetMainController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
--- @param view UUserWidget View 实例
--- @param model PetMainModel|nil Model 实例（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

--- UI 显示时调用
function M:OnShow()
    print("PetMainController: OnShow")
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
