--
-- JsonFile Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local JsonFile = require("Utility.JsonFile")

local function testRead()
    -- Test reading from content directory
    local result = JsonFile.Read("test.json")
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

local function testReadToSandbox()
    -- Test reading from sandbox directory
    local result = JsonFile.ReadToSandbox("test.json")
    TestFramework.assertNotNil(result, "JsonFile.ReadToSandbox should return data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() JsonFile.ReadToSandbox(nil) end)
    TestFramework.assertFalse(success, "JsonFile.ReadToSandbox should reject nil filename")
    
    success, errorMsg = pcall(function() JsonFile.ReadToSandbox(123) end)
    TestFramework.assertFalse(success, "JsonFile.ReadToSandbox should reject non-string filename")
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
TestFramework.addTestCase("JsonFile.ReadToSandbox", testReadToSandbox)
TestFramework.addTestCase("JsonFile.WriteToSandbox", testWriteToSandbox)

return {
    testRead = testRead,
    testWrite = testWrite,
    testReadToSandbox = testReadToSandbox,
    testWriteToSandbox = testWriteToSandbox
}