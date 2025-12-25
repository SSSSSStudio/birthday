---
-- HistoryManager 模块测试用例
-- 测试 Core.HistoryManager 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- 使用真实的 Interface 模块
local Interface = require("Utility.Interface")

local HistoryManager = require("Core.HistoryManager")

-- 测试初始化
local function testInit()
    TestFramework.assertNoError(function()
        local manager = HistoryManager:New()
        TestFramework.assertNotNil(manager, "HistoryManager should be created")
    end, "HistoryManager creation should not throw exception")
end

-- 测试 AddHistory 函数
local function testAddHistory()
    TestFramework.assertNoError(function()
        local manager = HistoryManager:New()
        
        -- 创建一个历史记录对象
        local history = {
            Undo = function(self)
                -- Undo logic
            end,
            Redo = function(self)
                -- Redo logic
            end
        }
        
        manager:AddHistory(history)
    end, "AddHistory should not throw exception")
end

-- 测试 Undo 函数
local function testUndo()
    TestFramework.assertNoError(function()
        local manager = HistoryManager:New()
        
        local history = {
            Undo = function(self) end,
            Redo = function(self) end
        }
        
        manager:AddHistory(history)
        manager:Undo()
    end, "Undo should not throw exception")
end

-- 测试 Redo 函数
local function testRedo()
    TestFramework.assertNoError(function()
        local manager = HistoryManager:New()
        
        local history = {
            Undo = function(self) end,
            Redo = function(self) end
        }
        
        manager:AddHistory(history)
        manager:Undo()
        manager:Redo()
    end, "Redo should not throw exception")
end

-- 测试 Clear 函数
local function testClear()
    TestFramework.assertNoError(function()
        local manager = HistoryManager:New()
        
        local history = {
            Undo = function(self) end,
            Redo = function(self) end
        }
        
        manager:AddHistory(history)
        manager:Clear()
    end, "Clear should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("HistoryManager.Init", testInit)
TestFramework.addTestCase("HistoryManager.AddHistory", testAddHistory)
TestFramework.addTestCase("HistoryManager.Undo", testUndo)
TestFramework.addTestCase("HistoryManager.Redo", testRedo)
TestFramework.addTestCase("HistoryManager.Clear", testClear)

return {
    testInit = testInit,
    testAddHistory = testAddHistory,
    testUndo = testUndo,
    testRedo = testRedo,
    testClear = testClear
}
