local UIConfigSystem = require "UI.UIConfigSystem"
local UILayerSystem = require "UI.Core.UILayerSystem"

local UIStateLayer = require "UI.Core.UIStateLayer"
local UIDialogLayer = require "UI.Core.UIDialogLayer"
local UILockLayer = require "UI.Core.UILockLayer"
local UIMsgBoxLayer = require "UI.Core.UIMsgBoxLayer"
local UIToastLayer = require "UI.Core.UIToastLayer"
local UITopLayer = require "UI.Core.UITopLayer"

local DEFAULT_MSG_BOX_NAME<const> = "MsgBox"
local DEFAULT_TOAST_NAME<const> = "Toast"
local DEFAULT_LOCK_NAME<const> = "Lock"

---@type UIStateLayer
local stateLayer = nil
---@type UIDialogLayer
local dialogLayer = nil
---@type UILockLayer
local lockLayer = nil
---@type UIMsgBoxLayer
local msgBoxLayer = nil
---@type UIToastLayer
local toastLayer = nil
---@type UITopLayer
local topLayer = nil

local bInitialized = false

---@class UIManager
local M = {
}

function M.RegisterDefaultConfig()
	UIConfigSystem.Register(DEFAULT_MSG_BOX_NAME, "UI.Widgets.MessageBox.MsgBoxController","/Game/Test/UITest/WBP_MessageBox.WBP_MessageBox_C", true)
	UIConfigSystem.Register(DEFAULT_TOAST_NAME, "UI.Widgets.Toast.ToastController","/Game/Test/UITest/WBP_Toast.WBP_Toast_C", true)
	UIConfigSystem.Register(DEFAULT_LOCK_NAME, "UI.Widgets.Lock.LockController","/Game/Test/UITest/WBP_Lock.WBP_Lock_C", true)
end

function M.Initialize()
	if bInitialized then
        return
    end
	bInitialized = true
	UILayerSystem.Initialize()
	stateLayer = UIStateLayer()
	dialogLayer = UIDialogLayer()
	lockLayer = UILockLayer()
	msgBoxLayer = UIMsgBoxLayer()
	toastLayer = UIToastLayer()
	topLayer = UITopLayer()
end

function M.Destroy()
	if not bInitialized then
        return
    end
	bInitialized = false
	if topLayer then
        topLayer:CloseAll()
        topLayer = nil
    end
	if toastLayer then
        toastLayer:CloseAll()
        toastLayer = nil
    end
	if msgBoxLayer then
        msgBoxLayer:CloseAll()
        msgBoxLayer = nil
    end
	if lockLayer then
		lockLayer:Close()
		lockLayer = nil
	end
	if stateLayer then
		stateLayer:CloseAll()
		stateLayer = nil
	end
	if dialogLayer then
		dialogLayer:CloseAll()
		dialogLayer = nil
    end
	UILayerSystem.Destroy()
end

function M.CloseAll()
	if not bInitialized then
		return
	end
    M.State_CloseAll()
    M.Dialog_CloseAll()
	M.Lock_Close()
	M.MsgBox_CloseAll()
	M.Toast_CloseAll()
end

---@param name string
---@param controllerPath string
---@param viewPath string
function M.RegisterConfig(name, controllerPath, viewPath, bPreload)
	UIConfigSystem.Register(name, controllerPath, viewPath, bPreload)
end

---@param name string
---@param model ModelBase
---@param bCacheCurrent boolean|nil
---@return UIControllerBase
function M.State_Open(name, model, bCacheCurrent)
	return stateLayer:Open(name, model, bCacheCurrent)
end

---@return UIControllerBase|nil
function M.State_GetOpenController()
	return stateLayer:GetOpenController()
end

---@return UIControllerBase
function M.State_CloseAndReopen()
    return stateLayer:CloseAndReopen()
end

function M.State_CloseAll()
	stateLayer:CloseAll()
end

