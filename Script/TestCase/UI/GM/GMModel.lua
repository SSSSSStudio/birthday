-- GMModel.lua
-- GM 工具模型
-- 负责管理 GM 工具的数据

local LuaHelper = require("Utility.LuaHelper")

---@class GMModel : UIModelBase
local M = LuaHelper.LuaClass("UI.Core.UIModelBase")

---创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
end

---初始化模型
function M:Initialize()
    -- 设置默认数据
    self:Set("tips", "GM工具")
    self:Set("commands", {})
    self:Set("history", {})
end

---更新模型数据
---@param data table 新的数据
function M:UpdateModel(data)
    if not data then return end
    
    if data.tips then
        self:Set("tips", data.tips)
    end
    if data.commands then
        self:Set("commands", data.commands)
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
    self:Set("history", history)
end

---获取命令历史
---@return table
function M:GetCommandHistory()
    return self:Get("history", {})
end

---清空命令历史
function M:ClearHistory()
    self:Set("history", {})
end

---重置数据
function M:Reset()
    self:Set("tips", "GM工具")
    self:Set("commands", {})
    self:Set("history", {})
end

---销毁模型
function M:Destroy()
    self:Reset()
    self.Super:Destroy()
end

return M
