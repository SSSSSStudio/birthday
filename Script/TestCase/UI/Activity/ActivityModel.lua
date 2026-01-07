-- ActivityModel.lua
-- Activity UI 模型
-- 负责管理 Activity UI 的数据

local LuaHelper = require("Utility.LuaHelper")

---@class ActivityModel : UIModelBase
local M = LuaHelper.LuaClass("UI.Core.UIModelBase")

---创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
end

---初始化模型
function M:Initialize()
    -- 设置默认数据
    self:Set("activityId", 0)
    self:Set("activityName", "活动")
    self:Set("startTime", 0)
    self:Set("endTime", 0)
    self:Set("isActive", false)
    self:Set("rewards", {})
end

---更新模型数据
---@param data table 新的数据
function M:UpdateModel(data)
    if not data then return end
    
    if data.activityId then
        self:Set("activityId", data.activityId)
    end
    if data.activityName then
        self:Set("activityName", data.activityName)
    end
    if data.startTime then
        self:Set("startTime", data.startTime)
    end
    if data.endTime then
        self:Set("endTime", data.endTime)
    end
    if data.isActive ~= nil then
        self:Set("isActive", data.isActive)
    end
    if data.rewards then
        self:Set("rewards", data.rewards)
    end
end

---检查活动是否进行中
---@return boolean
function M:IsActivityActive()
    return self:Get("isActive", false)
end

---重置数据
function M:Reset()
    self:Set("activityId", 0)
    self:Set("isActive", false)
    self:Set("rewards", {})
end

---销毁模型
function M:Destroy()
    self:Reset()
    self.Super:Destroy()
end

return M
