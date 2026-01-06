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

-- ========== 主界面，宠物界面等 统一接口 ==========

--- 打开状态 UI（State 层级的 UI）
--- @param uiName string UI 名称
--- @param params table|nil 传递给 UI 的参数（可选）
--- @param isCacheCurrent boolean|nil 是否使用 LRU 缓存（默认为 true）
--- @return UIControllerBase|nil 控制器实例
function M.StateOpen(uiName, params, isCacheCurrent)
    return UIStateManager:OpenUI(uiName, params, isCacheCurrent)
end

--- 关闭状态 UI（State 层级的 UI）
function M.StateClose()
    return UIStateManager:CloseCurrentUIAndReopen()
end

-- ========== 对话框UI ==========

---打开对话框UI
---@param uiName string UI名称
---@param params table|nil 传递给UI的参数（可选）
---@return UIControllerBase|nil 控制器实例
function M.DialogOpen(uiName, params)
    return UIDialogManager:OpenDialog(uiName, params)
end

---关闭对话框UI
---@param uiName string UI名称
function M.DialogClose(uiName)
    return UIDialogManager:CloseDialog(uiName)
end

---关闭顶层Dialog
function M.CloseTopDialog()
	UIDialogManager:CloseTopDialog()
end

---关闭所有Dialog
function M.CloseAllDialogs()
	UIDialogManager:CloseAllDialogs()
end

-- ========== Toast消息 ==========

---显示消息提示
---@param message string 消息内容
---@param duration number|nil 持续时间（秒），默认2秒
function M.ShowMessage(message, duration)
	UIToastManager:ShowToast(message, duration)
end

---清空Toast队列
function M.ClearToastQueue()
	UIToastManager:ClearQueue()
end

-- ========== 对话框 ==========

---显示确认对话框
---@param title string 标题
---@param content string 内容
---@param confirmCallback function|nil 确认回调
---@param cancelCallback function|nil 取消回调
function M.ShowConfirmDialog(title, content, confirmCallback, cancelCallback)
	UIMsgBoxManager:ShowConfirmDialog(title, content, confirmCallback, cancelCallback)
end

---显示提示对话框
---@param title string 标题
---@param content string 内容
---@param callback function|nil 确认回调
function M.ShowAlertDialog(title, content, callback)
	UIMsgBoxManager:ShowAlertDialog(title, content, callback)
end

---显示自定义对话框
---@param title string 标题
---@param content string 内容
---@param confirmText string 确认按钮文本
---@param cancelText string 取消按钮文本
---@param confirmCallback function|nil 确认回调
---@param cancelCallback function|nil 取消回调
function M.ShowCustomDialog(title, content, confirmText, cancelText, confirmCallback, cancelCallback)
	UIMsgBoxManager:ShowCustomDialog(title, content, confirmText, cancelText, confirmCallback, cancelCallback)
end

-- ========== 锁定界面 ==========

---显示锁定界面
---@param message string|nil 提示信息
function M.ShowLock(message)
	UILockManager:ShowLock(message)
end

---隐藏锁定界面
function M.HideLock()
	UILockManager:HideLock()
end

---检查是否已锁定
---@return boolean 是否锁定
function M.IsLocked()
	return UILockManager:IsLocked()
end


-- ========== 顶层UI ==========

---打开顶层UI
---@param uiName string UI名称
---@param params table|nil 传递给UI的参数（可选）
---@return UIControllerBase|nil 控制器实例
function M.TopOpen(uiName, params)
	return UITopManager:ShowTopUI(uiName, params)
end

---关闭顶层UI
---@param uiName string UI名称
function M.TopClose(uiName)
	return UITopManager:HideTopUI(uiName)
end

---销毁UI管理器
function M.Destroy()
	UILayerManager:Destroy()
	UIStateManager:Destroy()
	UIDialogManager:CloseAllDialogs()
	UIToastManager:ClearQueue()
	UITopManager:HideAllTopUI()
	M.isInitialized = false
end

return M