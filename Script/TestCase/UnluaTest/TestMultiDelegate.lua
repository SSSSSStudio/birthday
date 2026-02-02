--
-- MultiDelegate Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- 使用真实的 Interface 模块
local Interface = require("Utility.Interface")

local MultiDelegate = require("Core.MultiDelegate")

-- 测试初始化
local function testInit()
    local multiDelegate = MultiDelegate()
    
    TestFramework.assertNotNil(multiDelegate, "MultiDelegate should be created")
    -- MultiDelegate 使用 listenerSet 和 listenerList 而非 delegates
    TestFramework.assertNotNil(multiDelegate.listenerSet, "Listener set should exist")
    TestFramework.assertNotNil(multiDelegate.listenerList, "Listener list should exist")
end

-- 测试 Add 函数
local function testAdd()
    local multiDelegate = MultiDelegate()
    local count = 0
    
    local function handler1()
        count = count + 1
    end
    
    local function handler2()
        count = count + 10
    end
    
    multiDelegate:Add(handler1)
    multiDelegate:Add(handler2)
    
    TestFramework.assertTrue(true, "Add should not throw exception")
end

-- 测试 AddObject 函数
local function testAddObject()
    local multiDelegate = MultiDelegate()
    local testObj = {value = 0}
    
    local function handler(obj)
        obj.value = obj.value + 1
    end
    
    multiDelegate:AddObject(testObj, handler)
    
    TestFramework.assertTrue(true, "AddObject should not throw exception")
end

-- 测试 Remove 函数
local function testRemove()
    local multiDelegate = MultiDelegate()
    
    local function handler()
        return "test"
    end
    
    multiDelegate:Add(handler)
    multiDelegate:Remove(handler)
    
    TestFramework.assertTrue(true, "Remove should not throw exception")
end

-- 测试 Broadcast 函数
local function testBroadcast()
    local multiDelegate = MultiDelegate()
    local count = 0
    
    local function handler1(value)
        count = count + value
    end
    
    local function handler2(value)
        count = count + value * 2
    end
    
    multiDelegate:Add(handler1)
    multiDelegate:Add(handler2)
    multiDelegate:Broadcast(10)
    
    TestFramework.assertEquals(count, 30, "Broadcast should call all handlers")
end

-- 测试重复添加同一个处理器
local function testAddDuplicate()
    local multiDelegate = MultiDelegate()
    local count = 0
    
    local function handler()
        count = count + 1
    end
    
    -- 第一次添加应该成功
    local result1 = multiDelegate:Add(handler)
    TestFramework.assertTrue(result1, "First Add should return true")
    
    -- 第二次添加同一个处理器应该失败
    local result2 = multiDelegate:Add(handler)
    TestFramework.assertFalse(result2, "Duplicate Add should return false")
    
    -- 广播应该只调用一次
    multiDelegate:Broadcast()
    TestFramework.assertEquals(count, 1, "Handler should only be called once")
end

-- 测试移除不存在的处理器
local function testRemoveNonExistent()
    local multiDelegate = MultiDelegate()
    
    local function handler()
        return "test"
    end
    
    -- 移除未添加的处理器应该返回 false
    local result = multiDelegate:Remove(handler)
    TestFramework.assertFalse(result, "Remove non-existent handler should return false")
end

-- 测试空广播
local function testBroadcastEmpty()
    local multiDelegate = MultiDelegate()
    
    -- 空的 MultiDelegate 广播应该返回 false
    local result = multiDelegate:Broadcast()
    TestFramework.assertFalse(result, "Broadcast on empty MultiDelegate should return false")
end

-- 测试处理器中抛出错误
local function testBroadcastWithError()
    local multiDelegate = MultiDelegate()
    local count = 0
    
    local function handler1()
        count = count + 1
    end
    
    local function handler2()
        error("test error")
    end
    
    local function handler3()
        count = count + 1
    end
    
    multiDelegate:Add(handler1)
    multiDelegate:Add(handler2)
    multiDelegate:Add(handler3)
    
    -- 广播应该捕获错误并继续执行其他处理器
    TestFramework.assertNoError(function()
        multiDelegate:Broadcast()
    end, "Broadcast should handle errors in handlers")
    
    -- handler1 和 handler3 应该都被调用
    TestFramework.assertEquals(count, 2, "Other handlers should still be called after error")
