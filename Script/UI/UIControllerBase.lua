
local LuaHelper = require("Utility.LuaHelper")

---@class UIControllerBase
local M = LuaHelper.LuaClass()

--- 创建控制器实例
function M:__OnNew(name, view, model)
	assert(view, "view must be not nil")
	self.name = name
	self.view = view
	self.bIsVisible = true
	self:OnInitModel(model)
end

function M:OnInitModel(model)
	self.model = model
end

function M:__OnGC()
	self:Destroy()
end

function M:Destroy()
	if self.view then
		self.view:RemoveFromParent()
		self.view = nil
	end
	if self.model then
		self.model:RemoveObserverEvent(self)
		self.model = nil
	end
	self.bIsVisible = false
end

function M:GetName()
    return self.name
end



function M:Show()
    if self.bIsVisible then
        return
    end
	self.bIsVisible = true
	self.view:SetVisible(self.bIsVisible)
end

function M:Hide()
    if not self.bIsVisible then
        return
    end
    self.bIsVisible = false
	self.view:SetVisible(self.bIsVisible)
end

return M