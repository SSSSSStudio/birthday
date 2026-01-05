

---@class UIConfig
local M = {
	Main = {
		Name = "Main",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/UI/WBP_Main.WBP_Main_C'",
		require("TestCase.UI.Main.WBP_Main"),
		require("TestCase.UI.Main.MainUIController"),
		require("TestCase.UI.Main.MainUIModel")
	}
}

return M