-- 单元测试框架核心模块
-- 提供测试用例管理、断言、执行等核心功能
--

local TestFramework = {}

-- 存储所有测试用例
TestFramework.testCases = {}

-- 存储测试选项 (如 isAsync)
TestFramework.testOptions = {}

-- 存储测试结果
TestFramework.testResults = {}

-- 尝试加载 EventLoop 以支持超时
local EventLoop
pcall(function() EventLoop = require("Core.EventLoop") end)

---
-- 添加测试用例
-- @param name string 测试用例名称
-- @param testFunc function 测试函数
-- @param options table|boolean 可选配置，如 { isAsync = true } 或直接传 true 表示异步
--
function TestFramework.addTestCase(name, testFunc, options)
    if type(name) ~= "string" then
        error("Test case name must be a string")
    end
    
    if type(testFunc) ~= "function" then
        error("Test function must be a function")
    end
    
    TestFramework.testCases[name] = testFunc
    
    if type(options) == "boolean" then
        TestFramework.testOptions[name] = { isAsync = options }
    elseif type(options) == "table" then
        TestFramework.testOptions[name] = options
    else
        TestFramework.testOptions[name] = {}
    end
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
    
    -- 检查是否为异步测试（是否有参数，或显式标记）
    local info = debug.getinfo(testFunc)
    local nparams = info.nparams or 0
    local options = TestFramework.testOptions[name] or {}
    local isAsync = nparams > 0 or options.isAsync
    
    if isAsync then
        print("⚠️  Test '" .. name .. "' is asynchronous and cannot be run with runTest(). Use runTestAsync() or runAllTestsAsync().")
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
-- 异步运行单个测试用例
-- @param name string 测试用例名称
-- @param onComplete function 完成回调 (success, errorMsg)
--
function TestFramework.runTestAsync(name, onComplete)
    local testFunc = TestFramework.testCases[name]
    if not testFunc then
        print("❌ Test case '" .. name .. "' not found")
        if onComplete then onComplete(false, "Test case not found") end
        return
    end

    local info = debug.getinfo(testFunc)
    local nparams = info.nparams or 0
    local options = TestFramework.testOptions[name] or {}
    local isAsync = nparams > 0 or options.isAsync
    
    if not isAsync then
        -- 同步测试直接运行
        local success = TestFramework.runTest(name)
        if onComplete then onComplete(success) end
        return
    end

    print("⏳ Running async test '" .. name .. "'...")

    local timeoutTimer
    local isDone = false
    
    -- 完成回调
    local function done(errorMsg)
        if isDone then return end
        isDone = true
        
        -- 清理超时定时器
        if timeoutTimer and EventLoop and EventLoop.DelTicker then
             -- 注意：EventLoop.Timeout 返回的是 timerWatcher，可能需要特定方式取消
             -- 这里假设 EventLoop.Timeout 返回的对象有 stop 方法，或者我们忽略它
             -- 由于 EventLoop.lua 中 Timeout 返回 timerWatcher，它有 stop 方法
             pcall(function() timeoutTimer:stop() end)
        end

        local success = (errorMsg == nil)
        TestFramework.testResults[name] = {
            passed = success,
            error = errorMsg
        }

        if success then
            print("✅ Test '" .. name .. "' passed")
        else
            print("❌ Test '" .. name .. "' failed: " .. tostring(errorMsg))
        end

        if onComplete then onComplete(success, errorMsg) end
    end

    -- 设置超时 (默认 5 秒)
    if EventLoop then
        timeoutTimer = EventLoop.Timeout(5000, function()
            if not isDone then
                done("Timeout (5000ms)")
            end
        end, false)
    else
        print("⚠️  Core.EventLoop not found, timeout protection disabled for async tests.")
    end

    -- 使用协程运行测试
    local co = coroutine.create(function()
        local status, err = pcall(testFunc, done)
        if not status then
            done(err)
        end
    end)

    local status, err = coroutine.resume(co)
    if not status then
        done("Coroutine error: " .. tostring(err))
    end
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
        local testFunc = TestFramework.testCases[name]
        local info = debug.getinfo(testFunc)
        local nparams = info.nparams or 0
        local options = TestFramework.testOptions[name] or {}
        local isAsync = nparams > 0 or options.isAsync

        if not isAsync then
            local success = TestFramework.runTest(name)
            if success then
                passedCount = passedCount + 1
            else
                failedCount = failedCount + 1
            end
        else
            print("ℹ️  Skipping async test '" .. name .. "' in synchronous run.")
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
-- 异步运行所有测试用例
-- @param onComplete function 完成回调 (boolean allPassed)
--
function TestFramework.runAllTestsAsync(onComplete)
    print("\n" .. string.rep("=", 60))
    print("Running all tests (Async mode)...")
    print(string.rep("=", 60))
    
    local testNames = {}
    for name, _ in pairs(TestFramework.testCases) do
        table.insert(testNames, name)
    end
    table.sort(testNames)
    
    local totalCount = #testNames
    local currentIndex = 1
    local passedCount = 0
    local failedCount = 0

    local function runNext()
        if currentIndex > totalCount then
            -- 所有测试完成
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
            
            if onComplete then onComplete(failedCount == 0) end
            return
        end

        local name = testNames[currentIndex]
        currentIndex = currentIndex + 1
        
        TestFramework.runTestAsync(name, function(success)
            if success then
                passedCount = passedCount + 1
            else
                failedCount = failedCount + 1
            end
            -- 调度下一个测试（使用 EventLoop 避免栈溢出，或者直接调用）
            -- 如果有 EventLoop，最好用 AddTicker 或 Timeout(0) 来调度
            if EventLoop then
                EventLoop.Timeout(0, runNext, false)
            else
                runNext()
            end
        end)
    end

    runNext()
end

---
-- 清空所有测试用例和结果
--
function TestFramework.clear()
    TestFramework.testCases = {}
    TestFramework.testOptions = {}
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