--
-- HttpHelper 模块测试用例
-- 测试 Core.HttpHelper 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")

-- Mock UE 环境
if not UE then
    _G.UE = {}
    UE.EHttpVerb = { GET = "GET", POST = "POST" }
    UE.EHttpContentType = { Json = "application/json", Form_Data = "multipart/form-data", None = "" }
    
    local function createMockHttpObj()
        local obj = {}
        function obj:RegisterCompleteCallback(callback)
            self.callback = callback
        end
        function obj:Request()
            -- 模拟异步请求完成
            if self.callback then
                local EventLoop = require("Core.EventLoop")
                if EventLoop then
                    EventLoop.Timeout(10, function()
                        self.callback("Mock Response", 200)
                    end, false)
                else
                    self.callback("Mock Response", 200)
                end
            end
        end
        return obj
    end

    UE.UHttpObject = {
        HttpAsyncAction = function(...) return createMockHttpObj() end
    }
    UE.UHttpDownloadObject = {
        HttpAsyncAction = function(...) return createMockHttpObj() end
    }
    UE.UHttpUploadObject = {
        HttpAsyncAction = function(...) return createMockHttpObj() end
    }
end

-- 在 UE 环境下，直接使用真实的 UE 模块
-- UE 模块由 UnLua 自动提供，无需 mock

local HttpHelper = require("Core.HttpHelper")

-- 异步测试 Request
local function testRequestAsync(done)
    print("   [Test] Testing HttpHelper Request Async...")
    local target = {}
    HttpHelper.Request("https://example.com", target, function(t, result, code)
        if t == target and code == 200 then
            print("   [Test] Http Request success")
            done()
        else
            done("Http Request failed: code=" .. tostring(code))
        end
    end, UE.EHttpVerb.GET, UE.EHttpContentType.Json, "", "")
end

-- 异步测试 Download
local function testDownloadAsync(done)
    print("   [Test] Testing HttpHelper Download Async...")
    local target = {}
    HttpHelper.Download("https://example.com/file.zip", target, function(t, result, code)
        if t == target and code == 200 then
            print("   [Test] Http Download success")
            done()
        else
            done("Http Download failed")
        end
    end, "/tmp/file.zip")
end

-- 测试 Request 函数
local function testRequest()
    TestFramework.assertNoError(function()
        local target = {}
        HttpHelper.Request("https://example.com", target, function(result, code)
            -- 回调处理
        end, UE.EHttpVerb.GET, UE.EHttpContentType.Json, "", "")
    end, "Request should not throw exception")
end

-- 测试 Download 函数
local function testDownload()
    TestFramework.assertNoError(function()
        local target = {}
        HttpHelper.Download("https://example.com/file.zip", target, function(result, code)
            -- 回调处理
        end, "/tmp/file.zip")
    end, "Download should not throw exception")
end

-- 测试 Upload 函数
local function testUpload()
    TestFramework.assertNoError(function()
        local target = {}
        HttpHelper.Upload("https://example.com/upload", target, function(result, code)
            -- 回调处理
        end, "/tmp/file.zip")
    end, "Upload should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("HttpHelper.Request", testRequest)
TestFramework.addTestCase("HttpHelper.RequestAsync", testRequestAsync, { isAsync = true })
TestFramework.addTestCase("HttpHelper.Download", testDownload)
TestFramework.addTestCase("HttpHelper.DownloadAsync", testDownloadAsync, { isAsync = true })
TestFramework.addTestCase("HttpHelper.Upload", testUpload)

return {
    testRequest = testRequest,
    testRequestAsync = testRequestAsync,
    testDownload = testDownload,
    testDownloadAsync = testDownloadAsync,
    testUpload = testUpload
}