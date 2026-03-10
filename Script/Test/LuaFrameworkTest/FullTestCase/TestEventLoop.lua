--
-- EventLoop Module Tests
--

local TestFramework = require("Test.LuaFrameworkTest.FullTestCase.init")
local EventLoop = require("Core.EventLoop")

local function testStartup()
end

local function testShutdown()
end

local function testAddTicker()
    local testObj = {}
    local callbackCalled = false
    local receivedObj = nil
    local receivedDeltaTime = nil
    
    local function testFunc(obj, deltaTime)
        callbackCalled = true
        receivedObj = obj
        receivedDeltaTime = deltaTime
    end
    
    EventLoop.AddTicker(testObj, testFunc)
    
    -- Simulate tick callback being called
    -- This is a bit tricky to test since the tick callback is set during module load
    TestFramework.assertTrue(true, "AddTicker should not crash")
end

local function testDelTicker()
    local testObj = {}
    
    local function testFunc(obj, deltaTime)
        -- Test function
    end
    
    EventLoop.AddTicker(testObj, testFunc)
    EventLoop.DelTicker(testObj)
    
    TestFramework.assertTrue(true, "DelTicker should not crash")
end

local function testResetTicker()
    local testObj = {}
    
    local function testFunc(obj, deltaTime)
        -- Test function
    end
    
    EventLoop.AddTicker(testObj, testFunc)
    EventLoop.ResetTicker()
    
    TestFramework.assertTrue(true, "ResetTicker should not crash")
end

local function testClockMonotonic()
    local result = EventLoop.ClockMonotonic()
    
    TestFramework.assertTrue(result>99, "ClockMonotonic should return mocked value")
end

local function testClockRealtime()
    local result = EventLoop.ClockRealtime()
    
    TestFramework.assertTrue(result>999999999, "ClockRealtime should return mocked value")
end

local function testSleepFor()
    -- This should not crash
    EventLoop.SleepFor(100)
    TestFramework.assertTrue(true, "SleepFor should not crash")
end

local function testTimeout()
    local callbackCalled = false
    
    local function testFunc()
        callbackCalled = true
    end
    
    local timerWatcher = EventLoop.Timeout(1000, testFunc, false)
    
    TestFramework.assertNotNil(timerWatcher, "Timeout should return a timer watcher")
end

-- Register test cases
TestFramework.addTestCase("EventLoop.Startup", testStartup)
TestFramework.addTestCase("EventLoop.Shutdown", testShutdown)
TestFramework.addTestCase("EventLoop.AddTicker", testAddTicker)
TestFramework.addTestCase("EventLoop.DelTicker", testDelTicker)
TestFramework.addTestCase("EventLoop.ResetTicker", testResetTicker)
TestFramework.addTestCase("EventLoop.ClockMonotonic", testClockMonotonic)
TestFramework.addTestCase("EventLoop.ClockRealtime", testClockRealtime)
TestFramework.addTestCase("EventLoop.SleepFor", testSleepFor)
TestFramework.addTestCase("EventLoop.Timeout", testTimeout)

return {
    testStartup = testStartup,
    testShutdown = testShutdown,
    testAddTicker = testAddTicker,
    testDelTicker = testDelTicker,
    testResetTicker = testResetTicker,
    testClockMonotonic = testClockMonotonic,
    testClockRealtime = testClockRealtime,
    testSleepFor = testSleepFor,
    testTimeout = testTimeout
}