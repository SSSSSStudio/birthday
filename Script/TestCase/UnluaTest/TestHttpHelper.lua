--
-- HttpHelper Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local HttpHelper = require("Core.HttpHelper")
local EventLoop = require("Core.EventLoop")

local httpTestUrl = "https://yuque.antfin-inc.com/aliyunops/zeus-doc/https-apply" 

local function testRequest()
    local target = {}
    local callbackCalled = false
    local callbackResult = nil
    local callbackCode = nil
    
    local function testCallback(target, result, code)
        callbackCalled = true
        callbackResult = result
        callbackCode = code

		if #callbackResult > 1 then
			print("✅ Async Test 'HttpHelper.testRequest' passed1")
		else
			print("❌ Async Test 'HttpHelper.testRequest' failed: callbackResult should have content")
		end

		if callbackCode == 200 then
			print("✅ Async Test 'HttpHelper.testRequest' passed2")
		else
			print("❌ Async Test 'HttpHelper.testRequest' failed: callbackCode should be 200")
		end
    end
    
    -- Test normal request
    HttpHelper.Request(httpTestUrl, target, testCallback, UE.EHttpVerb.GET, UE.EHttpContentType.None, "", "")
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

		if #callbackResult > 1 then
			print("✅ Async Test 'HttpHelper.testDownload' passed1")
		else
			print("❌ Async Test 'HttpHelper.testDownload' failed: callbackResult should have content")
		end

		if callbackCode == 200 then
			print("✅ Async Test 'HttpHelper.testDownload' passed2")
		else
			print("❌ Async Test 'HttpHelper.testDownload' failed: callbackCode should be 200")
		end
    end
    
    -- Test normal download
    HttpHelper.Download(httpTestUrl, target, testCallback, "save/path/file.txt")
    
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
		if #callbackResult > 1 then
			print("✅ Async Test 'HttpHelper.Upload' passed1")
		else
			print("❌ Async Test 'HttpHelper.Upload' failed: callbackResult should have content")
		end
		
		if callbackCode == 200 then
			print("✅ Async Test 'HttpHelper.Upload' passed2")
		else
			print("❌ Async Test 'HttpHelper.Upload' failed: callbackCode should be 200")
		end
    end
    
    -- Test normal upload
    HttpHelper.Upload(httpTestUrl, target, testCallback, "path/to/file.txt")
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