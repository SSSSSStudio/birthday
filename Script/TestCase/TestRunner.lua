---
-- 测试运行器
-- 负责加载和运行测试套件
--

local TestFramework = require("TestCase.TestFramework")

local TestRunner = {}

---
-- 加载指定目录下的所有测试模块
-- @param testModules table 测试模块路径列表
--
function TestRunner.loadTests(testModules)
    if type(testModules) ~= "table" then
        error("testModules must be a table")
    end
    
    print("\n" .. string.rep("=", 60))
    print("Loading test modules...")
    print(string.rep("=", 60))
    
    local loadedCount = 0
    local failedCount = 0
    
    for _, modulePath in ipairs(testModules) do
        local success, result = pcall(require, modulePath)
        if success then
            print("✅ Loaded: " .. modulePath)
            loadedCount = loadedCount + 1
        else
            print("❌ Failed to load: " .. modulePath)
            print("   Error: " .. tostring(result))
            failedCount = failedCount + 1
        end
    end
    
    print(string.rep("-", 60))
    print(string.format("Loaded: %d, Failed: %d", loadedCount, failedCount))
    print(string.rep("=", 60))
    
    return loadedCount, failedCount
end

---
-- 运行所有已加载的测试
-- @return boolean 所有测试是否都通过
--
function TestRunner.runAll()
    return TestFramework.runAllTests()
end

---
-- 运行指定的测试用例
-- @param testName string 测试用例名称
-- @return boolean 测试是否通过
--
function TestRunner.runTest(testName)
    return TestFramework.runTest(testName)
end

---
-- 清空所有测试
--
function TestRunner.clear()
    TestFramework.clear()
end

---
-- 获取测试统计信息
-- @return table 统计信息
--
function TestRunner.getStatistics()
    return TestFramework.getStatistics()
end

---
-- 运行测试套件（加载并运行）
-- @param testModules table 测试模块路径列表
-- @return boolean 所有测试是否都通过
--
function TestRunner.runTestSuite(testModules)
    -- 清空之前的测试
    TestRunner.clear()
    
    -- 加载测试模块
    local loadedCount, failedCount = TestRunner.loadTests(testModules)
    
    if failedCount > 0 then
        print("\n⚠️  Some test modules failed to load. Aborting test run.")
        return false
    end
    
    if loadedCount == 0 then
        print("\n⚠️  No test modules loaded. Nothing to run.")
        return false
    end
    
    -- 运行所有测试
    return TestRunner.runAll()
end

return TestRunner
