-- WBP_GM.lua
-- GM View 层

---@type WBP_GM_C
local M = UnLua.Class()

function M:Construct()
    -- 绑定关闭按钮事件
    self.Button_Close.OnClicked:Add(self, self.OnButtonCloseClick)
end

---关闭按钮点击事件
function M:OnButtonCloseClick()
    local UIManager = require("UI.Core.UIManager")
    UIManager.Top_Close("GM")
end

return M
