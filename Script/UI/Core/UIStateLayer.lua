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
local UIConfigSystem = require("UI.Core.UIConfigSystem")

---@class UIStateLayer
local M = Interface("UIStateLayer")

function M:__init()
	self.currentController = nil  -- 当前显示的 UI 控制器
	self.recordStack = {}
	self.nameAndController = {}
end

function M:__gc()
	self:CloseAll()
end

--- @param name string
--- @param model ModelBase
--- @param bCacheCurrent boolean|nil
--- @return UIControllerBase
function M:Open(name, model, bCacheCurrent)
	if bCacheCurrent == nil then
		bCacheCurrent = true
	end
	
	local controller = self.nameAndController[name]
	if controller and controller == self.currentController then
		controller:OnInitModel(model)
		return controller
	end
	
	if self.currentController then
		if bCacheCurrent then
			TableEx.StackPush(self.recordStack, self.currentController)
			self.currentController:Hide()
			self.currentController = nil
		else
			self.nameAndController[self.currentController:GetName()] = nil
			self.currentController:Destroy()
			self.currentController = nil
		end
    end
	
	if controller then
		TableEx.StackMoveToTop(self.recordStack, controller)
		controller:OnInitModel(model)
		controller:Show()
		self.currentController = controller
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

	local view = UE.UWidgetBlueprintLibrary.Create(UEHelper.GetWorld(),viewClass)
	UILayerSystem.AddToLayer(view, "State")
	controller = config.controllerClass:New(name,view,model)
	self.nameAndController[name] = controller
	self.currentController = controller
    return controller
end

---@return UIControllerBase|nil 控制器实例，如果没有历史记录则返回 nil
function M:CloseAndReopen()
	if not self.currentController then
		return nil
	end

	self.nameAndController[self.currentController:GetName()] = nil
	self.currentController:Destroy()
	self.currentController = nil
	
	local controller =  TableEx.StackPop(self.recordStack)
	if not controller then
		return nil
	end
	controller:Show()
	self.currentController = controller
	return controller
end

---@return UIControllerBase|nil 控制器实例
function M:GetOpenController()
    return self.currentController
end

function M:CloseAll()
	if self.currentController then
		self.currentController:Destroy()
		self.currentController = nil
	end
	
	for _, controller in ipairs(self.recordStack) do
        controller:Destroy()
    end
		
    self.recordStack = {}
    self.nameAndController = {}
end

return M