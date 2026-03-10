--
-- lfixed Library Tests
--

local TestFramework = require("Test.LuaFrameworkTest.FullTestCase.init")
local lfixed = require("lfixed")

-- Helper function for floating point comparison
local function assertAlmostEqual(actual, expected, tolerance, message)
    local diff = math.abs(actual - expected)
    if diff > tolerance then
        error(string.format("%s: expected %s, got %s (diff: %s)",
            message or "Assertion failed",
            tostring(expected),
            tostring(actual),
            tostring(diff)))
    end
end

-- Test 1: Constructor
local function testConstructor()
    -- Default constructor
    local f1 = lfixed.new()
    TestFramework.assertEquals(f1:toInteger(), 0, "Default constructor should be 0")
    
    -- Integer constructor
    local f2 = lfixed.new(10)
    TestFramework.assertEquals(f2:toInteger(), 10, "Integer constructor")
    
    -- Float constructor
    local f3 = lfixed.new(3.1415)
    assertAlmostEqual(f3:toNumber(), 3.1415, 0.001, "Float constructor")
end

-- Test 2: Addition
local function testAddition()
    local a = lfixed.new(5)
    local b = lfixed.new(3)
    local c = a + b
    TestFramework.assertEquals(c:toInteger(), 8, "5 + 3 should be 8")
    
    local d = lfixed.new(2.5)
    local e = lfixed.new(1.5)
    local f = d + e
    assertAlmostEqual(f:toNumber(), 4.0, 0.001, "2.5 + 1.5 should be 4.0")
end

-- Test 3: Subtraction
local function testSubtraction()
    local g = lfixed.new(10)
    local h = lfixed.new(4)
    local i = g - h
    TestFramework.assertEquals(i:toInteger(), 6, "10 - 4 should be 6")
    
    local j = lfixed.new(5.5)
    local k = lfixed.new(2.5)
    local l = j - k
    assertAlmostEqual(l:toNumber(), 3.0, 0.001, "5.5 - 2.5 should be 3.0")
end

-- Test 4: Multiplication
local function testMultiplication()
    local m = lfixed.new(4)
    local n = lfixed.new(3)
    local o = m * n
    TestFramework.assertEquals(o:toInteger(), 12, "4 * 3 should be 12")
    
    local p = lfixed.new(2.5)
    local q = lfixed.new(4)
    local r = p * q
    assertAlmostEqual(r:toNumber(), 10.0, 0.001, "2.5 * 4 should be 10.0")
end

-- Test 5: Division
local function testDivision()
    local s = lfixed.new(10)
    local t = lfixed.new(2)
    local u = s / t
    TestFramework.assertEquals(u:toInteger(), 5, "10 / 2 should be 5")
    
    local v = lfixed.new(7.5)
    local w = lfixed.new(2.5)
    local x = v / w
    assertAlmostEqual(x:toNumber(), 3.0, 0.1, "7.5 / 2.5 should be 3.0")
end

-- Test 6: Division by zero
local function testDivisionByZero()
    local y = lfixed.new(10)
    local z = lfixed.new(0)
    local div_zero = y / z
    TestFramework.assertEquals(div_zero:toInteger(), 0, "Division by zero should return 0")
end

-- Test 7: Comparison operations
local function testComparison()
    local num1 = lfixed.new(5)
    local num2 = lfixed.new(5)
    local num3 = lfixed.new(10)
    
    TestFramework.assertTrue(num1 == num2, "5 == 5")
    TestFramework.assertFalse(num1 == num3, "5 != 10")
    TestFramework.assertTrue(num1 < num3, "5 < 10")
    TestFramework.assertTrue(num1 <= num2, "5 <= 5")
    TestFramework.assertTrue(num3 > num1, "10 > 5")
    TestFramework.assertTrue(num3 >= num2, "10 >= 5")
end

-- Test 8: Negative numbers
local function testNegativeNumbers()
    local neg1 = lfixed.new(-5)
    local neg2 = lfixed.new(-3)
    local neg3 = neg1 + neg2
    TestFramework.assertEquals(neg3:toInteger(), -8, "-5 + -3 should be -8")
    
    local neg4 = lfixed.new(-10)
    local neg5 = lfixed.new(3)
    local neg6 = neg4 + neg5
    TestFramework.assertEquals(neg6:toInteger(), -7, "-10 + 3 should be -7")
end

-- Test 9: Negative multiplication
local function testNegativeMultiplication()
    local neg7 = lfixed.new(-4)
    local neg8 = lfixed.new(3)
    local neg9 = neg7 * neg8
    TestFramework.assertEquals(neg9:toInteger(), -12, "-4 * 3 should be -12")
    
    local neg10 = lfixed.new(-4)
    local neg11 = lfixed.new(-3)
    local neg12 = neg10 * neg11
    TestFramework.assertEquals(neg12:toInteger(), 12, "-4 * -3 should be 12")
end

-- Test 10: Negative division
local function testNegativeDivision()
    local neg13 = lfixed.new(-10)
    local neg14 = lfixed.new(2)
    local neg15 = neg13 / neg14
    TestFramework.assertEquals(neg15:toInteger(), -5, "-10 / 2 should be -5")
    
    local neg16 = lfixed.new(-10)
    local neg17 = lfixed.new(-2)
    local neg18 = neg16 / neg17
    TestFramework.assertEquals(neg18:toInteger(), 5, "-10 / -2 should be 5")
