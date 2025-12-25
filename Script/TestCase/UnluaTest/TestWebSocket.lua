---
-- WebSocket Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- Mock the Interface module
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

-- Mock the EventLoop module
package.loaded["Utility.EventLoop"] = {
    Timeout = function(timeoutMs, callback)
        local timer = {}
        function timer:stop()
            -- Mock stop implementation
        end
        -- Simulate timeout callback
        callback()
        return timer
    end
}

-- Mock the UE module
local mockWebSocketObject = {}
mockWebSocketObject.Connect = function(self, url)
    -- Mock connect implementation
end

mockWebSocketObject.Close = function(self)
    -- Mock close implementation
end

mockWebSocketObject.SendStringMessage = function(self, message)
    -- Mock send string message implementation
end

mockWebSocketObject.SendArrayMessage = function(self, message)
    -- Mock send array message implementation
end

mockWebSocketObject.IsConnected = function(self)
    return true
end

mockWebSocketObject.SetCallback = function(self, messageCallback, connectCallback, errorCallback, closeCallback, binaryCallback)
    self.messageCallback = messageCallback
    self.connectCallback = connectCallback
    self.errorCallback = errorCallback
    self.closeCallback = closeCallback
    self.binaryCallback = binaryCallback
end

local mockUE = {
    NewObject = function(class)
        return mockWebSocketObject
    end
}

package.loaded.UE = mockUE

-- Mock UnLua module
package.loaded.UnLua = {
    Ref = function(obj)
        return {object = obj}
    end,
    Unref = function(ref)
        ref.object = nil
    end
}

local WebSocket = require("Core.WebSocket")

local function testInit()
    local ws = WebSocket:New()
    
    TestFramework.assertNotNil(ws, "WebSocket should be created")
    TestFramework.assertNotNil(ws.webSocketObj, "WebSocket should have webSocketObj")
    TestFramework.assertNotNil(ws.refWebsocket, "WebSocket should have refWebsocket")
end

local function testSetMessageCallback()
    local ws = WebSocket:New()
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
    local ws = WebSocket:New()
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
    local ws = WebSocket:New()
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
    local ws = WebSocket:New()
    local connectResult = nil
    
    local function connectCallback(success)
        connectResult = success
    end
    
    local result = ws:Connect("ws://example.com", 5000, connectCallback)
    
    TestFramework.assertTrue(result, "Connect should return true")
    TestFramework.assertEquals(ws.staus, 1, "Status should be connecting")
end

local function testConnectWhenAlreadyConnected()
    local ws = WebSocket:New()
    ws.staus = 1  -- connecting
    
    local function connectCallback(success)
        -- Should not be called
    end
    
    local result = ws:Connect("ws://example.com", 5000, connectCallback)
    
    TestFramework.assertFalse(result, "Connect should return false when already connecting")
end

local function testClose()
    local ws = WebSocket:New()
    ws.staus = 2  -- connected
    
    ws:Close()
    
    TestFramework.assertEquals(ws.staus, 0, "Status should be disconnected after close")
end

local function testSendString()
    local ws = WebSocket:New()
    ws.staus = 2  -- connected
    
    -- This should not crash
    ws:SendString("test message")
    TestFramework.assertTrue(true, "SendString should not crash when connected")
end

local function testSendStringWhenNotConnected()
    local ws = WebSocket:New()
    ws.staus = 0  -- disconnected
    
    -- This should not crash
    ws:SendString("test message")
    TestFramework.assertTrue(true, "SendString should not crash when not connected")
end

local function testSendBinaryMessage()
    local ws = WebSocket:New()
    ws.staus = 2  -- connected
    
    -- This should not crash
    ws:SendBinaryMessage("binary data")
    TestFramework.assertTrue(true, "SendBinaryMessage should not crash when connected")
end

local function testSendBinaryMessageWhenNotConnected()
    local ws = WebSocket:New()
    ws.staus = 0  -- disconnected
    
    -- This should not crash
    ws:SendBinaryMessage("binary data")
    TestFramework.assertTrue(true, "SendBinaryMessage should not crash when not connected")
end

local function testIsConnected()
    local ws = WebSocket:New()
    
    local result = ws:IsConnected()
    TestFramework.assertTrue(result, "IsConnected should return true (mocked)")
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