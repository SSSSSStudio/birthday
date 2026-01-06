-- UIModelBase.lua
-- UI 模型基类，MVC 结构中的 Model
-- 负责数据的管理、验证和持久化

local LuaHelper = require("Utility.LuaHelper")
local Log = require("Utility.Log")

---@class UIModelBase
local M = LuaHelper.LuaClass()

--- 创建模型实例
function M:__OnNew()
    self.data = {}           -- 数据存储
    self.controller = nil    -- Controller 引用
    self.view = nil          -- View 引用
end

--- 设置 Controller 引用
--- @param controller UIControllerBase Controller 实例
function M:SetController(controller)
    self.controller = controller
    -- 同时获取 View 引用
    if controller and controller.GetView then
        self.view = controller:GetView()
    end
end

--- 初始化模型（子类可以重写）
function M:Initialize()
    -- 子类可以重写此方法来初始化默认数据
end

--- 更新模型（子类可以重写）
--- @param data table 新的数据 对应UIManager.StateOpen(uiName, params)中的Param
function M:UpdateModel(data)
    -- 子类可以重写此方法来更新数据
end

--- 设置数据
--- @param key string 数据键
--- @param value any 数据值
function M:Set(key, value)
    self.data[key] = value
end

--- 获取数据
--- @param key string 数据键
--- @param default any|nil 默认值（可选）
--- @return any 数据值
function M:Get(key, default)
    local value = self.data[key]
    if value == nil then
        return default
    end
    return value
end

--- 批量设置数据
--- @param data table 数据表
function M:SetData(data)
    if not data then
        return
    end
    
    for key, value in pairs(data) do
        self:Set(key, value)
    end
end

--- 获取所有数据
--- @return table 所有数据的副本
function M:GetAll()
    local result = {}
    for key, value in pairs(self.data) do
        result[key] = value
    end
    return result
end

--- 清空数据
function M:Clear()
    self.data = {}
end

--- 检查数据是否存在
--- @param key string 数据键
--- @return boolean true 如果存在，false 否则
function M:Has(key)
    return self.data[key] ~= nil
end

--- 删除数据
--- @param key string 数据键
function M:Remove(key)
    self.data[key] = nil
end

--- 销毁模型（子类可以重写）
function M:Destroy()
    -- 清理数据
    self.data = {}
    
    -- 清理引用
    self.controller = nil
    self.view = nil
end

--- 获取 View 实例
--- @return UUserWidget|nil View 实例
function M:GetView()
    return self.view
end

--- 打印所有数据（用于调试）
function M:Debug()
	print("=== UIModelBase Debug ===")
	print("Model:", self)
	print("Data:")
	Log.PrintT(self.data)
	print("========================")
end

return M
