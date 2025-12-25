---
-- HttpHelper 模块测试用例
-- 测试 Core.HttpHelper 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- 在 UE 环境下，直接使用真实的 UE 模块
-- UE 模块由 UnLua 自动提供，无需 mock

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
