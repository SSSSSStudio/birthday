---
-- Log 模块测试用例
-- 测试 Utility.Log 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")
local Log = require("Utility.Log")

-- 测试 Config 函数
-- 已知问题：Log.lua 第 73 行使用了 math.type() 函数
-- math.type() 是 Lua 5.3+ 的特性，在 Lua 5.1/5.2 环境中不存在
-- 此测试会失败，用于记录模块的已知兼容性问题
local function testConfig()
    TestFramework.assertNoError(function()
        -- Log.Config 接受一个整数参数 depth，用于配置表格打印的最大深度
        Log.Config(32)  -- 设置最大深度为 32
    end, "Config should not throw exception")
end

-- 测试 Error 函数
local function testError()
    -- 测试错误日志输出
    TestFramework.assertNoError(function()
        Log.Error("Test error message")
    end, "Error should not throw exception")
end

-- 测试 Warning 函数
local function testWarning()
    -- 测试警告日志输出
    TestFramework.assertNoError(function()
        Log.Warning("Test warning message")
    end, "Warning should not throw exception")
end

-- 测试 Info 函数
local function testInfo()
    -- 测试信息日志输出
    TestFramework.assertNoError(function()
        Log.Info("Test info message")
    end, "Info should not throw exception")
end

-- 测试 PrintT 函数
local function testPrintT()
    -- 测试表格打印
    local testTable = {a = 1, b = 2, c = {d = 3}}
    
    TestFramework.assertNoError(function()
        Log.PrintT(testTable)
    end, "PrintT should not throw exception")
end

-- 测试 Printf 函数
local function testPrintf()
    -- 测试格式化打印
    TestFramework.assertNoError(function()
        Log.Printf("Test %s with number %d", "string", 123)
    end, "Printf should not throw exception")
end

-- 测试多参数日志
local function testMultipleArguments()
    TestFramework.assertNoError(function()
        Log.Info("String:", "test", "Number:", 123, "Boolean:", true)
    end, "Log should handle multiple arguments")
end

-- 测试表格日志
local function testTableLogging()
    local complexTable = {
        simple = "value",
        nested = {
            level1 = {
                level2 = {
                    level3 = "deep"
                }
            }
        },
        array = {1, 2, 3, 4, 5}
    }
    
    TestFramework.assertNoError(function()
        Log.Info(complexTable)
    end, "Log should handle complex tables")
end

-- 测试 nil 值日志
local function testNilLogging()
    TestFramework.assertNoError(function()
        Log.Info("Value is:", nil)
    end, "Log should handle nil values")
end

-- 测试循环引用表
local function testCircularReference()
    local t1 = {name = "t1"}
    local t2 = {name = "t2"}
    t1.ref = t2
    t2.ref = t1  -- 循环引用
    
    TestFramework.assertNoError(function()
        Log.Info(t1)
    end, "Log should handle circular references")
end

-- 测试深层嵌套表
local function testDeepNesting()
    -- 创建超过默认深度限制的嵌套表
    local deepTable = {}
    local current = deepTable
    for i = 1, 100 do
        current.next = {level = i}
        current = current.next
    end
    
    TestFramework.assertNoError(function()
        Log.Info(deepTable)
    end, "Log should handle deep nesting with depth limit")
end

-- 测试特殊字符
local function testSpecialCharacters()
    TestFramework.assertNoError(function()
        Log.Info("Special chars: \n\t\r\"'\\")
    end, "Log should handle special characters")
end

-- 测试空表
local function testEmptyTable()
    TestFramework.assertNoError(function()
        Log.PrintT({})
    end, "PrintT should handle empty table")
    
    TestFramework.assertNoError(function()
        Log.PrintT(nil)
    end, "PrintT should handle nil")
end

-- 测试格式化错误
local function testPrintfFormatError()
    -- 测试格式字符串与参数不匹配
    TestFramework.assertNoError(function()
        Log.Printf("Test %s %d", "only one param")
    end, "Printf should handle format mismatch gracefully")
    
    TestFramework.assertNoError(function()
        Log.Printf(nil, "arg1", "arg2")
    end, "Printf should handle nil format string")
end

-- 测试大量日志输出
local function testBulkLogging()
    TestFramework.assertNoError(function()
        for i = 1, 100 do
            Log.Info("Bulk log message", i)
        end
    end, "Log should handle bulk logging")
end

-- 注册测试用例
TestFramework.addTestCase("Log.Config", testConfig)
TestFramework.addTestCase("Log.Error", testError)
TestFramework.addTestCase("Log.Warning", testWarning)
TestFramework.addTestCase("Log.Info", testInfo)
TestFramework.addTestCase("Log.PrintT", testPrintT)
TestFramework.addTestCase("Log.Printf", testPrintf)
TestFramework.addTestCase("Log.MultipleArguments", testMultipleArguments)
TestFramework.addTestCase("Log.TableLogging", testTableLogging)
TestFramework.addTestCase("Log.NilLogging", testNilLogging)
TestFramework.addTestCase("Log.CircularReference", testCircularReference)
TestFramework.addTestCase("Log.DeepNesting", testDeepNesting)
TestFramework.addTestCase("Log.SpecialCharacters", testSpecialCharacters)
TestFramework.addTestCase("Log.EmptyTable", testEmptyTable)
TestFramework.addTestCase("Log.PrintfFormatError", testPrintfFormatError)
TestFramework.addTestCase("Log.BulkLogging", testBulkLogging)

return {
    testConfig = testConfig,
    testError = testError,
    testWarning = testWarning,
    testInfo = testInfo,
    testPrintT = testPrintT,
    testPrintf = testPrintf,
    testMultipleArguments = testMultipleArguments,
    testTableLogging = testTableLogging,
    testNilLogging = testNilLogging,
    testCircularReference = testCircularReference,
    testDeepNesting = testDeepNesting,
    testSpecialCharacters = testSpecialCharacters,
    testEmptyTable = testEmptyTable,
    testPrintfFormatError = testPrintfFormatError,
    testBulkLogging = testBulkLogging
}
