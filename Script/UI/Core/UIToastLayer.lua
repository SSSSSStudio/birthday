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

local MAX_SHOW_TOAST_COUNT<const> = 3
local DEFAULT_DURATION<const> = 2.0
local DEFAULT_TOAST_HEIGHT<const> = 20

local function GenerateNameId(self,name)
	while true do
		self.generateId = self.generateId + 1
		local nameId =  name .. "_" .. self.generateId
		if not self.nameAndController[nameId] then
			return 	nameId
		end
	end
end

local function UpdateToastPositions(self)
	local currentY = 0
	for _, controller in ipairs(self.showQueue) do
		local height = controller:UpdateToastPosition(currentY)
		currentY = currentY + (height > 0 and height or DEFAULT_TOAST_HEIGHT)
	end
end

local function ShowToast(self,name,model,content,duration)
	local config = UIConfigSystem.Get(name)
	if not config then
		Log.Error("UIConfigSystem", "UIConfig not found: " .. name)
		return
	end

	local viewClass = UE.UClass.Load(config.viewPath)
	if not viewClass then
		Log.Error("Failed to load View class for: " .. name)
		return
	end

	local nameId = GenerateNameId(self,name)

	local view = UE.UWidgetBlueprintLibrary.Create(UEHelper.GetWorld(),viewClass)
	UILayerSystem.AddToLayer(view, "Toast")
	local controller = config.controllerClass:New(nameId,view,model,content,duration)
	self.nameAndController[nameId] = controller
	self.showQueue[#self.showQueue + 1] = controller
	UpdateToastPositions(self)
end


---@class UIToastLayer
local M = Interface("UIToastLayer")

function M:__init()
	self.nameAndController = {}
	self.delayQueue = {}
	self.showQueue = {}
	self.generateId = 0
	self.maxShowCount = MAX_SHOW_TOAST_COUNT
end

function M:__gc()
	self:CloseAll()
end

---@param name string
---@param model ModelBase
---@param content string
---@param duration integer
---@return ToastController
function M:Open(name, model, content, duration)
	duration = duration or DEFAULT_DURATION
	
	if #self.showQueue >= self.maxShowCount then
		self.delayQueue[#self.delayQueue + 1] = {
			name = name,
			model = model,
			content = content,
            duration = duration ,
        }
		return
    end
	
	ShowToast(self,name,model,content,duration)
end

---@param name string
---@param bSilent boolean|nil
---@return boolean
function M:Close(name,bSilent)
	local controller = self.nameAndController[name]
	if not controller then
        return false
    end
	TableEx.ArrayRemoveItem(self.showQueue,controller)
	self.nameAndController[name] = nil
	controller:Destroy()

	if #self.delayQueue > 0 then
		local toastInfo = self.delayQueue[1]
		table.remove(self.delayQueue, 1)
		ShowToast(self,toastInfo.name,toastInfo.model,toastInfo.content,toastInfo.duration)
	elseif not bSilent then
		UpdateToastPositions(self)
	end

	if #self.showQueue == 0 then
		self.generateId = 0
	end
	
	return true
end

---@param count integer
function M:SetMaxShowCount(count)
    self.maxShowCount = count
end

function M:CloseAll()
    for _, controller in pairs(self.nameAndController) do
        controller:Destroy()
    end
	self.nameAndController = {}
	self.delayQueue = {}
	self.showQueue = {}
	self.generateId = 0
end

return M