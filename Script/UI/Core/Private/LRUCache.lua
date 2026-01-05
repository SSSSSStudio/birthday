-- LRUCache.lua
-- LRU（Least Recently Used）缓存数据结构，用于 UI 管理
-- 自动淘汰最近最少使用的 UI 元素，优化内存使用

local Interface = require("Utility.Interface")

---@class LRUCacheNode
---@field key any 键
---@field value any 值
---@field prev LRUCacheNode|nil 前一个节点
---@field next LRUCacheNode|nil 后一个节点

---@class LRUCache
local M = Interface("LRUCache")

--- 创建 LRU 缓存
--- @param capacity integer 缓存容量
--- @param onEvict function|nil 淘汰回调函数，当元素被淘汰时调用
--- @return LRUCache
function M:__init(capacity, onEvict)
	self.capacity = self.capacity or 10
	self.size = 0
	self.head = nil  -- 链表头部（最新使用的元素）
	self.tail = nil  -- 链表尾部（最久未使用的元素）
	self.map = {}    -- 哈希表，key -> node
	self.onEvict = onEvict  -- 淘汰回调
end

--- 创建链表节点
--- @param key any 键
--- @param value any 值
--- @return LRUCacheNode
local function createNode(key, value)
	return {
		key = key,
		value = value,
		prev = nil,
		next = nil
	}
end

--- 将节点移动到链表头部（标记为最近使用）
--- @param node LRUCacheNode 要移动的节点
function M:moveToHead(node)
	if self.head == node then
		return
	end
	
	-- 从当前位置移除
	if node.prev then
		node.prev.next = node.next
	end
	if node.next then
		node.next.prev = node.prev
	end
	
	-- 如果是尾部节点，更新尾部
	if self.tail == node then
		self.tail = node.prev
	end
	
	-- 插入到头部
	node.prev = nil
	node.next = self.head
	if self.head then
		self.head.prev = node
	end
	self.head = node
	
	-- 如果链表为空，更新尾部
	if not self.tail then
		self.tail = node
	end
end

--- 获取缓存中的值
--- @param key any 键
--- @return any|nil 值，如果不存在则返回 nil
function M:get(key)
	local node = self.map[key]
	if not node then
		return nil
	end
	
	-- 将访问的节点移动到头部
	self:moveToHead(node)
	return node.value
end

--- 添加或更新缓存
--- @param key any 键
--- @param value any 值
--- @return any 存储的值
function M:put(key, value)
	local node = self.map[key]
	
	if node then
		-- 更新已存在的节点
		node.value = value
		self:moveToHead(node)
		return node.value
	else
		-- 创建新节点
		node = createNode(key, value)
		self.map[key] = node
		
		-- 插入到头部
		if self.head then
			node.next = self.head
			self.head.prev = node
		end
		self.head = node
		
		-- 如果链表为空，更新尾部
		if not self.tail then
			self.tail = node
		end
		
		self.size = self.size + 1
		
		-- 检查是否超过容量
		if self.size > self.capacity then
			self:evict()
		end
		
		return node.value
	end
end

--- 淘汰最久未使用的元素
--- @return any|nil 被淘汰的值
function M:evict()
	if not self.tail then
		return nil
	end
	
	local evictedNode = self.tail
	
	-- 从链表中移除
	if self.tail.prev then
		self.tail.prev.next = nil
	end
	self.tail = self.tail.prev
	
	-- 如果只有一个节点，更新头部
	if not self.tail then
		self.head = nil
	end
	
	-- 从哈希表中移除
	self.map[evictedNode.key] = nil
	self.size = self.size - 1
	
	-- 调用淘汰回调
	if self.onEvict then
		self.onEvict(evictedNode.key, evictedNode.value)
	end
	
	return evictedNode.value
end

--- 移除指定键的元素
--- @param key any 键
--- @return any|nil 被移除的值，如果不存在则返回 nil
function M:remove(key)
	local node = self.map[key]
	if not node then
		return nil
	end
	
	-- 从链表中移除
	if node.prev then
		node.prev.next = node.next
	end
	if node.next then
		node.next.prev = node.prev
	end
	
	-- 更新头部和尾部
	if self.head == node then
		self.head = node.next
	end
	if self.tail == node then
		self.tail = node.prev
	end
	
	-- 从哈希表中移除
	self.map[key] = nil
	self.size = self.size - 1
	
	return node.value
end

--- 清空缓存
function M:clear()
	self.head = nil
	self.tail = nil
	self.map = {}
	self.size = 0
end

--- 获取缓存大小
--- @return integer 当前缓存中的元素数量
function M:size()
	return self.size
end

--- 检查键是否存在
--- @param key any 键
--- @return boolean true 如果存在，false 否则
function M:contains(key)
	return self.map[key] ~= nil
end

--- 获取所有键（按使用顺序，从最新到最旧）
--- @return table 键的列表
function M:keys()
	local keys = {}
	local node = self.head
	while node do
		table.insert(keys, node.key)
		node = node.next
	end
	return keys
end

--- 获取所有值（按使用顺序，从最新到最旧）
--- @return table 值的列表
function M:values()
	local values = {}
	local node = self.head
	while node do
		table.insert(values, node.value)
		node = node.next
	end
	return values
end

--- 遍历缓存中的所有元素
--- @param callback function 回调函数 callback(key:any, value:any)
function M:forEach(callback)
	local node = self.head
	while node do
		callback(node.key, node.value)
		node = node.next
	end
end

--- 打印缓存状态（用于调试）
function M:debug()
	print("=== LRUCache Debug ===")
	print("Capacity:", self.capacity)
	print("Size:", self.size)
	print("Keys (newest to oldest):")
	local node = self.head
	local index = 1
	while node do
		print(string.format("  %d. %s", index, tostring(node.key)))
		node = node.next
		index = index + 1
	end
	print("======================")
end

return M