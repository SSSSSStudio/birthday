-- UIConfig.lua
-- UI配置管理

local UILayerManager = require "UI.Core.Private.UILayerManager"

---@class UIConfig
local M = {
	-- Toast 配置
	Toast = {
		Name = "Toast",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/WBP_Toast.WBP_Toast_C'",
		ControllerClass = require("TestCase.UI.Toast.ToastController")
	},
	
	-- MessageBox 配置
	MessageBox = {
		Name = "MessageBox",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/WBP_MessageBox.WBP_MessageBox_C'",
		ViewClass = require("TestCase.UI.MessageBox.WBP_MessageBox"),
		ControllerClass = require("TestCase.UI.MessageBox.MessageBoxController")
	},
	
	-- Activity 配置（Dialog 层测试用）
	Activity = {
		Name = "Activity",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/WBP_Activity.WBP_Activity_C'",
		ViewClass = require("TestCase.UI.Activity.WBP_Activity"),
		ControllerClass = require("TestCase.UI.Activity.ActivityController"),
		ModelClass = require("TestCase.UI.Activity.ActivityModel")
	},
	
	-- Bag 配置（Dialog 层测试用）
	Bag = {
		Name = "Bag",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/WBP_Bag.WBP_Bag_C'",
		ViewClass = require("TestCase.UI.Bag.WBP_Bag"),
		ControllerClass = require("TestCase.UI.Bag.BagController"),
		ModelClass = require("TestCase.UI.Bag.BagModel")
	},
	
	-- GM 工具配置（Top 层）
	GM = {
		Name = "GM",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/WBP_GM.WBP_GM_C'",
		ViewClass = require("TestCase.UI.GM.WBP_GM"),
		ControllerClass = require("TestCase.UI.GM.GMController"),
		ModelClass = require("TestCase.UI.GM.GMModel")
	},
	
	-- Lock 锁定界面配置（Lock 层）
	Lock = {
		Name = "Lock",
		ViewPath = "/Script/UMGEditor.WidgetBlueprint'/Game/Test/UITest/WBP_Lock.WBP_Lock_C'",
		ControllerClass = require("TestCase.UI.Lock.LockController")
	},
	
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