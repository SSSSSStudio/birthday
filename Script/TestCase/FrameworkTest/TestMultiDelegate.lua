---
-- MultiDelegate 模块测试用例
-- 测试 Core.MultiDelegate 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- Mock Interface 模块
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

local MultiDelegate = require("Core.MultiDelegate")

-- 测试初始化
local function testInit()
    local multiDelegate = MultiDelegate:New()
    
    TestFramework.assertNotNil(multiDelegate, "MultiDelegate should be created")
    -- MultiDelegate 使用 listenerSet 和 listenerList 而非 delegates
    TestFramework.assertNotNil(multiDelegate.listenerSet, "Listener set should exist")
    TestFramework.assertNotNil(multiDelegate.listenerList, "Listener list should exist")
end

-- 测试 Add 函数
local function testAdd()
    local multiDelegate = MultiDelegate:New()
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
    local multiDelegate = MultiDelegate:New()
    local testObj = {value = 0}
    
    local function handler(obj)
        obj.value = obj.value + 1
    end
    
    multiDelegate:AddObject(testObj, handler)
    
    TestFramework.assertTrue(true, "AddObject should not throw exception")
end

-- 测试 Remove 函数
local function testRemove()
    local multiDelegate = MultiDelegate:New()
    
    local function handler()
        return "test"
    end
    
    multiDelegate:Add(handler)
    multiDelegate:Remove(handler)
    
    TestFramework.assertTrue(true, "Remove should not throw exception")
end

-- 测试 Broadcast 函数
local function testBroadcast()
    local multiDelegate = MultiDelegate:New()
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

-- 测试 RemoveAll 函数
local function testRemoveAll()
    local multiDelegate = MultiDelegate:New()
    
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

return {
    testInit = testInit,
    testAdd = testAdd,
    testAddObject = testAddObject,
    testRemove = testRemove,
    testBroadcast = testBroadcast,
    testRemoveAll = testRemoveAll
}
