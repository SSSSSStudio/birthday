
local Name = {
	UGC_Main = {
		require("Script.UI.UGC_Main"),
		require("Script.UI.UGC_Main.UGC_MainController"),
		require("Script.UI.UGC_Main.UGC_MainModel")
	},
	UGC_Test = {
        require("Script.UI.UGC_Test"),
        require("Script.UI.UGC_Test.UGC_TestController"),
        require("Script.UI.UGC_Test.UGC_TestModel")
    }
}

return Name