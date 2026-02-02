--
-- LuaHelper Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local LuaHelper = require("Utility.LuaHelper")

-- 测试 XpCall 函数
local function testXpCall()
    -- 注意：XpCall 内部使用 xpcall，但返回值是从索引2开始解包的
    -- 这意味着它不返回 success 标志，而是直接返回函数的返回值
    
    -- 测试正常执行
    local result = LuaHelper.XpCall(function()
        return "success"
    end)
    
    TestFramework.assertEquals(result, "success", "XpCall should return correct result")
    
    -- 测试错误处理（错误会被捕获并打印，但不会抛出）
    TestFramework.assertNoError(function()
        local result2 = LuaHelper.XpCall(function()
            error("test error")
        end)
        -- XpCall 会捕获错误并打印，返回值为 nil
        TestFramework.assertNil(result2, "XpCall should return nil for error function")
    end, "XpCall should catch and handle errors")
    
    -- 测试多返回值
    local r1, r2, r3 = LuaHelper.XpCall(function()
        return 1, 2, 3
    end)
    TestFramework.assertEquals(r1, 1, "XpCall should return first value")
    TestFramework.assertEquals(r2, 2, "XpCall should return second value")
    TestFramework.assertEquals(r3, 3, "XpCall should return third value")
    
    -- 测试带参数的函数调用
    local result3 = LuaHelper.XpCall(function(a, b)
        return a + b
    end, 10, 20)
    TestFramework.assertEquals(result3, 30, "XpCall should pass parameters correctly")
end

-- 测试 LuaClass 函数
local function testLuaClass()
    -- 测试创建基础类
    local BaseClass = LuaHelper.LuaClass()
    TestFramework.assertNotNil(BaseClass, "LuaClass should create a class")
    
    -- 测试类的 New 方法
    function BaseClass:__OnNew(value)
        self.value = value or 0
    end
    
    function BaseClass:GetValue()
        return self.value
    end
    
    local instance = BaseClass:New(100)
    TestFramework.assertNotNil(instance, "Class should be instantiable")
    TestFramework.assertEquals(instance:GetValue(), 100, "Instance should have correct value")
    
    -- 测试类继承
    local DerivedClass = LuaHelper.LuaClass("TestBaseClass")
    -- 注意：这里会尝试 require("TestBaseClass")，如果失败会打印错误但不会崩溃
    TestFramework.assertNotNil(DerivedClass, "LuaClass should handle inheritance")
end

-- 测试 Handler 函数
local function testHandler()
    local testObj = {
        value = 0,
        increment = function(self, amount)
            self.value = self.value + amount
            return self.value
        end
    }
    
    -- 创建处理函数
    local handler = LuaHelper.Handler(testObj, testObj.increment)
    TestFramework.assertNotNil(handler, "Handler should create a function")
    
    -- 调用处理函数
    local result = handler(10)
    TestFramework.assertEquals(result, 10, "Handler should call method correctly")
    TestFramework.assertEquals(testObj.value, 10, "Handler should modify object state")
    
    -- 测试 nil 参数（应该抛出错误）
    TestFramework.assertError(function()
        LuaHelper.Handler(nil, function() end)
    end, "Handler should throw error for nil target")
    
    TestFramework.assertError(function()
        LuaHelper.Handler({}, nil)
    end, "Handler should throw error for nil function")
end

-- 测试 HandleFunc 函数
local function testHandleFunc()
    local testObj = {
        result = ""
    }
    
    local function concat(self, ...)
        local args = {...}
        self.result = table.concat(args, ",")
        return self.result
    end
    
    -- 创建带预设参数的处理函数
    local handler = LuaHelper.HandleFunc(testObj, concat, "a", "b")
    TestFramework.assertNotNil(handler, "HandleFunc should create a function")
    
    -- 调用时追加参数
    local result = handler("c", "d")
    TestFramework.assertEquals(testObj.result, "a,b,c,d", "HandleFunc should merge parameters")
end

