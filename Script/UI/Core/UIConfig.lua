
-- UIConfig.lua
-- UI配置管理，管理所有UI的配置信息

local UILayerManager = require "UI.Core.Private.UILayerManager"

---@class UIConfig
local M = {
	-- 示例配置
	Main = {
		Name = "Main",
		Layer = UILayerManager.LayerType.State,
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/Main/WBP_Main.WBP_Main_C'",
		ViewClass = require("TestCase.UI.Main.WBP_Main"),
		ControllerClass = require("TestCase.UI.Main.MainUIController"),
		ModelClass = require("TestCase.UI.Main.MainUIModel")
	},
	PetMain = {
		Name = "PetMain",
		Layer = UILayerManager.LayerType.State,
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/Pet/WBP_PetMain.WBP_PetMain_C'",
		ViewClass = require("TestCase.UI.Pet.WBP_PetMain"),
		ControllerClass = require("TestCase.UI.Pet.PetMainController"),
		ModelClass = require("TestCase.UI.Pet.PetMainModel")
	}
}

---获取UI配置
---@param uiName string UI名称
---@return table|nil UI配置
function M:GetConfig(uiName)
	return self[uiName]
end

---注册UI配置
---@param uiName string UI名称
---@param config table UI配置
function M:RegisterConfig(uiName, config)
	config.Name = config.Name or uiName
	config.Layer = config.Layer or UILayerManager.LayerType.State
	self[uiName] = config
end

---批量注册UI配置
---@param configs table UI配置表
function M:RegisterConfigs(configs)
	for uiName, config in pairs(configs) do
		self:RegisterConfig(uiName, config)
	end
end

---获取所有UI配置
---@return table 所有UI配置
function M:GetAllConfigs()
	local configs = {}
	for k, v in pairs(self) do
		if type(v) == "table" and v.Name then
			configs[k] = v
		end
	end
	return configs
end

return M