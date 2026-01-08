-- UIManager.lua
-- UI 管理器，负责管理整个 UI 系统

local UILayerManager = require "UI.Core.Private.UILayerManager"
local UIStateManager = require "UI.Core.Private.UIStateManager"
local UIDialogManager = require "UI.Core.Private.UIDialogManager"
local UILockManager = require "UI.Core.Private.UILockManager"
local UIMsgBoxManager = require "UI.Core.Private.UIMsgBoxManager"
local UIToastManager = require "UI.Core.Private.UIToastManager"
local UITopManager = require "UI.Core.Private.UITopManager"

---@class UIManager
local M = {
	isInitialized = false,
	gameInstance = nil,
}

---初始化UI管理器
---@param gameInst any 游戏实例
function M.Initialize(gameInst)
	if M.isInitialized then return end
	
	M.gameInstance = gameInst
	UILayerManager:Initialize(gameInst)
	M.isInitialized = true
end

-- ========== State 层 UI（主界面、宠物界面等） ==========

---打开 State UI
---@param uiName string UI 名称
---@param params table|nil 参数（可选）
---@param isCacheCurrent boolean|nil 是否缓存当前UI（默认 true）
---@return UIControllerBase|nil
function M.State_Open(uiName, params, isCacheCurrent)
	if not uiName or type(uiName) ~= "string" then
		print("[UIManager] Error: Invalid uiName for State_Open")
		return nil
	end
    return UIStateManager:OpenUI(uiName, params, isCacheCurrent)
end

---关闭当前 State UI
function M.State_Close()
    return UIStateManager:CloseCurrentUIAndReopen()
end

-- ========== Dialog 层 UI（对话框） ==========

---打开 Dialog
---@param uiName string UI名称
---@param params table|nil 传递给UI的参数（可选）
---@return UIControllerBase|nil 控制器实例
function M.Dialog_Open(uiName, params)
	if not uiName or type(uiName) ~= "string" then
		print("[UIManager] Error: Invalid uiName for Dialog_Open")
		return nil
	end
    return UIDialogManager:Show(uiName, params)
end

---关闭指定 Dialog
---@param uiName string UI名称
function M.Dialog_Close(uiName)
	if not uiName or type(uiName) ~= "string" then
		print("[UIManager] Error: Invalid uiName for Dialog_Close")
		return
	end
    return UIDialogManager:Close(uiName)
end

---关闭顶层 Dialog
function M.Dialog_CloseTop()
	UIDialogManager:CloseTop()
end

---关闭所有 Dialog
function M.Dialog_CloseAll()
	UIDialogManager:CloseAll()
end

-- ========== Toast 层 UI（消息提示） ==========

---显示消息提示
---@param message string 消息内容
---@param duration number|nil 持续时间（秒），默认2秒
function M.Toast_Open(message, duration)
	if not message or type(message) ~= "string" then
		print("[UIManager] Error: Invalid message for Toast_Open")
		return
	end
	UIToastManager:Show("Toast", {message = message}, duration)
end

---清空Toast队列
function M.Toast_Clear()
	UIToastManager:ClearQueue()
end

-- ========== MessageBox 层 UI（消息框） ==========

---显示确认消息框
---@param title string 标题
---@param content string 内容
---@param confirmCallback function|nil 确认回调
---@param cancelCallback function|nil 取消回调
function M.MsgBox_OpenConfirm(title, content, confirmCallback, cancelCallback)
	return UIMsgBoxManager:ShowConfirm("MessageBox", title, content, confirmCallback, cancelCallback)
end

---显示提示消息框
---@param title string 标题
---@param content string 内容
---@param callback function|nil 确认回调
function M.MsgBox_OpenAlert(title, content, callback)
	return UIMsgBoxManager:ShowAlert("MessageBox", title, content, callback)
end

---显示自定义消息框
---@param title string 标题
---@param content string 内容
---@param confirmText string 确认按钮文本
---@param cancelText string 取消按钮文本
---@param confirmCallback function|nil 确认回调
---@param cancelCallback function|nil 取消回调
function M.MsgBox_OpenCustom(title, content, confirmText, cancelText, confirmCallback, cancelCallback)
	UIMsgBoxManager:ShowCustom("MessageBox", title, content, confirmText, cancelText, confirmCallback, cancelCallback)
end

-- ========== Lock 层 UI（锁定界面） ==========

---显示锁定界面（手动关闭）
---@param message string|nil 提示信息
function M.Lock_Open(message)
	UILockManager:Show(message)
end

---显示锁定界面（超时自动关闭）
---@param message string|nil 提示信息
---@param timeout number|nil 超时时间（秒），nil=默认30秒，0=不超时
function M.Lock_OpenWithTimeout(message, timeout)
	UILockManager:ShowWithTimeout(message, timeout)
end

---关闭锁定界面
function M.Lock_Close()
	UILockManager:Hide()
end

---检查是否已锁定
---@return boolean 是否锁定
function M.Lock_IsLocked()
	return UILockManager:IsShowing()
end

-- ========== Top 层 UI（顶层UI） ==========

---显示顶层 UI
---@param uiName string UI名称
---@param params table|nil 传递给UI的参数（可选）
---@return UIControllerBase|nil 控制器实例
function M.Top_Open(uiName, params)
	if not uiName or type(uiName) ~= "string" then
		print("[UIManager] Error: Invalid uiName for Top_Open")
		return nil
	end
	return UITopManager:Show(uiName, params)
end

---关闭指定顶层 UI
---@param uiName string UI名称
function M.Top_Close(uiName)
	if not uiName or type(uiName) ~= "string" then
		print("[UIManager] Error: Invalid uiName for Top_Close")
		return
	end
	return UITopManager:Close(uiName)
end

---关闭最顶层的 Top UI
function M.Top_CloseTop()
	UITopManager:CloseTop()
end

---关闭所有 Top UI
function M.Top_CloseAll()
	UITopManager:CloseAll()
end

---检查指定 Top UI 是否正在显示
---@param uiName string UI名称
---@return boolean
function M.Top_IsShowing(uiName)
	return UITopManager:IsShowing(uiName)
end

---获取GameInstance
------@return GI_G01GameInstance_C
function M.GetGameInstance()
    return M.gameInstance
end

---销毁UI管理器
function M.Destroy()
	UILayerManager:Destroy()
	UIStateManager:Destroy()
	UIDialogManager:Destroy()
	UIToastManager:Destroy()
	UIMsgBoxManager:Destroy()
	UILockManager:Destroy()
	UITopManager:Destroy()
	M.isInitialized = false
	M.gameInstance = nil
end

return M