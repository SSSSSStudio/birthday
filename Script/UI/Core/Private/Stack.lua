-- Stack.lua
-- 堆栈数据结构（后进先出 LIFO）
local Interface = require("Utility.Interface")

---@class Stack
local M = Interface("Stack")

--- 创建新的堆栈实例
--- @param maxSize integer|nil 最大容量（nil 表示无限制）
--- @param allowDuplicate boolean|nil 是否允许重复元素（默认 true）
--- @return Stack 堆栈实例
function M:__init(maxSize, allowDuplicate)
	self.items = {}
	self.maxSize = maxSize  -- 最大容量，nil 表示无限制
	self.allowDuplicate = allowDuplicate ~= false  -- 默认允许重复
end

--- 压入元素到堆栈顶部
--- @param item any 要压入的元素
--- @return boolean true 如果压入成功，false 如果不允许重复且元素已存在
function M:Push(item)
    -- 如果不允许重复，检查元素是否已存在
    if not self.allowDuplicate then
        for i = 1, #self.items do
            if self.items[i] == item then
                return false  -- 元素已存在，不允许重复
            end
        end
    end
    
    -- 如果栈已满，先移除底部元素
    if self.maxSize and #self.items >= self.maxSize then
        table.remove(self.items, 1)
    end
    table.insert(self.items, item)
    return true
end

--- 将堆栈中的指定元素移动到顶部
--- @param item any 要移动的元素
--- @return boolean true 如果移动成功，false 如果元素不存在
function M:MoveToTop(item)
    for i = #self.items, 1, -1 do
        if self.items[i] == item then
            -- 移除该元素
            table.remove(self.items, i)
            -- 重新压入到顶部
            table.insert(self.items, item)
            return true
        end
    end
    return false
end

--- 弹出堆栈顶部的元素
--- @return any|nil 弹出的元素，如果堆栈为空则返回 nil
function M:Pop()
    if self:IsEmpty() then
        return nil
    end
    return table.remove(self.items)
end

--- 查看堆栈顶部的元素（不弹出）
--- @return any|nil 堆栈顶部的元素，如果堆栈为空则返回 nil
function M:Peek()
    if self:IsEmpty() then
        return nil
    end
    return self.items[#self.items]
end

--- 删除堆栈中的指定元素（删除第一个匹配的元素）
--- @param item any 要删除的元素
--- @return boolean true 如果删除成功，false 如果元素不存在
function M:Remove(item)
    for i = #self.items, 1, -1 do
        if self.items[i] == item then
            table.remove(self.items, i)
            return true
        end
    end
    return false
end

--- 检查堆栈是否为空
--- @return boolean true 如果堆栈为空，false 否则
function M:IsEmpty()
    return #self.items == 0
end

--- 获取堆栈的大小
--- @return integer 堆栈中的元素数量
function M:Size()
    return #self.items
end

--- 获取堆栈的最大容量
--- @return integer|nil 最大容量，nil 表示无限制
function M:GetMaxSize()
    return self.maxSize
end

--- 设置堆栈的最大容量
--- @param maxSize integer|nil 最大容量（nil 表示无限制）
function M:SetMaxSize(maxSize)
    self.maxSize = maxSize
    -- 如果当前元素数量超过新的最大容量，移除底部多余的元素
    if maxSize and #self.items > maxSize then
        local removeCount = #self.items - maxSize
        for i = 1, removeCount do
            table.remove(self.items, 1)
        end
    end
end

--- 获取是否允许重复元素
--- @return boolean true 如果允许重复，false 否则
function M:GetAllowDuplicate()
    return self.allowDuplicate
end

--- 设置是否允许重复元素
--- @param allowDuplicate boolean 是否允许重复元素
function M:SetAllowDuplicate(allowDuplicate)
    self.allowDuplicate = allowDuplicate
end

--- 清空堆栈
function M:Clear()
    self.items = {}
end

--- 遍历堆栈中的所有元素（从栈顶到栈底）
--- @param callback function 回调函数，接收元素作为参数
function M:ForEach(callback)
    if type(callback) ~= "function" then
        error("Stack.ForEach: callback must be a function")
        return
    end
    
    -- 从栈顶到栈底遍历
    for i = #self.items, 1, -1 do
        callback(self.items[i])
    end
end

--- 转换为数组（从栈顶到栈底）
--- @return table 数组
function M:ToArray()
    local result = {}
    for i = #self.items, 1, -1 do
        table.insert(result, self.items[i])
    end
    return result
end

--- 打印堆栈内容（用于调试）
function M:Debug()
    print("Stack (Top -> Bottom):")
    for i = #self.items, 1, -1 do
        print(string.format("  [%d] %s", i, tostring(self.items[i])))
    end
end

return M
