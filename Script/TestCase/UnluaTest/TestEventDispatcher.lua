--
-- EventDispatcher Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
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

-- 测试事件处理器中抛出错误
local function testDispatchWithError()
    local count = 0
    
    local function handler1(data)
        count = count + 1
    end
    
    local function handler2(data)
        error("test error in handler")
    end
    
    local function handler3(data)
        count = count + 1
    end
    
    EventDispatcher.AddEvent("test_error", handler1)
    EventDispatcher.AddEvent("test_error", handler2)
    EventDispatcher.AddEvent("test_error", handler3)
    
    -- 分发事件应该捕获错误并继续执行其他处理器
    TestFramework.assertNoError(function()
        EventDispatcher.Dispatch("test_error", {})
    end, "Dispatch should handle errors in handlers")
    
    -- handler1 和 handler3 应该都被调用
    TestFramework.assertEquals(count, 2, "Other handlers should still be called after error")
    
    -- 清理
    EventDispatcher.RemoveEvent("test_error")
end

-- 测试不存在的事件分发
local function testDispatchNonExistent()
    -- 分发不存在的事件不应该抛出错误
    TestFramework.assertNoError(function()
        EventDispatcher.Dispatch("non_existent_event", {})
    end, "Dispatch non-existent event should not throw error")
end

-- 测试移除不存在的监听器
local function testRemoveNonExistent()
    local function handler(data)
        return data
    end
    
    -- 移除不存在的监听器不应该抛出错误
    TestFramework.assertNoError(function()
        EventDispatcher.RemoveEvent("non_existent_event", handler)
    end, "Remove non-existent listener should not throw error")
end

-- 测试参数验证
local function testParameterValidation()
    -- 测试 AddEvent 参数验证
    TestFramework.assertError(function()
        EventDispatcher.AddEvent(nil, function() end)
    end, "AddEvent should throw error for nil event name")
    
    TestFramework.assertError(function()
        EventDispatcher.AddEvent(123, function() end)
    end, "AddEvent should throw error for non-string event name")
    
    TestFramework.assertError(function()
        EventDispatcher.AddEvent("test", nil)
    end, "AddEvent should throw error for nil function")
    
    TestFramework.assertError(function()
        EventDispatcher.AddEvent("test", "not a function")
    end, "AddEvent should throw error for non-function")
    
    -- 测试 RemoveEvent 参数验证
    TestFramework.assertError(function()
        EventDispatcher.RemoveEvent(nil)
    end, "RemoveEvent should throw error for nil event name")
    
    TestFramework.assertError(function()
        EventDispatcher.RemoveEvent(123)
    end, "RemoveEvent should throw error for non-string event name")
    
    -- 测试 Dispatch 参数验证
    TestFramework.assertError(function()
        EventDispatcher.Dispatch(nil)
    end, "Dispatch should throw error for nil event name")
    
    TestFramework.assertError(function()
        EventDispatcher.Dispatch(123)
    end, "Dispatch should throw error for non-string event name")
end

-- 测试事件处理器的执行顺序
local function testDispatchOrder()
    local results = {}
    
    local function handler1(data)
        table.insert(results, 1)
    end
    
    local function handler2(data)
        table.insert(results, 2)
    end
    
    local function handler3(data)
        table.insert(results, 3)
    end
    
    EventDispatcher.AddEvent("test_order", handler1)
    EventDispatcher.AddEvent("test_order", handler2)
    EventDispatcher.AddEvent("test_order", handler3)
    EventDispatcher.Dispatch("test_order", {})
    
    TestFramework.assertEquals(#results, 3, "All handlers should be called")
    TestFramework.assertEquals(results[1], 1, "First handler should be called first")
    TestFramework.assertEquals(results[2], 2, "Second handler should be called second")
    TestFramework.assertEquals(results[3], 3, "Third handler should be called third")
    
    -- 清理
    EventDispatcher.RemoveEvent("test_order")
end

-- 测试带目标对象的事件处理
local function testDispatchWithTarget()
    local obj = {
        value = 0,
        handler = function(self, data)
            self.value = self.value + data.increment
        end
    }
    
    EventDispatcher.AddEvent("test_target", obj.handler, obj)
    EventDispatcher.Dispatch("test_target", {increment = 10})
    
    TestFramework.assertEquals(obj.value, 10, "Handler with target should modify object state")
    
    -- 清理
    EventDispatcher.RemoveEvent("test_target")
end

-- 注册测试用例
TestFramework.addTestCase("EventDispatcher.AddEvent", testAddEvent)
TestFramework.addTestCase("EventDispatcher.RemoveEvent", testRemoveEvent)
TestFramework.addTestCase("EventDispatcher.Dispatch", testDispatch)
TestFramework.addTestCase("EventDispatcher.MultipleListeners", testMultipleListeners)
TestFramework.addTestCase("EventDispatcher.RemoveAllListeners", testRemoveAllListeners)
TestFramework.addTestCase("EventDispatcher.DispatchWithError", testDispatchWithError)
TestFramework.addTestCase("EventDispatcher.DispatchNonExistent", testDispatchNonExistent)
TestFramework.addTestCase("EventDispatcher.RemoveNonExistent", testRemoveNonExistent)
TestFramework.addTestCase("EventDispatcher.ParameterValidation", testParameterValidation)
TestFramework.addTestCase("EventDispatcher.DispatchOrder", testDispatchOrder)
TestFramework.addTestCase("EventDispatcher.DispatchWithTarget", testDispatchWithTarget)

return {
    testAddEvent = testAddEvent,
    testRemoveEvent = testRemoveEvent,
    testDispatch = testDispatch,
    testMultipleListeners = testMultipleListeners,
    testRemoveAllListeners = testRemoveAllListeners,
    testDispatchWithError = testDispatchWithError,
    testDispatchNonExistent = testDispatchNonExistent,
    testRemoveNonExistent = testRemoveNonExistent,
    testParameterValidation = testParameterValidation,
    testDispatchOrder = testDispatchOrder,
    testDispatchWithTarget = testDispatchWithTarget
}