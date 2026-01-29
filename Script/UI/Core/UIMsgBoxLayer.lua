local Interface = require("Utility.Interface")
---@type UEHelper
local UEHelper = require("Core.UEHelper")
---@type Log
local Log = require("Utility.Log")
---@type UILayerSystem
local UILayerSystem = require "UI.Core.UILayerSystem"
---@type UIConfigSystem
local UIConfigSystem = require("UI.UIConfigSystem")

local ALERT_STYLE<const> = 1
local CONFIRM_STYLE<const> = 2

local function GenerateNameId(self,name)
	while true do
		self.generateId = self.generateId + 1
		local nameId =  name .. "_" .. self.generateId
        if not self.nameAndController[nameId] then
            return 	nameId
        end
    end
end

---@class UIMsgBoxLayer
local M = Interface("UIMsgBoxLayer")

function M:__init()
	self.nameAndController = {}
	self.generateId = 0
	self.count = 0
end

function M:__gc()
	self:CloseAll()
end

---@param name string
---@param model string
---@param title string
---@param content string
---@param type number
---@return UIMsgBoxController
function M:Open(name, model, title, content, bConfirm)
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

	local nameId = GenerateNameId(self,name)
	
	local view = UE.NewObject(viewClass,UEHelper.GetGameInstance())
	UILayerSystem.AddToLayer(view, "MsgBox")
	local controller = config.controllerClass:New(nameId,view,model,title,content,bConfirm and CONFIRM_STYLE or ALERT_STYLE)
	self.nameAndController[nameId] = controller
	self.count = self.count + 1
	return controller
end

---@param name string
---@param model string
---@param title string
---@param content string
---@return UIMsgBoxController
function M:OpenAlert(name, model, title, content)
	return self:Open(name, model, title, content, ALERT_STYLE)
end

---@param name string
---@param model string
---@param title string
---@param content string
---@return UIMsgBoxController
function M:OpenConfirm(name, model, title, content)
	return self:Open(name, model, title, content, CONFIRM_STYLE)
end

---@param name string
function M:Close(name)
    local controller = self.nameAndController[name]
    if not controller then
		return false
	end	
	controller:Destroy()
	self.nameAndController[name] = nil
	self.count = self.count - 1
	if self.count == 0 then
		self.generateId = 0
	end
	return true
end

function M:CloseAll()
    for _, controller in pairs(self.nameAndController) do
        controller:Destroy()
    end
    self.nameAndController = {}
	self.generateId = 0
	self.count = 0
end

return M
