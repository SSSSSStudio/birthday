---
-- JsonFile 模块测试用例
-- 测试 Utility.JsonFile 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")

-- 在 UE 环境下，直接使用真实的 lproject 和 ljson 模块
-- 这些模块由 LuaExtension 插件提供，无需 mock

local JsonFile = require("Utility.JsonFile")

-- 测试 Read 函数（API 存在性测试）
local function testRead()
    TestFramework.assertNoError(function()
        -- JsonFile.Read 需要文件系统支持，这里只测试 API 存在
        TestFramework.assertNotNil(JsonFile.Read, "Read method should exist")
        TestFramework.assertEquals(type(JsonFile.Read), "function", "Read should be a function")
    end, "Read API test should not throw exception")
end

-- 测试 Write 函数（API 存在性测试）
local function testWrite()
    TestFramework.assertNoError(function()
        -- JsonFile.Write 需要文件系统支持，这里只测试 API 存在
        TestFramework.assertNotNil(JsonFile.Write, "Write method should exist")
        TestFramework.assertEquals(type(JsonFile.Write), "function", "Write should be a function")
    end, "Write API test should not throw exception")
end

-- 测试 ReadFromSandbox 和 WriteToSandbox 函数（API 存在性测试）
local function testSandboxMethods()
    TestFramework.assertNoError(function()
        TestFramework.assertNotNil(JsonFile.ReadFromSandbox, "ReadFromSandbox method should exist")
        TestFramework.assertNotNil(JsonFile.WriteToSandbox, "WriteToSandbox method should exist")
        TestFramework.assertEquals(type(JsonFile.ReadFromSandbox), "function", "ReadFromSandbox should be a function")
        TestFramework.assertEquals(type(JsonFile.WriteToSandbox), "function", "WriteToSandbox should be a function")
    end, "Sandbox methods test should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("JsonFile.Read", testRead)
TestFramework.addTestCase("JsonFile.Write", testWrite)
TestFramework.addTestCase("JsonFile.SandboxMethods", testSandboxMethods)

return {
    testRead = testRead,
    testWrite = testWrite,
    testSandboxMethods = testSandboxMethods
}
