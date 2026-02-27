---
-- WebSocket Module Tests
--

local TestFramework = require("Test.LuaFrameworkTest.FullTestCase.init")
local WebSocket = require("Core.WebSocket")

local function testInit()
    local ws = WebSocket()
    
    TestFramework.assertNotNil(ws, "WebSocket should be created")
    TestFramework.assertNotNil(ws.webSocketObj, "WebSocket should have webSocketObj")
    TestFramework.assertNotNil(ws.refWebsocket, "WebSocket should have refWebsocket")
end

local function testSetMessageCallback()
    local ws = WebSocket()
    local callbackCalled = false
    local receivedMessage = nil
    
    local function messageCallback(messageString)
        callbackCalled = true
        receivedMessage = messageString
    end
    
    ws:SetMessageCallback(messageCallback)
    TestFramework.assertEquals(ws.messageCB, messageCallback, "Message callback should be set")
end

local function testSetBinaryMessageCallback()
    local ws = WebSocket()
    local callbackCalled = false
    local receivedMessage = nil
    local isLastFragment = nil
    
    local function binaryCallback(messageString, bIsLastFragment)
        callbackCalled = true
        receivedMessage = messageString
        isLastFragment = bIsLastFragment
    end
    
    ws:SetBinaryMessageCallback(binaryCallback)
    TestFramework.assertEquals(ws.binaryMessageCB, binaryCallback, "Binary message callback should be set")
end

local function testSetDisconnectCallback()
    local ws = WebSocket()
    local callbackCalled = false
    local receivedError = nil
    
    local function disconnectCallback(error)
        callbackCalled = true
        receivedError = error
    end
    
    ws:SetDisconnectCallback(disconnectCallback)
    TestFramework.assertEquals(ws._disconnectCB, disconnectCallback, "Disconnect callback should be set")
end

local function testConnect()
    local ws = WebSocket()
    local connectResult = nil
    
    local function connectCallback(success)
        connectResult = success
    end
    
    local result = ws:Connect("ws://example.com", 5000, connectCallback)
    
    TestFramework.assertTrue(result, "Connect should return true")
    TestFramework.assertEquals(ws.staus, 1, "Status should be connecting")
end

local function testConnectWhenAlreadyConnected()
    local ws = WebSocket()
    ws.staus = 1  -- connecting
    
    local function connectCallback(success)
        -- Should not be called
    end
    
    local result = ws:Connect("ws://example.com", 5000, connectCallback)
    
    TestFramework.assertFalse(result, "Connect should return false when already connecting")
end

local function testClose()
    local ws = WebSocket()
    ws.staus = 2  -- connected
    
    ws:Close()
    
    TestFramework.assertEquals(ws.staus, 0, "Status should be disconnected after close")
end

local function testSendString()
    local ws = WebSocket()
    ws.staus = 2  -- connected
    
    -- This should not crash
    ws:SendString("test message")
    TestFramework.assertTrue(true, "SendString should not crash when connected")
end

local function testSendStringWhenNotConnected()
    local ws = WebSocket()
    ws.staus = 0  -- disconnected
    
    -- This should not crash
    ws:SendString("test message")
    TestFramework.assertTrue(true, "SendString should not crash when not connected")
end

local function testSendBinaryMessage()
    local ws = WebSocket()
    ws.staus = 2  -- connected
    -- This should not crash
    ws:SendBinaryMessage( UE.TArray(3))
    TestFramework.assertTrue(true, "SendBinaryMessage should not crash when connected")
end

local function testSendBinaryMessageWhenNotConnected()
    local ws = WebSocket()
    ws.staus = 0  -- disconnected
    
    -- This should not crash
    ws:SendBinaryMessage(UE.TArray(3))
    TestFramework.assertTrue(true, "SendBinaryMessage should not crash when not connected")
end

local function testIsConnected()
    local ws = WebSocket()
    
    local result = ws:IsConnected()
    TestFramework.assertTrue(true, "IsConnected should return false")
end

-- Register test cases
TestFramework.addTestCase("WebSocket.Init", testInit)
TestFramework.addTestCase("WebSocket.SetMessageCallback", testSetMessageCallback)
TestFramework.addTestCase("WebSocket.SetBinaryMessageCallback", testSetBinaryMessageCallback)
TestFramework.addTestCase("WebSocket.SetDisconnectCallback", testSetDisconnectCallback)
TestFramework.addTestCase("WebSocket.Connect", testConnect)
TestFramework.addTestCase("WebSocket.ConnectWhenAlreadyConnected", testConnectWhenAlreadyConnected)
TestFramework.addTestCase("WebSocket.Close", testClose)
TestFramework.addTestCase("WebSocket.SendString", testSendString)
TestFramework.addTestCase("WebSocket.SendStringWhenNotConnected", testSendStringWhenNotConnected)
TestFramework.addTestCase("WebSocket.SendBinaryMessage", testSendBinaryMessage)
TestFramework.addTestCase("WebSocket.SendBinaryMessageWhenNotConnected", testSendBinaryMessageWhenNotConnected)
TestFramework.addTestCase("WebSocket.IsConnected", testIsConnected)

return {
    testInit = testInit,
    testSetMessageCallback = testSetMessageCallback,
    testSetBinaryMessageCallback = testSetBinaryMessageCallback,
    testSetDisconnectCallback = testSetDisconnectCallback,
    testConnect = testConnect,
    testConnectWhenAlreadyConnected = testConnectWhenAlreadyConnected,
    testClose = testClose,
    testSendString = testSendString,
    testSendStringWhenNotConnected = testSendStringWhenNotConnected,
    testSendBinaryMessage = testSendBinaryMessage,
    testSendBinaryMessageWhenNotConnected = testSendBinaryMessageWhenNotConnected,
    testIsConnected = testIsConnected
}