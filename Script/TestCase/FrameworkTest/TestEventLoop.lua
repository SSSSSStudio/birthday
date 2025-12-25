---
-- EventLoop 模块测试用例
-- 测试 Core.EventLoop 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- 在 UE 环境下，直接使用真实的 lproject 和 ltw2 模块
-- 这些模块由 LuaExtension 插件提供，无需 mock

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
-- 预期：Timeout 应该返回一个有效的 timer 对象，或在失败时返回 nil
-- 实际：EventLoop.lua 第 88 行存在 bug，当 levent.timer_watcher_new() 返回 nil 时
--       会尝试调用 nil:start() 导致崩溃
local function testTimeout()
    local timer = EventLoop.Timeout(1000, function()
        -- Timeout callback
    end, false)
    
    -- 期望：timer 应该是一个有效对象或 nil（如果创建失败）
    -- 不应该抛出异常
    TestFramework.assertNotNil(timer, "Timeout should return a valid timer object")
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
