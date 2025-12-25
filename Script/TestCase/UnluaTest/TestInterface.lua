--
-- Interface Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

local Interface = require("Utility.Interface")

local function testInterfaceCreation()
    local interface = Interface()
    
    TestFramework.assertNotNil(interface, "Interface should be created")
    TestFramework.assertNotNil(interface._keys, "Interface should have _keys")
end

local function testInterfaceInstantiation()
    local TestClass = Interface()
    
    function TestClass:__init(value)
        self.value = value
    end
    
    function TestClass:getValue()
        return self.value
    end
    
    local instance = TestClass(42)
    
    TestFramework.assertNotNil(instance, "Instance should be created")
    TestFramework.assertEquals(instance.value, 42, "Instance should have correct value")
    TestFramework.assertEquals(instance:getValue(), 42, "Instance should have correct method result")
end

local function testInterfaceWithFailedInit()
    local TestClass = Interface()
    
    function TestClass:__init(value)
        error("Initialization failed")
    end
    
    local success, errorMsg = pcall(function() TestClass(42) end)
    TestFramework.assertFalse(success, "Interface instantiation should fail when __init throws error")
    TestFramework.assertTrue(string.find(errorMsg, "Interface initialization failed") ~= nil, "Error message should contain initialization failure info")
end

local function testInterfaceMethodAccess()
    local TestClass = Interface()
    
    function TestClass:getValue()
        return 42
    end
    
    local instance = TestClass()
    
    TestFramework.assertEquals(instance:getValue(), 42, "Instance should be able to access methods")
end

local function testInterfacePairsError()
    local TestClass = Interface()
    local instance = TestClass()
    
    local success, errorMsg = pcall(function()
		for index, value in pairs(instance) do
			-- 处理逻辑
		end
	end)
    TestFramework.assertFalse(success, "pairs should fail on interface instance")
    TestFramework.assertTrue(string.find(errorMsg, "cannot use pairs") ~= nil, "Error message should indicate pairs is not allowed")
end

-- Register test cases
TestFramework.addTestCase("Interface.Creation", testInterfaceCreation)
TestFramework.addTestCase("Interface.Instantiation", testInterfaceInstantiation)
TestFramework.addTestCase("Interface.WithFailedInit", testInterfaceWithFailedInit)
TestFramework.addTestCase("Interface.MethodAccess", testInterfaceMethodAccess)
TestFramework.addTestCase("Interface.PairsError", testInterfacePairsError)

return {
    testInterfaceCreation = testInterfaceCreation,
    testInterfaceInstantiation = testInterfaceInstantiation,
    testInterfaceWithFailedInit = testInterfaceWithFailedInit,
    testInterfaceMethodAccess = testInterfaceMethodAccess,
    testInterfacePairsError = testInterfacePairsError,
}