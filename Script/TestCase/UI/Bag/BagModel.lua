-- BagModel.lua
-- Bag UI 模型
-- 负责管理 Bag UI 的数据

local LuaHelper = require("Utility.LuaHelper")

---@class BagModel : UIModelBase
local M = LuaHelper.LuaClass("UI.Core.UIModelBase")

---创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
end

---初始化模型
function M:Initialize()
    -- 设置默认数据
    self:Set("capacity", 50)
    self:Set("usedSlots", 0)
    self:Set("items", {})
end

---更新模型数据
---@param data table 新的数据
function M:UpdateModel(data)
    if not data then return end
    
    if data.capacity then
        self:Set("capacity", data.capacity)
    end
    if data.items then
        self:Set("items", data.items)
        self:Set("usedSlots", #data.items)
    end
end

---添加物品
---@param item table 物品数据
---@return boolean 是否添加成功
function M:AddItem(item)
    local capacity = self:Get("capacity", 50)
    local usedSlots = self:Get("usedSlots", 0)
    
    if usedSlots >= capacity then
        return false
    end
    
    local items = self:Get("items", {})
    table.insert(items, item)
    self:Set("items", items)
    self:Set("usedSlots", #items)
    return true
end

---移除物品
---@param index number 物品索引
---@return boolean 是否移除成功
function M:RemoveItem(index)
    local items = self:Get("items", {})
    if index < 1 or index > #items then
        return false
    end
    
    table.remove(items, index)
    self:Set("items", items)
    self:Set("usedSlots", #items)
    return true
end

---获取剩余空间
---@return number
function M:GetFreeSlots()
    local capacity = self:Get("capacity", 50)
    local usedSlots = self:Get("usedSlots", 0)
    return capacity - usedSlots
end

---重置数据
function M:Reset()
    self:Set("usedSlots", 0)
    self:Set("items", {})
end

---销毁模型
function M:Destroy()
    self:Reset()
    self.Super:Destroy()
end

return M
