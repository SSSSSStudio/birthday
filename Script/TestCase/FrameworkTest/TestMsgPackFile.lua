---
-- MsgPackFile 模块测试用例
-- 测试 Utility.MsgPackFile 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")
local MsgPackFile = require("Utility.MsgPackFile")

-- 测试 Read 方法（API 存在性测试）
local function testRead()
    TestFramework.assertNoError(function()
        -- MsgPackFile.Read 需要文件系统支持，这里只测试 API 存在
        TestFramework.assertNotNil(MsgPackFile.Read, "Read method should exist")
        TestFramework.assertEquals(type(MsgPackFile.Read), "function", "Read should be a function")
    end, "Read API test should not throw exception")
end

-- 测试 Write 方法（API 存在性测试）
local function testWrite()
    TestFramework.assertNoError(function()
        -- MsgPackFile.Write 需要文件系统支持，这里只测试 API 存在
        TestFramework.assertNotNil(MsgPackFile.Write, "Write method should exist")
        TestFramework.assertEquals(type(MsgPackFile.Write), "function", "Write should be a function")
    end, "Write API test should not throw exception")
end

-- 测试 ReadFromSandbox 和 WriteToSandbox 方法（API 存在性测试）
local function testSandboxMethods()
    TestFramework.assertNoError(function()
        -- 测试沙盒方法 API 存在
        TestFramework.assertNotNil(MsgPackFile.ReadFromSandbox, "ReadFromSandbox method should exist")
        TestFramework.assertEquals(type(MsgPackFile.ReadFromSandbox), "function", "ReadFromSandbox should be a function")
        
        TestFramework.assertNotNil(MsgPackFile.WriteToSandbox, "WriteToSandbox method should exist")
        TestFramework.assertEquals(type(MsgPackFile.WriteToSandbox), "function", "WriteToSandbox should be a function")
    end, "Sandbox methods API test should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("MsgPackFile.Read", testRead)
TestFramework.addTestCase("MsgPackFile.Write", testWrite)
TestFramework.addTestCase("MsgPackFile.SandboxMethods", testSandboxMethods)

return {
    testRead = testRead,
    testWrite = testWrite,
    testSandboxMethods = testSandboxMethods
}
