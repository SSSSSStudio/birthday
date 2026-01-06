

---@class UIConfig
local M = {
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