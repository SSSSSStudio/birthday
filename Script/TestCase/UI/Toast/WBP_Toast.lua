-- WBP_Toast.lua
-- Toast View 层
-- 负责处理界面显示和动画

---@type WBP_Toast_C
local M = UnLua.Class()

---构造函数
function M:Construct()
    -- 播放入场动画
    if self.Anim_In then
        self:PlayAnimation(self.Anim_In)
    end
end

---设置提示内容（供 Controller 调用）
---@param message string
function M:SetContent(message)
    if self.TextBlock_Content then
        self.TextBlock_Content:SetText(message)
    end
end

return M
