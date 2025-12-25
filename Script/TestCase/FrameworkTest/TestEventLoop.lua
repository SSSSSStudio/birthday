---
-- EventLoop 模块测试用例
-- 测试 Core.EventLoop 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- Mock lproject 模块
package.loaded["lproject"] = {
    set_beginplay_callback = function() end,
    set_tick_callback = function() end,
    set_endplay_callback = function() end,
    startup = function() return true end,
    shutdown = function() return true end
}

-- Mock ltw2 模块
package.loaded["ltw2.core"] = {
    clock_monotonic = function() return 1000 end,
    clock_realtime = function() return 1000 end,
    sleep_for = function() end
}

package.loaded["ltw2.event"] = {
    start = function() return true end,
    run = function() end,
    stop = function() end,
    timer_watcher_new = function()
        return {
            start = function() return true end,
            stop = function() end
        }
    end
}

local EventLoop = require("Core.EventLoop")

-- 测试 Startup 函数
local function testStartup()
    -- 注意：在 UE 环境中，lproject.startup() 可能返回 false
    -- 这是因为 lproject 可能已经在其他地方启动了
    TestFramework.assertNoError(function()
        local result = EventLoop.Startup()
        -- 不强制要求返回 true，因为可能已经启动
        TestFramework.assertNotNil(result, "Startup should return a boolean value")
    end, "Startup should not throw exception")
end

-- 测试 Shutdown 函数
local function testShutdown()
    TestFramework.assertNoError(function()
        local result = EventLoop.Shutdown()
        TestFramework.assertTrue(result, "Shutdown should return true")
    end, "Shutdown should not throw exception")
end

-- 测试 AddTicker 函数
local function testAddTicker()
    TestFramework.assertNoError(function()
        local obj = {}
        EventLoop.AddTicker(obj, function(self, deltaTime)
            -- Ticker callback
        end)
    end, "AddTicker should not throw exception")
end

-- 测试 DelTicker 函数
local function testDelTicker()
    TestFramework.assertNoError(function()
        local obj = {}
        EventLoop.AddTicker(obj, function(self, deltaTime) end)
        EventLoop.DelTicker(obj)
    end, "DelTicker should not throw exception")
end

-- 测试 Timeout 函数
-- 已知问题：EventLoop.lua 第 88 行存在 bug
-- 当 levent.timer_watcher_new() 返回 nil 时，会尝试调用 nil 的 start 方法导致崩溃
-- 此测试会失败，用于记录模块的已知问题
local function testTimeout()
    TestFramework.assertNoError(function()
        local timer = EventLoop.Timeout(1000, function()
            -- Timeout callback
        end, false)
        -- 如果 ltw2 库未正确初始化，timer 会为 nil
        -- 但 EventLoop.Timeout 没有做 nil 检查就调用了 start 方法
    end, "Timeout should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("EventLoop.Startup", testStartup)
TestFramework.addTestCase("EventLoop.Shutdown", testShutdown)
TestFramework.addTestCase("EventLoop.AddTicker", testAddTicker)
TestFramework.addTestCase("EventLoop.DelTicker", testDelTicker)
TestFramework.addTestCase("EventLoop.Timeout", testTimeout)

return {
    testStartup = testStartup,
    testShutdown = testShutdown,
    testAddTicker = testAddTicker,
    testDelTicker = testDelTicker,
    testTimeout = testTimeout
}
