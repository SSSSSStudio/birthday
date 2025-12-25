--
-- HttpHelper Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- Mock the UE module for testing
local mockHttpObject = {}
mockHttpObject.HttpAsyncAction = function(url, verb, contentType, context, token)
    local obj = {
        url = url,
        verb = verb,
        contentType = contentType,
        context = context,
        token = token,
        callbacks = {}
    }
    
    function obj:RegisterCompleteCallback(callback)
        table.insert(obj.callbacks, callback)
    end
    
    function obj:Request()
        -- Simulate async completion
        for _, callback in ipairs(self.callbacks) do
            callback("mock response", 200)
        end
    end
    
    return obj
end

local mockHttpDownloadObject = {}
mockHttpDownloadObject.HttpAsyncAction = function(url, verb, contentType, context, token, savePath)
    local obj = {
        url = url,
        verb = verb,
        contentType = contentType,
        context = context,
        token = token,
        savePath = savePath,
        callbacks = {}
    }
    
    function obj:RegisterCompleteCallback(callback)
        table.insert(obj.callbacks, callback)
    end
    
    function obj:Request()
        -- Simulate async completion
        for _, callback in ipairs(self.callbacks) do
            callback("mock download response", 200)
        end
    end
    
    return obj
end

local mockHttpUploadObject = {}
mockHttpUploadObject.HttpAsyncAction = function(url, verb, contentType, context, token, filePath)
    local obj = {
        url = url,
        verb = verb,
        contentType = contentType,
        context = context,
        token = token,
        filePath = filePath,
        callbacks = {}
    }
    
    function obj:RegisterCompleteCallback(callback)
        table.insert(obj.callbacks, callback)
    end
    
    function obj:Request()
        -- Simulate async completion
        for _, callback in ipairs(self.callbacks) do
            callback("mock upload response", 200)
        end
    end
    
    return obj
end

local mockEHttpVerb = {
    GET = "GET",
    POST = "POST",
    PUT = "PUT",
    DELETE = "DELETE"
}

local mockEHttpContentType = {
    None = "None",
    Form_Data = "Form_Data",
    Json = "Json"
}

package.loaded.UE = {
    UHttpObject = mockHttpObject,
    UHttpDownloadObject = mockHttpDownloadObject,
    UHttpUploadObject = mockHttpUploadObject,
    EHttpVerb = mockEHttpVerb,
    EHttpContentType = mockEHttpContentType
}

local HttpHelper = require("Core.HttpHelper")

local function testRequest()
    local target = {}
    local callbackCalled = false
    local callbackResult = nil
    local callbackCode = nil
    
    local function testCallback(target, result, code)
        callbackCalled = true
        callbackResult = result
        callbackCode = code
    end
    
    -- Test normal request
    HttpHelper.Request("http://example.com", target, testCallback, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "")
    
    TestFramework.assertTrue(callbackCalled, "HttpHelper.Request should call callback")
    TestFramework.assertEquals(callbackResult, "mock response", "HttpHelper.Request should return correct result")
    TestFramework.assertEquals(callbackCode, 200, "HttpHelper.Request should return correct code")
    
    -- Test with invalid target
    local success, errorMsg = pcall(function() 
        HttpHelper.Request("http://example.com", nil, testCallback, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Request should reject nil target")
    
    -- Test with invalid callback
    success, errorMsg = pcall(function() 
        HttpHelper.Request("http://example.com", target, nil, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Request should reject nil callback")
end

local function testDownload()
    local target = {}
    local callbackCalled = false
    local callbackResult = nil
    local callbackCode = nil
    
    local function testCallback(target, result, code)
        callbackCalled = true
        callbackResult = result
        callbackCode = code
    end
    
    -- Test normal download
    HttpHelper.Download("http://example.com/file", target, testCallback, "save/path/file.txt")
    
    TestFramework.assertTrue(callbackCalled, "HttpHelper.Download should call callback")
    TestFramework.assertEquals(callbackResult, "mock download response", "HttpHelper.Download should return correct result")
    TestFramework.assertEquals(callbackCode, 200, "HttpHelper.Download should return correct code")
    
    -- Test with invalid target
    local success, errorMsg = pcall(function() 
        HttpHelper.Download("http://example.com/file", nil, testCallback, "save/path/file.txt") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Download should reject nil target")
    
    -- Test with invalid callback
    success, errorMsg = pcall(function() 
        HttpHelper.Download("http://example.com/file", target, nil, "save/path/file.txt") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Download should reject nil callback")
end

local function testUpload()
    local target = {}
    local callbackCalled = false
    local callbackResult = nil
    local callbackCode = nil
    
    local function testCallback(target, result, code)
        callbackCalled = true
        callbackResult = result
        callbackCode = code
    end
    
    -- Test normal upload
    HttpHelper.Upload("http://example.com/upload", target, testCallback, "path/to/file.txt")
    
    TestFramework.assertTrue(callbackCalled, "HttpHelper.Upload should call callback")
    TestFramework.assertEquals(callbackResult, "mock upload response", "HttpHelper.Upload should return correct result")
    TestFramework.assertEquals(callbackCode, 200, "HttpHelper.Upload should return correct code")
    
    -- Test with invalid target
    local success, errorMsg = pcall(function() 
        HttpHelper.Upload("http://example.com/upload", nil, testCallback, "path/to/file.txt") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Upload should reject nil target")
    
    -- Test with invalid callback
    success, errorMsg = pcall(function() 
        HttpHelper.Upload("http://example.com/upload", target, nil, "path/to/file.txt") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Upload should reject nil callback")
end

-- Register test cases
TestFramework.addTestCase("HttpHelper.Request", testRequest)
TestFramework.addTestCase("HttpHelper.Download", testDownload)
TestFramework.addTestCase("HttpHelper.Upload", testUpload)

return {
    testRequest = testRequest,
    testDownload = testDownload,
    testUpload = testUpload
}