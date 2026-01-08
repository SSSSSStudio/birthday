local UIManager = require "UI.Core.UIManager"
local UIStateManager = require "UI.Core.Private.UIStateManager"
local UIDialogManager = require "UI.Core.Private.UIDialogManager"
local UITopManager = require "UI.Core.Private.UITopManager"
local Log = require "Utility.Log"

---@class UITool
local M = {
}

---通过 Widget 名称和控件名称获取控件
---支持从 State、Dialog、Top 层的 UI 中获取控件
---@param widgetName string Widget 名称（UI 配置中的键名）
---@param controlName string 控件名称（Widget 中的控件名）
---@return UWidget|nil 控件实例，如果未找到则返回 nil
function M.GetWidget(widgetName, controlName)
    if not widgetName or type(widgetName) ~= "string" or widgetName == "" then
        Log.Error("UITool", "Invalid widgetName")
        return nil
    end
    
    if not controlName or type(controlName) ~= "string" or controlName == "" then
        Log.Error("UITool", "Invalid controlName")
        return nil
    end
    
    local controller = nil
    
    -- 1. 尝试从 State 层获取
    if UIStateManager.currentController and UIStateManager.currentUI == widgetName then
        controller = UIStateManager.currentController
    end
    
    -- 2. 尝试从 Dialog 层获取
    if not controller then
        controller = UIDialogManager:GetController(widgetName)
    end
    
    -- 3. 尝试从 Top 层获取
    if not controller then
        controller = UITopManager:GetController(widgetName)
    end
    
    -- 如果找到 Controller，通过 GetWidget 获取控件
    if controller and controller.GetWidget then
        local widget = controller:GetWidget(controlName)
        if widget then
            return widget
        else
            Log.Warning("UITool", string.format("Control '%s' not found in Widget '%s'", controlName, widgetName))
        end
    else
        Log.Warning("UITool", string.format("Widget '%s' not found or not loaded", widgetName))
    end
    
    return nil
end

---递归复制 Widget 及其子控件
---新建同类型控件，复制 Style，并递归处理子控件
---@param originalWidget UWidget 原始 Widget
---@return UWidget|nil 复制的 Widget 实例
function M.DuplicateWidgetRecursive(originalWidget)
    if not originalWidget then
        return nil
    end
    
    -- 获取原始 Widget 的类
    local widgetClass = originalWidget:GetClass()
    if not widgetClass then
        Log.Error("UITool", "Failed to get widget class")
        return nil
    end
    
    -- 获取 World
    local world = UIManager.GetGameInstance():GetWorld()
    if not world then
        Log.Error("UITool", "Failed to get world")
        return nil
    end
    
    -- 创建新的 Widget 实例
    local newWidget = NewObject(widgetClass, world)
    if not newWidget then
        Log.Error("UITool", "Failed to create new widget instance")
        return nil
    end
    
    -- 复制 WidgetStyle
    if originalWidget.WidgetStyle then
        newWidget.WidgetStyle = originalWidget.WidgetStyle
    end
    
    -- 复制可见性
    newWidget:SetVisibility(originalWidget:GetVisibility())
    
    -- 复制渲染透明度
    newWidget:SetRenderOpacity(originalWidget:GetRenderOpacity())
    
    ---- 复制渲染变换
    --local renderTransform = originalWidget:GetRenderTransform()
    --newWidget:SetRenderTransform(renderTransform)
    
    -- 复制工具提示
    if originalWidget.GetToolTipText then
        newWidget:SetToolTipText(originalWidget:GetToolTipText())
    end
    
    -- 复制导航配置
    if originalWidget.GetNavigation then
        newWidget:SetNavigation(originalWidget:GetNavigation())
    end
    
    -- 复制裁剪属性
    if originalWidget.GetClipping then
        newWidget:SetClipping(originalWidget:GetClipping())
    end
    
    -- 复制文本框内容
    if originalWidget.GetText and newWidget.SetText then
        local originalText = originalWidget:GetText()
        if originalText then
            newWidget:SetText(originalText)
        end
    end
    
    -- 递归复制子控件（如果是容器类控件）
    if originalWidget.GetChildrenCount and originalWidget.GetChildAt then
        local childCount = originalWidget:GetChildrenCount()
        for i = 0, childCount - 1 do
            local child = originalWidget:GetChildAt(i)
            if child then
                local newChild = M.DuplicateWidgetRecursive(child)
                if newChild then
                    -- 将子控件添加到新 Widget
                    if newWidget.AddChild then
                        newWidget:AddChild(newChild)
                    elseif newWidget.AddChildToOverlay then
                        newWidget:AddChildToOverlay(newChild)
                    end
                end
            end
        end
    end
    
    return newWidget
