--
-- Channel Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local Channel = require("Core.Channel")
local EventLoop = require("Core.EventLoop")

local function testConnect()
    local connectResult = nil
    local function connectCallback(bSucc)
		connectResult = bSucc
		if bSucc then
			print("✅ Async Test 'Channel.Connect' passed")
		else
			print("❌ Async Test 'Channel.Connect' failed: connectCallback false")
		end
    end
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, connectCallback)
	TestFramework.assertNotNil(channel, "Channel.Connect should return a channel")
	TestFramework.assertNotNil(channel.conn, "Channel should have a connection")
	TestFramework.assertTrue(channel.bConnecting, "Channel should be connecting")
end

local function testConnectFailure()
    local function connectCallback(bSucc)
        -- Should be called with false
    end
    
    local channel = Channel.Connect("Error dir", 5000, true, connectCallback)
    
    TestFramework.assertNil(channel, "Channel.Connect should return nil on connection failure")
end

local function testSetDisconnectCallback()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    local callbackCalled = false
    local function disconnectCallback(self)
        callbackCalled = true
    end

	Channel.SetDisconnectCallback(channel, disconnectCallback)
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

	Channel.SetMessageCallback(channel, messageCallback)
    TestFramework.assertEquals(channel.messageCB, messageCallback, "Message callback should be set")
end

local function testBind()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    local result = Channel.Bind(channel, true, true)
    
    TestFramework.assertTrue(result, "Bind should return true")
    TestFramework.assertNotNil(channel.dataCache, "Channel should have a data cache after binding")
end

local function testBindWithoutConnection()
    local channel = {}
    
    local result = Channel.Bind(channel, true, true)
    
    TestFramework.assertFalse(result, "Bind should return false when there's no connection")
end

local function testSend()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
	Channel.Bind(channel, true, true)
    
    local result = Channel.Send(channel, "test data")
    
    TestFramework.assertTrue(result, "Send should return true")
end

local function testSendWithoutConnection()
    local channel = {}
    
    local result = Channel.Send(channel, "test data")
    
    TestFramework.assertFalse(result, "Send should return false when there's no connection")
end

local function testClose()
    local channel = Channel.Connect("127.0.0.1:8080", 5000, true, function(bSucc) end)
    
    -- This should not crash
	Channel.Close(channel, 5000)
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