-- UIDialogManager.lua
-- UI 对话框管理器，负责管理 Dialog 层级的 UI
-- 支持多个 Dialog 堆叠

local LRUCache = require("Script.UI.Core.Private.LRUCache")
local UILayerManager = require("Script.UI.Core.Private.UILayerManager")
local UIConfig = require("Script.UI.Core.UIConfig")

---@class UIDialogManager
local M = {
    dialogCache = nil,       -- Dialog 实例缓存
    dialogStack = {},        -- Dialog 栈（用于管理多个 Dialog 的显示顺序）
    isInitialized = false    -- 是否已初始化
}

--- 从栈中移除 Dialog（不更新 ZOrder）
--- 用于 LRU 淘汰回调，避免回调中的复杂逻辑和重入风险
--- 注意：这是内部函数，仅供 LRU 淘汰回调使用，外部请使用 CloseDialog
--- @param self table UIDialogManager 实例
--- @param uiName string UI 名称
--- @return boolean true 如果成功移除
local function removeFromStackNoZ(self, uiName)
	for i, info in ipairs(self.dialogStack) do
		if info.uiName == uiName then
			-- 隐藏 Dialog
			if info.controller and info.controller.Hide then
				info.controller:Hide()
			end
			table.remove(self.dialogStack, i)
			return true
		end
	end
	return false
end

--- 初始化 UI 对话框管理器
--- @param cacheCapacity number|nil 缓存容量（默认 3）
function M:Initialize(cacheCapacity)
    if self.isInitialized then
        return
    end
    
    -- 初始化 LRU 缓存，设置淘汰回调
    self.dialogCache = LRUCache(cacheCapacity or 3, function(uiName, controller)
        -- 淘汰回调中只做最小操作，避免重入/迭代修改容器的风险
        -- 如果 Dialog 仍在显示，从栈中移除并 Hide（不更新 ZOrder）
        removeFromStackNoZ(self, uiName)
        
        -- 销毁控制器
        if controller and controller.Destroy then
            controller:Destroy()
        end
    end)
    
    -- 初始化 Dialog 栈
    self.dialogStack = {}
    
    self.isInitialized = true
end

--- 显示 Dialog
--- @param uiName string UI 名称（对应 UIConfig 中的键名）
--- @param params table|nil 传递给 UI 的参数（可选）
--- @return UIControllerBase|nil 控制器实例
function M:ShowDialog(uiName, params)
    if not self.isInitialized then
        self:Initialize()
    end
    
    -- 检查配置是否存在
    local config = UIConfig[uiName]
    if not config then
        error("UI config not found: " .. tostring(uiName))
        return nil
    end
    
    -- 从缓存中获取或创建 Dialog
    ---@type UIControllerBase
    local controller = self.dialogCache:get(uiName)
    
    if not controller then
        -- 创建新的 Dialog 实例
        controller = self:CreateDialog(uiName, config)
        if not controller then
            return nil
        end
        
        -- 添加到缓存
        self.dialogCache:put(uiName, controller)
    end
    
    -- 更新参数
    if params and controller.UpdateModel then
        controller:UpdateModel(params)
    end
    
    -- 检查是否已存在，如果存在则先移除
    for i, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then
            table.remove(self.dialogStack, i)
            break
        end
    end
    
    -- 添加到 Dialog 栈顶部（后打开的在最上方）
    local dialogInfo = {
        uiName = uiName,
        controller = controller
    }
    table.insert(self.dialogStack, dialogInfo)
    
    -- 显示 Dialog
    if controller.Show then
        controller:Show(UILayerManager.LayerType.Dialog)
    end
    
    -- 设置 ZOrder（优先级高的在上层）
    self:UpdateDialogZOrder()
    
    return controller
end

--- 更新 Dialog 的 ZOrder（栈顶的在最上层）
--- ZOrder 策略：i * 10 为每个 Dialog 预留 10 个层级空间
--- 这样 Dialog 内部的子窗口、提示等可以使用 +1~+9 的相对层级
--- 注意：需要确保 Dialog 层的基础 ZOrder 不会与其他 Layer（如 Toast/Tooltip）冲突
function M:UpdateDialogZOrder()
    -- 按栈顺序设置 ZOrder，索引越大的越靠上
    for i, info in ipairs(self.dialogStack) do
        if info.controller and info.controller.GetView then
            local view = info.controller:GetView()
            if view then
                local slot = view.Slot
                if slot and slot.SetZOrder then
                    -- 设置 ZOrder，栈顶（最后添加的）ZOrder 最大
                    slot:SetZOrder(i * 10)
                end
            end
        end
    end
end

