---
-- IniParser 模块测试用例
-- 测试 Utility.IniParser 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")
local IniParser = require("Utility.IniParser")

-- 测试 Parse 函数
local function testParse()
    local iniContent = [[
[Section1]
key1=value1
key2=value2

[Section2]
key3=value3
]]
    
    local result = IniParser.Parse(iniContent)
    
    TestFramework.assertNotNil(result, "Parse should return a table")
    TestFramework.assertNotNil(result.Section1, "Parse should contain Section1")
    TestFramework.assertEquals(result.Section1.key1, "value1", "Parse should read key1 correctly")
end

-- 测试空 INI 解析
local function testParseEmpty()
    local iniContent = ""
    
    TestFramework.assertNoError(function()
        local result = IniParser.Parse(iniContent)
    end, "Parse should handle empty content")
end

-- 测试带注释的 INI 解析
local function testParseWithComments()
    local iniContent = [[
; This is a comment
[Section1]
key1=value1  ; inline comment
# Another comment style
key2=value2
]]
    
    TestFramework.assertNoError(function()
        local result = IniParser.Parse(iniContent)
        TestFramework.assertNotNil(result)
    end, "Parse should handle comments")
end

-- 注册测试用例
TestFramework.addTestCase("IniParser.Parse", testParse)
TestFramework.addTestCase("IniParser.ParseEmpty", testParseEmpty)
TestFramework.addTestCase("IniParser.ParseWithComments", testParseWithComments)

return {
    testParse = testParse,
    testParseEmpty = testParseEmpty,
    testParseWithComments = testParseWithComments
}
