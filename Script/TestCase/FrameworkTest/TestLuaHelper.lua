---
-- LuaHelper 模块测试用例
-- 测试 Utility.LuaHelper 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")
local LuaHelper = require("Utility.LuaHelper")

-- 测试 XpCall 函数
local function testXpCall()
    -- 测试正常执行
    local success, result = LuaHelper.XpCall(function()
        return "success"
    end)
    
    TestFramework.assertTrue(success, "XpCall should succeed for normal function")
    TestFramework.assertEquals(result, "success", "XpCall should return correct result")
    
    -- 测试错误处理
    local success2, error2 = LuaHelper.XpCall(function()
        error("test error")
    end)
    
    TestFramework.assertFalse(success2, "XpCall should fail for error function")
    TestFramework.assertNotNil(error2, "XpCall should return error message")
end

-- 测试 DisableGlobalVariable 函数
local function testDisableGlobalVariable()
    -- 测试禁用全局变量
    TestFramework.assertNoError(function()
        LuaHelper.DisableGlobalVariable()
    end, "DisableGlobalVariable should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("LuaHelper.XpCall", testXpCall)
TestFramework.addTestCase("LuaHelper.DisableGlobalVariable", testDisableGlobalVariable)

return {
    testXpCall = testXpCall,
    testDisableGlobalVariable = testDisableGlobalVariable
}
