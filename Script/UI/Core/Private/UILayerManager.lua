-- UILayerManager.lua
-- UI 层管理器，负责管理 UI 的层级关系

---@class UILayerManager
local M = {
	layers = {},
	isInitialized = false,
	gameInstance = nil
}

--- 定义 UI 层级枚举
M.LayerType = {
    State = 1,    -- 状态层
    Dialog = 2,   -- 对话框层
    Lock = 3,     -- 锁定层
    Messagebox = 4,   -- 消息框层
    Toast = 5     -- 提示层
}

--- UI 层配置
local LAYER_CONFIG = {
    { name = "StateLayer", type = M.LayerType.State, zOrder = 0 },
    { name = "DialogLayer", type = M.LayerType.Dialog, zOrder = 10 },
    { name = "LockLayer", type = M.LayerType.Lock, zOrder = 20 },
    { name = "MessageboxLayer", type = M.LayerType.Messagebox, zOrder = 30 },
    { name = "ToastLayer", type = M.LayerType.Toast, zOrder = 40 }
}

--- 初始化 UI 层管理器
function M:Initialize(gameInst)
	self.gameInstance = gameInst
    if self.isInitialized then
        return
    end
    
    -- 创建 5 个 UI 层
    for _, config in ipairs(LAYER_CONFIG) do
        local layer = self:CreateLayer(config)
        self.layers[config.type] = layer
    end
    
    self.isInitialized = true
end

--- 创建单个 UI 层
--- @param config table 层配置
--- @return UCanvasPanel UI 层
function M:CreateLayer(config)
	
	--local wClass = UE.UClass.Load("/Script/UMGEditor.WidgetBlueprint'/Game/UI/WBP_Main.WBP_Main_C'")
	---@type UOverlay
    local layer = NewObject(UE.UOverlay,self.gameInstance)
    -- 设置 ZOrder
	local Slot = UE.FGameViewportWidgetSlot()
	Slot.ZOrder = config.zOrder

	---@type UGameViewportSubsystem
	local GameViewportSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGameViewportSubsystem)
	GameViewportSubsystem:AddWidget(layer, Slot)
    --layer:SetRenderOpacity(1.0)
	--layer:AddToViewport(config.zOrder)
	layer:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    return layer
end

--- 获取指定类型的层
--- @param layerType integer 层级类型
--- @return UCanvasPanel|nil UI 层
function M:GetLayer(layerType)
    return self.layers[layerType]
end

--- 将 UI 添加到指定层
--- @param uiWidget UWidget UI 控件
--- @param layerType integer 层级类型
function M:AddToLayer(uiWidget, layerType)
	---@type UOverlay
    local layer = self:GetLayer(layerType)
    if layer and uiWidget then
        layer:AddChildToOverlay(uiWidget)
		uiWidget.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
		uiWidget.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
    end
end

--- 从指定层移除 UI
--- @param uiWidget UWidget UI 控件
--- @param layerType integer 层级类型
function M:RemoveFromLayer(uiWidget, layerType)
    local layer = self:GetLayer(layerType)
    if layer and uiWidget then
        layer:RemoveChild(uiWidget)
    end
end

--- 清空指定层
--- @param layerType integer 层级类型
function M:ClearLayer(layerType)
    local layer = self:GetLayer(layerType)
    if layer then
        layer:ClearChildren()
    end
end

--- 清空所有层
function M:ClearAllLayers()
    for layerType, layer in pairs(self.layers) do
        if layer then
            layer:ClearChildren()
        end
    end
end

--- 销毁 UI 层管理器
function M:Destroy()
    self:ClearAllLayers()
    
    for layerType, layer in pairs(self.layers) do
        if layer then
            layer:RemoveFromParent()
            self.layers[layerType] = nil
        end
    end
    
    self.isInitialized = false
end

return M
