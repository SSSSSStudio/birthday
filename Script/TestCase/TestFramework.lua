---
-- 单元测试框架核心模块
-- 提供测试用例管理、断言、执行等核心功能
--

local TestFramework = {}

-- 存储所有测试用例
TestFramework.testCases = {}

-- 存储测试结果
TestFramework.testResults = {}

---
-- 添加测试用例
-- @param name string 测试用例名称
-- @param testFunc function 测试函数
--
function TestFramework.addTestCase(name, testFunc)
    if type(name) ~= "string" then
        error("Test case name must be a string")
    end
    
    if type(testFunc) ~= "function" then
        error("Test function must be a function")
    end
    
    TestFramework.testCases[name] = testFunc
end

---
-- 运行单个测试用例
-- @param name string 测试用例名称
-- @return boolean 测试是否通过
--
function TestFramework.runTest(name)
    local testFunc = TestFramework.testCases[name]
    if not testFunc then
        print("❌ Test case '" .. name .. "' not found")
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

---
-- 运行所有测试用例
-- @return boolean 所有测试是否都通过
--
function TestFramework.runAllTests()
    print("\n" .. string.rep("=", 60))
    print("Running all tests...")
    print(string.rep("=", 60))
    
    local passedCount = 0
    local failedCount = 0
    local testNames = {}
    
    -- 收集所有测试名称并排序
    for name, _ in pairs(TestFramework.testCases) do
        table.insert(testNames, name)
    end
    table.sort(testNames)
    
    -- 按顺序执行测试
    for _, name in ipairs(testNames) do
        local success = TestFramework.runTest(name)
        if success then
            passedCount = passedCount + 1
        else
            failedCount = failedCount + 1
        end
    end
    
    -- 输出测试结果统计
    print("\n" .. string.rep("=", 60))
    print("Test Results Summary")
    print(string.rep("=", 60))
    print("✅ Passed: " .. passedCount)
    print("❌ Failed: " .. failedCount)
    print("📊 Total:  " .. (passedCount + failedCount))
    print(string.rep("=", 60))
    
    if failedCount == 0 then
        print("🎉 All tests passed!")
    else
        print("⚠️  Some tests failed!")
    end
    print(string.rep("=", 60) .. "\n")
    
    return failedCount == 0
end

---
-- 清空所有测试用例和结果
--
function TestFramework.clear()
    TestFramework.testCases = {}
    TestFramework.testResults = {}
end

---
-- 获取测试统计信息
-- @return table 包含通过数、失败数、总数的表
--
function TestFramework.getStatistics()
    local passed = 0
    local failed = 0
    
    for _, result in pairs(TestFramework.testResults) do
        if result.passed then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end
    
    return {
        passed = passed,
        failed = failed,
        total = passed + failed
    }
end

-- ============================================================================
-- 断言函数
-- ============================================================================

---
-- 断言两个值相等
-- @param actual any 实际值
-- @param expected any 期望值
-- @param message string 可选的错误消息
--
function TestFramework.assertEquals(actual, expected, message)
    if actual ~= expected then
        local errorMsg = string.format(
            "Expected %s, but got %s", 
            tostring(expected), 
            tostring(actual)
        )
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言条件为真
-- @param condition boolean 条件
-- @param message string 可选的错误消息
--
function TestFramework.assertTrue(condition, message)
    if not condition then
        local errorMsg = "Expected true, but got false"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言条件为假
-- @param condition boolean 条件
-- @param message string 可选的错误消息
--
function TestFramework.assertFalse(condition, message)
    if condition then
        local errorMsg = "Expected false, but got true"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言值不为nil
-- @param value any 值
-- @param message string 可选的错误消息
--
function TestFramework.assertNotNil(value, message)
    if value == nil then
        local errorMsg = "Expected non-nil value, but got nil"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言值为nil
-- @param value any 值
-- @param message string 可选的错误消息
--
function TestFramework.assertNil(value, message)
    if value ~= nil then
        local errorMsg = string.format("Expected nil, but got %s", tostring(value))
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言表包含指定的键
-- @param table table 表
-- @param key any 键
-- @param message string 可选的错误消息
--
function TestFramework.assertContainsKey(table, key, message)
    if type(table) ~= "table" then
        error("First argument must be a table")
    end
    
    if table[key] == nil then
        local errorMsg = string.format("Table does not contain key: %s", tostring(key))
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言表不包含指定的键
-- @param table table 表
-- @param key any 键
-- @param message string 可选的错误消息
--
function TestFramework.assertNotContainsKey(table, key, message)
    if type(table) ~= "table" then
        error("First argument must be a table")
    end
    
    if table[key] ~= nil then
        local errorMsg = string.format("Table contains key: %s", tostring(key))
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言函数抛出错误
-- @param func function 要执行的函数
-- @param message string 可选的错误消息
--
function TestFramework.assertError(func, message)
    if type(func) ~= "function" then
        error("First argument must be a function")
    end
    
    local success, _ = pcall(func)
    if success then
        local errorMsg = "Expected function to throw an error, but it didn't"
        if message then
            errorMsg = message .. ": " .. errorMsg
        end
        error(errorMsg)
    end
end

---
-- 断言函数不抛出错误
-- @param func function 要执行的函数
-- @param message string 可选的错误消息
--
function TestFramework.assertNoError(func, message)
    if type(func) ~= "function" then
        error("First argument must be a function")
    end
    
    local success, errorMsg = pcall(func)
    if not success then
        local msg = "Expected function not to throw an error, but it did: " .. tostring(errorMsg)
        if message then
            msg = message .. ": " .. msg
        end
        error(msg)
    end
end

return TestFramework
