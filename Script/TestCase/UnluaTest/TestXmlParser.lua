--
-- XmlParser Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local XmlParser = require("Utility.XmlParser")

local function testParse()
    local xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Configuration xmlns=\"https://www.unrealengine.com/BuildConfiguration\"> </Configuration>"
    local result = XmlParser.Parse(xmlString)
	TestFramework.assertNotNil(result, "XmlParser.Parse should return data")
	TestFramework.assertEquals(result.xmlns, "https://www.unrealengine.com/BuildConfiguration","XmlParser.Read should return str data")
end

local function testRead()
    local result = XmlParser.Read("Test/TestCaseData/BuildConfiguration.xml")
    
    TestFramework.assertNotNil(result, "XmlParser.Read should return data")
    TestFramework.assertEquals(result.xmlns, "https://www.unrealengine.com/BuildConfiguration","XmlParser.Read should return str data")
    
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