---
-- 运行所有测试用例
-- 使用新的测试框架和测试运行器
--

local TestRunner = require("Test.LuaFrameworkTest.TestRunner")

-- 定义所有测试模块
local testModules = {
    -- Utility 模块测试
    "Test.LuaFrameworkTest.FullTestCase.TestTableEx",
    "Test.LuaFrameworkTest.FullTestCase.TestLog",
    "Test.LuaFrameworkTest.FullTestCase.TestLuaHelper",
    "Test.LuaFrameworkTest.FullTestCase.TestJsonFile",
    "Test.LuaFrameworkTest.FullTestCase.TestCsvParser",
    "Test.LuaFrameworkTest.FullTestCase.TestIniParser",
    "Test.LuaFrameworkTest.FullTestCase.TestXmlParser",
    "Test.LuaFrameworkTest.FullTestCase.TestMsgPackFile",
    "Test.LuaFrameworkTest.FullTestCase.TestInterface",
    ----
    ---- Core 模块测试
    "Test.LuaFrameworkTest.FullTestCase.TestEventDispatcher",
    "Test.LuaFrameworkTest.FullTestCase.TestHttpHelper",
    "Test.LuaFrameworkTest.FullTestCase.TestWebSocket",
    "Test.LuaFrameworkTest.FullTestCase.TestChannel",
    "Test.LuaFrameworkTest.FullTestCase.TestDelegate",
    "Test.LuaFrameworkTest.FullTestCase.TestMultiDelegate",
    "Test.LuaFrameworkTest.FullTestCase.TestObservable",
    "Test.LuaFrameworkTest.FullTestCase.TestEventLoop",
    "Test.LuaFrameworkTest.FullTestCase.TestHistoryManager",
    "Test.LuaFrameworkTest.FullTestCase.TestProtoDispatcher",
    "Test.LuaFrameworkTest.FullTestCase.TestFixed",
}

-- 运行测试套件
local success = TestRunner.runTestSuite(testModules)

return success