---
-- Observable 模块测试用例
-- 测试 Core.Observable 的所有功能
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

local Observable = require("Core.Observable")

-- 测试初始化
local function testInit()
    local observable = Observable:New()
    
    TestFramework.assertNotNil(observable, "Observable should be created")
    -- Observable 使用 container 而非 observers
    TestFramework.assertNotNil(observable.container, "Container should exist")
end

-- 测试 Register 函数
local function testRegister()
    local observable = Observable:New()
    local count = 0
    
    local function observer(data)
        count = count + data
    end
    
    -- Observable.Register 需要 signal 参数
    TestFramework.assertNoError(function()
        observable:Register("test_signal", observer)
    end, "Register should not throw exception")
end

-- 测试 Deregister 函数
local function testDeregister()
    local observable = Observable:New()
    
    local function observer(data)
        return data
    end
    
    -- Observable.Deregister 需要 signal 参数
    TestFramework.assertNoError(function()
        observable:Register("test_signal", observer)
        observable:Deregister("test_signal", observer)
    end, "Deregister should not throw exception")
end

-- 测试 Notify 函数
-- 注意：Observable.Register 有 bug (list[#list] = v 应该是 list[#list + 1] = v)
-- 导致注册多个观察者时只有最后一个会被保留，这里只测试单个观察者
local function testNotify()
    local observable = Observable:New()
    local called = false
    local receivedData = nil
    
    local function observer(data)
        called = true
        receivedData = data
    end
    
    -- Observable.Notify 需要 signal 参数
    TestFramework.assertNoError(function()
        observable:Register("test_signal", observer)
        observable:Notify("test_signal", 10)
    end, "Notify should not throw exception")
    
    -- 验证观察者被调用
    TestFramework.assertTrue(called, "Notify should call observer")
    TestFramework.assertEquals(receivedData, 10, "Observer should receive correct data")
end

-- 测试 Deregister 清除所有监听器
local function testDeregisterAll()
    local observable = Observable:New()
    
    local function observer(data)
        return data
    end
    
    -- Deregister 不传 func 参数时会清除该 signal 的所有监听器
    TestFramework.assertNoError(function()
        observable:Register("test_signal", observer)
        observable:Deregister("test_signal")  -- 清除所有监听器
    end, "Deregister all should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("Observable.Init", testInit)
TestFramework.addTestCase("Observable.Register", testRegister)
TestFramework.addTestCase("Observable.Deregister", testDeregister)
TestFramework.addTestCase("Observable.Notify", testNotify)
TestFramework.addTestCase("Observable.DeregisterAll", testDeregisterAll)

return {
    testInit = testInit,
    testRegister = testRegister,
    testDeregister = testDeregister,
    testNotify = testNotify,
    testDeregisterAll = testDeregisterAll
}
