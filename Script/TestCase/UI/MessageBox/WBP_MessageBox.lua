-- WBP_MessageBox.lua
-- MessageBox View 层

---@type WBP_MessageBox_C
local M = UnLua.Class()

function M:Construct()
    -- 绑定按钮事件
    self.Button_Close.OnClicked:Add(self, self.OnButtonCloseClick)
    self.Button_Confirm.OnClicked:Add(self, self.OnButtonConfirmClick)
    self.Button_Cancel.OnClicked:Add(self, self.OnButtonCancelClick)
end

---关闭按钮点击事件
function M:OnButtonCloseClick()
    if self.Controller and self.Controller.cancelCallback then
        self.Controller.cancelCallback()
    end
end

---确认按钮点击事件
function M:OnButtonConfirmClick()
    if self.Controller and self.Controller.confirmCallback then
        self.Controller.confirmCallback()
    end
end

---取消按钮点击事件
function M:OnButtonCancelClick()
    if self.Controller and self.Controller.cancelCallback then
        self.Controller.cancelCallback()
    end
end

return M
