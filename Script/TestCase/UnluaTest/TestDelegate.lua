--
-- Delegate Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local Delegate = require("Core.Delegate")

local function testInit()
    local delegate = Delegate:New()
    
    TestFramework.assertNotNil(delegate, "Delegate should be created")
    TestFramework.assertNil(delegate.obj, "Delegate obj should be nil initially")
    TestFramework.assertNil(delegate.func, "Delegate func should be nil initially")
end

local function testBind()
    local delegate = Delegate:New()
    
    local function testFunc()
        -- Test function
    end
    
    local result = delegate:Bind(testFunc)
    
    TestFramework.assertTrue(result, "Bind should return true")
    TestFramework.assertEquals(delegate.func, testFunc, "Delegate func should be set")
    
    -- Test binding again (should fail)
    local result2 = delegate:Bind(testFunc)
    TestFramework.assertFalse(result2, "Bind should return false when already bound")
end

local function testBindWithInvalidFunc()
    local delegate = Delegate:New()
    
    -- Test with nil function
    local success, errorMsg = pcall(function() delegate:Bind(nil) end)
    TestFramework.assertFalse(success, "Bind should reject nil function")
    
    -- Test with non-function
    success, errorMsg = pcall(function() delegate:Bind("not a function") end)
    TestFramework.assertFalse(success, "Bind should reject non-function")
end

local function testBindObject()
    local delegate = Delegate:New()
    local testObj = {}
    
    local function testMethod()
        -- Test method
    end
    
    local result = delegate:BindObject(testObj, testMethod)
    
    TestFramework.assertTrue(result, "BindObject should return true")
    TestFramework.assertEquals(delegate.obj, testObj, "Delegate obj should be set")
    TestFramework.assertEquals(delegate.func, testMethod, "Delegate func should be set")
    
    -- Test binding again (should fail)
    local result2 = delegate:BindObject(testObj, testMethod)
    TestFramework.assertFalse(result2, "BindObject should return false when already bound")
end

local function testBindObjectWithInvalidParams()
    local delegate = Delegate:New()
    local testObj = {}
    
    local function testMethod()
        -- Test method
    end
    
    -- Test with nil object
    local success, errorMsg = pcall(function() delegate:BindObject(nil, testMethod) end)
    TestFramework.assertFalse(success, "BindObject should reject nil object")
    
    -- Test with non-table object
    success, errorMsg = pcall(function() delegate:BindObject("not a table", testMethod) end)
    TestFramework.assertFalse(success, "BindObject should reject non-table object")
    
    -- Test with nil method
    success, errorMsg = pcall(function() delegate:BindObject(testObj, nil) end)
    TestFramework.assertFalse(success, "BindObject should reject nil method")
    
    -- Test with non-function method
    success, errorMsg = pcall(function() delegate:BindObject(testObj, "not a function") end)
    TestFramework.assertFalse(success, "BindObject should reject non-function method")
end

local function testUnbind()
    local delegate = Delegate:New()
    local testObj = {}
    
    local function testFunc()
        -- Test function
    end
    
    delegate:Bind(testFunc)
    delegate:Unbind()
    
    TestFramework.assertNil(delegate.obj, "Delegate obj should be nil after unbind")
    TestFramework.assertNil(delegate.func, "Delegate func should be nil after unbind")
end

local function testExecute()
    local delegate = Delegate:New()
    local executeCount = 0
    
    local function testFunc(arg1, arg2)
        executeCount = executeCount + 1
        TestFramework.assertEquals(arg1, "test1", "First argument should be correct")
        TestFramework.assertEquals(arg2, "test2", "Second argument should be correct")
    end
    
    -- Test execute without binding (should fail)
    local result = delegate:Execute("test1", "test2")
    TestFramework.assertFalse(result, "Execute should return false when not bound")
    
    -- Test execute with binding
    delegate:Bind(testFunc)
    local result2 = delegate:Execute("test1", "test2")
    TestFramework.assertTrue(result2, "Execute should return true when bound")
    TestFramework.assertEquals(executeCount, 1, "Function should be executed once")
end

local function testExecuteWithObject()
    local delegate = Delegate:New()
    local testObj = {value = 0}
    local executeCount = 0
    
    local function testMethod(obj, arg1, arg2)
        executeCount = executeCount + 1
        TestFramework.assertEquals(obj, testObj, "Object should be passed correctly")
        TestFramework.assertEquals(arg1, "test1", "First argument should be correct")
        TestFramework.assertEquals(arg2, "test2", "Second argument should be correct")
        obj.value = obj.value + 1
    end
    
    delegate:BindObject(testObj, testMethod)
    local result = delegate:Execute("test1", "test2")
    
    TestFramework.assertTrue(result, "Execute should return true when bound with object")
    TestFramework.assertEquals(executeCount, 1, "Method should be executed once")
    TestFramework.assertEquals(testObj.value, 1, "Object value should be updated")
end

local function testIsValid()
    local delegate = Delegate:New()
    
    -- Test when not bound
    local result = delegate:IsValid()
    TestFramework.assertFalse(result, "IsValid should return false when not bound")
    
    -- Test when bound
    local function testFunc()
        -- Test function
    end
    delegate:Bind(testFunc)
    local result2 = delegate:IsValid()
    TestFramework.assertTrue(result2, "IsValid should return true when bound")
    
    -- Test after unbind
    delegate:Unbind()
    local result3 = delegate:IsValid()
    TestFramework.assertFalse(result3, "IsValid should return false after unbind")
end

-- Register test cases
TestFramework.addTestCase("Delegate.Init", testInit)
TestFramework.addTestCase("Delegate.Bind", testBind)
TestFramework.addTestCase("Delegate.BindWithInvalidFunc", testBindWithInvalidFunc)
TestFramework.addTestCase("Delegate.BindObject", testBindObject)
TestFramework.addTestCase("Delegate.BindObjectWithInvalidParams", testBindObjectWithInvalidParams)
TestFramework.addTestCase("Delegate.Unbind", testUnbind)
TestFramework.addTestCase("Delegate.Execute", testExecute)
TestFramework.addTestCase("Delegate.ExecuteWithObject", testExecuteWithObject)
TestFramework.addTestCase("Delegate.IsValid", testIsValid)

return {
    testInit = testInit,
    testBind = testBind,
    testBindWithInvalidFunc = testBindWithInvalidFunc,
    testBindObject = testBindObject,
    testBindObjectWithInvalidParams = testBindObjectWithInvalidParams,
    testUnbind = testUnbind,
    testExecute = testExecute,
    testExecuteWithObject = testExecuteWithObject,
    testIsValid = testIsValid
}