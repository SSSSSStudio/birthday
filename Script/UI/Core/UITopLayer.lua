local Interface = require("Utility.Interface")
---@type UEHelper
local UEHelper = require("Core.UEHelper")
---@type TableEx
local TableEx = require("Utility.TableEx")
---@type Log
local Log = require("Utility.Log")
---@type UILayerSystem
local UILayerSystem = require "UI.Core.UILayerSystem"
---@type UIConfigSystem
local UIConfigSystem = require("UI.UIConfigSystem")

local function UpdateOrder(self)
	if #self.controllerStack > 0 then
		for index, controller in pairs(self.controllerStack) do
			controller.view.Slot:SetZOrder(index)
		end
	end
end

---@class UITopLayer
local M = Interface("UITopLayer")

function M:__init()
	self.nameAndController = {}
	self.controllerStack = {}
end

function M:__gc()
	self:CloseAll()
end

---@param name string
---@param model ModelBase
---@return UIControllerBase
function M:Open(name, model)
	local controller = self.nameAndController[name]
	if controller then
		controller:OnInitModel(model)
		if controller ~= self:GetTopController() then
			TableEx.StackMoveToTop(self.controllerStack, controller)
			UpdateOrder(self)
		end
		return controller
	end

	local config = UIConfigSystem.Get(name)
	if not config then
		Log.Error("UIConfigSystem", "UIConfig not found: " .. name)
		return nil
	end

	local viewClass = UE.UClass.Load(config.viewPath)
	if not viewClass then
		Log.Error("Failed to load View class for: " .. name)
		return nil
	end

	local view = UE.NewObject(viewClass,UEHelper.GetGameInstance())
	UILayerSystem.AddToLayer(view, "Top")
	controller = config.controllerClass:New(name,view,model)
	self.nameAndController[name] = controller
	TableEx.StackPush(self.controllerStack,controller)
	return controller
end

---@param name string
---@return boolean
function M:Close(name)
	local controller = self.nameAndController[name]
	if not controller then
		return false
	end
	self.nameAndController[name] = nil
	TableEx.StackRemoveItem(self.controllerStack, controller)
	controller:Destroy()
	UpdateOrder(self)
	return true
end


function M:CloseTop()
	local controller = TableEx.StackPop(self.controllerStack)
	if not controller then
		return false
	end

	self.nameAndController[controller:GetName()] = nil
	controller:Destroy()
	controller = nil
	UpdateOrder(self)
	return true
end

function M:CloseAll()
	for _, controller in pairs(self.controllerStack) do
		controller:Destroy()
	end
	self.controllerStack = {}
	self.nameAndController = {}
end

---@param name string
---@return UIControllerBase|nil
function M:GetController(name)
	return self.nameAndController[name]
end

---@return UIControllerBase|nil
function M:GetTopController()
	return TableEx.StackPeek(self.controllerStack)
end

return M