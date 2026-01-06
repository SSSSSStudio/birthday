
-- UIConfig.lua
-- UI配置管理，管理所有UI的配置信息

local UILayerManager = require "UI.Core.Private.UILayerManager"

---@class UIConfig
local M = {
	-- 示例配置
	Main = {
		Name = "Main",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/Main/WBP_Main.WBP_Main_C'",
		ViewClass = require("TestCase.UI.Main.WBP_Main"),
		ControllerClass = require("TestCase.UI.Main.MainUIController"),
		ModelClass = require("TestCase.UI.Main.MainUIModel")
	},
	PetMain = {
		Name = "PetMain",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/Pet/WBP_PetMain.WBP_PetMain_C'",
		ViewClass = require("TestCase.UI.Pet.WBP_PetMain"),
		ControllerClass = require("TestCase.UI.Pet.PetMainController"),
		ModelClass = require("TestCase.UI.Pet.PetMainModel")
	}
}

return M