---
-- EventDispatcher 模块测试用例
-- 测试 Core.EventDispatcher 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")
local EventDispatcher = require("Core.EventDispatcher")

-- 测试 AddEvent 函数
local function testAddEvent()
    local count = 0
    
    local function handler(data)
        count = count + data.value
    end
    
    TestFramework.assertNoError(function()
        EventDispatcher.AddEvent("test_event", handler)
    end, "AddEvent should not throw exception")
end

-- 测试 RemoveEvent 函数
local function testRemoveEvent()
    local function handler(data)
        return data
    end
    
    TestFramework.assertNoError(function()
        EventDispatcher.AddEvent("test_event_remove", handler)
        EventDispatcher.RemoveEvent("test_event_remove", handler)
    end, "RemoveEvent should not throw exception")
end

-- 测试 Dispatch 函数
local function testDispatch()
    local result = 0
    
    local function handler(data)
        result = data.value * 2
    end
    
    EventDispatcher.AddEvent("test_dispatch", handler)
    EventDispatcher.Dispatch("test_dispatch", {value = 25})
    
    TestFramework.assertEquals(result, 50, "Dispatch should trigger handler")
    
    -- 清理
    EventDispatcher.RemoveEvent("test_dispatch", handler)
end

-- 测试多个监听器
local function testMultipleListeners()
    local sum = 0
    
    local function handler1(data)
        sum = sum + data.value
    end
    
    local function handler2(data)
        sum = sum + data.value * 2
    end
    
    EventDispatcher.AddEvent("test_multiple", handler1)
    EventDispatcher.AddEvent("test_multiple", handler2)
    EventDispatcher.Dispatch("test_multiple", {value = 10})
    
    TestFramework.assertEquals(sum, 30, "Multiple listeners should all be called")
    
    -- 清理
    EventDispatcher.RemoveEvent("test_multiple")
end

-- 测试 RemoveEvent 清除所有监听器
local function testRemoveAllListeners()
    local count = 0
    
    local function handler1(data)
        count = count + 1
    end
    
    local function handler2(data)
        count = count + 1
    end
    
    EventDispatcher.AddEvent("test_clear_all", handler1)
    EventDispatcher.AddEvent("test_clear_all", handler2)
    
    -- 不传 func 参数，清除所有监听器
    EventDispatcher.RemoveEvent("test_clear_all")
    
    -- 分发事件，不应该触发任何处理器
    EventDispatcher.Dispatch("test_clear_all", {})
    
    TestFramework.assertEquals(count, 0, "RemoveEvent without func should clear all listeners")
end

-- 注册测试用例
TestFramework.addTestCase("EventDispatcher.AddEvent", testAddEvent)
TestFramework.addTestCase("EventDispatcher.RemoveEvent", testRemoveEvent)
TestFramework.addTestCase("EventDispatcher.Dispatch", testDispatch)
TestFramework.addTestCase("EventDispatcher.MultipleListeners", testMultipleListeners)
TestFramework.addTestCase("EventDispatcher.RemoveAllListeners", testRemoveAllListeners)

return {
    testAddEvent = testAddEvent,
    testRemoveEvent = testRemoveEvent,
    testDispatch = testDispatch,
    testMultipleListeners = testMultipleListeners,
    testRemoveAllListeners = testRemoveAllListeners
}
