--
-- TableEx Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local TableEx = require("Utility.TableEx")

local function testCheckTable()
    -- Test with nil input
    local result = TableEx.CheckTable(nil)
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(type(result), "table")
    
    -- Test with table input
    local inputTable = {a = 1, b = 2}
    result = TableEx.CheckTable(inputTable)
    TestFramework.assertEquals(result, inputTable)
    
    -- Test with non-table input
    result = TableEx.CheckTable("not a table")
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(type(result), "table")
end

local function testDeepCopy()
    local original = {
        a = 1,
        b = "string",
        c = {
            d = 2,
            e = {
                f = 3
            }
        }
    }
    
    local copied = TableEx.DeepCopy(original)
    
    -- Check that copied table is not the same reference
    TestFramework.assertNotNil(copied)
    TestFramework.assertFalse(copied == original)
    
    -- Check that values are the same
    TestFramework.assertEquals(copied.a, original.a)
    TestFramework.assertEquals(copied.b, original.b)
    TestFramework.assertEquals(copied.c.d, original.c.d)
    TestFramework.assertEquals(copied.c.e.f, original.c.e.f)
    
    -- Check that nested tables are not the same reference
    TestFramework.assertFalse(copied.c == original.c)
    TestFramework.assertFalse(copied.c.e == original.c.e)
end

local function testLength()
    -- Test with empty table
    local emptyTable = {}
    TestFramework.assertEquals(TableEx.Length(emptyTable), 0)
    
    -- Test with non-empty table
    local testTable = {a = 1, b = 2, c = 3}
    TestFramework.assertEquals(TableEx.Length(testTable), 3)
    
    -- Test with array-like table
    local arrayTable = {"a", "b", "c", "d"}
    TestFramework.assertEquals(TableEx.Length(arrayTable), 4)
end

local function testGetKeys()
    local testTable = {a = 1, b = 2, c = 3}
    local keys = TableEx.GetKeys(testTable)
    
    TestFramework.assertNotNil(keys)
    TestFramework.assertEquals(#keys, 3)
    
    -- Check that all keys are present
    local keySet = {}
    for _, key in ipairs(keys) do
        keySet[key] = true
    end
    
    TestFramework.assertTrue(keySet.a)
    TestFramework.assertTrue(keySet.b)
    TestFramework.assertTrue(keySet.c)
end

local function testGetMapValues()
    local testTable = {a = 1, b = 2, c = 3}
    local values = TableEx.GetValues(testTable)
    
    TestFramework.assertNotNil(values)
    TestFramework.assertEquals(#values, 3)
    
    -- Check that all values are present
    local valueSet = {}
    for _, value in ipairs(values) do
        valueSet[value] = true
    end
    
    TestFramework.assertTrue(valueSet[1])
    TestFramework.assertTrue(valueSet[2])
    TestFramework.assertTrue(valueSet[3])
end

local function testMerge()
    local dest = {a = 1, b = 2}
    local src = {b = 3, c = 4}
    
    TableEx.Merge(dest, src)
    
    TestFramework.assertEquals(dest.a, 1)
    TestFramework.assertEquals(dest.b, 3)  -- Should be overwritten
    TestFramework.assertEquals(dest.c, 4)  -- Should be added
end

local function testMap()
    local testTable = {a = 1, b = 2, c = 3}
    
    TableEx.Map(testTable, function(value, key)
        return value * 2
    end)
    
    TestFramework.assertEquals(testTable.a, 2)
    TestFramework.assertEquals(testTable.b, 4)
    TestFramework.assertEquals(testTable.c, 6)
end

-- Register test cases
TestFramework.addTestCase("TableEx.CheckTable", testCheckTable)
TestFramework.addTestCase("TableEx.DeepCopy", testDeepCopy)
TestFramework.addTestCase("TableEx.Length", testLength)
TestFramework.addTestCase("TableEx.GetKeys", testGetKeys)
TestFramework.addTestCase("TableEx.GetMapValues", testGetMapValues)
TestFramework.addTestCase("TableEx.Merge", testMerge)
TestFramework.addTestCase("TableEx.Map", testMap)

return {
    testCheckTable = testCheckTable,
    testDeepCopy = testDeepCopy,
    testLength = testLength,
    testGetKeys = testGetKeys,
    testGetMapValues = testGetMapValues,
    testMerge = testMerge,
    testMap = testMap
}