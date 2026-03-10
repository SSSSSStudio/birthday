--
-- Channel 模块测试用例
-- 测试 Core.Channel 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.FullTestCase.init")

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

-- 测试 SetMessageCallback 函数
local function testSetMessageCallback()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            Channel.SetMessageCallback(channel, function(ch, dataCache)
                -- Message callback
            end)
        end
    end, "SetMessageCallback should not throw exception")
end

-- 测试 Bind 函数
local function testBind()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            local result = Channel.Bind(channel, true, true)
            TestFramework.assertNotNil(result, "Bind should return a result")
        end
    end, "Bind should not throw exception")
end

-- 测试连接失败场景
local function testConnectFailure()
    TestFramework.assertNoError(function()
        -- 使用无效地址测试连接失败
        local channel = Channel.Connect("invalid_address", 100, true, function(success)
            -- 连接失败回调
            TestFramework.assertFalse(success, "Connection should fail for invalid address")
        end)
    end, "Connect with invalid address should not throw exception")
end

-- 测试超时场景
local function testConnectTimeout()
    TestFramework.assertNoError(function()
        -- 使用很短的超时时间
        local channel = Channel.Connect("192.0.2.1:9999", 1, true, function(success)
            -- 超时回调
        end)
    end, "Connect with short timeout should not throw exception")
end

-- 测试发送到未连接的通道
local function testSendDisconnected()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            -- 立即关闭
            Channel.Close(channel, 0)
            -- 尝试发送
            local result = Channel.Send(channel, "test")
            -- 应该返回 false 或 nil
        end
    end, "Send to disconnected channel should not throw exception")
end

-- 测试多次关闭
local function testMultipleClose()
    TestFramework.assertNoError(function()
        local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        if channel then
            Channel.Close(channel, 1000)
            -- 再次关闭
            Channel.Close(channel, 1000)
        end
    end, "Multiple Close calls should not throw exception")
end

-- 测试流式和非流式连接
local function testStreamAndNonStream()
    TestFramework.assertNoError(function()
        -- 流式连接 (TCP)
        local channel1 = Channel.Connect("127.0.0.1:8080", 5000, true, function(success) end)
        TestFramework.assertNotNil(channel1, "Stream connection should be created")
        
        -- 非流式连接 (UDP)
        local channel2 = Channel.Connect("127.0.0.1:8080", 5000, false, function(success) end)
        TestFramework.assertNotNil(channel2, "Non-stream connection should be created")
    end, "Both stream and non-stream connections should work")
end

-- 测试零超时
local function testZeroTimeout()
    TestFramework.assertNoError(function()
        -- 零超时应该表示不设置超时
        local channel = Channel.Connect("127.0.0.1:8080", 0, true, function(success) end)
        TestFramework.assertNotNil(channel, "Connection with zero timeout should be created")
    end, "Zero timeout should not throw exception")
end

-- 测试负超时
local function testNegativeTimeout()
    TestFramework.assertNoError(function()
        -- 负超时应该被忽略或当作零处理
        local channel = Channel.Connect("127.0.0.1:8080", -1, true, function(success) end)
    end, "Negative timeout should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("Channel.Connect", testConnect)
TestFramework.addTestCase("Channel.SetDisconnectCallback", testSetDisconnectCallback)
TestFramework.addTestCase("Channel.Send", testSend)
TestFramework.addTestCase("Channel.Close", testClose)
TestFramework.addTestCase("Channel.SetMessageCallback", testSetMessageCallback)
TestFramework.addTestCase("Channel.Bind", testBind)
TestFramework.addTestCase("Channel.ConnectFailure", testConnectFailure)
TestFramework.addTestCase("Channel.ConnectTimeout", testConnectTimeout)
TestFramework.addTestCase("Channel.SendDisconnected", testSendDisconnected)
TestFramework.addTestCase("Channel.MultipleClose", testMultipleClose)
TestFramework.addTestCase("Channel.StreamAndNonStream", testStreamAndNonStream)
TestFramework.addTestCase("Channel.ZeroTimeout", testZeroTimeout)
TestFramework.addTestCase("Channel.NegativeTimeout", testNegativeTimeout)

return {
    testConnect = testConnect,
    testSetDisconnectCallback = testSetDisconnectCallback,
    testSend = testSend,
    testClose = testClose,
    testSetMessageCallback = testSetMessageCallback,
    testBind = testBind,
    testConnectFailure = testConnectFailure,
    testConnectTimeout = testConnectTimeout,
    testSendDisconnected = testSendDisconnected,
    testMultipleClose = testMultipleClose,
    testStreamAndNonStream = testStreamAndNonStream,
    testZeroTimeout = testZeroTimeout,
    testNegativeTimeout = testNegativeTimeout
}