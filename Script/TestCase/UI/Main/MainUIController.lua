-- MainUIController.lua
-- Main UI 控制器
local LuaHelper = require("Utility.LuaHelper")

---@class MainUIController : UIControllerBase
local M = LuaHelper.LuaClass("UI.Core.UIControllerBase")

--- 创建控制器实例
--- @param view UUserWidget View 实例
--- @param model MainUIModel|nil Model 实例（可选）
function M:__OnNew(view, model)
    self.Super.__OnNew(self, view, model)
end

--- UI 显示时调用
function M:OnShow()
    print("MainUIController: OnShow")
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
