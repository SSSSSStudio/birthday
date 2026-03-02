local LuaHelper = require("Utility.LuaHelper")
local CombatState = require("GamePlay.Combat.GameLogic.CombatState")
local CombatEvent = require("GamePlay.Combat.GameLogic.CombatEvent")

local M = LuaHelper.LuaClass()

M.InputMode = {
	Manual = 1,
	Auto = 2,
	Verify = 3
}

function M:__OnNew(mode, inputData)
	self.mode = mode
	if inputData ~= nil then
		self.mode = self.InputMode.Verify
	end
	self.inputData = inputData
	self.skillId = 0
	self.targetIds = {}
	self.isWaitingForInput = false
	self.inputCompleted = false

	CombatEvent.Subscribe(CombatEvent.EventType.ManualSkillInput, self.ManualSkillInput, self)
	CombatEvent.Subscribe(CombatEvent.EventType.ActionStart, self.ActionStart, self)
end

function M:__OnDestroy()
	CombatEvent.Unsubscribe(CombatEvent.EventType.ManualSkillInput, self.ManualSkillInput, self)
	CombatEvent.Unsubscribe(CombatEvent.EventType.ActionStart, self.ActionStart, self)
end

--- 获取输入模式
function M:GetMode()
	return self.mode
end
--- 设置输入模式
---@param mode number 输入模式
function M:SetMode(mode)
	self.mode = mode
end

--- 角色行动开始
---@param eventData table 技能输入数据
function M:ActionStart(eventData)
	if self.mode == M.InputMode.Manual then
		self.skillId = 0
		self.targetIds = {}
		self.isWaitingForInput = true
		self.inputCompleted = false
	end
end

-- 获取输入数据
---@param roundIndex number 回合索引
---@param attacker CombatEntity 攻击者
---@param skill Skill 技能
---@return table 输入数据
function M:GetInputData(roundIndex, attacker)
	if self.mode == M.InputMode.Manual then
		return { self.skillId, self.targetIds }
	elseif self.mode == M.InputMode.Verify then
		return self.inputData[roundIndex]
	elseif self.mode == M.InputMode.Auto then
		local autoSkill = attacker:GetAutoSkill()
		local targets = self:SelectTargetsAuto(attacker, autoSkill)
		return { autoSkill.id, targets }
	end

	return nil
end

--- 手动技能输入
---@param eventData table 技能输入数据
function M:ManualSkillInput(eventData)
	if self.mode == M.InputMode.Manual and self.isWaitingForInput then
		self.skillId = eventData.skillId
		self.targetIds = eventData.targetIds
		self.inputCompleted = true
		self.isWaitingForInput = false
		print("[CombatInput] Manual input received: skillId =", self.skillId, ", targetIds =", #self.targetIds)
	end
end

--- 检查是否在等待输入
---@return boolean
function M:IsWaitingForInput()
	return self.isWaitingForInput
end

--- 检查输入是否完成
---@return boolean
function M:IsInputCompleted()
	return self.inputCompleted
end

--- 获取自动选择目标
---@param attacker CombatEntity 攻击者
---@param skill Skill 技能
function M:SelectTargetsAuto(attacker, skill)
	local allEntities = attacker:CombatManager():GetAllAliveEntities()

	local targets = {}
	if skill:AutoSkillType() == CombatState.AutoSkillType.Self then
		-- 单体目标：对自己释放
		table.insert(targets, attacker.id)

	elseif skill:AutoSkillType() == CombatState.AutoSkillType.SelfTeam then
		-- 己方全体
		for _, entity in ipairs(allEntities) do
			if entity.entityType == attacker.entityType then
				table.insert(targets, entity.id)
			end
		end

	elseif skill:AutoSkillType() == CombatState.AutoSkillType.TargetTeam then
		-- 敌方全体
		for _, entity in ipairs(allEntities) do
			if entity:IsAlive() and entity.entityType ~= attacker.entityType then
				table.insert(targets, entity.id)
			end
		end

	elseif skill:AutoSkillType() == CombatState.AutoSkillType.SelfNearest then
		-- 己方最近
		local nearestEntity = nil
		local nearestDistance = 1000

		for _, entity in ipairs(allEntities) do
			if entity:IsAlive() and entity.entityType == attacker.entityType and entity ~= attacker then
				local distance = math.abs(entity.position - attacker.position)
				if distance < nearestDistance then
					nearestDistance = distance
					nearestEntity = entity
				end
			end
		end

		if nearestEntity then
			table.insert(targets, nearestEntity.id)
		end

	elseif skill:AutoSkillType() == CombatState.AutoSkillType.TargetNearest then
		-- 敌方最近
		local nearestEntity = nil
		local nearestDistance = 1000

		for _, entity in ipairs(allEntities) do
			if entity:IsAlive() and entity.entityType ~= attacker.entityType then
				local distance = math.abs(entity.position - attacker.position)
				if distance < nearestDistance then
					nearestDistance = distance
					nearestEntity = entity
				end
			end
		end

		if nearestEntity then
			table.insert(targets, nearestEntity.id)
		end

	elseif skill:AutoSkillType() == CombatState.AutoSkillType.SelfLowHealth then
		-- 己方血量最低
		local lowestHealthEntity = nil
		local lowestHealthPercent = 1.0

		for _, entity in ipairs(allEntities) do
			if entity:IsAlive() and entity.entityType == attacker.entityType then
				local healthPercent = entity:GetHpPercent():ToNumber()
				if healthPercent < lowestHealthPercent then
					lowestHealthPercent = healthPercent
					lowestHealthEntity = entity
				end
			end
		end

		if lowestHealthEntity then
			table.insert(targets, lowestHealthEntity.id)
		end

	elseif skill:AutoSkillType() == CombatState.AutoSkillType.TargetLowHealth then
		-- 敌方血量最低
		local lowestHealthEntity = nil
		local lowestHealthPercent = 1.0

		for _, entity in ipairs(allEntities) do
			if entity:IsAlive() and entity.entityType ~= attacker.entityType then
				local healthPercent = entity:GetHpPercent():ToNumber()
				if healthPercent < lowestHealthPercent then
					lowestHealthPercent = healthPercent
					lowestHealthEntity = entity
				end
			end
		end

		if lowestHealthEntity then
			table.insert(targets, lowestHealthEntity.id)
		end

	else
		-- 默认：选择第一个敌方目标
		for _, entity in ipairs(allEntities) do
			if entity:IsAlive() and entity.entityType ~= attacker.entityType then
				table.insert(targets, entity.id)
				break
			end
		end
	end

	return targets
end

return M