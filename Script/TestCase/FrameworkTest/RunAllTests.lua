---
-- 运行所有 Lua 框架测试用例
-- 使用测试框架和测试运行器
--

-- 设置 Lua 模块搜索路径
local scriptPath = "Script/?.lua;Script/?/init.lua"
package.path = scriptPath .. ";" .. package.path

local TestRunner = require("TestCase.TestRunner")

-- 定义所有测试模块
local testModules = {
    -- Utility 模块测试
    "TestCase.FrameworkTest.TestTableEx",
    "TestCase.FrameworkTest.TestLog",
    "TestCase.FrameworkTest.TestLuaHelper",
    "TestCase.FrameworkTest.TestJsonFile",
    "TestCase.FrameworkTest.TestCsvParser",
    "TestCase.FrameworkTest.TestIniParser",
    "TestCase.FrameworkTest.TestXmlParser",
    "TestCase.FrameworkTest.TestMsgPackFile",
    "TestCase.FrameworkTest.TestInterface",
    
    -- Core 模块测试
    "TestCase.FrameworkTest.TestDelegate",
    "TestCase.FrameworkTest.TestMultiDelegate",
    "TestCase.FrameworkTest.TestObservable",
    "TestCase.FrameworkTest.TestEventDispatcher",
    "TestCase.FrameworkTest.TestEventLoop",
    "TestCase.FrameworkTest.TestHttpHelper",
    "TestCase.FrameworkTest.TestWebSocket",
    "TestCase.FrameworkTest.TestChannel",
    "TestCase.FrameworkTest.TestHistoryManager",
    "TestCase.FrameworkTest.TestProtoDispatcher",
}

-- 运行测试套件
local success = TestRunner.runTestSuite(testModules)

return success
