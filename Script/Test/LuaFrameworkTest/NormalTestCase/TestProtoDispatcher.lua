---
-- ProtoDispatcher 模块测试用例
-- 测试 Core.ProtoDispatcher 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")
local ProtoDispatcher = require("Core.ProtoDispatcher")

-- 测试 AddDispatch 函数
local function testAddDispatch()
    local target = {}
    
    TestFramework.assertNoError(function()
        ProtoDispatcher.AddDispatch("test_proto", target, function(self, data)
            return data
        end)
    end, "AddDispatch should not throw exception")
end

-- 测试 RemoveDispatch 函数
local function testRemoveDispatch()
    local target = {}
    
    TestFramework.assertNoError(function()
        ProtoDispatcher.AddDispatch("test_remove", target, function(self, data)
            return data
        end)
        ProtoDispatcher.RemoveDispatch("test_remove", target)
    end, "RemoveDispatch should not throw exception")
end

-- 测试 DispatchMessage 函数
local function testDispatchMessage()
    local target = {}
    local result = nil
    
    TestFramework.assertNoError(function()
        ProtoDispatcher.AddDispatch("test_dispatch", target, function(self, data)
            result = data.value * 2
        end)
        
        ProtoDispatcher.DispatchMessage("test_dispatch", {value = 15})
    end, "DispatchMessage should not throw exception")
    
    TestFramework.assertEquals(result, 30, "DispatchMessage should call handler")
end

-- 测试 UnDispatch 函数
local function testUnDispatch()
    local target = {}
    
    TestFramework.assertNoError(function()
        ProtoDispatcher.AddDispatch("test_clear", target, function(self, data)
            return data
        end)
        ProtoDispatcher.UnDispatch("test_clear")
    end, "UnDispatch should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("ProtoDispatcher.AddDispatch", testAddDispatch)
TestFramework.addTestCase("ProtoDispatcher.RemoveDispatch", testRemoveDispatch)
TestFramework.addTestCase("ProtoDispatcher.DispatchMessage", testDispatchMessage)
TestFramework.addTestCase("ProtoDispatcher.UnDispatch", testUnDispatch)

return {
    testAddDispatch = testAddDispatch,
    testRemoveDispatch = testRemoveDispatch,
    testDispatchMessage = testDispatchMessage,
    testUnDispatch = testUnDispatch
}