end

-- Test 11: Copy constructor
local function testCopyConstructor()
    local orig = lfixed.new(42)
    local copy = lfixed.new(orig)
    TestFramework.assertEquals(copy:toInteger(), 42, "Copy constructor should work")
end

-- Test 12: toNumber conversion
local function testToNumberConversion()
    local num = lfixed.new(3.14159)
    local as_number = num:toNumber()
    assertAlmostEqual(as_number, 3.14159, 0.001, "toNumber conversion")
end

-- Test 13: toInteger conversion
local function testToIntegerConversion()
    local num2 = lfixed.new(3.9)
    local as_int = num2:toInteger()
    TestFramework.assertEquals(as_int, 3, "toInteger should truncate")
end

-- Test 14: toString conversion
local function testToStringConversion()
    local num3 = lfixed.new(3.14159)
    local as_string = num3:toString()
    TestFramework.assertTrue(string.find(as_string, "3.14") ~= nil, "toString should contain '3.14'")
end

-- Test 15: Complex calculation
local function testComplexCalculation()
    local x1 = lfixed.new(2.5)
    local x2 = lfixed.new(1.5)
    local x3 = lfixed.new(3)
    local result = (x1 + x2) * x3
    assertAlmostEqual(result:toNumber(), 12.0, 0.001, "(2.5 + 1.5) * 3 should be 12.0")
end

-- Test 16: Precision test
local function testPrecision()
    local p1 = lfixed.new(0.1)
    local p2 = lfixed.new(0.2)
    local p3 = p1 + p2
    assertAlmostEqual(p3:toNumber(), 0.3, 0.001, "0.1 + 0.2 should be approximately 0.3")
end

-- Test 17: Large numbers
local function testLargeNumbers()
    local large1 = lfixed.new(1000000)
    local large2 = lfixed.new(2000000)
    local large3 = large1 + large2
    TestFramework.assertEquals(large3:toInteger(), 3000000, "Large number addition")
    
    local large4 = lfixed.new(1000)
    local large5 = lfixed.new(1000)
    local large6 = large4 * large5
    TestFramework.assertEquals(large6:toInteger(), 1000000, "Large number multiplication")
end

-- Test 18: Chained operations
local function testChainedOperations()
    local c1 = lfixed.new(1)
    local c2 = lfixed.new(2)
    local c3 = lfixed.new(3)
    local c4 = lfixed.new(4)
    local chain = ((c1 + c2) * c3) - c4
    TestFramework.assertEquals(chain:toInteger(), 5, "Chained operations: ((1 + 2) * 3) - 4 = 5")
end

-- Register test cases
TestFramework.addTestCase("lfixed.Constructor", testConstructor)
TestFramework.addTestCase("lfixed.Addition", testAddition)
TestFramework.addTestCase("lfixed.Subtraction", testSubtraction)
TestFramework.addTestCase("lfixed.Multiplication", testMultiplication)
TestFramework.addTestCase("lfixed.Division", testDivision)
TestFramework.addTestCase("lfixed.DivisionByZero", testDivisionByZero)
TestFramework.addTestCase("lfixed.Comparison", testComparison)
TestFramework.addTestCase("lfixed.NegativeNumbers", testNegativeNumbers)
TestFramework.addTestCase("lfixed.NegativeMultiplication", testNegativeMultiplication)
TestFramework.addTestCase("lfixed.NegativeDivision", testNegativeDivision)
TestFramework.addTestCase("lfixed.CopyConstructor", testCopyConstructor)
TestFramework.addTestCase("lfixed.ToNumberConversion", testToNumberConversion)
TestFramework.addTestCase("lfixed.ToIntegerConversion", testToIntegerConversion)
TestFramework.addTestCase("lfixed.ToStringConversion", testToStringConversion)
TestFramework.addTestCase("lfixed.ComplexCalculation", testComplexCalculation)
TestFramework.addTestCase("lfixed.Precision", testPrecision)
TestFramework.addTestCase("lfixed.LargeNumbers", testLargeNumbers)
TestFramework.addTestCase("lfixed.ChainedOperations", testChainedOperations)

return {
    testConstructor = testConstructor,
    testAddition = testAddition,
    testSubtraction = testSubtraction,
    testMultiplication = testMultiplication,
    testDivision = testDivision,
    testDivisionByZero = testDivisionByZero,
    testComparison = testComparison,
    testNegativeNumbers = testNegativeNumbers,
    testNegativeMultiplication = testNegativeMultiplication,
    testNegativeDivision = testNegativeDivision,
    testCopyConstructor = testCopyConstructor,
    testToNumberConversion = testToNumberConversion,
    testToIntegerConversion = testToIntegerConversion,
    testToStringConversion = testToStringConversion,
    testComplexCalculation = testComplexCalculation,
    testPrecision = testPrecision,
    testLargeNumbers = testLargeNumbers,
    testChainedOperations = testChainedOperations
}