end

-- 测试对象方法的调用顺序
local function testAddObjectOrder()
    local multiDelegate = MultiDelegate()
    local results = {}
    
    local obj1 = {
        id = 1,
        handler = function(self, value)
            table.insert(results, self.id * value)
        end
    }
    
    local obj2 = {
        id = 2,
        handler = function(self, value)
            table.insert(results, self.id * value)
        end
    }
    
    multiDelegate:AddObject(obj1, obj1.handler)
    multiDelegate:AddObject(obj2, obj2.handler)
    multiDelegate:Broadcast(10)
    
    TestFramework.assertEquals(#results, 2, "Both object handlers should be called")
    TestFramework.assertEquals(results[1], 10, "First handler should receive correct value")
    TestFramework.assertEquals(results[2], 20, "Second handler should receive correct value")
end

-- 测试参数验证
local function testParameterValidation()
    local multiDelegate = MultiDelegate()
    
    -- 测试 Add 参数验证
    TestFramework.assertError(function()
        multiDelegate:Add(nil)
    end, "Add should throw error for nil function")
    
    TestFramework.assertError(function()
        multiDelegate:Add("not a function")
    end, "Add should throw error for non-function")
    
    -- 测试 AddObject 参数验证
    TestFramework.assertError(function()
        multiDelegate:AddObject(nil, function() end)
    end, "AddObject should throw error for nil object")
    
    TestFramework.assertError(function()
        multiDelegate:AddObject({}, nil)
    end, "AddObject should throw error for nil method")
    
    TestFramework.assertError(function()
        multiDelegate:AddObject({}, "not a function")
    end, "AddObject should throw error for non-function method")
    
    -- 测试 Remove 参数验证
    TestFramework.assertError(function()
        multiDelegate:Remove(nil)
    end, "Remove should throw error for nil function")
end

-- 测试 RemoveAll 函数
local function testRemoveAll()
    local multiDelegate = MultiDelegate()
    
    local function handler()
        return "test"
    end
    
    multiDelegate:Add(handler)
    -- MultiDelegate 使用 RemoveAll 而非 Clear
    multiDelegate:RemoveAll()
    
    TestFramework.assertTrue(true, "RemoveAll should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("MultiDelegate.Init", testInit)
TestFramework.addTestCase("MultiDelegate.Add", testAdd)
TestFramework.addTestCase("MultiDelegate.AddObject", testAddObject)
TestFramework.addTestCase("MultiDelegate.Remove", testRemove)
TestFramework.addTestCase("MultiDelegate.Broadcast", testBroadcast)
TestFramework.addTestCase("MultiDelegate.RemoveAll", testRemoveAll)
TestFramework.addTestCase("MultiDelegate.AddDuplicate", testAddDuplicate)
TestFramework.addTestCase("MultiDelegate.RemoveNonExistent", testRemoveNonExistent)
TestFramework.addTestCase("MultiDelegate.BroadcastEmpty", testBroadcastEmpty)
TestFramework.addTestCase("MultiDelegate.BroadcastWithError", testBroadcastWithError)
TestFramework.addTestCase("MultiDelegate.AddObjectOrder", testAddObjectOrder)
TestFramework.addTestCase("MultiDelegate.ParameterValidation", testParameterValidation)

return {
    testInit = testInit,
    testAdd = testAdd,
    testAddObject = testAddObject,
    testRemove = testRemove,
    testBroadcast = testBroadcast,
    testRemoveAll = testRemoveAll,
    testAddDuplicate = testAddDuplicate,
    testRemoveNonExistent = testRemoveNonExistent,
    testBroadcastEmpty = testBroadcastEmpty,
    testBroadcastWithError = testBroadcastWithError,
    testAddObjectOrder = testAddObjectOrder,
    testParameterValidation = testParameterValidation
}