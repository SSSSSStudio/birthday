--
-- Run All Tests
--

print("Starting all tests...")

-- Load test modules
require("TestCase.UnluaTest.TestTableEx")
require("TestCase.UnluaTest.TestLog")
require("TestCase.UnluaTest.TestLuaHelper")
require("TestCase.UnluaTest.TestJsonFile")
require("TestCase.UnluaTest.TestCsvParser")
require("TestCase.UnluaTest.TestIniParser")
require("TestCase.UnluaTest.TestEventDispatcher")
require("TestCase.UnluaTest.TestHttpHelper")
require("TestCase.UnluaTest.TestWebSocket")
require("TestCase.UnluaTest.TestChannel")
require("TestCase.UnluaTest.TestDelegate")
require("TestCase.UnluaTest.TestMultiDelegate")
require("TestCase.UnluaTest.TestObservable")
require("TestCase.UnluaTest.TestEventLoop")
require("TestCase.UnluaTest.TestHistoryManager")
require("TestCase.UnluaTest.TestProtoDispatcher")
require("TestCase.UnluaTest.TestInterface")
require("TestCase.UnluaTest.TestXmlParser")
require("TestCase.UnluaTest.TestMsgPackFile")

-- Get the test framework
local TestFramework = require("TestCase.UnluaTest.init")

-- Run all tests
local success = TestFramework.runAllTests()

if success then
    print("\n🎉 All tests passed!")
else
    print("\n❌ Some tests failed!")
end

return success