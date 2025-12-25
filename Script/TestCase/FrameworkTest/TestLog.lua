---
-- Log 模块测试用例
-- 测试 Utility.Log 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")
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

-- 注册测试用例
TestFramework.addTestCase("Log.Config", testConfig)
TestFramework.addTestCase("Log.Error", testError)
TestFramework.addTestCase("Log.Warning", testWarning)
TestFramework.addTestCase("Log.Info", testInfo)
TestFramework.addTestCase("Log.PrintT", testPrintT)
TestFramework.addTestCase("Log.Printf", testPrintf)

return {
    testConfig = testConfig,
    testError = testError,
    testWarning = testWarning,
    testInfo = testInfo,
    testPrintT = testPrintT,
    testPrintf = testPrintf
}
