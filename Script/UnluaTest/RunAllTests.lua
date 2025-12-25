--
-- Run All Tests
--

print("Starting all tests...")

-- Load test modules
require("UnluaTest.TestTableEx")
require("UnluaTest.TestLog")
require("UnluaTest.TestLuaHelper")
require("UnluaTest.TestJsonFile")
require("UnluaTest.TestCsvParser")
require("UnluaTest.TestIniParser")
require("UnluaTest.TestEventDispatcher")
require("UnluaTest.TestHttpHelper")
require("UnluaTest.TestWebSocket")
require("UnluaTest.TestChannel")
require("UnluaTest.TestDelegate")
require("UnluaTest.TestMultiDelegate")
require("UnluaTest.TestObservable")
require("UnluaTest.TestEventLoop")
require("UnluaTest.TestHistoryManager")
require("UnluaTest.TestProtoDispatcher")
require("UnluaTest.TestInterface")
require("UnluaTest.TestXmlParser")
require("UnluaTest.TestMsgPackFile")

-- Get the test framework
local TestFramework = require("UnluaTest.init")

-- Run all tests
local success = TestFramework.runAllTests()

if success then
    print("\n🎉 All tests passed!")
else
    print("\n❌ Some tests failed!")
end

return success