end

---复制 Widget
---新建同类型控件，复制 Style，并递归处理子控件
---@param widget UWidget 要复制的 Widget 对象
---@return UWidget|nil 复制的 Widget 实例，如果失败则返回 nil
function M.DuplicateWidget(widget)
    -- 递归复制 Widget 及其子控件
    local duplicatedWidget = M.DuplicateWidgetRecursive(widget)
    if not duplicatedWidget then
        Log.Error("UITool", "Failed to duplicate widget")
        return nil
    end
    
    Log.Info("UITool", "Widget duplicated successfully")
    return duplicatedWidget
end

---复制 Widget 并包裹在 SizeBox 中
---新建同类型控件，复制 Style，并递归处理子控件，然后将复制的控件包裹在一个 SizeBox 中
---SizeBox 的大小设置为原控件的大小
---@param widget UWidget 要复制的 Widget 对象
---@return USizeBox|nil 包裹了复制控件的 SizeBox 实例，如果失败则返回 nil
function M.DuplicateWidgetInSizeBox(widget)
    if not widget then
        Log.Error("UITool", "Failed to duplicate widget in SizeBox: widget is nil")
        return nil
    end
    
    -- 获取原控件的大小
    local localSize = M.GetWidgetSize(widget)
    if not localSize then
        Log.Error("UITool", "Failed to get widget size")
        return nil
    end
    
    -- 递归复制 Widget 及其子控件
    local duplicatedWidget = M.DuplicateWidgetRecursive(widget)
    if not duplicatedWidget then
        Log.Error("UITool", "Failed to duplicate widget")
        return nil
    end
    
    -- 获取 World
    local world = UIManager.GetGameInstance():GetWorld()
    if not world then
        Log.Error("UITool", "Failed to get world")
        return nil
    end
    
    -- 创建 SizeBox
    local sizeBox = NewObject(UE.USizeBox, world)
    if not sizeBox then
        Log.Error("UITool", "Failed to create SizeBox")
        return nil
    end
    
    -- 设置 SizeBox 的大小为原控件的大小
    sizeBox:SetWidthOverride(localSize.X)
    sizeBox:SetHeightOverride(localSize.Y)
    
    -- 将复制的控件添加到 SizeBox 中
    sizeBox:AddChild(duplicatedWidget)
    
    Log.Info("UITool", "Widget duplicated and wrapped in SizeBox successfully,Size: "..localSize.X..","..localSize.Y)
    return sizeBox,duplicatedWidget
end

---获取控件的屏幕位置和大小
---使用 LocalToViewport 将控件的局部坐标转换为屏幕视口坐标
---@param widget UWidget Widget 对象
---@return FVector2D|nil ViewportPosition 控件在屏幕视口中的位置，如果失败则返回 nil
---@return FVector2D|nil localSize 控件的局部大小，如果失败则返回 nil
function M.GetWidgetScreenGeometry(widget)
    if not widget then
        Log.Error("UITool", "Failed to get widget geometry: widget is nil")
        return nil, nil
    end
    
    -- 获取缓存的几何信息
    local geometry = widget:GetCachedGeometry()
    if not geometry then
        Log.Warning("UITool", "Failed to get geometry for widget")
        return nil, nil
    end
    
    -- 获取局部大小
    local localSize = UE.USlateBlueprintLibrary.GetLocalSize(geometry)
    if not localSize then
        Log.Warning("UITool", "Failed to get local size for widget")
        return nil, nil
    end
    
    -- 获取屏幕位置
	local PixelPosition = UE.FVector2D(0,0)
	local ViewportPosition = UE.FVector2D(0,0)
	UE.USlateBlueprintLibrary.LocalToViewport(UIManager.GetGameInstance(), geometry,UE.FVector2D(0,0),PixelPosition, ViewportPosition)
	
    -- 返回位置和大小信息
    return ViewportPosition, localSize
