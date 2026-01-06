-- PetMainModel.lua
-- Pet Main UI 模型，MVC 结构中的 Model
-- 负责管理 Pet Main UI 的数据

local LuaHelper = require("Utility.LuaHelper")
local Log = require("Utility.Log")
local EventDispatcher = require("Core.EventDispatcher")

---@class PetMainModel : UIModelBase
local M = LuaHelper.LuaClass("UI.Core.UIModelBase")

--- 创建模型实例
function M:__OnNew()
    self.Super.__OnNew(self)
end

--- 初始化模型
function M:Initialize()
    -- 设置默认数据
    self:Set("petId", 0)
    self:Set("petName", "My Pet")
    self:Set("level", 1)
    self:Set("hunger", 100)
    self:Set("happiness", 100)
    self:Set("maxHunger", 100)
    self:Set("maxHappiness", 100)
    self:Set("exp", 0)
    self:Set("maxExp", 100)
    
    -- 监听宠物相关事件
    EventDispatcher.AddEvent("Pet.Feed", self.OnPetFeed, self)
    EventDispatcher.AddEvent("Pet.Play", self.OnPetPlay, self)
    EventDispatcher.AddEvent("Pet.Update", self.OnPetUpdate, self)
end

--- 更新模型（子类可以重写）
--- @param data table 新的数据 对应UIManager.StateOpen(uiName, params)中的Param
function M:UpdateModel(data)
    print("PetMainModel.UpdateModel:", data)
    
    -- 更新宠物数据
    if data.petId then
        self:Set("petId", data.petId)
    end
    if data.petName then
        self:Set("petName", data.petName)
    end
    if data.level then
        self:Set("level", data.level)
    end
    if data.hunger then
        self:Set("hunger", data.hunger)
    end
    if data.happiness then
        self:Set("happiness", data.happiness)
    end
end

--- 喂食事件处理
function M:OnPetFeed(data)
    print("PetMainModel.OnPetFeed:", data)
    self:Feed(data and data.amount or 10)
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
        self:Set("hunger", data.hunger)
    end
    if data.happiness then
        self:Set("happiness", data.happiness)
    end
    if data.level then
        self:Set("level", data.level)
    end
end

--- 喂食
--- @param amount number 喂食量
function M:Feed(amount)
    local currentHunger = self:Get("hunger", 0)
    local maxHunger = self:Get("maxHunger", 100)
    local newHunger = math.min(currentHunger + amount, maxHunger)
    
    self:Set("hunger", newHunger)
    
    -- 分发喂食事件
    EventDispatcher.Dispatch("Pet.Feeded", {
        petId = self:Get("petId", 0),
        amount = amount,
        currentHunger = newHunger
    })
end

--- 玩耍
--- @param amount number 玩耍量
function M:Play(amount)
    local currentHappiness = self:Get("happiness", 0)
    local maxHappiness = self:Get("maxHappiness", 100)
    local newHappiness = math.min(currentHappiness + amount, maxHappiness)
    
    self:Set("happiness", newHappiness)
    
    -- 分发玩耍事件
    EventDispatcher.Dispatch("Pet.Played", {
        petId = self:Get("petId", 0),
        amount = amount,
        currentHappiness = newHappiness
    })
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
    self:Set("hunger", 100)
    self:Set("happiness", 100)
    self:Set("exp", 0)
end

--- 销毁模型
function M:Destroy()
    -- 移除事件监听
    EventDispatcher.RemoveEvent("Pet.Feed", self.OnPetFeed)
    EventDispatcher.RemoveEvent("Pet.Play", self.OnPetPlay)
    EventDispatcher.RemoveEvent("Pet.Update", self.OnPetUpdate)
    
    self:Reset()
    self.Super:Destroy()
end

return M
