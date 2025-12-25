---
-- 运行所有 Lua 框架测试用例
-- 使用测试框架和测试运行器
--
-- 测试覆盖统计：
-- - 总测试模块：19 个
-- - 总测试用例：约 140+ 个（增强后）
-- - Core 模块：10 个
-- - Utility 模块：9 个
--
-- 增强内容：
-- - LuaHelper：从 2 个测试增加到 8 个（覆盖率从 22% 提升到 100%）
-- - MultiDelegate：从 6 个测试增加到 12 个（增加边界和异常测试）
-- - EventDispatcher：从 5 个测试增加到 11 个（增加错误处理和顺序测试）
-- - Log：从 6 个测试增加到 15 个（增加复杂场景测试）
-- - Channel：从 4 个测试增加到 13 个（增加连接失败和超时测试）
--

-- 设置 Lua 模块搜索路径
local scriptPath = "Script/?.lua;Script/?/init.lua"
package.path = scriptPath .. ";" .. package.path

local TestRunner = require("TestCase.TestRunner")

-- 定义所有测试模块
local testModules = {
    -- Utility 模块测试（9个模块）
    "TestCase.FrameworkTest.TestTableEx",        -- 17 个测试
    "TestCase.FrameworkTest.TestLog",            -- 15 个测试（增强）
    "TestCase.FrameworkTest.TestLuaHelper",      -- 8 个测试（增强）
    "TestCase.FrameworkTest.TestJsonFile",       -- 3 个测试
    "TestCase.FrameworkTest.TestCsvParser",      -- 3 个测试
    "TestCase.FrameworkTest.TestIniParser",      -- 3 个测试
    "TestCase.FrameworkTest.TestXmlParser",      -- 3 个测试
    "TestCase.FrameworkTest.TestMsgPackFile",    -- 3 个测试
    "TestCase.FrameworkTest.TestInterface",      -- 4 个测试
    
    -- Core 模块测试（10个模块）
    "TestCase.FrameworkTest.TestDelegate",       -- 7 个测试
    "TestCase.FrameworkTest.TestMultiDelegate",  -- 12 个测试（增强）
    "TestCase.FrameworkTest.TestObservable",     -- 5 个测试
    "TestCase.FrameworkTest.TestEventDispatcher",-- 11 个测试（增强）
    "TestCase.FrameworkTest.TestEventLoop",      -- 5 个测试
    "TestCase.FrameworkTest.TestHttpHelper",     -- 3 个测试
    "TestCase.FrameworkTest.TestWebSocket",      -- 4 个测试
    "TestCase.FrameworkTest.TestChannel",        -- 13 个测试（增强）
    "TestCase.FrameworkTest.TestHistoryManager", -- 5 个测试
    "TestCase.FrameworkTest.TestProtoDispatcher",-- 4 个测试
}

-- 运行测试套件
local success = TestRunner.runTestSuite(testModules)

return success
