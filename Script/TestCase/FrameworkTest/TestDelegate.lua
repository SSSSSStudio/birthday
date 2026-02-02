---
-- Delegate 模块测试用例
-- 测试 Core.Delegate 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")

-- Mock Interface 模块已移除，直接使用 Utility.Interface

local Delegate = require("Core.Delegate")

-- 测试初始化
local function testInit()
    local delegate = Delegate()
    
    TestFramework.assertNotNil(delegate, "Delegate should be created")
    TestFramework.assertNil(delegate.obj, "Delegate obj should be nil initially")
    TestFramework.assertNil(delegate.func, "Delegate func should be nil initially")
end

-- 测试 Bind 函数
local function testBind()
    local delegate = Delegate()
    
    local function testFunc()
        return "test"
    end
    
    local result = delegate:Bind(testFunc)
    
    TestFramework.assertTrue(result, "Bind should return true")
    TestFramework.assertEquals(delegate.func, testFunc, "Delegate func should be set")
    
    -- 测试重复绑定
    local result2 = delegate:Bind(testFunc)
    TestFramework.assertFalse(result2, "Bind should return false when already bound")
end

-- 测试 BindObject 函数
local function testBindObject()
    local delegate = Delegate()
    local testObj = {value = 100}
    
    local function testMethod(obj, arg)
        return obj.value + arg
    end
    
    local result = delegate:BindObject(testObj, testMethod)
    
    TestFramework.assertTrue(result, "BindObject should return true")
    TestFramework.assertEquals(delegate.obj, testObj, "Delegate obj should be set")
    TestFramework.assertEquals(delegate.func, testMethod, "Delegate func should be set")
end

-- 测试 Unbind 函数
local function testUnbind()
    local delegate = Delegate()
    
    local function testFunc()
        return "test"
    end
    
    delegate:Bind(testFunc)
    delegate:Unbind()
    
    TestFramework.assertNil(delegate.obj, "Delegate obj should be nil after unbind")
    TestFramework.assertNil(delegate.func, "Delegate func should be nil after unbind")
end

-- 测试 Execute 函数
local function testExecute()
    local delegate = Delegate()
    local executeCount = 0
    
    local function testFunc(arg1, arg2)
        executeCount = executeCount + 1
        return arg1 + arg2
    end
    
    -- 未绑定时执行
    local result = delegate:Execute(1, 2)
    TestFramework.assertFalse(result, "Execute should return false when not bound")
    
    -- 绑定后执行
    delegate:Bind(testFunc)
    local result2 = delegate:Execute(10, 20)
    TestFramework.assertTrue(result2, "Execute should return true when bound")
    TestFramework.assertEquals(executeCount, 1, "Function should be executed once")
end

-- 测试 ExecuteWithObject 函数
local function testExecuteWithObject()
    local delegate = Delegate()
    local testObj = {value = 50}
    
    local function testMethod(obj, arg)
        obj.value = obj.value + arg
        return obj.value
    end
    
    delegate:BindObject(testObj, testMethod)
    local result = delegate:Execute(25)
    
    TestFramework.assertTrue(result, "Execute should return true")
    TestFramework.assertEquals(testObj.value, 75, "Object value should be updated")
end

-- 测试 IsValid 函数
local function testIsValid()
    local delegate = Delegate()
    
    -- 未绑定时
    TestFramework.assertFalse(delegate:IsValid(), "IsValid should return false when not bound")
    
    -- 绑定后
    local function testFunc()
        return "test"
    end
    delegate:Bind(testFunc)
    TestFramework.assertTrue(delegate:IsValid(), "IsValid should return true when bound")
    
    -- 解绑后
    delegate:Unbind()
    TestFramework.assertFalse(delegate:IsValid(), "IsValid should return false after unbind")
end

-- 注册测试用例
TestFramework.addTestCase("Delegate.Init", testInit)
TestFramework.addTestCase("Delegate.Bind", testBind)
TestFramework.addTestCase("Delegate.BindObject", testBindObject)
TestFramework.addTestCase("Delegate.Unbind", testUnbind)
TestFramework.addTestCase("Delegate.Execute", testExecute)
TestFramework.addTestCase("Delegate.ExecuteWithObject", testExecuteWithObject)
TestFramework.addTestCase("Delegate.IsValid", testIsValid)

return {
    testInit = testInit,
    testBind = testBind,
    testBindObject = testBindObject,
    testUnbind = testUnbind,
    testExecute = testExecute,
    testExecuteWithObject = testExecuteWithObject,
    testIsValid = testIsValid
}
