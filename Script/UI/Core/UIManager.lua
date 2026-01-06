-- UIManager.lua
-- UI 管理器，负责管理整个 UI 系统

local UILayerManager = require "UI.Core.Private.UILayerManager"
local UIStateManager = require "UI.Core.Private.UIStateManager"
local UIDialogManager = require "UI.Core.Private.UIDialogManager"
local UILockManager = require "UI.Core.Private.UILockManager"
local UIMsgBoxManager = require "UI.Core.Private.UIMsgBoxManager"
local UIToastManager = require "UI.Core.Private.UIToastManager"
local UITopManager = require "UI.Core.Private.UITopManager"
local UIConfig = require "UI.Core.UIConfig"

---@class UIManager
local M = {
	isInitialized = false,
	gameInstance = nil,
	-- 层级管理器映射表
	layerManagers = {
		[UILayerManager.LayerType.State] = UIStateManager,
		[UILayerManager.LayerType.Dialog] = UIDialogManager,
		[UILayerManager.LayerType.Lock] = UILockManager,
		[UILayerManager.LayerType.Messagebox] = UIMsgBoxManager,
		[UILayerManager.LayerType.Toast] = UIToastManager,
		[UILayerManager.LayerType.Top] = UITopManager
	}
}

---初始化UI管理器
---@param gameInst any 游戏实例
function M.Initialize(gameInst)
	if M.isInitialized then return end
	
	M.gameInstance = gameInst
	UILayerManager:Initialize(gameInst)
	M.isInitialized = true
end

--- 打开状态 UI（State 层级的 UI）
--- @param uiName string UI 名称
--- @param params table|nil 传递给 UI 的参数（可选）
--- @param isCacheCurrent boolean|nil 是否使用 LRU 缓存（默认为 true）
--- @return UIControllerBase|nil 控制器实例
function M.StateOpen(uiName, params, isCacheCurrent)
    return UIStateManager:OpenUI(uiName, params, isCacheCurrent)
end

---获取层级管理器
---@param layer number 层级类型
---@return table 层级管理器
local function GetLayerManager(layer)
	return M.layerManagers[layer] or UIStateManager
end

-- ========== 对外统一接口 ==========

---显示UI界面（根据配置的Layer自动选择层级）
---@param uiName string UI名称
---@param ... any 传递给UI的参数
function M.ShowUI(uiName, ...)
	local config = GetUIConfig(uiName)
	if not config then
		print(string.format("[UIManager] UI '%s' not found", uiName))
		return
	end

	local layer = config.Layer or UILayerManager.LayerType.State
	local manager = GetLayerManager(layer)
	local params = {...}
	
	-- 根据层级调用对应方法
	if layer == UILayerManager.LayerType.State then
		return manager:OpenUI(uiName, params[1])
	elseif layer == UILayerManager.LayerType.Dialog then
		return manager:OpenDialog(uiName, params[1])
	elseif layer == UILayerManager.LayerType.Top then
		return manager:ShowTopUI(uiName, params[1])
	end
end

---隐藏UI界面（根据配置的Layer自动选择层级）
---@param uiName string UI名称
function M.HideUI(uiName)
	local config = GetUIConfig(uiName)
	if not config then
		print(string.format("[UIManager] UI '%s' not found", uiName))
		return
	end

	local layer = config.Layer or UILayerManager.LayerType.State
	local manager = GetLayerManager(layer)
	
	-- 根据层级调用对应方法
	if layer == UILayerManager.LayerType.State then
		manager:CloseCurrentUIAndReopen()
	elseif layer == UILayerManager.LayerType.Dialog then
		manager:CloseDialog(uiName)
	elseif layer == UILayerManager.LayerType.Top then
		manager:HideTopUI(uiName)
	end
end

---切换UI（仅State层有效）
---@param uiName string UI名称
---@param ... any 传递给UI的参数
function M.SwitchUI(uiName, ...)
	local config = GetUIConfig(uiName)
	if not config then
		print(string.format("[UIManager] UI '%s' not found", uiName))
		return
	end

	local layer = config.Layer or UILayerManager.LayerType.State
	if layer ~= UILayerManager.LayerType.State then
		print(string.format("[UIManager] SwitchUI only for State layer, '%s' is layer %d", uiName, layer))
		return
	end

	local params = {...}
	return UIStateManager:OpenUI(uiName, params[1])
end

---检查UI是否显示
---@param uiName string UI名称
---@return boolean 是否显示
function M.IsUIShowing(uiName)
	local config = GetUIConfig(uiName)
	if not config then return false end

	local layer = config.Layer or UILayerManager.LayerType.State
	
	if layer == UILayerManager.LayerType.State then
		return UIStateManager:IsUIShowing(uiName)
	elseif layer == UILayerManager.LayerType.Dialog then
		return UIDialogManager:IsDialogShowing(uiName)
	elseif layer == UILayerManager.LayerType.Top then
		return UITopManager:IsTopUIShowing(uiName)
	end
	
	return false
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

---关闭顶层Dialog
function M.CloseTopDialog()
	UIDialogManager:CloseTopDialog()
end

---关闭所有Dialog
function M.CloseAllDialogs()
	UIDialogManager:CloseAllDialogs()
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

-- ========== 配置管理 ==========

---注册UI
---@param uiName string UI名称
---@param config table UI配置
function M.RegisterUI(uiName, config)
	UIConfig:RegisterConfig(uiName, config)
end

---批量注册UI
---@param configs table UI配置表
function M.RegisterUIBatch(configs)
	UIConfig:RegisterConfigs(configs)
end

---获取UI配置
---@param uiName string UI名称
---@return table|nil UI配置
function M.GetUIConfig(uiName)
	return UIConfig:GetConfig(uiName)
end

-- ========== 系统管理 ==========

---销毁UI管理器
function M.Destroy()
	UILayerManager:Destroy()
	UIStateManager:ClearCache()
	UIDialogManager:CloseAllDialogs()
	UIToastManager:ClearQueue()
	UITopManager:HideAllTopUI()
	M.isInitialized = false
end

return M