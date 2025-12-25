--
-- XmlParser Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local XmlParser = require("Utility.XmlParser")

local function testParse()
    local xmlString = "<root><element>test</element></root>"
    local result = XmlParser.Parse(xmlString)
    
    TestFramework.assertNotNil(result, "XmlParser.Parse should return data")
    TestFramework.assertTrue(result.mocked, "XmlParser.Parse should return mocked data")
    TestFramework.assertEquals(result.content, xmlString, "XmlParser.Parse should return correct content")
    
    -- Test with invalid input
    local success, errorMsg = pcall(function() XmlParser.Parse(nil) end)
    TestFramework.assertFalse(success, "XmlParser.Parse should reject nil input")
    
    success, errorMsg = pcall(function() XmlParser.Parse(123) end)
    TestFramework.assertFalse(success, "XmlParser.Parse should reject non-string input")
end

local function testRead()
    local result = XmlParser.Read("test.xml")
    
    TestFramework.assertNotNil(result, "XmlParser.Read should return data")
    TestFramework.assertTrue(result.mocked, "XmlParser.Read should return mocked data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() XmlParser.Read(nil) end)
    TestFramework.assertFalse(success, "XmlParser.Read should reject nil filename")
    
    success, errorMsg = pcall(function() XmlParser.Read(123) end)
    TestFramework.assertFalse(success, "XmlParser.Read should reject non-string filename")
end

-- Register test cases
TestFramework.addTestCase("XmlParser.Parse", testParse)
TestFramework.addTestCase("XmlParser.Read", testRead)

return {
    testParse = testParse,
    testRead = testRead
}