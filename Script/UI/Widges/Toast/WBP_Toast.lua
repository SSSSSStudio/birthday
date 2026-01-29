--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class WBP_Toast_C : UIViewBase
local M = UnLua.Class("UI.UIViewBase")

function M:Construct()
	self.Super.Construct(self)
	if self.Anim_In then
		self:PlayAnimation(self.Anim_In)
	end
end

function M:SetContent(content)
	if self.TextBlock_Content then
		if content then
			self.TextBlock_Content:SetText(content)
		else
			self.TextBlock_Content:SetText("")
		end
	end
end

function M:UpdateToastPosition(positionY)
	if not self.Anim_In then
        return
    end

	self:ForceLayoutPrepass()
	if self.Slot:IsA(UE.UCanvasPanelSlot) then
		self.Slot:SetPosition(UE.FVector2D(0, positionY))
	elseif self.Slot:IsA(UE.UOverlaySlot) then
		local margin = UE.FMargin()
		margin.Top = positionY
		self.Slot:SetPadding(margin)
		self.Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Top)
		self.Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Center)
	end

	local height = self:GetDesiredSize().Y
	if height <= 0 then
		height = self.Slot:GetSize().Y
	end
	return height
end

return M
