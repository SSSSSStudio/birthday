-- ActivityModel.lua
-- Activity UI 模型
-- 负责管理 Activity UI 的数据

local LuaHelper = require("Utility.LuaHelper")

---@class ActivityModel : ModelBase
local M = LuaHelper.LuaClass("Core.ModelBase")

---创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
	self:Initialize()
end

---销毁模型
function M:__OnGC()
	self:Reset()
	self.Super:__OnGC(self)
end

function M:Get(key,default)
	if not self[key] then
		return default
	end
	return self[key]
end

---初始化模型
function M:Initialize()
    -- 设置默认数据
	self.activityId = 0
	self.activityName = "活动"
	self.startTime = 0
    self.endTime = 0
	self.isActive = false
	self.rewards = {}
end

---更新模型数据
---@param data table 新的数据
function M:UpdateModel(data)
    if not data then return end
    
    if data.activityId then
		self.activityId = data.activityId
    end
    if data.activityName then
		self.activityName = data.activityName
    end
    if data.startTime then
		self.startTime = data.startTime
    end
    if data.endTime then
		self.endTime = data.endTime
    end
    if data.isActive ~= nil then
		self.isActive = data.isActive
    end
    if data.rewards then
		self.rewards = data.rewards
    end
end

---检查活动是否进行中
---@return boolean
function M:IsActivityActive()
    return self:Get("isActive", false)
end

---重置数据
function M:Reset()
	self.activityId = 0
	self.isActive = false
	self.rewards = {}
end



return M
