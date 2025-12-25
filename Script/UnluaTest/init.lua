---
-- UnluaTest Framework Initialization
--

-- 测试框架主模块
local TestFramework = {}

-- 存储所有测试用例
TestFramework.testCases = {}

-- 存储测试结果
TestFramework.testResults = {}

-- 添加测试用例
function TestFramework.addTestCase(name, testFunc)
    TestFramework.testCases[name] = testFunc
end

-- 运行单个测试用例
function TestFramework.runTest(name)
    local testFunc = TestFramework.testCases[name]
    if not testFunc then
        print("Test case '" .. name .. "' not found")
        return false
    end
    
    local success, errorMsg = pcall(testFunc)
    TestFramework.testResults[name] = {
        passed = success,
        error = errorMsg
    }
    
    if success then
        print("✅ Test '" .. name .. "' passed")
    else
        print("❌ Test '" .. name .. "' failed: " .. tostring(errorMsg))
    end
    
    return success
end

-- 运行所有测试用例
function TestFramework.runAllTests()
    print("Running all tests...")
    local passedCount = 0
    local failedCount = 0
    
    for name, _ in pairs(TestFramework.testCases) do
        local success = TestFramework.runTest(name)
        if success then
            passedCount = passedCount + 1
        else
            failedCount = failedCount + 1
        end
    end
    
    print("\n=== Test Results ===")
    print("Passed: " .. passedCount)
    print("Failed: " .. failedCount)
    print("Total: " .. (passedCount + failedCount))
    
    return failedCount == 0
end

-- 断言函数
function TestFramework.assertEquals(actual, expected, message)
    if actual ~= expected then
        local errorMsg = string.format("Expected %s, but got %s", tostring(expected), tostring(actual))
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

function TestFramework.assertTrue(condition, message)
    if not condition then
        local errorMsg = "Expected true, but got false"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

function TestFramework.assertFalse(condition, message)
    if condition then
        local errorMsg = "Expected false, but got true"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

function TestFramework.assertNotNil(value, message)
    if value == nil then
        local errorMsg = "Expected non-nil value, but got nil"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

function TestFramework.assertNil(value, message)
    if value ~= nil then
        local errorMsg = string.format("Expected nil, but got %s", tostring(value))
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

return TestFramework
