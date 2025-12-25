---
-- CsvParser Module Tests
--

local TestFramework = require("UnluaTest.init")

-- Mock the lpeg module for testing
package.loaded.lpeg = {
    P = function(pattern)
        if pattern == '\r\n' or pattern == '\n' then
            return {type = "eol"}
        end
        return {type = "pattern", value = pattern}
    end,
    S = function(chars)
        return {type = "set", chars = chars}
    end,
    C = function(pattern)
        return {type = "capture", pattern = pattern}
    end,
    Ct = function(pattern)
        return {type = "table_capture", pattern = pattern}
    end,
    Cs = function(pattern)
        return {type = "substitution_capture", pattern = pattern}
    end,
    match = function(grammar, input)
        -- Mock implementation for testing
        if input == "name,age\nstring,int\nJohn,25\nJane,30" then
            return {
                {"name", "age"},
                {"string", "int"},
                {"John", "25"},
                {"Jane", "30"}
            }
        end
        return nil
    end
}

-- Mock the lproject module
package.loaded.lproject = {
    get_content_dir = function()
        return "Content/"
    end
}

-- Mock the UE.File class
local mockFile = {}
mockFile.Open = function(self, path, mode)
    self.path = path
    self.mode = mode
    return true
end
mockFile.TotalSize = function(self)
    return 100
end
mockFile.Read = function(self, size)
    return "name,age\nstring,int\nJohn,25\nJane,30"
end
mockFile.Close = function(self)
    return true
end

-- Mock UE module
package.loaded.UE = {
    File = function()
        return mockFile
    end
}

local CsvParser = require("Utility.CsvParser")

function testParse()
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
    
    -- Test with invalid input
    local result2 = CsvParser.Parse(nil)
    TestFramework.assertNil(result2, "CsvParser.Parse should return nil for nil input")
    
    local result3 = CsvParser.Parse(123)
    TestFramework.assertNil(result3, "CsvParser.Parse should return nil for non-string input")
end

function testRead()
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