---@param name string
---@param model ModelBase
---@return UIControllerBase
function M.Dialog_Open(name, model)
    return dialogLayer:Open(name, model)
end

---@param name string
---@return boolean
function M.Dialog_Close(name)
    return dialogLayer:Close(name)
end

---@return UIControllerBase|nil
function M.Dialog_GetTopController()
    return dialogLayer:GetTopController()
end

---@param name string
---@return UIControllerBase|nil
function M.Dialog_GetController(name)
    return dialogLayer:GetController(name)
end

function M.Dialog_CloseTop()
	return dialogLayer:CloseTop()
end

function M.Dialog_CloseAll()
	dialogLayer:CloseAll()
end

---@param name string
---@param model ModelBase
---@return LockController
function M.Lock_Open(model, message)
	return lockLayer:Open(DEFAULT_LOCK_NAME, model, message, 0)
end

---@param name string
---@param model ModelBase
---@param message string
---@param timeout integer|nil 超时时间（秒），nil=默认30秒，0=不超时
---@return LockController
function M.Lock_OpenWithTimeout(model, message, timeout)
	return lockLayer:Open(DEFAULT_LOCK_NAME, model, message, timeout)
end

function M.Lock_OpenCustom(name, model, message, timeout)
	name = name or DEFAULT_LOCK_NAME
    return lockLayer:Open(name, model, message, timeout)
end

function M.Lock_Close()
	lockLayer:Close()
end

---@return boolean 是否锁定
function M.Lock_IsLocked()
	return lockLayer:IsLocked()
end

---@param model ModelBase
---@param title string
---@param content string
---@return UIMsgBoxController
function M.MsgBox_OpenAlert(model, title, content)
	return msgBoxLayer:OpenAlert(DEFAULT_MSG_BOX_NAME, model, title, content)
end
---@param model ModelBase
---@param title string
---@param content string
---@return UIMsgBoxController
function M.MsgBox_OpenConfirm(model, title, content)
    return msgBoxLayer:OpenConfirm(DEFAULT_MSG_BOX_NAME, model, title, content)
end

---@param name string
---@param model ModelBase
---@param title string
---@param content string
---@param bConfirm boolean
---@return UIMsgBoxController
function M.MsgBox_OpenCustom(name, model, title, content, bConfirm)
	name  = name or DEFAULT_MSG_BOX_NAME
    return msgBoxLayer:Open(name, model, title, content, bConfirm)
end

---@param name string
function M.MsgBox_Close(name)
	return msgBoxLayer:Close(name)
end

function M.MsgBox_CloseAll()
   msgBoxLayer:CloseAll()
end

---@param count integer
function M.Toast_SetMaxShowCount(count)
	toastLayer:SetMaxShowCount(count)
end

---@param name string
---@param model ModelBase
---@param content string
---@param duration integer
---@return ToastController
function M.Toast_OpenCustom(name, model, content, duration)
    name = name or DEFAULT_TOAST_NAME
    return toastLayer:Open(name, model, content, duration)
end

function M.Toast_Open(model, content, duration)
	return toastLayer:Open(DEFAULT_TOAST_NAME, model, content, duration)
end

---@param name string
---@param bSilent boolean|nil
---@return boolean
function M.Toast_Close(name, bSilent)
    return toastLayer:Close(name,bSilent)
end

function M.Toast_CloseAll()
    toastLayer:CloseAll()
end

---@param name string
---@param model ModelBase
---@return UIControllerBase
function M.Top_Open(name, model)
	return topLayer:Open(name, model)
end

---@param name string
---@return boolean
function M.Top_Close(name)
	return topLayer:Close(name)
end

---@return UIControllerBase|nil
function M.Top_GetTopController()
	return topLayer:GetTopController()
end

---@param name string
---@return UIControllerBase|nil
function M.Top_GetController(name)
	return topLayer:GetController(name)
end

function M.Top_CloseTop()
	return topLayer:CloseTop()
end

function M.Top_CloseAll()
	topLayer:CloseAll()
end

return M