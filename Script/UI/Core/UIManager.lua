-- UIManager.lua
-- UI 管理器，负责管理整个 UI 系统

local UILayerManager = require "UI.Core.Private.UILayerManager"
local UIStateManager = require "UI.Core.Private.UIStateManager"

---@class UIManager
local M = {
	isInitialized = false,
	gameInstance = nil
}

function M.Initialize(gameInst)
	M.gameInstance = gameInst
    if M.isInitialized then
        return
    end
    
    -- 初始化 UILayerManager
    UILayerManager:Initialize(M.gameInstance)
    M.isInitialized = true
end

--- 打开状态 UI（State 层级的 UI）
--- @param uiName string UI 名称
--- @param params table|nil 传递给 UI 的参数（可选）
--- @param isCache boolean|nil 是否使用 LRU 缓存（默认为 true）
--- @return UIControllerBase|nil 控制器实例
function M.StateOpen(uiName, params, isCache)
    return UIStateManager:OpenUI(uiName, params, isCache)
end

--- 关闭状态 UI（State 层级的 UI）
function M.StateClose()
    UIStateManager:CloseCurrentUIAndReopen()
end

--- 清空状态 UI 缓存
function M.StateCacheClear()
    UIStateManager:ClearCache()
end

-- 销毁 UI 管理器
function M.Destroy()
    if UILayerManager then
        UILayerManager:Destroy()
        UILayerManager = nil
    end

	M.isInitialized = false
end

return M