---
-- TableEx 模块测试用例
-- 测试 Utility.TableEx 的所有功能
--

local TestFramework = require("Test.LuaFrameworkTest.NormalTestCase.init")
local TableEx = require("Utility.TableEx")

-- 测试 CheckTable 函数
local function testCheckTable()
    -- 测试 nil 输入
    local result = TableEx.CheckTable(nil)
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(type(result), "table")
    
    -- 测试表输入
    local inputTable = {a = 1, b = 2}
    result = TableEx.CheckTable(inputTable)
    TestFramework.assertEquals(result, inputTable)
    
    -- 测试非表输入
    result = TableEx.CheckTable("not a table")
    TestFramework.assertNotNil(result)
    TestFramework.assertEquals(type(result), "table")
    
    -- 测试数字输入
    result = TableEx.CheckTable(123)
    TestFramework.assertEquals(type(result), "table")
end

-- 测试 DeepCopy 函数
local function testDeepCopy()
    local original = {
        a = 1,
        b = "string",
        c = {
            d = 2,
            e = {
                f = 3
            }
        },
        arr = {1, 2, 3}
    }
    
    local copied = TableEx.DeepCopy(original)
    
    -- 检查拷贝的表不是同一个引用
    TestFramework.assertNotNil(copied)
    TestFramework.assertFalse(copied == original)
    
    -- 检查值相同
    TestFramework.assertEquals(copied.a, original.a)
    TestFramework.assertEquals(copied.b, original.b)
    TestFramework.assertEquals(copied.c.d, original.c.d)
    TestFramework.assertEquals(copied.c.e.f, original.c.e.f)
    
    -- 检查嵌套表不是同一个引用
    TestFramework.assertFalse(copied.c == original.c)
    TestFramework.assertFalse(copied.c.e == original.c.e)
    TestFramework.assertFalse(copied.arr == original.arr)
    
    -- 修改拷贝不影响原表
    copied.a = 999
    copied.c.d = 888
    TestFramework.assertEquals(original.a, 1)
    TestFramework.assertEquals(original.c.d, 2)
end

-- 测试 Length 函数
local function testLength()
    -- 测试空表
    local emptyTable = {}
    TestFramework.assertEquals(TableEx.Length(emptyTable), 0)
    
    -- 测试非空表
    local testTable = {a = 1, b = 2, c = 3}
    TestFramework.assertEquals(TableEx.Length(testTable), 3)
    
    -- 测试数组表
    local arrayTable = {"a", "b", "c", "d"}
    TestFramework.assertEquals(TableEx.Length(arrayTable), 4)
    
    -- 测试混合表
    local mixedTable = {a = 1, b = 2, [1] = "x", [2] = "y"}
    TestFramework.assertEquals(TableEx.Length(mixedTable), 4)
end

