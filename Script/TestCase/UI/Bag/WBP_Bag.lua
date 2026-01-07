-- WBP_Bag.lua
-- Bag View 层

---@type WBP_Bag_C
local M = UnLua.Class()

function M:Construct()
    -- 绑定按钮事件
    self.Button_Close.OnClicked:Add(self, self.OnButtonCloseClick)
end

---关闭按钮点击事件
function M:OnButtonCloseClick()
    local UIManager = require("UI.Core.UIManager")
    UIManager.Dialog_Close("Bag")
end

return M