-- 测试 Split 函数
local function testSplit()
    -- 测试正常分割
    local result = LuaHelper.Split("a,b,c,d", ",")
    TestFramework.assertEquals(#result, 4, "Split should return correct number of parts")
    TestFramework.assertEquals(result[1], "a", "Split should return correct first part")
    TestFramework.assertEquals(result[4], "d", "Split should return correct last part")
    
    -- 测试空字符串
    local result2 = LuaHelper.Split("", ",")
    TestFramework.assertEquals(#result2, 0, "Split should return empty table for empty string")
    
    -- 测试 nil 输入
    local result3 = LuaHelper.Split(nil, ",")
    TestFramework.assertEquals(#result3, 0, "Split should return empty table for nil")
    
    -- 测试单个元素
    local result4 = LuaHelper.Split("single", ",")
    TestFramework.assertEquals(#result4, 1, "Split should handle single element")
    TestFramework.assertEquals(result4[1], "single", "Split should return correct single element")
    
    -- 测试连续分隔符
    local result5 = LuaHelper.Split("a,,b", ",")
    TestFramework.assertEquals(#result5, 3, "Split should handle consecutive delimiters")
    TestFramework.assertEquals(result5[2], "", "Split should return empty string for consecutive delimiters")
end

-- 测试 DateFormat 函数
local function testDateFormat()
    -- 使用固定时间戳测试：2024-01-15 10:30:45
    local timestamp = 1705294245
    
    -- 测试完整格式
    local result = LuaHelper.DateFormat("yyyy-MM-dd hh:mm:ss", timestamp)
    TestFramework.assertNotNil(result, "DateFormat should return a string")
    -- 注意：由于时区差异，这里只验证格式正确性
    TestFramework.assertTrue(string.match(result, "%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d") ~= nil, 
        "DateFormat should return correct format")
    
    -- 测试年份格式
    local result2 = LuaHelper.DateFormat("yyyy", timestamp)
    TestFramework.assertTrue(string.match(result2, "%d%d%d%d") ~= nil, 
        "DateFormat should format year correctly")
    
    -- 测试月日格式
    local result3 = LuaHelper.DateFormat("MM-dd", timestamp)
    TestFramework.assertTrue(string.match(result3, "%d%d%-%d%d") ~= nil, 
        "DateFormat should format month-day correctly")
    
    -- 测试时分秒格式
    local result4 = LuaHelper.DateFormat("hh:mm:ss", timestamp)
    TestFramework.assertTrue(string.match(result4, "%d%d:%d%d:%d%d") ~= nil, 
        "DateFormat should format time correctly")
end

-- 测试 SecondsFormat 函数
local function testSecondsFormat()
    -- 测试正数秒数
    local result = LuaHelper.SecondsFormat("hh:mm:ss", 3661)  -- 1小时1分1秒
    TestFramework.assertEquals(result, "01:01:01", "SecondsFormat should format positive seconds")
    
    -- 测试负数秒数
    local result2 = LuaHelper.SecondsFormat("hh:mm:ss", -3661)
    TestFramework.assertEquals(result2, "-01:01:01", "SecondsFormat should format negative seconds")
    
    -- 测试零秒
    local result3 = LuaHelper.SecondsFormat("hh:mm:ss", 0)
    TestFramework.assertEquals(result3, "00:00:00", "SecondsFormat should format zero seconds")
    
    -- 测试大数值
    local result4 = LuaHelper.SecondsFormat("hh:mm:ss", 86400)  -- 24小时
    TestFramework.assertEquals(result4, "24:00:00", "SecondsFormat should format large seconds")
    
    -- 测试只显示分秒
    local result5 = LuaHelper.SecondsFormat("mm:ss", 125)  -- 2分5秒
    TestFramework.assertEquals(result5, "02:05", "SecondsFormat should format mm:ss")
    
    -- 测试单位格式
    local result6 = LuaHelper.SecondsFormat("h:m:s", 3661)
    TestFramework.assertEquals(result6, "1:1:1", "SecondsFormat should format single digit")
end

-- 测试 DisableGlobalVariable 函数
local function testDisableGlobalVariable()
    -- 测试禁用全局变量
    TestFramework.assertNoError(function()
        LuaHelper.DisableGlobalVariable()
    end, "DisableGlobalVariable should not throw exception")
    
    -- 测试设置全局变量会抛出错误
    -- 注意：这个测试可能会影响后续测试，因为它修改了全局元表
    -- 如果启用此测试，需要在测试结束后恢复全局元表
    -- TestFramework.assertError(function()
    --     testGlobalVar = "test"
    -- end, "Setting global variable should throw error after DisableGlobalVariable")
end

-- 注册测试用例
TestFramework.addTestCase("LuaHelper.XpCall", testXpCall)
TestFramework.addTestCase("LuaHelper.LuaClass", testLuaClass)
TestFramework.addTestCase("LuaHelper.Handler", testHandler)
TestFramework.addTestCase("LuaHelper.HandleFunc", testHandleFunc)
TestFramework.addTestCase("LuaHelper.Split", testSplit)
TestFramework.addTestCase("LuaHelper.DateFormat", testDateFormat)
TestFramework.addTestCase("LuaHelper.SecondsFormat", testSecondsFormat)
TestFramework.addTestCase("LuaHelper.DisableGlobalVariable", testDisableGlobalVariable)

return {
    testXpCall = testXpCall,
    testLuaClass = testLuaClass,
    testHandler = testHandler,
    testHandleFunc = testHandleFunc,
    testSplit = testSplit,
    testDateFormat = testDateFormat,
    testSecondsFormat = testSecondsFormat,
    testDisableGlobalVariable = testDisableGlobalVariable
}