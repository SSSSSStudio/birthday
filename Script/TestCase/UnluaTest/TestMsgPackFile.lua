--
-- MsgPackFile Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local MsgPackFile = require("Utility.MsgPackFile")

local function testRead()
    -- Prepare data
    local testData = {
        key = "value", 
        number = 42,
        table2 = {key = "su", number = 41}
    }
    local writeResult = MsgPackFile.Write("Test/TestCaseData/Read.msg", testData)
    TestFramework.assertTrue(writeResult, "MsgPackFile.Write should succeed")

    -- Test reading from content directory
    local result = MsgPackFile.Read("Test/TestCaseData/Read.msg")
    TestFramework.assertNotNil(result, "MsgPackFile.Read should return data")
    TestFramework.assertEquals(result.number, 42,"MsgPackFile.Read should return mocked data")
	TestFramework.assertEquals(result.table2.key, "su","MsgPackFile.Read should return mocked data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.Read(nil) end)
    TestFramework.assertFalse(success, "MsgPackFile.Read should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.Read(123) end)
    TestFramework.assertFalse(success, "MsgPackFile.Read should reject non-string filename")
end

local function testWrite()
	local testTable = {
		key = "value", 
		number = 42,
		table2 = {key = "su", number = 41}
	}
    -- Test writing to content directory
    local result = MsgPackFile.Write("Test/TestCaseData/Write.msg",testTable)
    TestFramework.assertNotNil(result, "MsgPackFile.Write should return result")
    TestFramework.assertTrue(result == 0, "MsgPackFile.Write should return positive byte count")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.Write(nil, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.Write should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.Write(123, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.Write should reject non-string filename")
end

local function testReadToSandbox()
    -- Prepare data
    local testData = {
        key = "value", 
        number = 42,
        table2 = {key = "su", number = 41}
    }
    local writeResult = MsgPackFile.WriteToSandbox("Read.msg", testData)
    TestFramework.assertTrue(writeResult, "MsgPackFile.WriteToSandbox should succeed")

    -- Test reading from sandbox directory
    local result = MsgPackFile.ReadFromSandbox("Read.msg")
    TestFramework.assertNotNil(result, "MsgPackFile.ReadFromSandbox should return data")
	TestFramework.assertEquals(result.number, 42,"MsgPackFile.ReadFromSandbox should return mocked data")
	TestFramework.assertEquals(result.table2.key, "su","MsgPackFile.ReadFromSandbox should return mocked data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.ReadFromSandbox(nil) end)
    TestFramework.assertFalse(success, "MsgPackFile.ReadFromSandbox should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.ReadFromSandbox(123) end)
    TestFramework.assertFalse(success, "MsgPackFile.ReadFromSandbox should reject non-string filename")
end

local function testWriteToSandbox()
    -- Test writing to sandbox directory
	local testTable = {
		key = "value",
		number = 42,
		table2 = {key = "su", number = 41}
	}
    local result = MsgPackFile.WriteToSandbox("test.msg",testTable)
    TestFramework.assertNotNil(result, "MsgPackFile.WriteToSandbox should return result")
    TestFramework.assertTrue(result == 0, "MsgPackFile.WriteToSandbox should return positive byte count")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.WriteToSandbox(nil, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.WriteToSandbox should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.WriteToSandbox(123, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.WriteToSandbox should reject non-string filename")
end

-- Register test cases
TestFramework.addTestCase("MsgPackFile.Read", testRead)
TestFramework.addTestCase("MsgPackFile.Write", testWrite)
TestFramework.addTestCase("MsgPackFile.ReadFromSandbox", testReadToSandbox)
TestFramework.addTestCase("MsgPackFile.WriteToSandbox", testWriteToSandbox)

return {
    testRead = testRead,
    testWrite = testWrite,
    testReadToSandbox = testReadToSandbox,
    testWriteToSandbox = testWriteToSandbox
}