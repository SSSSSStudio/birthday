-- WBP_Lock.lua
-- Lock View 层
-- 负责锁定界面的显示逻辑

---@type WBP_Lock_C
local M = UnLua.Class()

---构造函数
function M:Construct()
    -- 锁定界面通常拦截点击，防止穿透
    self:SetVisibility(UE.ESlateVisibility.Visible)
end

---设置提示信息
---@param message string
function M:SetMessage(message)
    if self.Textblock_Tips then
        self.Textblock_Tips:SetText(message)
    end
end

return M