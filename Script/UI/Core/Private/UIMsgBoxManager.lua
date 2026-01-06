-- UIMsgBoxManager.lua
-- 消息框管理器：管理 Messagebox 层级的 UI，支持多个消息框堆叠显示

local UILayerManager = require("Script.UI.Core.Private.UILayerManager")
local UIConfig = require("Script.UI.Core.UIConfig")
local Log = require("Utility.Log")

---@class UIMsgBoxManager
local M = {
    msgBoxStack = {},      -- 消息框栈
    nextMsgBoxId = 1,      -- 下一个消息框 ID
    isInitialized = false,
    processingCallbacks = {}  -- 正在处理的回调 {[msgBoxId] = true}
}

--- 消息框类型
M.MsgBoxType = {
    Alert = 1,    -- 提示框（仅确定按钮）
    Confirm = 2   -- 确认框（确定+取消按钮）
}

--- 默认配置
local DEFAULT_CONFIRM_TEXT = "确定"
local DEFAULT_CANCEL_TEXT = "取消"
local MAX_MSGBOX_ID = 999999  -- ID 上限，防止溢出

--- 初始化
function M:Initialize()
    if self.isInitialized then return end
    self.msgBoxStack = {}
    self.nextMsgBoxId = 1
    self.processingCallbacks = {}
    self.isInitialized = true
end

--- 显示消息框
---@param uiName string UI 名称
---@param params table|nil 参数 {title, content, type, confirmText, cancelText, showConfirmButton, showCancelButton}
---@param confirmCallback function|nil 确认回调
---@param cancelCallback function|nil 取消回调
---@return number msgBoxId（失败返回 0）
function M:Show(uiName, params, confirmCallback, cancelCallback)
    -- 参数校验
    if not uiName or uiName == "" then
        Log.Error("UIMsgBoxManager", "Invalid uiName")
        return 0
    end
    if params ~= nil and type(params) ~= "table" then
        Log.Error("UIMsgBoxManager", "Invalid params type: " .. type(params))
        return 0
    end
    
    self:Initialize()
    
    if not UILayerManager.isInitialized then
        UILayerManager:Initialize()
    end
    
    local config = UIConfig[uiName]
    if not config then
        Log.Error("UIMsgBoxManager", "UI config not found: " .. uiName)
        return 0
    end
    
    -- 创建消息框实例
    local controller, view = self:CreateMsgBox(uiName, config)
    if not controller then return 0 end
    
    -- 准备参数（浅拷贝避免污染外部数据）
    local finalParams = self:PrepareParams(params)
    
    -- 更新模型数据
    if controller.UpdateModel then
        controller:UpdateModel(finalParams)
    end
    
    -- 生成消息框 ID（循环使用，防止溢出）
    local msgBoxId = self.nextMsgBoxId
    self.nextMsgBoxId = (self.nextMsgBoxId % MAX_MSGBOX_ID) + 1
    
    -- 设置回调（包装异常处理和自动关闭）
    if controller.SetCallbacks then
        controller:SetCallbacks(
            self:WrapCallback(msgBoxId, confirmCallback),
            self:WrapCallback(msgBoxId, cancelCallback)
        )
    end
    
    -- 添加到栈
    table.insert(self.msgBoxStack, {
        msgBoxId = msgBoxId,
        uiName = uiName,
        controller = controller,
        view = view
    })
    
    -- 显示消息框
    local success, err = pcall(function()
        if controller.Show then
            controller:Show(UILayerManager.LayerType.Messagebox)
        end
    end)
    
    if not success then
        Log.Error("UIMsgBoxManager", "Failed to show: " .. uiName .. ", " .. tostring(err))
        table.remove(self.msgBoxStack)
        self:CleanupMsgBox(controller, view)
        return 0
    end
    
    return msgBoxId
end

--- 显示提示框（仅确定按钮）
function M:ShowAlert(uiName, title, content, confirmCallback, confirmText)
    return self:Show(uiName, {
        title = title,
        content = content,
        type = M.MsgBoxType.Alert,
        confirmText = confirmText
    }, confirmCallback, nil)
end

--- 显示确认框（确定+取消按钮）
function M:ShowConfirm(uiName, title, content, confirmCallback, cancelCallback, confirmText, cancelText)
    return self:Show(uiName, {
        title = title,
        content = content,
        type = M.MsgBoxType.Confirm,
        confirmText = confirmText,
        cancelText = cancelText
    }, confirmCallback, cancelCallback)
end

--- 显示自定义消息框
function M:ShowCustom(uiName, title, content, confirmText, cancelText, confirmCallback, cancelCallback)
    local params = {
        title = title,
        content = content,
        confirmText = confirmText,
        type = cancelText and M.MsgBoxType.Confirm or M.MsgBoxType.Alert,
        cancelText = cancelText
    }
    return self:Show(uiName, params, confirmCallback, cancelCallback)
end

