--
-- HttpHelper Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local HttpHelper = require("Core.HttpHelper")
local EventLoop = require("Core.EventLoop")

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
    HttpHelper.Request(httpTestUrl, target, testCallback, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "")
	
	EventLoop.Timeout(1000, function()
		TestFramework.assertTrue(callbackCalled, "HttpHelper.Request should call callback")
		TestFramework.assertNotNil(callbackResult,  "HttpHelper.Request should return correct result")
		TestFramework.assertEquals(callbackCode, 200, "HttpHelper.Request should return correct code")
	end, true)
    
    -- Test with invalid target
    local success, errorMsg = pcall(function() 
        HttpHelper.Request(httpTestUrl, nil, testCallback, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Request should reject nil target")
    
    -- Test with invalid callback
    success, errorMsg = pcall(function() 
        HttpHelper.Request(httpTestUrl, target, nil, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "") 
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
    HttpHelper.Download(httpTestUrl, target, testCallback, "save/path/file.txt")

	local function testFunc()
		TestFramework.assertTrue(callbackCalled, "HttpHelper.Download should call callback")
		TestFramework.assertEquals(callbackResult, "mock download response", "HttpHelper.Download should return correct result")
		TestFramework.assertEquals(callbackCode, 200, "HttpHelper.Download should return correct code")
	end
	
	EventLoop.Timeout(1000, testFunc, false)
    
    -- Test with invalid target
    local success, errorMsg = pcall(function() 
        HttpHelper.Download(httpTestUrl, nil, testCallback, "save/path/file.txt") 
    end)
    TestFramework.assertFalse(success, "HttpHelper.Download should reject nil target")
    
    -- Test with invalid callback
    success, errorMsg = pcall(function() 
        HttpHelper.Download(httpTestUrl, target, nil, "save/path/file.txt") 
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