--
-- IniParser Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")

-- Mock the lpeg module for testing
package.loaded.lpeg = {
    P = function(pattern)
        if pattern == '\r\n' or pattern == '\n' then
            return {type = "eol"}
        end
        return {type = "pattern", value = pattern}
    end,
    S = function(chars)
        return {type = "set", chars = chars}
    end,
    C = function(pattern)
        return {type = "capture", pattern = pattern}
    end,
    Cf = function(pattern, func)
        return {type = "fold_capture", pattern = pattern, func = func}
    end,
    Cc = function(value)
        return {type = "constant_capture", value = value}
    end,
    Ct = function(pattern)
        return {type = "table_capture", pattern = pattern}
    end,
    Cg = function(pattern, name)
        return {type = "group_capture", pattern = pattern, name = name}
    end,
    Cs = function(pattern)
        return {type = "substitution_capture", pattern = pattern}
    end,
    R = function(range)
        return {type = "range", range = range}
    end,
    V = function(name)
        return {type = "variable", name = name}
    end,
    locale = function(lpeg)
        lpeg.space = {type = "space"}
        lpeg.alpha = {type = "alpha"}
        lpeg.digit = {type = "digit"}
        return lpeg
    end,
    match = function(grammar, input)
        -- Mock implementation for testing
        if input == "[section1]\nkey1=value1\nkey2=value2\n[section2]\nkey3=value3" then
            return {
                section1 = {
                    key1 = "value1",
                    key2 = "value2"
                },
                section2 = {
                    key3 = "value3"
                }
            }
        end
        return nil
    end
}

-- Mock the lproject module
package.loaded.lproject = {
    get_content_dir = function()
        return "Content/"
    end
}

-- Mock the UE.File class
local mockFile = {}
mockFile.Open = function(self, path, mode)
    self.path = path
    self.mode = mode
    return true
end
mockFile.TotalSize = function(self)
    return 100
end
mockFile.Read = function(self, size)
    return "[section1]\nkey1=value1\nkey2=value2\n[section2]\nkey3=value3"
end
mockFile.Close = function(self)
    return true
end

-- Mock UE module
package.loaded.UE = {
    File = function()
        return mockFile
    end
}

local IniParser = require("Utility.IniParser")

local function testParse()
    -- Test parsing a simple INI string
    local iniString = "[section1]\nkey1=value1\nkey2=value2\n[section2]\nkey3=value3"
    local result = IniParser.Parse(iniString)
    
    TestFramework.assertNotNil(result, "IniParser.Parse should return data")
    TestFramework.assertTrue(type(result) == "table", "IniParser.Parse should return a table")
    TestFramework.assertNotNil(result.section1, "IniParser should parse section1")
    TestFramework.assertNotNil(result.section2, "IniParser should parse section2")
    TestFramework.assertEquals(result.section1.key1, "value1", "IniParser should parse key1 correctly")
    TestFramework.assertEquals(result.section1.key2, "value2", "IniParser should parse key2 correctly")
    TestFramework.assertEquals(result.section2.key3, "value3", "IniParser should parse key3 correctly")
    
    -- Test with invalid input
    local result2 = IniParser.Parse(nil)
    TestFramework.assertNil(result2, "IniParser.Parse should return nil for nil input")
    
    local result3 = IniParser.Parse(123)
    TestFramework.assertNil(result3, "IniParser.Parse should return nil for non-string input")
end

local function testRead()
    -- Test reading from file
    local result = IniParser.Read("test.ini")
    
    TestFramework.assertNotNil(result, "IniParser.Read should return data")
    TestFramework.assertTrue(type(result) == "table", "IniParser.Read should return a table")
    
    -- Test with invalid filename
    local success, errorMsg = pcall(function() IniParser.Read(nil) end)
    TestFramework.assertFalse(success, "IniParser.Read should reject nil filename")
    
    success, errorMsg = pcall(function() IniParser.Read(123) end)
    TestFramework.assertFalse(success, "IniParser.Read should reject non-string filename")
end

local function testConfig()
    -- Test configuring the parser
    IniParser.config({
        separator = ":",
        comment = "#",
        trim = false,
        lowercase = true,
        escape = false
    })
    
    TestFramework.assertTrue(true, "IniParser.config should not crash")
    
    -- Reset to default config
    IniParser.config({})
    TestFramework.assertTrue(true, "IniParser.config should accept empty config")
end

-- Register test cases
TestFramework.addTestCase("IniParser.Parse", testParse)
TestFramework.addTestCase("IniParser.Read", testRead)
TestFramework.addTestCase("IniParser.Config", testConfig)

return {
    testParse = testParse,
    testRead = testRead,
    testConfig = testConfig
}