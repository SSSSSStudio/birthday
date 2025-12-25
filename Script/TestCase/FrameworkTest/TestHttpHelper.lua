---
-- HttpHelper 模块测试用例
-- 测试 Core.HttpHelper 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- Mock UE 模块
package.loaded["UE"] = package.loaded["UE"] or {}
UE.UHttpObject = UE.UHttpObject or {}
UE.UHttpObject.HttpAsyncAction = function()
    return {
        RegisterCompleteCallback = function(self, callback)
            -- Mock callback registration
        end,
        Request = function(self)
            -- Mock request
        end
    }
end

UE.UHttpDownloadObject = UE.UHttpDownloadObject or {}
UE.UHttpDownloadObject.HttpAsyncAction = function()
    return {
        RegisterCompleteCallback = function(self, callback)
            -- Mock callback registration
        end,
        Request = function(self)
            -- Mock request
        end
    }
end

UE.UHttpUploadObject = UE.UHttpUploadObject or {}
UE.UHttpUploadObject.HttpAsyncAction = function()
    return {
        RegisterCompleteCallback = function(self, callback)
            -- Mock callback registration
        end,
        Request = function(self)
            -- Mock request
        end
    }
end

UE.EHttpVerb = {GET = 0, POST = 1, PUT = 2, DELETE = 3, Post = 1}
UE.EHttpContentType = {None = 0, Json = 1, Form_Data = 2}

local HttpHelper = require("Core.HttpHelper")

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
TestFramework.addTestCase("HttpHelper.Download", testDownload)
TestFramework.addTestCase("HttpHelper.Upload", testUpload)

return {
    testRequest = testRequest,
    testDownload = testDownload,
    testUpload = testUpload
}
