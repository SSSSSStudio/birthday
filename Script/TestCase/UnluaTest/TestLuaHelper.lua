--
-- LuaHelper Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local LuaHelper = require("Utility.LuaHelper")

local function testXpCall()
    -- Test with a function that doesn't throw an error
    local function testFunc(a, b)
        return a + b
    end
    
    local result = LuaHelper.XpCall(testFunc, 2, 3)
    TestFramework.assertEquals(result, 5, "XpCall should return correct result")
    
    -- Test with a function that throws an error
    local function errorFunc()
        error("Test error")
    end
    
    local success, errorMsg = pcall(function() LuaHelper.XpCall(errorFunc) end)
    TestFramework.assertTrue(success, "XpCall should handle errors gracefully")
end

local function testSplit()
    -- Test normal split
    local result = LuaHelper.Split("a,b,c", ",")
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(#result, 3)
    TestFramework.assertEquals(result[1], "a")
    TestFramework.assertEquals(result[2], "b")
    TestFramework.assertEquals(result[3], "c")
    
    -- Test split with empty string
    result = LuaHelper.Split("", ",")
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(#result, 0)
    
    -- Test split with nil string
    result = LuaHelper.Split(nil, ",")
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(#result, 0)
    
    -- Test split with nil delimiter
    result = LuaHelper.Split("a,b,c", nil)
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(#result, 0)
end

local function testDateFormat()
    -- Test date formatting
    local timestamp = os.time({year = 2023, month = 12, day = 25, hour = 14, min = 30, sec = 45})
    local result = LuaHelper.DateFormat("yyyy.MM.dd hh:mm:ss", timestamp)
    TestFramework.assertEquals(result, "2023.12.25 14:30:45", "DateFormat should format correctly")
    
    -- Test with different format
    result = LuaHelper.DateFormat("yy-M-d h:m:s", timestamp)
    TestFramework.assertEquals(result, "23-12-25 14:30:45", "DateFormat should handle different formats")
end

local function testSecondsFormat()
    -- Test positive seconds
    local result = LuaHelper.SecondsFormat("hh:mm:ss", 3661)
    TestFramework.assertEquals(result, "01:01:01", "SecondsFormat should format positive seconds correctly")
    
    -- Test negative seconds
    result = LuaHelper.SecondsFormat("hh:mm:ss", -3661)
    TestFramework.assertEquals(result, "-01:01:01", "SecondsFormat should format negative seconds correctly")
    
    -- Test with different format
    result = LuaHelper.SecondsFormat("h:m:s", 3661)
    TestFramework.assertEquals(result, "1:1:1", "SecondsFormat should handle different formats")
end

local function testHandler()
    local obj = {value = 0}
    
    function obj:increment(amount)
        self.value = self.value + amount
        return self.value
    end
    
    local handler = LuaHelper.Handler(obj, obj.increment)
    local result = handler(5)
    
    TestFramework.assertEquals(result, 5, "Handler should call method with correct parameters")
    TestFramework.assertEquals(obj.value, 5, "Handler should modify object state")
end

local function testHandleFunc()
    local target = {value = 0}
    local callCount = 0
    
    local function testFunc(target, value)
        callCount = callCount + 1
        target.value = value
    end
    
    local handler = LuaHelper.HandleFunc(target, testFunc, 10)
    handler()
    
    TestFramework.assertEquals(callCount, 1, "HandleFunc should call function")
    TestFramework.assertEquals(target.value, 10, "HandleFunc should pass parameters correctly")
end

-- Register test cases
TestFramework.addTestCase("LuaHelper.XpCall", testXpCall)
TestFramework.addTestCase("LuaHelper.Split", testSplit)
TestFramework.addTestCase("LuaHelper.DateFormat", testDateFormat)
TestFramework.addTestCase("LuaHelper.SecondsFormat", testSecondsFormat)
TestFramework.addTestCase("LuaHelper.Handler", testHandler)
TestFramework.addTestCase("LuaHelper.HandleFunc", testHandleFunc)

return {
    testXpCall = testXpCall,
    testSplit = testSplit,
    testDateFormat = testDateFormat,
    testSecondsFormat = testSecondsFormat,
    testHandler = testHandler,
    testHandleFunc = testHandleFunc
}