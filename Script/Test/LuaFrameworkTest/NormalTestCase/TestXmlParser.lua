---
-- XmlParser 模块测试用例
-- 测试 Utility.XmlParser 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")
local XmlParser = require("Utility.XmlParser")

-- 测试 Parse 函数
local function testParse()
    local xmlContent = [[
<root>
    <item id="1">Value1</item>
    <item id="2">Value2</item>
</root>
]]
    
    TestFramework.assertNoError(function()
        local result = XmlParser.Parse(xmlContent)
        TestFramework.assertNotNil(result, "Parse should return a table")
    end, "Parse should handle valid XML")
end

-- 测试简单 XML 解析
local function testParseSimple()
    local xmlContent = "<root><child>text</child></root>"
    
    TestFramework.assertNoError(function()
        local result = XmlParser.Parse(xmlContent)
        TestFramework.assertNotNil(result)
    end, "Parse should handle simple XML")
end

-- 测试空 XML 解析
local function testParseEmpty()
    local xmlContent = ""
    
    TestFramework.assertNoError(function()
        XmlParser.Parse(xmlContent)
    end, "Parse should handle empty content gracefully")
end

-- 注册测试用例
TestFramework.addTestCase("XmlParser.Parse", testParse)
TestFramework.addTestCase("XmlParser.ParseSimple", testParseSimple)
TestFramework.addTestCase("XmlParser.ParseEmpty", testParseEmpty)

return {
    testParse = testParse,
    testParseSimple = testParseSimple,
    testParseEmpty = testParseEmpty
}
