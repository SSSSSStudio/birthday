--
-- CsvParser Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local CsvParser = require("Utility.CsvParser")

local function testParse()
    -- Test parsing a simple CSV string
    local csvPath = "Test/Csv/Character.csv"
    local result = CsvParser.Read(csvPath)
    
    TestFramework.assertNotNil(result, "CsvParser.Parse should return data")
    TestFramework.assertTrue(type(result) == "table", "CsvParser.Parse should return a table")
    TestFramework.assertEquals(result:Count(), 2, "CsvParser should have 2 data rows")
    
    -- Test getting a value
    local value = result:GetValue(3, "AssetName")
    TestFramework.assertEquals(value, "Jiayu", "GetValue should return correct value")
    
    -- Test getting a row
    local row = result:GetRow(1)
    TestFramework.assertNotNil(row, "GetRow should return a row")
    TestFramework.assertEquals(#row, 22, "Row should have 2 columns")
    
    -- Test with invalid input
    local result2 = CsvParser.Parse(nil)
    TestFramework.assertNil(result2, "CsvParser.Parse should return nil for nil input")
    
    local result3 = CsvParser.Parse(123)
    TestFramework.assertNil(result3, "CsvParser.Parse should return nil for non-string input")
end

local function testRead()
    -- Test reading from file
    local result = CsvParser.Read("test.csv")
    
    TestFramework.assertNotNil(result, "CsvParser.Read should return data")
    TestFramework.assertTrue(type(result) == "table", "CsvParser.Read should return a table")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() CsvParser.Read(nil) end)
    TestFramework.assertFalse(success, "CsvParser.Read should reject nil filename")
    
    success, errorMsg = pcall(function() CsvParser.Read(123) end)
    TestFramework.assertFalse(success, "CsvParser.Read should reject non-string filename")
end

-- Register test cases
TestFramework.addTestCase("CsvParser.Parse", testParse)
TestFramework.addTestCase("CsvParser.Read", testRead)

return {
    testParse = testParse,
    testRead = testRead
}