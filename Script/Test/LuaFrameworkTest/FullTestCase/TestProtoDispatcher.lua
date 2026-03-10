--
-- ProtoDispatcher Module Tests
--

local TestFramework = require("Test.LuaFrameworkTest.FullTestCase.init")
local ProtoDispatcher = require("Core.ProtoDispatcher")

local function testInit()
    -- This should not crash
    ProtoDispatcher.Init("test/path")
    TestFramework.assertTrue(true, "Init should not crash")
end

local function testCleanup()
    -- This should not crash
    ProtoDispatcher.Cleanup()
    TestFramework.assertTrue(true, "Cleanup should not crash")
end

local function testImportProtoFile()
    -- Test with empty file list
    ProtoDispatcher.ImportProtoFile({})
    TestFramework.assertTrue(true, "ImportProtoFile should not crash with empty list")
    
    -- Test with invalid input
    local success, errorMsg = pcall(function() ProtoDispatcher.ImportProtoFile(nil) end)
    TestFramework.assertFalse(success, "ImportProtoFile should reject nil file list")
end

local function testAddDispatch()
    local testTarget = {}
    
    local function testFunc(target, arg1, arg2)
        -- Test function
    end
    
    ProtoDispatcher.AddDispatch("TestType", testTarget, testFunc)
    
    TestFramework.assertTrue(true, "AddDispatch should not crash")
    
    -- Test adding another function for the same type
    local function testFunc2(target, arg1, arg2)
        -- Test function 2
    end
    
    ProtoDispatcher.AddDispatch("TestType", testTarget, testFunc2)
    TestFramework.assertTrue(true, "AddDispatch should not crash when adding another function for same type")
end

local function testUnDispatch()
    local testTarget = {}
    
    local function testFunc(target, arg1, arg2)
        -- Test function
    end
    
    -- Add dispatch first
    ProtoDispatcher.AddDispatch("TestType", testTarget, testFunc)
    
    -- UnDispatch
    ProtoDispatcher.UnDispatch("TestType")
    
    TestFramework.assertTrue(true, "UnDispatch should not crash")
end

local function testRemoveDispatch()
    local testTarget1 = {}
    local testTarget2 = {}
    
    local function testFunc1(target, arg1, arg2)
        -- Test function 1
    end
    
    local function testFunc2(target, arg1, arg2)
        -- Test function 2
    end
    
    -- Add dispatches first
    ProtoDispatcher.AddDispatch("TestType", testTarget1, testFunc1)
    ProtoDispatcher.AddDispatch("TestType", testTarget2, testFunc2)
    
    -- Remove one dispatch
    ProtoDispatcher.RemoveDispatch("TestType", testTarget1)
    
    TestFramework.assertTrue(true, "RemoveDispatch should not crash")
end

local function testDispatchMessage()
    local testTarget = {value = 0}
    local executeCount = 0
    local receivedArgs = {}
    
    local function testFunc(target, arg1, arg2)
        executeCount = executeCount + 1
        receivedArgs = {target, arg1, arg2}
        if target then
            target.value = target.value + 1
        end
    end
    
    -- Test dispatch without any registered functions
    ProtoDispatcher.DispatchMessage("TestType", "test1", "test2")
    TestFramework.assertEquals(executeCount, 0, "Function should not be executed when no functions are registered")
    
    -- Add dispatch
    ProtoDispatcher.AddDispatch("TestType", testTarget, testFunc)
    
    -- Test dispatch with registered functions
    ProtoDispatcher.DispatchMessage("TestType", "test1", "test2")
    
    TestFramework.assertEquals(executeCount, 1, "Function should be executed once")
    TestFramework.assertEquals(receivedArgs[1], testTarget, "Target should be passed correctly")
    TestFramework.assertEquals(receivedArgs[2], "test1", "First argument should be correct")
    TestFramework.assertEquals(receivedArgs[3], "test2", "Second argument should be correct")
    TestFramework.assertEquals(testTarget.value, 1, "Target value should be updated")
end

local function testDispatchMessageMultipleTargets()
    local testTarget1 = {value = 0}
    local testTarget2 = {value = 0}
    local executeCount1 = 0
    local executeCount2 = 0
    
    local function testFunc1(target, arg1, arg2)
        executeCount1 = executeCount1 + 1
        target.value = target.value + 1
    end
    
    local function testFunc2(target, arg1, arg2)
        executeCount2 = executeCount2 + 1
        target.value = target.value + 1
    end
    
    -- Add multiple dispatches
    ProtoDispatcher.AddDispatch("TestType", testTarget1, testFunc1)
    ProtoDispatcher.AddDispatch("TestType", testTarget2, testFunc2)
    
    -- Test dispatch
    ProtoDispatcher.DispatchMessage("TestType", "test1", "test2")
    
    TestFramework.assertEquals(executeCount1, 1, "First function should be executed once")
    TestFramework.assertEquals(executeCount2, 1, "Second function should be executed once")
    TestFramework.assertEquals(testTarget1.value, 1, "First target value should be updated")
    TestFramework.assertEquals(testTarget2.value, 1, "Second target value should be updated")
end

-- Register test cases
TestFramework.addTestCase("ProtoDispatcher.Init", testInit)
TestFramework.addTestCase("ProtoDispatcher.Cleanup", testCleanup)
TestFramework.addTestCase("ProtoDispatcher.ImportProtoFile", testImportProtoFile)
TestFramework.addTestCase("ProtoDispatcher.AddDispatch", testAddDispatch)
TestFramework.addTestCase("ProtoDispatcher.UnDispatch", testUnDispatch)
TestFramework.addTestCase("ProtoDispatcher.RemoveDispatch", testRemoveDispatch)
TestFramework.addTestCase("ProtoDispatcher.DispatchMessage", testDispatchMessage)
TestFramework.addTestCase("ProtoDispatcher.DispatchMessageMultipleTargets", testDispatchMessageMultipleTargets)

return {
    testInit = testInit,
    testCleanup = testCleanup,
    testImportProtoFile = testImportProtoFile,
    testAddDispatch = testAddDispatch,
    testUnDispatch = testUnDispatch,
    testRemoveDispatch = testRemoveDispatch,
    testDispatchMessage = testDispatchMessage,
    testDispatchMessageMultipleTargets = testDispatchMessageMultipleTargets
}