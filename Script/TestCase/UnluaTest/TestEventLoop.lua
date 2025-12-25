--
-- EventLoop Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- Mock the lproject module
local mockLproject = {
    startup = function()
        return true
    end,
    shutdown = function()
        return true
    end,
    set_beginplay_callback = function(callback)
        -- Mock implementation
    end,
    set_tick_callback = function(callback)
        -- Mock implementation
    end,
    set_endplay_callback = function(callback)
        -- Mock implementation
    end,
    start = function()
        return true
    end
}

package.loaded["lproject"] = mockLproject

-- Mock the ltw2.core module
local mockLtw2Core = {
    clock_monotonic = function()
        return 1000
    end,
    clock_realtime = function()
        return 2000
    end,
    sleep_for = function(duration)
        -- Mock implementation
    end
}

package.loaded["ltw2.core"] = mockLtw2Core

-- Mock the ltw2.event module
local mockTimerWatcher = {
    start = function(self, intervalMs, bOnce, func)
        self.intervalMs = intervalMs
        self.bOnce = bOnce
        self.func = func
        return true
    end
}

local mockLtw2Event = {
    start = function(flag)
        return true
    end,
    stop = function()
        -- Mock implementation
    end,
    run = function()
        -- Mock implementation
    end,
    timer_watcher_new = function()
        return mockTimerWatcher
    end
}

package.loaded["ltw2.event"] = mockLtw2Event

-- Mock the LuaHelper module
package.loaded["Utility.luaHelper"] = {
    XpCall = function(func, ...)
        return func(...)
    end
}

local EventLoop = require("Core.EventLoop")

local function testStartup()
    local result = EventLoop.Startup()
    
    TestFramework.assertTrue(result, "Startup should return true")
end

local function testShutdown()
    local result = EventLoop.Shutdown()
    
    TestFramework.assertTrue(result, "Shutdown should return true")
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
    
    TestFramework.assertEquals(result, 1000, "ClockMonotonic should return mocked value")
end

local function testClockRealtime()
    local result = EventLoop.ClockRealtime()
    
    TestFramework.assertEquals(result, 2000, "ClockRealtime should return mocked value")
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
    TestFramework.assertEquals(timerWatcher, mockTimerWatcher, "Timeout should return the mock timer watcher")
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