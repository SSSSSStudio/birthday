---
-- CsvParser 模块测试用例
-- 测试 Utility.CsvParser 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

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
-- 已知问题：CsvParser.lua 模块存在 bug（第 49 行未检查 data[1] 是否为 nil）
-- 此测试会失败，用于记录模块的已知问题
local function testParseEmpty()
    local csvContent = ""
    
    TestFramework.assertNoError(function()
        local result = CsvParser.Parse(csvContent)
        -- 空内容应该返回 nil，这是预期行为
        TestFramework.assertNil(result, "Parse should return nil for empty content")
    end, "Parse should handle empty content")
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
