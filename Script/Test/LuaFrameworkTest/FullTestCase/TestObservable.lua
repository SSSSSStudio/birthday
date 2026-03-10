--
-- Observable Module Tests
--

local TestFramework = require("Test.LuaFrameworkTest.FullTestCase.init")
local Observable = require("Core.Observable")

local function testInit()
    local observable = Observable()
    
    TestFramework.assertNotNil(observable, "Observable should be created")
    TestFramework.assertNotNil(observable.container, "Observable should have container")
end

local function testRegister()
    local observable = Observable()
    local testObserver = {}
    
    local function testFunc(observer, arg1, arg2)
        -- Test function
    end
    
    observable:Register("testSignal", testFunc, testObserver)
    
    TestFramework.assertNotNil(observable.container["testSignal"], "Signal should be registered")
    TestFramework.assertEquals(#observable.container["testSignal"], 1, "Container should have one entry")
    
    -- Test registering another function for the same signal
    local function testFunc2(observer, arg1, arg2)
        -- Test function 2
    end
    
    observable:Register("testSignal", testFunc2, testObserver)
    TestFramework.assertEquals(#observable.container["testSignal"], 2, "Container should have two entries")
end

local function testRegisterWithInvalidParams()
    local observable = Observable()
    local testObserver = {}
    
    local function testFunc(observer, arg1, arg2)
        -- Test function
    end
    
    -- Test with nil signal
    local success, errorMsg = pcall(function() observable:Register(nil, testFunc, testObserver) end)
    TestFramework.assertFalse(success, "Register should reject nil signal")
    
    -- Test with non-string signal
    success, errorMsg = pcall(function() observable:Register(123, testFunc, testObserver) end)
    TestFramework.assertFalse(success, "Register should reject non-string signal")
    
    -- Test with nil function
    success, errorMsg = pcall(function() observable:Register("testSignal", nil, testObserver) end)
    TestFramework.assertFalse(success, "Register should reject nil function")
    
    -- Test with non-function
    success, errorMsg = pcall(function() observable:Register("testSignal", "not a function", testObserver) end)
    TestFramework.assertFalse(success, "Register should reject non-function")
end

local function testRegisterWithoutObserver()
    local observable = Observable()
    
    local function testFunc(arg1, arg2)
        -- Test function
    end
    
    observable:Register("testSignal", testFunc)
    
    TestFramework.assertNotNil(observable.container["testSignal"], "Signal should be registered")
    TestFramework.assertEquals(#observable.container["testSignal"], 1, "Container should have one entry")
end

local function testDeregister()
    local observable = Observable()
    local testObserver = {}
    
    local function testFunc(observer, arg1, arg2)
        -- Test function
    end
    
    -- Register first
    observable:Register("testSignal", testFunc, testObserver)
    
    -- Deregister
    observable:Deregister("testSignal", testFunc)
    
    TestFramework.assertEquals(#observable.container["testSignal"], 0, "Container should be empty after deregistering")
    
    -- Try to deregister the same function again (should not crash)
    observable:Deregister("testSignal", testFunc)
    TestFramework.assertTrue(true, "Deregister should not crash when deregistering non-existent function")
end

local function testDeregisterWithInvalidParams()
    local observable = Observable()
    
    -- Test with nil signal
    local success, errorMsg = pcall(function() observable:Deregister(nil, function() end) end)
    TestFramework.assertFalse(success, "Deregister should reject nil signal")
    
    -- Test with non-string signal
    success, errorMsg = pcall(function() observable:Deregister(123, function() end) end)
    TestFramework.assertFalse(success, "Deregister should reject non-string signal")
end

local function testDeregisterAllForSignal()
    local observable = Observable()
    local testObserver = {}
    
    local function testFunc1(observer, arg1, arg2)
        -- Test function 1
    end
    
    local function testFunc2(observer, arg1, arg2)
        -- Test function 2
    end
	
	local function testFunc3(observer, arg1, arg2)
        -- Test function 3
    end
    
    -- Register multiple functions
    observable:Register("testSignal", testFunc1, testObserver)
    observable:Register("testSignal", testFunc2, testObserver)
	observable:Register("testSignal", testFunc3, testObserver)
    
    TestFramework.assertEquals(#observable.container["testSignal"], 3, "Container should have 3 entries")
    
    -- Deregister all functions for signal
    observable:Deregister("testSignal")
    
    TestFramework.assertNil(observable.container["testSignal"], "Signal should be removed from container")
end

local function testNotify()
    local observable = Observable()
    local testObserver = {value = 0}
    local executeCount = 0
    local receivedArgs = {}
    
    local function testFunc(observer, arg1, arg2)
        executeCount = executeCount + 1
        receivedArgs = {observer, arg1, arg2}
        if observer then
            observer.value = observer.value + 1
        end
    end
    
    -- Test notify without any registered functions
    observable:Notify("testSignal", "test1", "test2")
    TestFramework.assertEquals(executeCount, 0, "Function should not be executed when no functions are registered")
    
    -- Register function
    observable:Register("testSignal", testFunc, testObserver)
    
    -- Test notify with registered functions
    observable:Notify("testSignal", "test1", "test2")
    
    TestFramework.assertEquals(executeCount, 1, "Function should be executed once")
    TestFramework.assertEquals(receivedArgs[1], testObserver, "Observer should be passed correctly")
    TestFramework.assertEquals(receivedArgs[2], "test1", "First argument should be correct")
    TestFramework.assertEquals(receivedArgs[3], "test2", "Second argument should be correct")
    TestFramework.assertEquals(testObserver.value, 1, "Observer value should be updated")
end

local function testNotifyWithoutObserver()
    local observable = Observable()
    local executeCount = 0
    local receivedArgs = {}
    
    local function testFunc(arg1, arg2)
        executeCount = executeCount + 1
        receivedArgs = {arg1, arg2}
    end
    
    -- Register function without observer
    observable:Register("testSignal", testFunc)
    
    -- Test notify
    observable:Notify("testSignal", "test1", "test2")
    
    TestFramework.assertEquals(executeCount, 1, "Function should be executed once")
    TestFramework.assertEquals(receivedArgs[1], "test1", "First argument should be correct")
    TestFramework.assertEquals(receivedArgs[2], "test2", "Second argument should be correct")
end

local function testNotifyMultipleFunctions()
    local observable = Observable()
    local testObserver = {}
    local executeCount1 = 0
    local executeCount2 = 0
    
    local function testFunc1(observer, arg1, arg2)
        executeCount1 = executeCount1 + 1
    end
    
    local function testFunc2(observer, arg1, arg2)
        executeCount2 = executeCount2 + 1
    end
    
    -- Register multiple functions
    observable:Register("testSignal", testFunc1, testObserver)
    observable:Register("testSignal", testFunc2, testObserver)
    
    -- Test notify
    observable:Notify("testSignal", "test1", "test2")
    
    TestFramework.assertEquals(executeCount1, 1, "First function should be executed once")
    TestFramework.assertEquals(executeCount2, 1, "Second function should be executed once")
end

local function testNotifyWithInvalidSignal()
    local observable = Observable()
    
    -- Test with nil signal
    local success, errorMsg = pcall(function() observable:Notify(nil, "test1", "test2") end)
    TestFramework.assertFalse(success, "Notify should reject nil signal")
    
    -- Test with non-string signal
    success, errorMsg = pcall(function() observable:Notify(123, "test1", "test2") end)
    TestFramework.assertFalse(success, "Notify should reject non-string signal")
end

-- Register test cases
TestFramework.addTestCase("Observable.Init", testInit)
TestFramework.addTestCase("Observable.Register", testRegister)
TestFramework.addTestCase("Observable.RegisterWithInvalidParams", testRegisterWithInvalidParams)
TestFramework.addTestCase("Observable.RegisterWithoutObserver", testRegisterWithoutObserver)
TestFramework.addTestCase("Observable.Deregister", testDeregister)
TestFramework.addTestCase("Observable.DeregisterWithInvalidParams", testDeregisterWithInvalidParams)
TestFramework.addTestCase("Observable.DeregisterAllForSignal", testDeregisterAllForSignal)
TestFramework.addTestCase("Observable.Notify", testNotify)
TestFramework.addTestCase("Observable.NotifyWithoutObserver", testNotifyWithoutObserver)
TestFramework.addTestCase("Observable.NotifyMultipleFunctions", testNotifyMultipleFunctions)
TestFramework.addTestCase("Observable.NotifyWithInvalidSignal", testNotifyWithInvalidSignal)

return {
    testInit = testInit,
    testRegister = testRegister,
    testRegisterWithInvalidParams = testRegisterWithInvalidParams,
    testRegisterWithoutObserver = testRegisterWithoutObserver,
    testDeregister = testDeregister,
    testDeregisterWithInvalidParams = testDeregisterWithInvalidParams,
    testDeregisterAllForSignal = testDeregisterAllForSignal,
    testNotify = testNotify,
    testNotifyWithoutObserver = testNotifyWithoutObserver,
    testNotifyMultipleFunctions = testNotifyMultipleFunctions,
    testNotifyWithInvalidSignal = testNotifyWithInvalidSignal
}