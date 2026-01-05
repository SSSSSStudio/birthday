-- UIManager.lua
-- UI 管理器，负责管理整个 UI 系统

local UILayerManager = require "Script.UI.Core.UILayerManager"
local UIStateManager = require "Script.UI.Core.Private.UIStateManager"

---@class UIManager
local M = {
	isInitialized = false
}

--private
local function Initialize()
    if M.isInitialized then
        return
    end
    
    -- 初始化 UILayerManager
    UILayerManager:Initialize()
    M.isInitialized = true
end

function M.Get()
	Initialize()
	return M
end

--- 打开状态 UI（State 层级的 UI）
--- @param uiName string UI 名称
--- @param params table|nil 传递给 UI 的参数（可选）
--- @return UIControllerBase|nil 控制器实例
function M:StateOpen(uiName, params)
    return UIStateManager:OpenUI(uiName, params)
end

--- 关闭状态 UI（State 层级的 UI）
--- @param uiName string UI 名称
function M:StateClose(uiName)
    UIStateManager:CloseUI(uiName)
end

--- 清空状态 UI 缓存
function M:StateCacheClear()
    UIStateManager:ClearCache()
end

-- 销毁 UI 管理器
function M:Destroy()
    if UILayerManager then
        UILayerManager:Destroy()
        UILayerManager = nil
    end
    
    self.isInitialized = false
end

return M