--
-- IniParser Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local IniParser = require("Utility.IniParser")

local function testParse()
    -- Test parsing a simple INI string
    local iniString = "[section1]\nkey1=value1\nkey2=value2\n[section2]\nkey3=value3"
    local result = IniParser.Parse(iniString)
    
    TestFramework.assertNotNil(result, "IniParser.Parse should return data")
    TestFramework.assertTrue(type(result) == "table", "IniParser.Parse should return a table")
    TestFramework.assertNotNil(result.section1, "IniParser should parse section1")
    TestFramework.assertNotNil(result.section2, "IniParser should parse section2")
    TestFramework.assertEquals(result.section1.key1, "value1", "IniParser should parse key1 correctly")
    TestFramework.assertEquals(result.section1.key2, "value2", "IniParser should parse key2 correctly")
    TestFramework.assertEquals(result.section2.key3, "value3", "IniParser should parse key3 correctly")
end

local function testRead()
    -- Test reading from file
    local result = IniParser.Read("Test/TestCaseData/DefaultGame.ini")
    
    TestFramework.assertNotNil(result, "IniParser.Read should return data")
    TestFramework.assertTrue(type(result) == "table", "IniParser.Read should return a table")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() IniParser.Read(nil) end)
    TestFramework.assertFalse(success, "IniParser.Read should reject nil filename")
    
    success, errorMsg = pcall(function() IniParser.Read(123) end)
    TestFramework.assertFalse(success, "IniParser.Read should reject non-string filename")
end

local function testConfig()
    -- Test configuring the parser
    IniParser.config({
        separator = ":",
        comment = "#",
        trim = false,
        lowercase = true,
        escape = false
    })
    
    TestFramework.assertTrue(true, "IniParser.config should not crash")
    
    -- Reset to default config
    IniParser.config({})
    TestFramework.assertTrue(true, "IniParser.config should accept empty config")
end

-- Register test cases
TestFramework.addTestCase("IniParser.Parse", testParse)
TestFramework.addTestCase("IniParser.Read", testRead)
TestFramework.addTestCase("IniParser.Config", testConfig)

return {
    testParse = testParse,
    testRead = testRead,
    testConfig = testConfig
}