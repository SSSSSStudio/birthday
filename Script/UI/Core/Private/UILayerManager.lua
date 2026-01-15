-- UILayerManager.lua
-- UI 层管理器，负责管理 UI 的层级关系

local LayerType = require("UI.Core.Private.LayerType")
local layers = nil
local layersRef = nil
local isInitialized = false
---@type GI_G01GameInstance_C
local gameInstance = nil
---@class UILayerManager
local M = {
}

--- UI 层配置
local LAYER_CONFIG<const> = {
    { name = "StateLayer", type = LayerType.State, zOrder = 0 },
    { name = "DialogLayer", type = LayerType.Dialog, zOrder = 10 },
    { name = "LockLayer", type = LayerType.Lock, zOrder = 20 },
    { name = "MessageboxLayer", type = LayerType.Messagebox, zOrder = 30 },
    { name = "ToastLayer", type = LayerType.Toast, zOrder = 40 },
    { name = "TopLayer", type = LayerType.Top, zOrder = 50 }
}

--- 创建单个 UI 层
--- @param config table 层配置
--- @return UCanvasPanel UI 层
local function CreateLayer(config)
	---@type UOverlay
	local layer = NewObject(UE.UOverlay,gameInstance)
	-- 设置 ZOrder
	local Slot = UE.FGameViewportWidgetSlot()
	Slot.ZOrder = config.zOrder

	---@type UGameViewportSubsystem
	local GameViewportSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGameViewportSubsystem)
	GameViewportSubsystem:AddWidget(layer, Slot)
	layer:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
	return layer
end

function M.Get()
	if isInitialized == false then
		M.Initialize()
	end
	return M
end

--- 初始化 UI 层管理器
function M.Initialize()
    if isInitialized then
        return
    end
	
	layers = {}
	layersRef = {}
	isInitialized = false
	gameInstance = require("Core.UEHelper").GetGameInstance()
    
    -- 创建 6 个 UI 层
    for _, config in ipairs(LAYER_CONFIG) do
        local layer = CreateLayer(config)
		layers[config.type] = layer
		layersRef[config.type] = UnLua.Ref(layer)
    end
    
    isInitialized = true
end

--- 获取指定类型的层
--- @param layerType integer 层级类型
--- @return UOverlay|nil UI 层
function M.GetLayer(layerType)
    return layers[layerType];
end

--- 将 UI 添加到指定层
--- @param uiWidget UWidget UI 控件
--- @param layerType integer 层级类型
function M.AddToLayer(uiWidget, layerType)
	---@type UOverlay
    local layer = M.GetLayer(layerType)
    if layer and uiWidget then
        layer:AddChildToOverlay(uiWidget)
		uiWidget.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
		uiWidget.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
    end
end

--- 从指定层移除 UI
--- @param uiWidget UWidget UI 控件
--- @param layerType integer 层级类型
function M.RemoveFromLayer(uiWidget, layerType)
    local layer = M.GetLayer(layerType)
    if layer and uiWidget then
        layer:RemoveChild(uiWidget)
    end
end

--- 清空指定层
--- @param layerType integer 层级类型
function M.ClearLayer(layerType)
    local layer = M.GetLayer(layerType)
    if layer then
        layer:ClearChildren()
    end
end

--- 清空所有层
function M.ClearAllLayers()
    for layerType, layer in pairs(layers) do
        if layer then
            layer:ClearChildren()
        end
    end
end

--- 销毁 UI 层管理器
function M.Destroy()
    M.ClearAllLayers()
    for layerType, layer in pairs(layers) do
        if layer then
            layer:RemoveFromParent()
            layers[layerType] = nil
			layersRef[layerType] = nil
        end
    end
	
	layers = {}
	layersRef = {}
    isInitialized = false
	gameInstance = nil
end

return M
