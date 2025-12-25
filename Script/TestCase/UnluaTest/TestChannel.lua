--
-- Channel Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- Mock the ltw2.event module
local mockTimerWatcher = {}
mockTimerWatcher.start = function(self, timeoutMs, repeatFlag, callback)
    self.timeoutMs = timeoutMs
    self.repeatFlag = repeatFlag
    self.callback = callback
end
mockTimerWatcher.stop = function(self)
    -- Mock stop implementation
end

local mockConnection = {}
mockConnection.connect = function(self, bStream, addr, callback)
    self.bStream = bStream
    self.addr = addr
    self.connectCallback = callback
    -- Simulate successful connection
    callback(true)
    return true
end
mockConnection.close = function(self, force)
    self.closed = true
    self.force = force
end
mockConnection.bind = function(self, bKeepAlive, bTcpNoDelay)
    self.bKeepAlive = bKeepAlive
    self.bTcpNoDelay = bTcpNoDelay
    return true
end
mockConnection.send = function(self, data)
    self.sentData = data
    return true
end
mockConnection.set_disconnect_callback = function(self, callback)
    self.disconnectCallback = callback
end
mockConnection.set_close_callback = function(self, callback)
    self.closeCallback = callback
end
mockConnection.set_receive_callback = function(self, callback)
    self.receiveCallback = callback
end

local mockLtw2Event = {
    connection_new = function()
        return mockConnection
    end,
    timer_watcher_new = function()
        return mockTimerWatcher
    end
}

package.loaded["ltw2.event"] = mockLtw2Event

-- Mock the ltw2.core module
local mockLtw2Core = {
    ringbuf_new = function(size)
        local ringbuf = {}
        ringbuf.write = function(self, data)
            self.data = data
        end
        return ringbuf
    end
}

package.loaded["ltw2.core"] = mockLtw2Core

local Channel = require("Core.Channel")

local function testConnect()
    local connectResult = nil
    
    local function connectCallback(bSucc)
        connectResult = bSucc
    end
    
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, connectCallback)
    
    TestFramework.assertNotNil(channel, "Channel.Connect should return a channel")
    TestFramework.assertNotNil(channel.conn, "Channel should have a connection")
    TestFramework.assertTrue(channel.bConnecting, "Channel should be connecting")
    TestFramework.assertTrue(connectResult, "Connect callback should be called with success")
end

local function testConnectFailure()
    -- Mock connection failure
    mockConnection.connect = function(self, bStream, addr, callback)
        -- Simulate failed connection
        callback(false)
        return false
    end
    
    local function connectCallback(bSucc)
        -- Should be called with false
    end
    
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, connectCallback)
    
    TestFramework.assertNil(channel, "Channel.Connect should return nil on connection failure")
    
    -- Reset mock
    mockConnection.connect = function(self, bStream, addr, callback)
        self.bStream = bStream
        self.addr = addr
        self.connectCallback = callback
        callback(true)
        return true
    end
end

local function testSetDisconnectCallback()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    local callbackCalled = false
    local function disconnectCallback(self)
        callbackCalled = true
    end
    
    channel.SetDisconnectCallback(channel, disconnectCallback)
    TestFramework.assertEquals(channel.disconnectCB, disconnectCallback, "Disconnect callback should be set")
end

local function testSetMessageCallback()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    local callbackCalled = false
    local receivedData = nil
    
    local function messageCallback(self, dataCache)
        callbackCalled = true
        receivedData = dataCache
    end
    
    channel.SetMessageCallback(channel, messageCallback)
    TestFramework.assertEquals(channel.messageCB, messageCallback, "Message callback should be set")
end

local function testBind()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    local result = channel.Bind(channel, true, true)
    
    TestFramework.assertTrue(result, "Bind should return true")
    TestFramework.assertNotNil(channel.dataCache, "Channel should have a data cache after binding")
end

local function testBindWithoutConnection()
    local channel = {}
    
    local result = channel.Bind(channel, true, true)
    
    TestFramework.assertFalse(result, "Bind should return false when there's no connection")
end

local function testSend()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    channel.Bind(channel, true, true)
    
    local result = channel.Send(channel, "test data")
    
    TestFramework.assertTrue(result, "Send should return true")
end

local function testSendWithoutConnection()
    local channel = {}
    
    local result = channel.Send(channel, "test data")
    
    TestFramework.assertFalse(result, "Send should return false when there's no connection")
end

local function testClose()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    -- This should not crash
    channel.Close(channel, 5000)
    TestFramework.assertTrue(true, "Close should not crash")
end

-- Register test cases
TestFramework.addTestCase("Channel.Connect", testConnect)
TestFramework.addTestCase("Channel.ConnectFailure", testConnectFailure)
TestFramework.addTestCase("Channel.SetDisconnectCallback", testSetDisconnectCallback)
TestFramework.addTestCase("Channel.SetMessageCallback", testSetMessageCallback)
TestFramework.addTestCase("Channel.Bind", testBind)
TestFramework.addTestCase("Channel.BindWithoutConnection", testBindWithoutConnection)
TestFramework.addTestCase("Channel.Send", testSend)
TestFramework.addTestCase("Channel.SendWithoutConnection", testSendWithoutConnection)
TestFramework.addTestCase("Channel.Close", testClose)

return {
    testConnect = testConnect,
    testConnectFailure = testConnectFailure,
    testSetDisconnectCallback = testSetDisconnectCallback,
    testSetMessageCallback = testSetMessageCallback,
    testBind = testBind,
    testBindWithoutConnection = testBindWithoutConnection,
    testSend = testSend,
    testSendWithoutConnection = testSendWithoutConnection,
    testClose = testClose
}