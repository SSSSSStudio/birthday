---
-- MsgPackFile Module Tests
--

local TestFramework = require("UnluaTest.init")

-- Mock the lmsgpack module
local mockLmsgpack = {
    encode = function(...)
        return "encoded_data"
    end,
    decode = function(s)
        return {mocked = true, data = s}
    end
}

package.loaded["lmsgpack"] = mockLmsgpack

-- Mock the lproject module
package.loaded["lproject"] = {
    get_content_dir = function()
        return "Content/"
    end,
    get_app_sandboxes_dir = function()
        return "Sandbox/"
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
    return "encoded_data"
end
mockFile.Write = function(self, data)
    self.writtenData = data
    return #data
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

local MsgPackFile = require("Utility.MsgPackFile")

function testRead()
    -- Test reading from content directory
    local result = MsgPackFile.Read("test.msgpack")
    TestFramework.assertNotNil(result, "MsgPackFile.Read should return data")
    TestFramework.assertTrue(result.mocked, "MsgPackFile.Read should return mocked data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.Read(nil) end)
    TestFramework.assertFalse(success, "MsgPackFile.Read should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.Read(123) end)
    TestFramework.assertFalse(success, "MsgPackFile.Read should reject non-string filename")
end

function testWrite()
    -- Test writing to content directory
    local result = MsgPackFile.Write("test.msgpack", {key = "value", number = 42})
    TestFramework.assertNotNil(result, "MsgPackFile.Write should return result")
    TestFramework.assertTrue(result > 0, "MsgPackFile.Write should return positive byte count")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.Write(nil, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.Write should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.Write(123, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.Write should reject non-string filename")
end

function testReadToSandbox()
    -- Test reading from sandbox directory
    local result = MsgPackFile.ReadToSandbox("test.msgpack")
    TestFramework.assertNotNil(result, "MsgPackFile.ReadToSandbox should return data")
    TestFramework.assertTrue(result.mocked, "MsgPackFile.ReadToSandbox should return mocked data")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.ReadToSandbox(nil) end)
    TestFramework.assertFalse(success, "MsgPackFile.ReadToSandbox should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.ReadToSandbox(123) end)
    TestFramework.assertFalse(success, "MsgPackFile.ReadToSandbox should reject non-string filename")
end

function testWriteToSandbox()
    -- Test writing to sandbox directory
    local result = MsgPackFile.WriteToSandbox("test.msgpack", {key = "value", number = 42})
    TestFramework.assertNotNil(result, "MsgPackFile.WriteToSandbox should return result")
    TestFramework.assertTrue(result > 0, "MsgPackFile.WriteToSandbox should return positive byte count")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() MsgPackFile.WriteToSandbox(nil, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.WriteToSandbox should reject nil filename")
    
    success, errorMsg = pcall(function() MsgPackFile.WriteToSandbox(123, {key = "value"}) end)
    TestFramework.assertFalse(success, "MsgPackFile.WriteToSandbox should reject non-string filename")
end

-- Register test cases
TestFramework.addTestCase("MsgPackFile.Read", testRead)
TestFramework.addTestCase("MsgPackFile.Write", testWrite)
TestFramework.addTestCase("MsgPackFile.ReadToSandbox", testReadToSandbox)
TestFramework.addTestCase("MsgPackFile.WriteToSandbox", testWriteToSandbox)

return {
    testRead = testRead,
    testWrite = testWrite,
    testReadToSandbox = testReadToSandbox,
    testWriteToSandbox = testWriteToSandbox
}
