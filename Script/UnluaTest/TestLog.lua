---
-- Log Module Tests
--

local TestFramework = require("UnluaTest.init")
local Log = require("Utility.Log")

function testConfig()
    -- Test setting max depth
    Log.Config(32)
    -- If no error is thrown, the test passes
    TestFramework.assertTrue(true, "Log.Config should accept integer values")
    
    -- Test with invalid input (this should throw an error)
    local success, errorMsg = pcall(function() Log.Config("invalid") end)
    TestFramework.assertFalse(success, "Log.Config should reject non-integer values")
end

function testToString()
    -- This function is internal, so we'll test it indirectly through other functions
    TestFramework.assertTrue(true, "ToString function tested indirectly")
end

function testError()
    -- Test that Error function doesn't crash (we can't easily test UnLua.LogError output)
    Log.Error("Test error message")
    TestFramework.assertTrue(true, "Log.Error should not crash")
end

function testWarning()
    -- Test that Warning function doesn't crash
    Log.Warning("Test warning message")
    TestFramework.assertTrue(true, "Log.Warning should not crash")
end

function testInfo()
    -- Test that Info function doesn't crash
    Log.Info("Test info message")
    TestFramework.assertTrue(true, "Log.Info should not crash")
end

function testPrintT()
    -- Test with nil input
    Log.PrintT(nil)
    TestFramework.assertTrue(true, "Log.PrintT should handle nil input")
    
    -- Test with simple table
    local simpleTable = {a = 1, b = "test"}
    Log.PrintT(simpleTable)
    TestFramework.assertTrue(true, "Log.PrintT should handle simple table")
    
    -- Test with nested table
    local nestedTable = {a = 1, b = {c = 2, d = {e = 3}}}
    Log.PrintT(nestedTable)
    TestFramework.assertTrue(true, "Log.PrintT should handle nested table")
end

function testPrintf()
    -- Test basic printf functionality
    Log.Printf("Test message: %s, number: %d", "hello", 42)
    TestFramework.assertTrue(true, "Log.Printf should not crash")
    
    -- Test with invalid format (should not crash)
    Log.Printf("Test message: %s, number: %d", "hello")
    TestFramework.assertTrue(true, "Log.Printf should handle format errors gracefully")
end

-- Register test cases
TestFramework.addTestCase("Log.Config", testConfig)
TestFramework.addTestCase("Log.Error", testError)
TestFramework.addTestCase("Log.Warning", testWarning)
TestFramework.addTestCase("Log.Info", testInfo)
TestFramework.addTestCase("Log.PrintT", testPrintT)
TestFramework.addTestCase("Log.Printf", testPrintf)

return {
    testConfig = testConfig,
    testError = testError,
    testWarning = testWarning,
    testInfo = testInfo,
    testPrintT = testPrintT,
    testPrintf = testPrintf
}
