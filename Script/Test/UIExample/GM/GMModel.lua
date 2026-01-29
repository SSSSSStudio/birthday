-- GMModel.lua
-- GM 工具模型
-- 负责管理 GM 工具的数据

local LuaHelper = require("Utility.LuaHelper")

---@class GMModel : ModelBase
local M = LuaHelper.LuaClass("Core.ModelBase")

---创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
	self:Initialize()
end

function M:Get(key,default)
	if not self[key] then
		return default
	end
	return self[key]
end

---初始化模型
function M:Initialize()
	self.tips = "GM工具"
	self.commands = {}
	self.history = {}
end

---更新模型数据
---@param data table 新的数据
function M:UpdateModel(data)
    if not data then return end
    
    if data.tips then
		self.tips = data.tips
    end
    if data.commands then
		self.commands = data.commands
    end
end

---添加命令历史
---@param command string 命令
function M:AddCommandHistory(command)
    local history = self:Get("history", {})
    table.insert(history, {
        command = command,
        timestamp = os.time()
    })
	self.history = history
end

---获取命令历史
---@return table
function M:GetCommandHistory()
    return self:Get("history", {})
end

---清空命令历史
function M:ClearHistory()
	self.history = {}
end

---重置数据
function M:Reset()
	self.tips = "GM工具"
	self.commands = {}
	self.history = {}
end

---销毁模型
function M:Destroy()
    self:Reset()
	self.Super:Destroy(self)
end

return M
