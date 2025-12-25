--
-- EventDispatcher Module Tests
--

local TestFramework = require("TestCase.UnluaTest.init")
local EventDispatcher = require("Core.EventDispatcher")

local function testAddEvent()
    local eventReceived = false
    local testTarget = {}
    
    -- Test adding an event with target
    local function testHandler(target, data)
        eventReceived = true
        TestFramework.assertEquals(target, testTarget)
        TestFramework.assertEquals(data, "testData")
    end
    
    EventDispatcher.AddEvent("TestEvent", testHandler, testTarget)
    EventDispatcher.Dispatch("TestEvent", "testData")
    
    TestFramework.assertTrue(eventReceived, "Event should be received")
end

local function testRemoveEvent()
    local eventReceived = false
    local testTarget = {}
    
    local function testHandler(target, data)
        eventReceived = true
    end
    
    -- Add event
    EventDispatcher.AddEvent("TestEvent2", testHandler, testTarget)
    
    -- Remove event
    EventDispatcher.RemoveEvent("TestEvent2", testHandler)
    
    -- Dispatch event (should not be received)
    EventDispatcher.Dispatch("TestEvent2", "testData")
    
    TestFramework.assertFalse(eventReceived, "Event should not be received after removal")
end

local function testRemoveAllEvents()
    local eventReceived = false
    local testTarget = {}
    
    local function testHandler(target, data)
        eventReceived = true
    end
    
    -- Add event
    EventDispatcher.AddEvent("TestEvent3", testHandler, testTarget)
    
    -- Remove all events for this name
    EventDispatcher.RemoveEvent("TestEvent3")
    
    -- Dispatch event (should not be received)
    EventDispatcher.Dispatch("TestEvent3", "testData")
    
    TestFramework.assertFalse(eventReceived, "Event should not be received after removing all events")
end

local function testDispatch()
    local receivedData = nil
    local testTarget = {}
    
    local function testHandler(target, data)
        receivedData = data
    end
    
    EventDispatcher.AddEvent("TestEvent4", testHandler, testTarget)
    EventDispatcher.Dispatch("TestEvent4", "testData")
    
    TestFramework.assertEquals(receivedData, "testData", "Event should receive correct data")
end

local function testDispatchWithoutTarget()
    local receivedData = nil
    
    local function testHandler(data)
        receivedData = data
    end
    
    EventDispatcher.AddEvent("TestEvent5", testHandler)
    EventDispatcher.Dispatch("TestEvent5", "testData")
    
    TestFramework.assertEquals(receivedData, "testData", "Event without target should receive correct data")
end

local function testMultipleListeners()
    local receivedCount = 0
    local testTarget = {}
    
    local function testHandler1(target, data)
        receivedCount = receivedCount + 1
    end
    
    local function testHandler2(target, data)
        receivedCount = receivedCount + 1
    end
    
    EventDispatcher.AddEvent("TestEvent6", testHandler1, testTarget)
    EventDispatcher.AddEvent("TestEvent6", testHandler2, testTarget)
    EventDispatcher.Dispatch("TestEvent6", "testData")
    
    TestFramework.assertEquals(receivedCount, 2, "Both listeners should receive the event")
end

-- Register test cases
TestFramework.addTestCase("EventDispatcher.AddEvent", testAddEvent)
TestFramework.addTestCase("EventDispatcher.RemoveEvent", testRemoveEvent)
TestFramework.addTestCase("EventDispatcher.RemoveAllEvents", testRemoveAllEvents)
TestFramework.addTestCase("EventDispatcher.Dispatch", testDispatch)
TestFramework.addTestCase("EventDispatcher.DispatchWithoutTarget", testDispatchWithoutTarget)
TestFramework.addTestCase("EventDispatcher.MultipleListeners", testMultipleListeners)

return {
    testAddEvent = testAddEvent,
    testRemoveEvent = testRemoveEvent,
    testRemoveAllEvents = testRemoveAllEvents,
    testDispatch = testDispatch,
    testDispatchWithoutTarget = testDispatchWithoutTarget,
    testMultipleListeners = testMultipleListeners
}