---
-- Interface 模块测试用例
-- 测试 Utility.Interface 的所有功能
--

local TestFramework = require("TestCase.FrameworkTest.init")
local Interface = require("Utility.Interface")

-- 测试创建接口类
local function testCreateInterface()
    TestFramework.assertNoError(function()
        local MyClass = Interface("MyClass")
        TestFramework.assertNotNil(MyClass, "Interface should create a class")
        TestFramework.assertEquals(type(MyClass), "table", "Interface should return a table")
    end, "Interface creation should not throw exception")
end

-- 测试实例化
local function testInstantiation()
    TestFramework.assertNoError(function()
        local MyClass = Interface()
        
        function MyClass:__init(value)
            self.value = value
        end
        
        -- Interface 通过 __call 元方法实例化，不是 :New()
        local instance = MyClass(123)
        
        TestFramework.assertNotNil(instance, "Should create an instance")
        TestFramework.assertEquals(instance.value, 123, "Instance should have correct value")
    end, "Instantiation should not throw exception")
end

-- 测试方法调用
local function testMethodCall()
    TestFramework.assertNoError(function()
        local MyClass = Interface()
        
        function MyClass:__init(value)
            self.value = value
        end
        
        function MyClass:getValue()
            return self.value
        end
        
        function MyClass:setValue(newValue)
            self.value = newValue
        end
        
        local instance = MyClass(100)
        
        TestFramework.assertEquals(instance:getValue(), 100, "getValue should return correct value")
        
        instance:setValue(200)
        TestFramework.assertEquals(instance:getValue(), 200, "setValue should update value")
    end, "Method call should not throw exception")
end

-- 测试多个实例独立性
local function testMultipleInstances()
    TestFramework.assertNoError(function()
        local MyClass = Interface()
        
        function MyClass:__init(value)
            self.value = value
        end
        
        local instance1 = MyClass(111)
        local instance2 = MyClass(222)
        
        TestFramework.assertEquals(instance1.value, 111, "Instance1 should have its own value")
        TestFramework.assertEquals(instance2.value, 222, "Instance2 should have its own value")
        
        instance1.value = 333
        TestFramework.assertEquals(instance1.value, 333, "Instance1 value should change")
        TestFramework.assertEquals(instance2.value, 222, "Instance2 value should not change")
    end, "Multiple instances should not throw exception")
end

-- 注册测试用例
TestFramework.addTestCase("Interface.CreateInterface", testCreateInterface)
TestFramework.addTestCase("Interface.Instantiation", testInstantiation)
TestFramework.addTestCase("Interface.MethodCall", testMethodCall)
TestFramework.addTestCase("Interface.MultipleInstances", testMultipleInstances)

return {
    testCreateInterface = testCreateInterface,
    testInstantiation = testInstantiation,
    testMethodCall = testMethodCall,
    testMultipleInstances = testMultipleInstances
}