end

---获取控件的屏幕位置
---返回控件在屏幕上的绝对位置
---@param widget UWidget Widget 对象
---@return FVector2D|nil 控件在屏幕视口中的位置，如果失败则返回 nil
function M.GetWidgetScreenPosition(widget)
    local ViewportPosition, _ = M.GetWidgetScreenGeometry(widget)
    return ViewportPosition
end

---获取控件的大小
---返回控件的局部大小
---@param widget UWidget Widget 对象
---@return FVector2D|nil 控件的局部大小，如果失败则返回 nil
function M.GetWidgetSize(widget)
    local _, localSize = M.GetWidgetScreenGeometry(widget)
    return localSize
end

---在目标 Layer 上同位置创建一个相同的新控件
---复制指定控件，并将其添加到目标 Layer 的相同位置
---@param targetLayer UPanelWidget 目标 Layer（容器控件）
---@param widgetName string Widget 名称
---@param controlName string 控件名称
---@return UWidget|nil 新创建的控件，如果失败则返回 nil
function M.DuplicateWidgetToLayer(targetLayer, widgetName, controlName)
    -- 参数验证
    if not targetLayer then
        Log.Error("UITool", "Failed to duplicate widget to layer: targetLayer is nil")
        return nil
    end
    
    if not widgetName or type(widgetName) ~= "string" or widgetName == "" then
        Log.Error("UITool", "Invalid widgetName")
        return nil
    end
    
    if not controlName or type(controlName) ~= "string" or controlName == "" then
        Log.Error("UITool", "Invalid controlName")
        return nil
    end
    
    -- 获取原始控件
    local originalWidget = M.GetWidget(widgetName, controlName)
    if not originalWidget then
        Log.Error("UITool", string.format("Failed to get original widget: %s.%s", widgetName, controlName))
        return nil
    end
    
    -- 获取原始控件的位置和大小
    local position = M.GetWidgetScreenPosition(originalWidget)
    local size = M.GetWidgetSize(originalWidget)
    
    if not position or not size then
        Log.Error("UITool", string.format("Failed to get widget geometry: %s.%s", widgetName, controlName))
        return nil
    end
    
    -- 复制控件
    local newWidget,duplicatedWidget = M.DuplicateWidgetInSizeBox(originalWidget)
    if not newWidget then
        Log.Error("UITool", string.format("Failed to duplicate widget: %s.%s", widgetName, controlName))
        return nil
    end
    
    -- 将新控件添加到目标 Layer
    targetLayer:AddChild(newWidget)
    
    -- 设置新控件的位置和大小
    if newWidget.Slot then
        newWidget.Slot:SetSize(UE.FVector2D(size.X, size.Y))
        newWidget.Slot:SetPosition(position)
    end
    
    Log.Info("UITool", string.format("Widget duplicated to layer successfully: %s.%s at position (%.2f, %.2f)", 
        widgetName, controlName, position.X, position.Y))
    
    return newWidget,duplicatedWidget
end

