-- MainUIModel.lua
-- Main UI 模型，MVC 结构中的 Model
-- 负责管理 Main UI 的数据

local LuaHelper = require("Utility.LuaHelper")
local Log = require("Utility.Log")
local EventDispatcher = require("Core.EventDispatcher")

---@class MainUIModel : UIModelBase
local M = LuaHelper.LuaClass("UI.Core.UIModelBase")

--- 创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
	
	self.AttrData = {
        Level = 1,
        Exp = 0,
        HP = 100
    }
end

--- 初始化模型
function M:Initialize()
    -- 设置默认数据
    self:Set("title", "Main UI")
    self:Set("count", 0)
    self:Set("isVisible", true)
    self:Set("userName", "Player")
    self:Set("level", 1)
    self:Set("exp", 0)
    self:Set("maxExp", 100)

	EventDispatcher.AddEvent("Main.EventTest",  self.EventTest,self)
	EventDispatcher.AddEvent("Character.AddExp",  self.AddExp,self)
	
	--网络监听 更新数据
end

function M:EventTest(data)
    print("MainUIModel.EventTest:")
	Log.PrintT(data)
	self:Set("TestData", data)
end

--- 增加经验值
--- @param amount number 增加的经验值
function M:AddExp(amount)
    local currentExp = self:Get("exp", 0)
    local maxExp = self:Get("maxExp", 100)
    local newExp = currentExp + amount
    
    -- 检查是否升级
    if newExp >= maxExp then
        local level = self:Get("level", 1)
        if level < 100 then
            self:Set("level", level + 1)
            self:Set("exp", newExp - maxExp)
            self:Set("maxExp", maxExp * 1.2) -- 升级后最大经验值增加 20%
        else
            self:Set("exp", maxExp) -- 已达最高等级
        end
    else
        self:Set("exp", newExp)
    end
	
	self.AttrData.Level = self:Get("level");
	self.AttrData.Exp = self:Get("exp");
	self.AttrData.HP = 100+self:Get("level")*30
end

function M:GetAttrData()
    return self.AttrData
end

--- 获取经验百分比
--- @return number 经验百分比 (0-100)
function M:GetExpPercent()
    local exp = self:Get("exp", 0)
    local maxExp = self:Get("maxExp", 100)
    if maxExp == 0 then
        return 0
    end
    return (exp / maxExp) * 100
end

--- 重置数据
function M:Reset()
    self:Set("count", 0)
    self:Set("level", 1)
    self:Set("exp", 0)
    self:Set("maxExp", 100)
end

--- 销毁模型
function M:Destroy()
	EventDispatcher.RemoveEvent("Main.EventTest",self.EventTest)
	EventDispatcher.RemoveEvent("Character.AddExp",self.AddExp)
    self:Reset()
    self.Super:Destroy()
end

return M