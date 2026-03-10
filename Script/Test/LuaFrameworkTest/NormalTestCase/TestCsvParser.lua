---
-- CsvParser 模块测试用例
-- 测试 Utility.CsvParser 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")

-- Mock lpeg 模块
package.loaded["lpeg"] = package.loaded["lpeg"] or require("lpeg")

-- Mock lproject 模块
package.loaded["lproject"] = package.loaded["lproject"] or {
    get_content_dir = function() return "" end
}

local CsvParser = require("Utility.CsvParser")

-- 测试 Parse 函数
-- CSV 格式要求：第1行是列名，第2行是数据类型，第3行开始是数据
local function testParse()
    local csvContent = "name,age,city\nstring,int,string\nAlice,30,Beijing\nBob,25,Shanghai"
    
    local result = CsvParser.Parse(csvContent)
    
    TestFramework.assertNotNil(result, "Parse should return a table")
    TestFramework.assertTrue(#result >= 2, "Parse should return at least 2 rows")
    TestFramework.assertEquals(result:Count(), 2, "Should have 2 data rows")
end

-- 测试带引号的 CSV 解析
local function testParseWithQuotes()
    local csvContent = 'name,description\nstring,string\n"Alice","A person"\n"Bob","Another person"'
    
    TestFramework.assertNoError(function()
        local result = CsvParser.Parse(csvContent)
        TestFramework.assertNotNil(result, "Parse should return a table")
        TestFramework.assertEquals(result:Count(), 2, "Should have 2 data rows")
    end, "Parse should handle quoted values")
end

-- 测试空 CSV 解析
-- 预期：空内容应该返回 nil 或空表，而不是抛出异常
-- 实际：CsvParser.lua 第 49 行存在 bug，未检查 data[1] 是否为 nil，会抛出异常
local function testParseEmpty()
    local csvContent = ""
    
    -- 期望：Parse 应该优雅地处理空内容，返回 nil
    local result = CsvParser.Parse(csvContent)
    TestFramework.assertNil(result, "Parse should return nil for empty content")
end

-- 注册测试用例
TestFramework.addTestCase("CsvParser.Parse", testParse)
TestFramework.addTestCase("CsvParser.ParseWithQuotes", testParseWithQuotes)
TestFramework.addTestCase("CsvParser.ParseEmpty", testParseEmpty)

return {
    testParse = testParse,
    testParseWithQuotes = testParseWithQuotes,
    testParseEmpty = testParseEmpty
}