--- 关闭指定 Dialog
--- @param uiName string UI 名称
--- @return boolean true 如果成功关闭，false 如果 Dialog 不在栈中
function M:CloseDialog(uiName)
    if not self.isInitialized then
        return false
    end
    
    -- 从栈中移除并隐藏
    local removed = removeFromStackNoZ(self, uiName)
    
    -- 更新 ZOrder
    self:UpdateDialogZOrder()
    
    return removed
end

--- 关闭最顶层的 Dialog
function M:CloseTopDialog()
    if #self.dialogStack == 0 then
        return
    end
    
    local topDialog = self.dialogStack[#self.dialogStack]
    if topDialog then
        self:CloseDialog(topDialog.uiName)
    end
end

--- 关闭所有 Dialog
function M:CloseAllDialogs()
    -- 从后往前关闭（避免索引问题）
    for i = #self.dialogStack, 1, -1 do
        local info = self.dialogStack[i]
        if info.controller and info.controller.Hide then
            info.controller:Hide()
        end
    end
    
    -- 清空栈
    self.dialogStack = {}
    
    -- 更新 ZOrder（防止 Hide 延迟移除时的层级问题）
    self:UpdateDialogZOrder()
end

--- 创建 Dialog 实例
--- @param uiName string UI 名称
--- @param config table UI 配置
--- @return UIControllerBase|nil 控制器实例
function M:CreateDialog(uiName, config)
    -- config[1] 是 View 类，config[2] 是 Controller 类，config[3] 是 Model 数据
    local ViewClass = config[1]
    local ControllerClass = config[2]
    local ModelData = config[3] or {}
    
    if not ViewClass or not ControllerClass then
        error("Invalid UI config for: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 View 实例
    -- 注意：NewObject 未传 Outer，依赖 Controller 的强引用管理生命周期
    local view = NewObject(ViewClass)
    if not view then
        error("Failed to create View for: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 Controller 实例
    local controller = ControllerClass.new(view, ModelData)
    if not controller then
        error("Failed to create Controller for: " .. tostring(uiName))
        return nil
    end
    
    -- 初始化控制器
    if controller.Initialize then
        controller:Initialize()
    end
    
    return controller
end

--- 获取指定 Dialog 的控制器
--- @param uiName string UI 名称
--- @return UIControllerBase|nil 控制器实例
function M:GetController(uiName)
    if not self.dialogCache then
        return nil
    end
    return self.dialogCache:get(uiName)
end

--- 获取最顶层 Dialog 的控制器
--- @return UIControllerBase|nil 控制器实例
function M:GetTopController()
    if #self.dialogStack == 0 then
        return nil
    end
    
    local topDialog = self.dialogStack[#self.dialogStack]
    return topDialog and topDialog.controller or nil
end

--- 检查 Dialog 是否正在显示
--- @param uiName string UI 名称
--- @return boolean true 如果正在显示，false 否则
function M:IsDialogShowing(uiName)
    for _, info in ipairs(self.dialogStack) do
        if info.uiName == uiName then
            return true
        end
    end
    return false
end

--- 获取当前显示的 Dialog 数量
--- @return number Dialog 数量
function M:GetDialogCount()
    return #self.dialogStack
end

--- 获取所有正在显示的 Dialog 名称列表
--- @return table Dialog 名称列表
function M:GetShowingDialogs()
    local dialogs = {}
    for _, info in ipairs(self.dialogStack) do
        table.insert(dialogs, info.uiName)
    end
    return dialogs
end

--- 预加载 Dialog（提前创建并缓存，但不显示）
--- @param uiName string UI 名称
--- @return UIControllerBase|nil 控制器实例，如果预加载失败则返回 nil
function M:PreloadDialog(uiName)
    if not self.isInitialized then
        self:Initialize()
    end
    
    -- 检查是否已在缓存中
    local cached = self.dialogCache:get(uiName)
    if cached then
        return cached
    end
    
    -- 检查配置是否存在
    local config = UIConfig[uiName]
    if not config then
        error("UI config not found: " .. tostring(uiName))
        return nil
    end
    
    -- 创建 Dialog 实例并缓存
    local controller = self:CreateDialog(uiName, config)
    if controller then
        self.dialogCache:put(uiName, controller)
    end
    
    return controller
end

--- 先关闭所有显示中的 Dialog，再清理缓存
function M:ClearCache()
    -- 先关闭所有显示中的 Dialog（会调用 Hide）
    self:CloseAllDialogs()
    
    -- 再清空缓存（会触发淘汰回调，销毁 Controller）
    if self.dialogCache then
        self.dialogCache:clear()
    end
end

--- 销毁 UI 对话框管理器
function M:Destroy()
    -- 清空缓存（内部会先 CloseAllDialogs，避免重复调用）
    self:ClearCache()
    
    self.dialogCache = nil
    self.isInitialized = false
end

return M
