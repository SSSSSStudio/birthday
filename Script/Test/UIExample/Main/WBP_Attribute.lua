--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_Attribute_C
local M = UnLua.Class()


--- 更新属性显示
--- @param Level integer 等级
--- @param Exp integer 经验
--- @param HP integer 魔法值
function M:UpdateAttr(Level, Exp, HP)
	-- 更新等级文本
	if self.TextLV then
		self.TextLV:SetText("等级:           " .. tostring(Level or 0))
	end
	
	-- 更新经验文本
	if self.TextExp then
		self.TextExp:SetText("经验值:       " .. tostring(Exp or 0))
	end
	
	-- 更新魔法值文本
	if self.TextHP then
		self.TextHP:SetText("生命:           " .. tostring(HP or 0))
	end
end

return M