local RedDotButtons = {}
---用 Overlay 包裹 Button 的子控件，并在右上角添加红点
---将 Button 的所有子控件移动到 Overlay 中，Overlay 作为 Button 的子控件，并在 Overlay 右上角添加红点
---@param buttonWidget UButton Button 控件
---@param redDotSize number|nil 红点大小（默认为 10）
---@return UOverlay|nil 包裹后的 Overlay，如果失败则返回 nil
function M.AddRedDotToButton(buttonWidget, redDotSize)
    if not buttonWidget then
        Log.Error("UITool", "Failed to wrap button children with red dot: buttonWidget is nil")
        return nil
    end
    
    -- 检查是否已经添加过红点
    if RedDotButtons[buttonWidget] then
        Log.Warning("UITool", "Button already has red dot, skipping")
        return nil
    end
    
    -- 检查是否是容器控件
    if not buttonWidget.GetChildrenCount or not buttonWidget.GetChildAt then
        Log.Error("UITool", "Button widget is not a container widget")
        return nil
    end
    
    -- 设置默认红点大小
    redDotSize = redDotSize or 10
    
    -- 获取 World
    local world = UIManager.GetGameInstance():GetWorld()
    if not world then
        Log.Error("UITool", "Failed to get world")
        return nil
    end
    
    -- 获取 Button 的大小
    local buttonSize = M.GetWidgetSize(buttonWidget)
    if not buttonSize then
        Log.Error("UITool", "Failed to get button size")
        return nil
    end
    
    -- 收集 Button 的子控件（Button 只有一个子控件）
    local child = buttonWidget:GetChildAt(0)
    if not child then
        Log.Error("UITool", "Button has no child")
        return nil
    end
    
    -- 创建 Overlay
	-----@type UOverlay
    local overlay = NewObject(UE.UOverlay, world)
    if not overlay then
        Log.Error("UITool", "Failed to create Overlay")
        return nil
    end
    
    -- 将子控件从 Button 移除，并添加到 Overlay
    child:RemoveFromParent()
    overlay:AddChild(child)
    
    -- 将 Overlay 添加到 Button
    buttonWidget:AddChild(overlay)
	buttonWidget.isHasRedDot = true

	---@type UButtonSlot
	local OverlaySlot = overlay.Slot
	if OverlaySlot then
        OverlaySlot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
        OverlaySlot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Fill)
		OverlaySlot:SetPadding(UE.FMargin(0, 0, 0, 0))
    end
    
    -- 创建红点（使用 Border 控件）
	---@type UImage
    local redDotImage = NewObject(UE.UImage, world)
    if not redDotImage then
        Log.Error("UITool", "Failed to create red dot Border")
        return nil
    end
    
    -- 设置红点样式
    local redBrush = UE.FSlateBrush()
	redBrush.DrawAs = UE.ESlateBrushDrawType.RoundedBox
	--redBrush.ImageSize = UE.FVector2f(10, 10) 有bug 吧 设置无效
	redDotImage:SetBrush(redBrush)
	redDotImage:SetColorAndOpacity(UE.FLinearColor(1.0, 0.0, 0.0, 1.0))
	redDotImage:SetRenderScale(UE.FVector2D(redDotSize/32, redDotSize/32.0))
    -- 将红点添加到 Overlay
    overlay:AddChildToOverlay(redDotImage)
    
	---@type UOverlaySlot
	local DotSlot = redDotImage.Slot
    -- 设置红点位置和大小
    if DotSlot then
		DotSlot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Right)
		DotSlot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Top)
        -- 设置红点在右上角（偏移量为负，使其部分超出边界）
		DotSlot:SetPadding(UE.FMargin(0,-20,-10,0)) -- UnLua有bug 设置无效
    end
    
    -- 标记该 Button 已经添加过红点，记录红点控件和 Overlay
    RedDotButtons[buttonWidget] = {
        overlay = overlay,
        redDotImage = redDotImage,
        child = child
    }
    
    Log.Info("UITool", "Button wrapped with red dot successfully")
    return overlay
end

---从 Button 中删除红点并还原
---使用记录的信息直接删除红点和 Overlay，并还原子控件
---@param buttonWidget UButton Button 控件
---@return boolean 是否成功删除红点
function M.RemoveRedDotFromButton(buttonWidget)
	if not buttonWidget then
		Log.Error("UITool", "Failed to remove red dot from button: buttonWidget is nil")
		return false
	end

	-- 检查是否已经添加过红点
	local redDotInfo = RedDotButtons[buttonWidget]
	if not redDotInfo then
		Log.Warning("UITool", "Button does not have red dot, skipping")
		return false
	end

	local overlay = redDotInfo.overlay
	local redDotImage = redDotInfo.redDotImage
	local child = redDotInfo.child

	-- 验证记录的信息是否有效
	if not overlay then
		Log.Error("UITool", "Overlay not found in red dot info")
		return false
	end

	-- 删除红点
	if redDotImage then
		redDotImage:RemoveFromParent()
	end

	-- 将子控件从 Overlay 移除，并添加回 Button
	if child then
		child:RemoveFromParent()
	end
	-- 删除 Overlay
	overlay:RemoveFromParent()
	if child then
		buttonWidget:AddChild(child)
	end
    
    -- 删除 Overlay
    overlay:RemoveFromParent()
    
    -- 清除标记
    RedDotButtons[buttonWidget] = nil
    buttonWidget.isHasRedDot = nil
    
    Log.Info("UITool", "Red dot removed from button successfully")
    return true
end

return M