--- 准备参数（设置默认值和按钮显示状态）
function M:PrepareParams(params)
    local finalParams = {}
    if params then
        for k, v in pairs(params) do
            finalParams[k] = v
        end
    end
    
    -- 设置默认按钮文本
    finalParams.confirmText = finalParams.confirmText or DEFAULT_CONFIRM_TEXT
    finalParams.cancelText = finalParams.cancelText or DEFAULT_CANCEL_TEXT
    
    -- 根据类型设置按钮显示状态
    local msgType = finalParams.type
    if msgType == M.MsgBoxType.Alert then
        finalParams.showConfirmButton = finalParams.showConfirmButton ~= false
        finalParams.showCancelButton = false
    elseif msgType == M.MsgBoxType.Confirm then
        finalParams.showConfirmButton = finalParams.showConfirmButton ~= false
        finalParams.showCancelButton = finalParams.showCancelButton ~= false
    else
        finalParams.showConfirmButton = finalParams.showConfirmButton ~= false
        finalParams.showCancelButton = finalParams.showCancelButton ~= false
    end
    
    return finalParams
end

--- 包装回调（添加异常处理和自动关闭）
function M:WrapCallback(msgBoxId, callback)
    return function(...)
        -- 检查该消息框的回调是否正在处理
        if self.processingCallbacks[msgBoxId] then
            Log.Warning("UIMsgBoxManager", "Callback for msgBoxId " .. msgBoxId .. " is already processing, skip")
            return
        end
        
        self.processingCallbacks[msgBoxId] = true
        
        -- 使用 pcall 保护回调执行和清理逻辑
        local success, err = pcall(function()
            if callback then
                callback(...)
            end
        end)
        
        if not success then
            Log.Error("UIMsgBoxManager", "Callback error: " .. tostring(err))
        end
        
        -- 确保标志被清除（即使回调出错）
        self.processingCallbacks[msgBoxId] = nil
        self:Close(msgBoxId)
    end
end

--- 关闭指定消息框
function M:Close(msgBoxId)
    if not self.isInitialized then return false end
    
    for i, info in ipairs(self.msgBoxStack) do
        if info.msgBoxId == msgBoxId then
            self:CleanupMsgBox(info.controller, info.view)
            table.remove(self.msgBoxStack, i)
            -- 清除回调处理标志
            self.processingCallbacks[msgBoxId] = nil
            return true
        end
    end
    return false
end

--- 关闭顶层消息框
function M:CloseTop()
    if #self.msgBoxStack > 0 then
        self:Close(self.msgBoxStack[#self.msgBoxStack].msgBoxId)
    end
end

--- 关闭所有消息框
function M:CloseAll()
    for i = #self.msgBoxStack, 1, -1 do
        local info = self.msgBoxStack[i]
        self:CleanupMsgBox(info.controller, info.view)
        -- 清除回调处理标志
        self.processingCallbacks[info.msgBoxId] = nil
    end
    self.msgBoxStack = {}
end

--- 清理消息框资源
function M:CleanupMsgBox(controller, view)
    if controller then
        if controller.Hide then
            pcall(controller.Hide, controller)
        end
        if controller.Destroy then
            pcall(controller.Destroy, controller)
        end
    end
    if view then
        pcall(view.RemoveFromParent, view)
    end
end

--- 创建消息框实例
function M:CreateMsgBox(uiName, config)
    local ViewClass, ControllerClass, ModelData = config[1], config[2], config[3] or {}
    
    if not ViewClass or not ControllerClass then
        Log.Error("UIMsgBoxManager", "Invalid config: " .. uiName)
        return nil, nil
    end
    
    local world = UE.GetWorld()
    if not world then
        Log.Error("UIMsgBoxManager", "Failed to get world")
        return nil, nil
    end

    local view = UE.UWidgetBlueprintLibrary.Create(world, ViewClass, nil)
    if not view then
        Log.Error("UIMsgBoxManager", "Failed to create view: " .. uiName)
        return nil, nil
    end
    
    local controller = ControllerClass.new(view, ModelData)
    if not controller then
        Log.Error("UIMsgBoxManager", "Failed to create controller: " .. uiName)
        if view then
            view:RemoveFromParent()
        end
        return nil, nil
    end
    
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller, view
end

--- 获取顶层 Controller
function M:GetTopController()
    local top = self.msgBoxStack[#self.msgBoxStack]
    return top and top.controller or nil
end

--- 获取指定 UI 的所有 Controller
function M:GetShowingControllers(uiName)
    local controllers = {}
    for _, info in ipairs(self.msgBoxStack) do
        if info.uiName == uiName then
            table.insert(controllers, info.controller)
        end
    end
    return controllers
end

--- 检查消息框是否正在显示
function M:IsShowing(msgBoxId)
    for _, info in ipairs(self.msgBoxStack) do
        if info.msgBoxId == msgBoxId then return true end
    end
    return false
end

--- 获取当前显示的消息框数量
function M:GetCount()
    return #self.msgBoxStack
end

--- 获取所有显示中的消息框名称
function M:GetShowingMsgBoxes()
    local msgBoxes = {}
    for _, info in ipairs(self.msgBoxStack) do
        table.insert(msgBoxes, info.uiName)
    end
    return msgBoxes
end

--- 销毁
function M:Destroy()
    self:CloseAll()
    self.msgBoxStack = {}
    self.nextMsgBoxId = 1
    self.processingCallbacks = {}
    self.isInitialized = false
end

return M
