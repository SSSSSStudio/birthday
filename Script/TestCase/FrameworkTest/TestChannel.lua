---
-- Channel 模块测试用例
-- 测试 Core.Channel 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- Mock ltw2 模块
package.loaded["ltw2.event"] = {
    connection_new = function()
        return {
            connect = function() return true end,
            close = function() end,
            send = function() return true end,
            bind = function() return true end,
            set_disconnect_callback = function() end,
            set_close_callback = function() end,
            set_receive_callback = function() end
        }
    end,
    timer_watcher_new = function()
        return {
            start = function() end,
            stop = function() end
        }
    end
}

package.loaded["ltw2.core"] = {
    ringbuf_new = function()
        return {
            write = function() end,
            read = function() return "" end
        }
    end
}

local Channel = require("Core.Channel")

-- 测试 Connect 函数
local function testConnect()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success)
            -- Connection callback
        end)
        TestFramework.assertNotNil(channel, "Channel should be created")
    end, "Connect should not throw exception")
end

-- 测试 SetDisconnectCallback 函数
local function testSetDisconnectCallback()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            Channel.SetDisconnectCallback(channel, function() end)
        end
    end, "SetDisconnectCallback should not throw exception")
end

-- 测试 Send 函数
local function testSend()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            local result = Channel.Send(channel, "test message")
            TestFramework.assertNotNil(result, "Send should return a result")
        end
    end, "Send should not throw exception")
end

-- 测试 Close 函数
local function testClose()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            Channel.Close(channel, 1000)
        end
    end, "Close should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("Channel.Connect", testConnect)
TestFramework.addTestCase("Channel.SetDisconnectCallback", testSetDisconnectCallback)
TestFramework.addTestCase("Channel.Send", testSend)
TestFramework.addTestCase("Channel.Close", testClose)

return {
    testConnect = testConnect,
    testSetDisconnectCallback = testSetDisconnectCallback,
    testSend = testSend,
    testClose = testClose
}
