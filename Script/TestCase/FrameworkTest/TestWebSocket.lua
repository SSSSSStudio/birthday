---
-- WebSocket 模块测试用例
-- 测试 Core.WebSocket 的所有功能
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

local WebSocket = require("Core.WebSocket")

-- 测试初始化
local function testInit()
    TestFramework.assertNoError(function()
        local ws = WebSocket()
        TestFramework.assertNotNil(ws, "WebSocket should be created")
    end, "WebSocket creation should not throw exception")
end

-- 测试 Connect 函数（API 存在性测试）
local function testConnect()
    TestFramework.assertNoError(function()
        -- WebSocket.Connect 需要 UE 环境支持，这里只测试 API 存在
        TestFramework.assertNotNil(WebSocket.Connect, "Connect method should exist")
        TestFramework.assertEquals(type(WebSocket.Connect), "function", "Connect should be a function")
    end, "Connect API test should not throw exception")
end

-- 测试 SendString 函数（API 存在性测试）
local function testSendString()
    TestFramework.assertNoError(function()
        -- WebSocket.SendString 需要连接状态，这里只测试 API 存在
        TestFramework.assertNotNil(WebSocket.SendString, "SendString method should exist")
        TestFramework.assertEquals(type(WebSocket.SendString), "function", "SendString should be a function")
    end, "SendString API test should not throw exception")
end

-- 测试 Close 函数
local function testClose()
    TestFramework.assertNoError(function()
        local ws = WebSocket()
        ws:Close()
    end, "Close should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("WebSocket.Init", testInit)
TestFramework.addTestCase("WebSocket.Connect", testConnect)
TestFramework.addTestCase("WebSocket.SendString", testSendString)
TestFramework.addTestCase("WebSocket.Close", testClose)

return {
    testInit = testInit,
    testConnect = testConnect,
    testSendString = testSendString,
    testClose = testClose
}
