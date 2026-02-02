--
-- JsonFile Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local JsonFile = require("Utility.JsonFile")
local JsonFilePath = "Test/TestCaseData/UGC_SG.json";
local WriteJsonFilePath = "Test/TestCaseData/Test_Write.json";
local function testRead()
    -- Test reading from content directory
    local result = JsonFile.Read(JsonFilePath)
    TestFramework.assertNotNil(result, "JsonFile.Read should return data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() JsonFile.Read(nil) end)
    TestFramework.assertFalse(success, "JsonFile.Read should reject nil filename")
    
    success, errorMsg = pcall(function() JsonFile.Read(123) end)
    TestFramework.assertFalse(success, "JsonFile.Read should reject non-string filename")
end

local function testWrite()
    -- Test writing to content directory
    local testData = {key = "value", number = 42}
    local result = JsonFile.Write("test.json", testData)
    TestFramework.assertNotNil(result, "JsonFile.Write should return result")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() JsonFile.Write(nil, testData) end)
    TestFramework.assertFalse(success, "JsonFile.Write should reject nil filename")
    
    -- Test with invalid data
    success, errorMsg = pcall(function() JsonFile.Write("test.json", "not a table") end)
    TestFramework.assertFalse(success, "JsonFile.Write should reject non-table data")
    
    success, errorMsg = pcall(function() JsonFile.Write("test.json", nil) end)
    TestFramework.assertFalse(success, "JsonFile.Write should reject nil data")
end

local function testReadFromSandbox()

    -- Prepare data
    local testData = {key = "value", number = 42}
    local writeResult = JsonFile.WriteToSandbox("UGC_SG.json", testData)
    TestFramework.assertTrue(writeResult, "JsonFile.WriteToSandbox should succeed")

    -- Test reading from sandbox directory
    local result = JsonFile.ReadFromSandbox("UGC_SG.json")
    TestFramework.assertNotNil(result, "JsonFile.ReadFromSandbox should return data")
    TestFramework.assertEquals(result.number, 42, "JsonFile.ReadFromSandbox should return correct data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() JsonFile.ReadFromSandbox(nil) end)
    TestFramework.assertFalse(success, "JsonFile.ReadFromSandbox should reject nil filename")
    
    success, errorMsg = pcall(function() JsonFile.ReadFromSandbox(123) end)
    TestFramework.assertFalse(success, "JsonFile.ReadFromSandbox should reject non-string filename")
end

local function testWriteToSandbox()
    -- Test writing to sandbox directory
    local testData = {key = "value", number = 42}
    local result = JsonFile.WriteToSandbox("test.json", testData)
    TestFramework.assertNotNil(result, "JsonFile.WriteToSandbox should return result")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() JsonFile.WriteToSandbox(nil, testData) end)
    TestFramework.assertFalse(success, "JsonFile.WriteToSandbox should reject nil filename")
    
    -- Test with invalid data
    success, errorMsg = pcall(function() JsonFile.WriteToSandbox("test.json", "not a table") end)
    TestFramework.assertFalse(success, "JsonFile.WriteToSandbox should reject non-table data")
    
    success, errorMsg = pcall(function() JsonFile.WriteToSandbox("test.json", nil) end)
    TestFramework.assertFalse(success, "JsonFile.WriteToSandbox should reject nil data")
end

-- Register test cases
TestFramework.addTestCase("JsonFile.Read", testRead)
TestFramework.addTestCase("JsonFile.Write", testWrite)
TestFramework.addTestCase("JsonFile.ReadFromSandbox", testReadFromSandbox)
TestFramework.addTestCase("JsonFile.WriteToSandbox", testWriteToSandbox)

return {
    testRead = testRead,
    testWrite = testWrite,
    testReadFromSandbox = testReadFromSandbox,
    testWriteToSandbox = testWriteToSandbox
}