-- 测试 GetKeys 函数
local function testGetKeys()
    local testTable = {a = 1, b = 2, c = 3}
    local keys = TableEx.GetKeys(testTable)
    
    TestFramework.assertNotNil(keys)
    TestFramework.assertEquals(#keys, 3)
    
    -- 检查所有键都存在
    local keySet = {}
    for _, key in ipairs(keys) do
        keySet[key] = true
    end
    
    TestFramework.assertTrue(keySet.a)
    TestFramework.assertTrue(keySet.b)
    TestFramework.assertTrue(keySet.c)
end

-- 测试 GetValues 函数
local function testGetValues()
    local testTable = {a = 1, b = 2, c = 3}
    local values = TableEx.GetValues(testTable)
    
    TestFramework.assertNotNil(values)
    TestFramework.assertEquals(#values, 3)
    
    -- 检查所有值都存在
    local valueSet = {}
    for _, value in ipairs(values) do
        valueSet[value] = true
    end
    
    TestFramework.assertTrue(valueSet[1])
    TestFramework.assertTrue(valueSet[2])
    TestFramework.assertTrue(valueSet[3])
end

-- 测试 Merge 函数
local function testMerge()
    local dest = {a = 1, b = 2}
    local src = {b = 3, c = 4}
    
    TableEx.Merge(dest, src)
    
    TestFramework.assertEquals(dest.a, 1)
    TestFramework.assertEquals(dest.b, 3)  -- 应该被覆盖
    TestFramework.assertEquals(dest.c, 4)  -- 应该被添加
end

-- 测试 Map 函数
local function testMap()
    local testTable = {a = 1, b = 2, c = 3}
    
    TableEx.Map(testTable, function(value, key)
        return value * 2
    end)
    
    TestFramework.assertEquals(testTable.a, 2)
    TestFramework.assertEquals(testTable.b, 4)
    TestFramework.assertEquals(testTable.c, 6)
end

-- 测试 Filter 函数
local function testFilter()
    local testTable = {a = 1, b = 2, c = 3, d = 4}
    
    -- 过滤掉偶数
    TableEx.Filter(testTable, function(value, key)
        return value % 2 == 0
    end)
    
    TestFramework.assertEquals(testTable.a, 1)
    TestFramework.assertNil(testTable.b)
    TestFramework.assertEquals(testTable.c, 3)
    TestFramework.assertNil(testTable.d)
end

-- 测试 Foreach 函数
local function testForeach()
    local testTable = {a = 1, b = 2, c = 3}
    local count = 0
    
    TableEx.Foreach(testTable, function(value, key)
        count = count + 1
    end)
    
    TestFramework.assertEquals(count, 3)
end

-- 测试 KeyOf 函数
local function testKeyOf()
    local testTable = {a = 1, b = 2, c = 3}
    
    local key = TableEx.KeyOf(testTable, 2)
    TestFramework.assertEquals(key, "b")
    
    key = TableEx.KeyOf(testTable, 999)
    TestFramework.assertNil(key)
end

-- 测试 GetFilter 函数
local function testGetFilter()
    local testTable = {a = 1, b = 2, c = 3, d = 4}
    
    -- 获取第一个偶数
    local value, key = TableEx.GetFilter(testTable, function(v, k)
        return v % 2 == 0
    end, false)
    
    TestFramework.assertNotNil(value)
    TestFramework.assertTrue(value == 2 or value == 4)
    
    -- 获取所有偶数
    local values, keys = TableEx.GetFilter(testTable, function(v, k)
        return v % 2 == 0
    end, true)
    
    TestFramework.assertEquals(#values, 2)
    TestFramework.assertEquals(#keys, 2)
end

-- 测试 GetFilterArray 函数
local function testGetFilterArray()
    local testArray = {1, 2, 3, 4, 5}
    
    -- 获取第一个偶数
    local value, index = TableEx.GetFilterArray(testArray, function(v)
        return v % 2 == 0
    end, false)
    
    TestFramework.assertEquals(value, 2)
    TestFramework.assertEquals(index, 2)
    
    -- 获取所有偶数
    local values, indices = TableEx.GetFilterArray(testArray, function(v)
        return v % 2 == 0
    end, true)
    
    TestFramework.assertEquals(#values, 2)
    TestFramework.assertEquals(values[1], 2)
    TestFramework.assertEquals(values[2], 4)
end

-- 测试 ArrayRemove 函数
local function testArrayRemove()
    local testArray = {1, 2, 3, 4, 5}
    
    -- 移除所有偶数
    TableEx.ArrayRemove(testArray, function(v)
        return v % 2 == 0
    end)
    
    TestFramework.assertEquals(#testArray, 3)
    TestFramework.assertEquals(testArray[1], 1)
    TestFramework.assertEquals(testArray[2], 3)
    TestFramework.assertEquals(testArray[3], 5)
end

-- 测试 ArrayForeach 函数
local function testArrayForeach()
    local testArray = {1, 2, 3, 4, 5}
    local sum = 0
    
    TableEx.ArrayForeach(testArray, function(value, index)
        sum = sum + value
    end)
    
    TestFramework.assertEquals(sum, 15)
end

-- 测试 ArrayNext 函数
local function testArrayNext()
    local testArray = {"a", "b", "c"}
    
    local next1 = TableEx.ArrayNext(testArray, 1)
    TestFramework.assertEquals(next1, "b")
    
    local next2 = TableEx.ArrayNext(testArray, 3)
    TestFramework.assertEquals(next2, "a")  -- 循环回到第一个
end

-- 测试 ArrayIndexOf 函数
local function testArrayIndexOf()
    local testArray = {"a", "b", "c", "b", "d"}
    
    local index = TableEx.ArrayIndexOf(testArray, "b")
    TestFramework.assertEquals(index, 2)
    
    -- 从指定位置开始查找
    local index2 = TableEx.ArrayIndexOf(testArray, "b", 3)
    TestFramework.assertEquals(index2, 4)
    
    -- 查找不存在的值
    local index3 = TableEx.ArrayIndexOf(testArray, "z")
    TestFramework.assertNil(index3)
end

-- 注册测试用例
TestFramework.addTestCase("TableEx.CheckTable", testCheckTable)
TestFramework.addTestCase("TableEx.DeepCopy", testDeepCopy)
TestFramework.addTestCase("TableEx.Length", testLength)
TestFramework.addTestCase("TableEx.GetKeys", testGetKeys)
TestFramework.addTestCase("TableEx.GetValues", testGetValues)
TestFramework.addTestCase("TableEx.Merge", testMerge)
TestFramework.addTestCase("TableEx.Map", testMap)
TestFramework.addTestCase("TableEx.Filter", testFilter)
TestFramework.addTestCase("TableEx.Foreach", testForeach)
TestFramework.addTestCase("TableEx.KeyOf", testKeyOf)
TestFramework.addTestCase("TableEx.GetFilter", testGetFilter)
TestFramework.addTestCase("TableEx.GetFilterArray", testGetFilterArray)
TestFramework.addTestCase("TableEx.ArrayRemove", testArrayRemove)
TestFramework.addTestCase("TableEx.ArrayForeach", testArrayForeach)
TestFramework.addTestCase("TableEx.ArrayNext", testArrayNext)
TestFramework.addTestCase("TableEx.ArrayIndexOf", testArrayIndexOf)

return {
    testCheckTable = testCheckTable,
    testDeepCopy = testDeepCopy,
    testLength = testLength,
    testGetKeys = testGetKeys,
    testGetValues = testGetValues,
    testMerge = testMerge,
    testMap = testMap,
    testFilter = testFilter,
    testForeach = testForeach,
    testKeyOf = testKeyOf,
    testGetFilter = testGetFilter,
    testGetFilterArray = testGetFilterArray,
    testArrayRemove = testArrayRemove,
    testArrayForeach = testArrayForeach,
    testArrayNext = testArrayNext,
    testArrayIndexOf = testArrayIndexOf
}
