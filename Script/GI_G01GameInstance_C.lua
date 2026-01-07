require("Config.Debugger")
local LuaHelper = require("Utility.LuaHelper")
local EventLoop = require("Core.EventLoop")
local UIManager = require("UI.Core.UIManager")

---@type GI_G01GameInstance_C
local M = UnLua.Class()

function M:ReceiveInit()
	LuaHelper.DisableGlobalVariable()
	EventLoop.Startup()
end

function M:ReceiveShutdown()
	EventLoop.Shutdown()
end

function M:RunTest()
	-- 等待引擎完全初始化后再执行测试
	EventLoop.Timeout(500, function()
		local success, err = pcall(function()
			UIManager.Initialize(self)

			-- 设置鼠标显示和输入模式
			local world = self:GetWorld()
			if world then
				local playerController = UE.UGameplayStatics.GetPlayerController(world, 0)
				if playerController then
					playerController.bShowMouseCursor = true
					UE.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(playerController, nil, UE.EMouseLockMode.DoNotLock)
				end
			end
			
			-- 运行UI测试
			local UIManagerTest = require("TestCase.UI.UIManagerTest")
			UIManagerTest.TestMultiLayer()
		end)
		
		if not success then
			print("[Error] RunTest failed:", err)
		end
	end)
end

return M