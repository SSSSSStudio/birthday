--
-- CsvParser Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local CsvParser = require("Utility.CsvParser")
local csvPath = "Test/TestCaseData/Character.csv"
local function testParse()
    -- Test parsing a simple CSV string

	local csvString = "name,age\nstring,int\nJohn,25\nJane,30"
	local result = CsvParser.Parse(csvString)

	TestFramework.assertNotNil(result, "CsvParser.Parse should return data")
	TestFramework.assertTrue(type(result) == "table", "CsvParser.Parse should return a table")
	TestFramework.assertEquals(result:Count(), 2, "CsvParser should have 2 data rows")

	-- Test getting a value
	local value = result:GetValue(1, "name")
	TestFramework.assertEquals(value, "John", "GetValue should return correct value")

	-- Test getting a row
	local row = result:GetRow(1)
	TestFramework.assertNotNil(row, "GetRow should return a row")
	TestFramework.assertEquals(#row, 2, "Row should have 2 columns")
end

local function testRead()
    -- Test reading from file
    local result = CsvParser.Read(csvPath)
    
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