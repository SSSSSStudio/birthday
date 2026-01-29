-- PetMainModel.lua
-- Pet Main UI 模型，MVC 结构中的 Model
-- 负责管理 Pet Main UI 的数据

local LuaHelper = require("Utility.LuaHelper")
local Log = require("Utility.Log")

---@class PetMainModel : ModelBase
local M = LuaHelper.LuaClass("Core.ModelBase")

--- 创建模型实例
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

--- 初始化模型
function M:Initialize()
    -- 设置默认数据
	self.petId = 0
	self.petName = "My Pet"
	self.level = 1
	self.hunger = 100
    self.happiness = 100
	self.maxHunger = 100
    self.maxHappiness = 100
	self.exp = 0
	self.maxExp = 100
	
	self.AttrData = {
		Level = 1,
		Exp = 0,
		HP = 100
	}
end

function M:GetAttrData()
	return self.AttrData
end

--- 更新模型（子类可以重写）
--- @param data table 新的数据 对应UIManager.StateOpen(uiName, params)中的Param
function M:UpdateModel(data)
    print("PetMainModel.UpdateModel:", data)
    
    -- 更新宠物数据
    if data.petId then
		self.petId = data.petId
    end
    if data.petName then
		self.petName = data.petName
    end
    if data.level then
		self.level = data.level
    end
    if data.hunger then
		self.hunger = data.hunger
    end
    if data.happiness then
		self.happiness = data.happiness
    end
end

--- 喂食事件处理
function M:OnPetFeed(data)
    print("PetMainModel.OnPetFeed:", data)
    self:Feed(data and data.amount or 10)
	
	self.AttrData.Exp = self.AttrData.Exp + 10
	self.AttrData.HP = self.AttrData.HP + 10
	self.AttrData.Level = self.AttrData.Level + 1
	self:TriggerEvent("UpdateAttr",self.AttrData.Level, self.AttrData.Exp, self.AttrData.HP)
end

--- 玩耍事件处理
function M:OnPetPlay(data)
    print("PetMainModel.OnPetPlay:", data)
    self:Play(data and data.amount or 10)
end

--- 宠物更新事件处理
function M:OnPetUpdate(data)
    print("PetMainModel.OnPetUpdate:", data)
    Log.PrintT(data)
    
    -- 更新宠物数据
    if data.hunger then
		self.hunger = data.hunger
    end
    if data.happiness then
		self.happiness = data.happiness
    end
    if data.level then
		self.level = data.level
    end
end

--- 喂食
--- @param amount number 喂食量
function M:Feed(amount)
    local currentHunger = self:Get("hunger", 0)
    local maxHunger = self:Get("maxHunger", 100)
    local newHunger = math.min(currentHunger + amount, maxHunger)

	self.hunger = newHunger
    
    -- 分发喂食事件
	self:TriggerEvent("Pet.Feeded",
		self:Get("petId", 0),
		amount,
		newHunger
	)
end

--- 玩耍
--- @param amount number 玩耍量
function M:Play(amount)
    local currentHappiness = self:Get("happiness", 0)
    local maxHappiness = self:Get("maxHappiness", 100)
    local newHappiness = math.min(currentHappiness + amount, maxHappiness)
    
	self.happiness = newHappiness

	self:TriggerEvent("Pet.Played", 
        self:Get("petId", 0),
        amount,
        newHappiness
	)
end

--- 获取饥饿度百分比
--- @return number 饥饿度百分比 (0-100)
function M:GetHungerPercent()
    local hunger = self:Get("hunger", 0)
    local maxHunger = self:Get("maxHunger", 100)
    if maxHunger == 0 then
        return 0
    end
    return (hunger / maxHunger) * 100
end

--- 获取快乐度百分比
--- @return number 快乐度百分比 (0-100)
function M:GetHappinessPercent()
    local happiness = self:Get("happiness", 0)
    local maxHappiness = self:Get("maxHappiness", 100)
    if maxHappiness == 0 then
        return 0
    end
    return (happiness / maxHappiness) * 100
end

--- 重置数据
function M:Reset()
	self.hunger = 100
	self.happiness = 100
	self.exp = 0
end

--- 销毁模型
function M:Destroy()
    self:Reset()
    self.Super:Destroy(self)
end

return M
