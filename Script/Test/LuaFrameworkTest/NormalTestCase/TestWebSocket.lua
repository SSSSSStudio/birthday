-- WebSocket 模块测试用例
-- 测试 Core.WebSocket 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")

-- Mock Interface 模块已移除，直接使用 Utility.Interface

-- Mock UE 和 UnLua 环境
if not UE then
    _G.UE = {}
    _G.UnLua = {}
    
    -- Mock UWebSocketObject
    UE.UWebSocketObject = {}
    
    -- Mock UnLua.Ref/Unref
    function UnLua.Ref(obj) return obj end
    function UnLua.Unref(obj) end
    
    -- Mock UE.NewObject
    function UE.NewObject(class)
        local obj = {}
        
        function obj:SetCallback(onMsg, onConnect, onError, onClose, onBinaryMsg)
            self.callbacks = {
                onMsg = onMsg,
                onConnect = onConnect,
                onError = onError,
                onClose = onClose,
                onBinaryMsg = onBinaryMsg
            }
        end
        
        function obj:Connect(url)
            self.url = url
            -- 模拟异步连接成功
            if self.callbacks and self.callbacks.onConnect then
                -- 使用 EventLoop 模拟异步延迟，如果可用
                local EventLoop = require("Core.EventLoop")
                if EventLoop then
                    EventLoop.Timeout(10, function()
                        self.callbacks.onConnect()
                    end, false)
                else
                    self.callbacks.onConnect()
                end
            end
        end
        
        function obj:Close()
            if self.callbacks and self.callbacks.onClose then
                self.callbacks.onClose(1000, "Normal Closure", true)
            end
        end
        
        function obj:SendStringMessage(msg) end
        function obj:SendArrayMessage(msg) end
        function obj:IsConnected() return true end
        
        return obj
    end
end

-- 预期：WebSocket 模块应该能正常加载
-- 实际：WebSocket.lua 第 8 行存在 bug，require("Utility.EventLoop") 路径错误
--       正确路径应该是 require("Core.EventLoop")
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

-- 异步测试 Connect
local function testConnectAsync(done)
    print("   [Test] Testing WebSocket Connect Async...")
    local ws = WebSocket()
    
    -- 设置连接回调
    local isConnected = false
    
    -- 调用 Connect
    ws:Connect("ws://example.com", 1000, function(success)
        if success then
            print("   [Test] WebSocket Connected successfully")
            isConnected = true
            ws:Close()
            done()
        else
            done("WebSocket connection failed")
        end
    end)
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
TestFramework.addTestCase("WebSocket.ConnectAsync", testConnectAsync, { isAsync = true })
TestFramework.addTestCase("WebSocket.SendString", testSendString)
TestFramework.addTestCase("WebSocket.Close", testClose)

return {
    testInit = testInit,
    testConnect = testConnect,
    testConnectAsync = testConnectAsync,
    testSendString = testSendString,
    testClose = testClose
}