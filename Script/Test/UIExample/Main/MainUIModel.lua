-- MainUIModel.lua
-- Main UI 模型，MVC 结构中的 Model
-- 负责管理 Main UI 的数据

local LuaHelper = require("Utility.LuaHelper")
local Log = require("Utility.Log")
local ActivityModel = require("Test.UIExample.Activity.ActivityModel")
local PetMainModel = require("Test.UIExample.Pet.PetMainModel")
local GMModel = require("Test.UIExample.GM.GMModel")
local BagModel = require("Test.UIExample.Bag.BagModel")

---@class MainUIModel : ModelBase
local M = LuaHelper.LuaClass("Core.ModelBase")

--- 创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
	
	self.AttrData = {
        Level = 1,
        Exp = 0,
        HP = 100
    }
	self:Initialize()
	self.Activity = ActivityModel:New()
	self.petMain = PetMainModel:New()
	self.gmModel = GMModel:New()
	self.bagModel = BagModel:New()
end

function M:__OnGC()
	self:Reset()
	self.Super:__OnGC(self)
end

function M:Initialize()
	self.title = "Main UI"

	self.count = 0
	self.title = "Main UI"
	self.isVisible = true
	self.userName = "Player"
	self.level = 1
	self.exp = 0
	self.maxExp = 100
end

function M:EventTest(data)
    print("MainUIModel.EventTest:")
	Log.PrintT(data)
	self.TestData = data
end

function M:Get(key,default)
	if not self[key] then
		return default
	end
	return self[key]
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
			self.level = level + 1
			self.exp = newExp - maxExp
			self.maxExp = maxExp * 1.2
        else
			self.exp = maxExp
        end
    else
		self.exp = newExp
    end
	
	self.AttrData.Level = self:Get("level");
	self.AttrData.Exp = self:Get("exp");
	self.AttrData.HP = 100+self:Get("level")*30
	self:TriggerEvent("UpdateAttr",self.AttrData.Level, self.AttrData.Exp, self.AttrData.HP)
end

function M:GetAttrData()
    return self.AttrData
end

function M:GetPetMainData()
    return self.petMain
end

function M:GetActivity()
	return self.Activity
end

function M:GetGMModel()
    return self.gmModel
end

function M:GetBagModel()
	return self.bagModel
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
	self.count = 0
	self.level = 1
	self.exp = 0
	self.maxExp = 100
end


return M