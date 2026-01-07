-- UIManagerTest.lua
-- UIManager 接口测试用例

local UIManager = require("UI.Core.UIManager")
local Log = require("Utility.Log")

local M = {}

-- ========== State 层测试 ==========

--- 测试 State_Open 和 State_Close
function M.TestState()
	UIManager.State_Open("Main")
end

--- 测试 State 界面切换
function M.TestStateSwitch()
	UIManager.State_Open("PetMain")
end

--- 测试 State_Close
function M.TestStateClose()
    UIManager.State_Close()
end
-- ========== Dialog 层测试 ==========

--- 测试 Dialog_Open 和 Dialog_Close
function M.TestDialog()
	UIManager.Dialog_Open("Activity")
end

--- 测试多个 Dialog 堆叠
function M.TestDialogStack()
	UIManager.Dialog_Open("Activity")
	UIManager.Dialog_Open("Bag")
end

--- 测试关闭所有 Dialog
function M.TestDialogCloseAll()
	UIManager.Dialog_CloseAll()
end

-- ========== Toast 层测试 ==========

--- 测试 Toast_Open
function M.TestToast()
	UIManager.Toast_Open("这是一条提示消息", 2.0)
end

--- 测试多个 Toast
function M.TestToastMultiple()
	UIManager.Toast_Open("消息1", 1.0)
	UIManager.Toast_Open("消息2", 1.0)
	UIManager.Toast_Open("消息3", 2.0)
	UIManager.Toast_Open("消息4", 2.0)
	UIManager.Toast_Open("消息5", 3.0)
end

--- 测试 Toast_Clear
function M.TestToastClear()
	UIManager.Toast_Open("消息1", 1.0)
	UIManager.Toast_Open("消息2", 1.0)
	UIManager.Toast_Open("消息3", 2.0)
	UIManager.Toast_Open("消息4", 2.0)
	UIManager.Toast_Open("消息5", 3.0)
	-- 前3个会显示，后2个会进入队列
	-- 调用 Toast_Clear 清空队列，后2个不会再显示
	UIManager.Toast_Clear()
end

-- ========== MessageBox 层测试 ==========

--- 测试 MsgBox_OpenConfirm（确认框）
function M.TestMsgBoxConfirm()
	UIManager.MsgBox_OpenConfirm(
		"删除确认",
		"你确定要删除这个文件吗？",
		function()
			UIManager.Toast_Open("已确认删除", 1.5)
		end,
		function()
			UIManager.Toast_Open("已取消删除", 1.5)
		end
	)
end

--- 测试 MsgBox_OpenAlert（提示框）
function M.TestMsgBoxAlert()
	UIManager.MsgBox_OpenAlert(
		"提示",
		"操作成功！",
		function()
			UIManager.Toast_Open("已确认", 1.5)
		end
	)
end

--- 测试 MsgBox_OpenCustom（自定义按钮文本）
function M.TestMsgBoxCustom()
	UIManager.MsgBox_OpenCustom(
		"自定义消息框",
		"是否继续操作？",
		"继续",
		"放弃",
		function()
			UIManager.Toast_Open("选择了继续", 1.5)
		end,
		function()
			UIManager.Toast_Open("选择了放弃", 1.5)
		end
	)
end

--- 测试多个 MessageBox 堆叠
function M.TestMsgBoxStack()
	UIManager.MsgBox_OpenAlert("消息1", "第一个消息框")
	UIManager.MsgBox_OpenAlert("消息2", "第二个消息框")
	UIManager.MsgBox_OpenAlert("消息3", "第三个消息框")
end

-- ========== Lock 层测试 ==========

--- 测试 Lock_Open 和 Lock_Close
function M.TestLock()
	UIManager.Lock_Open("加载中...")
end

--- 测试 Lock_IsLocked
function M.TestLockStatus()
	print("锁定状态:", UIManager.Lock_IsLocked())
	UIManager.Lock_Open("处理中...")
	print("锁定状态:", UIManager.Lock_IsLocked())
end

--- 测试 Lock_OpenWithTimeout（超时自动关闭）
function M.TestLockTimeout()
	UIManager.Lock_OpenWithTimeout("加载中，5秒后自动关闭...", 5)
end

-- ========== Top 层测试 ==========

--- 测试 Top_Open 和 Top_Close
function M.TestTop()
	UIManager.Top_Open("GM")
end

--- 测试 Top_Close
function M.TestTopClose()
	UIManager.Top_Open("GM")
	UIManager.Top_Close("GM")
end

--- 测试 Top_CloseTop
function M.TestTopCloseTop()
	UIManager.Top_Open("GM")
	UIManager.Top_CloseTop()
end

--- 测试 Top_CloseAll
function M.TestTopCloseAll()
	UIManager.Top_Open("GM")
	UIManager.Top_CloseAll()
end

--- 测试 Top_IsShowing
function M.TestTopIsShowing()
	print("GM 是否显示:", UIManager.Top_IsShowing("GM"))
	UIManager.Top_Open("GM")
	print("GM 是否显示:", UIManager.Top_IsShowing("GM"))
	UIManager.Top_Close("GM")
	print("GM 是否显示:", UIManager.Top_IsShowing("GM"))
end

-- ========== 综合测试 ==========

--- 测试多层级 UI 同时显示（六层全开）
function M.TestMultiLayer()
	print("========== 开始六层级测试 ==========")
	
	-- 1. State 层 - 主界面
	print("1. 打开 State 层 - Main")
	UIManager.State_Open("Main")
	
	-- 2. Dialog 层 - 对话框
	print("2. 打开 Dialog 层 - Activity")
	UIManager.Dialog_Open("Activity", {title = "活动"})
	
	-- 3. Toast 层 - 提示
	print("3. 打开 Toast 层")
	UIManager.Toast_Open("六层级测试：所有层级都已打开", 3.0)
	
	-- 4. MsgBox 层 - 消息框
	print("4. 打开 MsgBox 层")
	UIManager.MsgBox_OpenAlert("提示", "这是一个六层级测试\n所有UI层都已显示")
	
	-- 5. Lock 层 - 锁定界面
	print("5. 打开 Lock 层")
	UIManager.Lock_OpenWithTimeout("加载中，5秒后自动关闭...", 5)
	
	-- 6. Top 层 - GM工具
	print("6. 打开 Top 层 - GM")
	UIManager.Top_Open("GM")
	
	print("========== 六层级测试完成 ==========")
	print("State(Main) + Dialog(Activity) + Toast + MsgBox + Lock + Top(GM)")
end

--- 测试回调嵌套
function M.TestCallbackNesting()
	UIManager.MsgBox_OpenConfirm(
		"第一步",
		"是否继续到第二步？",
		function()
			UIManager.Toast_Open("进入第二步", 1.0)
			UIManager.MsgBox_OpenConfirm(
				"第二步",
				"是否继续到第三步？",
				function()
					UIManager.Toast_Open("进入第三步", 1.0)
					UIManager.MsgBox_OpenAlert(
						"完成",
						"所有步骤已完成！",
						function()
							UIManager.Toast_Open("测试结束", 2.0)
						end
					)
				end,
				function()
					UIManager.Toast_Open("在第二步取消", 1.5)
				end
			)
		end,
		function()
			UIManager.Toast_Open("在第一步取消", 1.5)
		end
	)
end
return M
