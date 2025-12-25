--
-- MultiDelegate Module Tests
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

-- Mock the LuaHelper module
package.loaded["Utility.LuaHelper"] = {
    XpCall = function(func, ...)
        return func(...)
    end
}

-- Mock the TableEx module
package.loaded["Utility.TableEx"] = {
    ArrayRemove = function(array, func)
        for i = #array, 1, -1 do
            if func(array[i]) then
                table.remove(array, i)
            end
        end
    end
}

local MultiDelegate = require("Core.MultiDelegate")

local function testInit()
    local multiDelegate = MultiDelegate:New()
    
    TestFramework.assertNotNil(multiDelegate, "MultiDelegate should be created")
    TestFramework.assertNotNil(multiDelegate.listenerSet, "MultiDelegate should have listenerSet")
    TestFramework.assertNotNil(multiDelegate.listenerList, "MultiDelegate should have listenerList")
    TestFramework.assertEquals(#multiDelegate.listenerList, 0, "Listener list should be empty initially")
end

local function testAdd()
    local multiDelegate = MultiDelegate:New()
    
    local function testFunc()
        -- Test function
    end
    
    local result = multiDelegate:Add(testFunc)
    
    TestFramework.assertTrue(result, "Add should return true")
    TestFramework.assertTrue(multiDelegate.listenerSet[testFunc], "Function should be in listenerSet")
    TestFramework.assertEquals(#multiDelegate.listenerList, 1, "Listener list should have one entry")
    
    -- Test adding the same function again (should fail)
    local result2 = multiDelegate:Add(testFunc)
    TestFramework.assertFalse(result2, "Add should return false when adding the same function")
    TestFramework.assertEquals(#multiDelegate.listenerList, 1, "Listener list should still have one entry")
end

local function testAddWithInvalidFunc()
    local multiDelegate = MultiDelegate:New()
    
    -- Test with nil function
    local success, errorMsg = pcall(function() multiDelegate:Add(nil) end)
    TestFramework.assertFalse(success, "Add should reject nil function")
    
    -- Test with non-function
    success, errorMsg = pcall(function() multiDelegate:Add("not a function") end)
    TestFramework.assertFalse(success, "Add should reject non-function")
end

local function testAddObject()
    local multiDelegate = MultiDelegate:New()
    local testObj = {}
    
    local function testMethod()
        -- Test method
    end
    
    local result = multiDelegate:AddObject(testObj, testMethod)
    
    TestFramework.assertTrue(result, "AddObject should return true")
    TestFramework.assertTrue(multiDelegate.listenerSet[testMethod], "Method should be in listenerSet")
    TestFramework.assertEquals(#multiDelegate.listenerList, 1, "Listener list should have one entry")
    
    -- Test adding the same method again (should fail)
    local result2 = multiDelegate:AddObject(testObj, testMethod)
    TestFramework.assertFalse(result2, "AddObject should return false when adding the same method")
    TestFramework.assertEquals(#multiDelegate.listenerList, 1, "Listener list should still have one entry")
end

local function testAddObjectWithInvalidParams()
    local multiDelegate = MultiDelegate:New()
    local testObj = {}
    
    local function testMethod()
        -- Test method
    end
    
    -- Test with nil object
    local success, errorMsg = pcall(function() multiDelegate:AddObject(nil, testMethod) end)
    TestFramework.assertFalse(success, "AddObject should reject nil object")
    
    -- Test with non-table object
    success, errorMsg = pcall(function() multiDelegate:AddObject("not a table", testMethod) end)
    TestFramework.assertFalse(success, "AddObject should reject non-table object")
    
    -- Test with nil method
    success, errorMsg = pcall(function() multiDelegate:AddObject(testObj, nil) end)
    TestFramework.assertFalse(success, "AddObject should reject nil method")
    
    -- Test with non-function method
    success, errorMsg = pcall(function() multiDelegate:AddObject(testObj, "not a function") end)
    TestFramework.assertFalse(success, "AddObject should reject non-function method")
end

local function testRemove()
    local multiDelegate = MultiDelegate:New()
    
    local function testFunc()
        -- Test function
    end
    
    -- Add function first
    multiDelegate:Add(testFunc)
    
    -- Remove function
    local result = multiDelegate:Remove(testFunc)
    
    TestFramework.assertTrue(result, "Remove should return true")
    TestFramework.assertFalse(multiDelegate.listenerSet[testFunc], "Function should not be in listenerSet")
    TestFramework.assertEquals(#multiDelegate.listenerList, 0, "Listener list should be empty")
    
    -- Try to remove the same function again (should fail)
    local result2 = multiDelegate:Remove(testFunc)
    TestFramework.assertFalse(result2, "Remove should return false when removing non-existent function")
end

local function testRemoveWithInvalidFunc()
    local multiDelegate = MultiDelegate:New()
    
    -- Test with nil function
    local success, errorMsg = pcall(function() multiDelegate:Remove(nil) end)
    TestFramework.assertFalse(success, "Remove should reject nil function")
    
    -- Test with non-function
    success, errorMsg = pcall(function() multiDelegate:Remove("not a function") end)
    TestFramework.assertFalse(success, "Remove should reject non-function")
end

local function testRemoveAll()
    local multiDelegate = MultiDelegate:New()
    local testObj = {}
    
    local function testFunc1()
        -- Test function 1
    end
    
    local function testFunc2()
        -- Test function 2
    end
    
    local function testMethod()
        -- Test method
    end
    
    -- Add multiple listeners
    multiDelegate:Add(testFunc1)
    multiDelegate:Add(testFunc2)
    multiDelegate:AddObject(testObj, testMethod)
    
    TestFramework.assertEquals(#multiDelegate.listenerList, 3, "Listener list should have three entries")
    
    -- Remove all
    multiDelegate:RemoveAll()
    
    TestFramework.assertEquals(#multiDelegate.listenerList, 0, "Listener list should be empty after RemoveAll")
    TestFramework.assertEquals(next(multiDelegate.listenerSet), nil, "ListenerSet should be empty after RemoveAll")
end

local function testBroadcast()
    local multiDelegate = MultiDelegate:New()
    local executeCount = 0
    local receivedArgs = {}
    
    local function testFunc(arg1, arg2)
        executeCount = executeCount + 1
        receivedArgs = {arg1, arg2}
    end
    
    -- Test broadcast with no listeners
    local result = multiDelegate:Broadcast("test1", "test2")
    TestFramework.assertFalse(result, "Broadcast should return false when no listeners")
    
    -- Add listener
    multiDelegate:Add(testFunc)
    
    -- Test broadcast with listeners
    local result2 = multiDelegate:Broadcast("test1", "test2")
    TestFramework.assertTrue(result2, "Broadcast should return true when there are listeners")
    TestFramework.assertEquals(executeCount, 1, "Function should be executed once")
    TestFramework.assertEquals(receivedArgs[1], "test1", "First argument should be correct")
    TestFramework.assertEquals(receivedArgs[2], "test2", "Second argument should be correct")
end

local function testBroadcastWithObject()
    local multiDelegate = MultiDelegate:New()
    local testObj = {value = 0}
    local executeCount = 0
    local receivedArgs = {}
    
    local function testMethod(obj, arg1, arg2)
        executeCount = executeCount + 1
        receivedArgs = {obj, arg1, arg2}
        obj.value = obj.value + 1
    end
    
    -- Add object listener
    multiDelegate:AddObject(testObj, testMethod)
    
    -- Test broadcast
    local result = multiDelegate:Broadcast("test1", "test2")
    TestFramework.assertTrue(result, "Broadcast should return true when there are listeners")
    TestFramework.assertEquals(executeCount, 1, "Method should be executed once")
    TestFramework.assertEquals(receivedArgs[1], testObj, "Object should be passed correctly")
    TestFramework.assertEquals(receivedArgs[2], "test1", "First argument should be correct")
    TestFramework.assertEquals(receivedArgs[3], "test2", "Second argument should be correct")
    TestFramework.assertEquals(testObj.value, 1, "Object value should be updated")
end

local function testBroadcastMultipleListeners()
    local multiDelegate = MultiDelegate:New()
    local executeCount1 = 0
    local executeCount2 = 0
    
    local function testFunc1()
        executeCount1 = executeCount1 + 1
    end
    
    local function testFunc2()
        executeCount2 = executeCount2 + 1
    end
    
    -- Add multiple listeners
    multiDelegate:Add(testFunc1)
    multiDelegate:Add(testFunc2)
    
    -- Test broadcast
    local result = multiDelegate:Broadcast()
    TestFramework.assertTrue(result, "Broadcast should return true when there are listeners")
    TestFramework.assertEquals(executeCount1, 1, "First function should be executed once")
    TestFramework.assertEquals(executeCount2, 1, "Second function should be executed once")
end

-- Register test cases
TestFramework.addTestCase("MultiDelegate.Init", testInit)
TestFramework.addTestCase("MultiDelegate.Add", testAdd)
TestFramework.addTestCase("MultiDelegate.AddWithInvalidFunc", testAddWithInvalidFunc)
TestFramework.addTestCase("MultiDelegate.AddObject", testAddObject)
TestFramework.addTestCase("MultiDelegate.AddObjectWithInvalidParams", testAddObjectWithInvalidParams)
TestFramework.addTestCase("MultiDelegate.Remove", testRemove)
TestFramework.addTestCase("MultiDelegate.RemoveWithInvalidFunc", testRemoveWithInvalidFunc)
TestFramework.addTestCase("MultiDelegate.RemoveAll", testRemoveAll)
TestFramework.addTestCase("MultiDelegate.Broadcast", testBroadcast)
TestFramework.addTestCase("MultiDelegate.BroadcastWithObject", testBroadcastWithObject)
TestFramework.addTestCase("MultiDelegate.BroadcastMultipleListeners", testBroadcastMultipleListeners)

return {
    testInit = testInit,
    testAdd = testAdd,
    testAddWithInvalidFunc = testAddWithInvalidFunc,
    testAddObject = testAddObject,
    testAddObjectWithInvalidParams = testAddObjectWithInvalidParams,
    testRemove = testRemove,
    testRemoveWithInvalidFunc = testRemoveWithInvalidFunc,
    testRemoveAll = testRemoveAll,
    testBroadcast = testBroadcast,
    testBroadcastWithObject = testBroadcastWithObject,
    testBroadcastMultipleListeners = testBroadcastMultipleListeners
}