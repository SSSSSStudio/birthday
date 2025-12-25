--
-- HistoryManager Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- Mock the Interface module
package.loaded["Utility.Interface"] = function(name)
    local class = {}
    class.__index = class
    
    function class.New(self, ...)
        local instance = setmetatable({}, self)
        if instance.__init then
            instance:__init(...)
        end
        return instance
    end
    
    return class
end

local HistoryManager = require("Core.HistoryManager")

local function testInit()
    local historyManager = HistoryManager:New()
    
    TestFramework.assertNotNil(historyManager, "HistoryManager should be created")
    TestFramework.assertNotNil(historyManager.undoStack, "HistoryManager should have undoStack")
    TestFramework.assertNotNil(historyManager.redoStack, "HistoryManager should have redoStack")
    TestFramework.assertEquals(historyManager.maxStep, 256, "HistoryManager should have default maxStep of 256")
    
    -- Test with custom maxStep
    local historyManager2 = HistoryManager:New(100)
    TestFramework.assertEquals(historyManager2.maxStep, 100, "HistoryManager should accept custom maxStep")
end

local function testAddHistory()
    local historyManager = HistoryManager:New()
    
    local testHistory = {
        Undo = function(self)
            -- Undo implementation
        end,
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    historyManager:AddHistory(testHistory)
    
    TestFramework.assertEquals(#historyManager.undoStack, 1, "Undo stack should have one entry")
    TestFramework.assertEquals(#historyManager.redoStack, 0, "Redo stack should be empty")
    
    -- Test adding another history
    local testHistory2 = {
        Undo = function(self)
            -- Undo implementation
        end,
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    historyManager:AddHistory(testHistory2)
    TestFramework.assertEquals(#historyManager.undoStack, 2, "Undo stack should have two entries")
    
    -- Test redo stack is cleared after adding new history
    historyManager:Undo()
    TestFramework.assertEquals(#historyManager.redoStack, 1, "Redo stack should have one entry after undo")
    
    local testHistory3 = {
        Undo = function(self)
            -- Undo implementation
        end,
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    historyManager:AddHistory(testHistory3)
    TestFramework.assertEquals(#historyManager.redoStack, 0, "Redo stack should be cleared after adding new history")
end

local function testAddHistoryWithInvalidParams()
    local historyManager = HistoryManager:New()
    
    -- Test with nil history
    local success, errorMsg = pcall(function() historyManager:AddHistory(nil) end)
    TestFramework.assertFalse(success, "AddHistory should reject nil history")
    
    -- Test with history missing Undo method
    local invalidHistory1 = {
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    success, errorMsg = pcall(function() historyManager:AddHistory(invalidHistory1) end)
    TestFramework.assertFalse(success, "AddHistory should reject history without Undo method")
    
    -- Test with history missing Redo method
    local invalidHistory2 = {
        Undo = function(self)
            -- Undo implementation
        end
    }
    
    success, errorMsg = pcall(function() historyManager:AddHistory(invalidHistory2) end)
    TestFramework.assertFalse(success, "AddHistory should reject history without Redo method")
end

local function testAddHistoryWithMaxStepLimit()
    local historyManager = HistoryManager:New(3)
    
    for i = 1, 5 do
        local testHistory = {
            Undo = function(self)
                -- Undo implementation
            end,
            Redo = function(self)
                -- Redo implementation
            end
        }
        historyManager:AddHistory(testHistory)
    end
    
    TestFramework.assertEquals(#historyManager.undoStack, 3, "Undo stack should not exceed maxStep")
end

local function testUndo()
    local historyManager = HistoryManager:New()
    local undoCalled = false
    local redoCalled = false
    
    local testHistory = {
        Undo = function(self)
            undoCalled = true
        end,
        Redo = function(self)
            redoCalled = true
        end
    }
    
    historyManager:AddHistory(testHistory)
    
    -- Test undo
    historyManager:Undo()
    
    TestFramework.assertTrue(undoCalled, "Undo method should be called")
    TestFramework.assertFalse(redoCalled, "Redo method should not be called")
    TestFramework.assertEquals(#historyManager.undoStack, 0, "Undo stack should be empty after undo")
    TestFramework.assertEquals(#historyManager.redoStack, 1, "Redo stack should have one entry after undo")
    
    -- Test undo when no history available
    historyManager:Undo()
    TestFramework.assertEquals(#historyManager.undoStack, 0, "Undo stack should remain empty when no history available")
end

local function testRedo()
    local historyManager = HistoryManager:New()
    local undoCalled = 0
    local redoCalled = 0
    
    local testHistory = {
        Undo = function(self)
            undoCalled = undoCalled + 1
        end,
        Redo = function(self)
            redoCalled = redoCalled + 1
        end
    }
    
    historyManager:AddHistory(testHistory)
    historyManager:Undo()
    
    TestFramework.assertEquals(undoCalled, 1, "Undo method should be called once")
    TestFramework.assertEquals(redoCalled, 0, "Redo method should not be called yet")
    TestFramework.assertEquals(#historyManager.undoStack, 0, "Undo stack should be empty after undo")
    TestFramework.assertEquals(#historyManager.redoStack, 1, "Redo stack should have one entry after undo")
    
    -- Test redo
    historyManager:Redo()
    
    TestFramework.assertEquals(undoCalled, 1, "Undo method should still be called once")
    TestFramework.assertEquals(redoCalled, 1, "Redo method should be called once")
    TestFramework.assertEquals(#historyManager.undoStack, 1, "Undo stack should have one entry after redo")
    TestFramework.assertEquals(#historyManager.redoStack, 0, "Redo stack should be empty after redo")
    
    -- Test redo when no history available
    historyManager:Redo()
    TestFramework.assertEquals(#historyManager.redoStack, 0, "Redo stack should remain empty when no history available")
end

local function testClear()
    local historyManager = HistoryManager:New()
    
    local testHistory = {
        Undo = function(self)
            -- Undo implementation
        end,
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    historyManager:AddHistory(testHistory)
    historyManager:Undo()
    
    TestFramework.assertEquals(#historyManager.undoStack, 0, "Undo stack should have one entry before clear")
    TestFramework.assertEquals(#historyManager.redoStack, 1, "Redo stack should have one entry before clear")
    
    -- Test clear
    historyManager:Clear()
    
    TestFramework.assertEquals(#historyManager.undoStack, 0, "Undo stack should be empty after clear")
    TestFramework.assertEquals(#historyManager.redoStack, 0, "Redo stack should be empty after clear")
end

local function testIsCanUndo()
    local historyManager = HistoryManager:New()
    
    -- Test when no history
    local result = historyManager:IsCanUndo()
    TestFramework.assertFalse(result, "IsCanUndo should return false when no history")
    
    -- Add history
    local testHistory = {
        Undo = function(self)
            -- Undo implementation
        end,
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    historyManager:AddHistory(testHistory)
    
    -- Test when history available
    local result2 = historyManager:IsCanUndo()
    TestFramework.assertTrue(result2, "IsCanUndo should return true when history available")
    
    -- Undo and test again
    historyManager:Undo()
    local result3 = historyManager:IsCanUndo()
    TestFramework.assertFalse(result3, "IsCanUndo should return false after undo")
end

local function testIsCanRedo()
    local historyManager = HistoryManager:New()
    
    -- Test when no history
    local result = historyManager:IsCanRedo()
    TestFramework.assertFalse(result, "IsCanRedo should return false when no history")
    
    -- Add history and undo
    local testHistory = {
        Undo = function(self)
            -- Undo implementation
        end,
        Redo = function(self)
            -- Redo implementation
        end
    }
    
    historyManager:AddHistory(testHistory)
    historyManager:Undo()
    
    -- Test when redo history available
    local result2 = historyManager:IsCanRedo()
    TestFramework.assertTrue(result2, "IsCanRedo should return true when redo history available")
    
    -- Redo and test again
    historyManager:Redo()
    local result3 = historyManager:IsCanRedo()
    TestFramework.assertFalse(result3, "IsCanRedo should return false after redo")
end

-- Register test cases
TestFramework.addTestCase("HistoryManager.Init", testInit)
TestFramework.addTestCase("HistoryManager.AddHistory", testAddHistory)
TestFramework.addTestCase("HistoryManager.AddHistoryWithInvalidParams", testAddHistoryWithInvalidParams)
TestFramework.addTestCase("HistoryManager.AddHistoryWithMaxStepLimit", testAddHistoryWithMaxStepLimit)
TestFramework.addTestCase("HistoryManager.Undo", testUndo)
TestFramework.addTestCase("HistoryManager.Redo", testRedo)
TestFramework.addTestCase("HistoryManager.Clear", testClear)
TestFramework.addTestCase("HistoryManager.IsCanUndo", testIsCanUndo)
TestFramework.addTestCase("HistoryManager.IsCanRedo", testIsCanRedo)

return {
    testInit = testInit,
    testAddHistory = testAddHistory,
    testAddHistoryWithInvalidParams = testAddHistoryWithInvalidParams,
    testAddHistoryWithMaxStepLimit = testAddHistoryWithMaxStepLimit,
    testUndo = testUndo,
    testRedo = testRedo,
    testClear = testClear,
    testIsCanUndo = testIsCanUndo,
    testIsCanRedo = testIsCanRedo
}