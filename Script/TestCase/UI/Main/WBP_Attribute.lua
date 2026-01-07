--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type WBP_Attribute_C
local M = UnLua.Class()

 function M:Construct()
 end

--- 更新属性显示
--- @param AttrData table 属性数据，包含LV、Exp、MP字段
function M:UpdateView(AttrData)
	if not AttrData then
		return
	end
	
	-- 更新等级文本
	if self.TextLV then
		self.TextLV:SetText("等级:           " .. tostring(AttrData.Level or 0))
	end
	
	-- 更新经验文本
	if self.TextExp then
		self.TextExp:SetText("经验值:       " .. tostring(AttrData.Exp or 0))
	end
	
	-- 更新魔法值文本
	if self.TextHP then
		self.TextHP:SetText("生命:           " .. tostring(AttrData.HP or 0))
	end
end

return M
