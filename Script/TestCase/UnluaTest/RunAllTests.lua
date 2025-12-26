---
-- 运行所有测试用例
-- 使用新的测试框架和测试运行器
--

local TestRunner = require("TestCase.TestRunner")

-- 定义所有测试模块
local testModules = {
    -- Utility 模块测试
    "TestCase.UnluaTest.TestTableEx",
    "TestCase.UnluaTest.TestLog",
    "TestCase.UnluaTest.TestLuaHelper",
    "TestCase.UnluaTest.TestJsonFile",
    "TestCase.UnluaTest.TestCsvParser",
    "TestCase.UnluaTest.TestIniParser",
    "TestCase.UnluaTest.TestXmlParser",
    "TestCase.UnluaTest.TestMsgPackFile",
    "TestCase.UnluaTest.TestInterface",
    --
    -- Core 模块测试
    "TestCase.UnluaTest.TestEventDispatcher",
    "TestCase.UnluaTest.TestHttpHelper",
    "TestCase.UnluaTest.TestWebSocket",
    "TestCase.UnluaTest.TestChannel",
    "TestCase.UnluaTest.TestDelegate",
    "TestCase.UnluaTest.TestMultiDelegate",
    "TestCase.UnluaTest.TestObservable",
    "TestCase.UnluaTest.TestEventLoop",
    "TestCase.UnluaTest.TestHistoryManager",
    "TestCase.UnluaTest.TestProtoDispatcher",
}

-- 运行测试套件
local success = TestRunner.runTestSuite(testModules)

return success