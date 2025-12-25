# UnluaTest Framework

## 概述

UnluaTest是一个为Unlua项目中的Lua模块设计的测试框架。它提供了一套简单的API来编写和运行测试用例。

## 目录结构

```
UnluaTest/
├── init.lua              # 测试框架主模块
├── TestTableEx.lua       # TableEx模块测试用例
├── TestLog.lua           # Log模块测试用例
├── TestLuaHelper.lua     # LuaHelper模块测试用例
├── TestJsonFile.lua      # JsonFile模块测试用例
├── TestCsvParser.lua     # CsvParser模块测试用例
├── TestIniParser.lua     # IniParser模块测试用例
├── TestEventDispatcher.lua # EventDispatcher模块测试用例
├── TestHttpHelper.lua    # HttpHelper模块测试用例
├── TestWebSocket.lua     # WebSocket模块测试用例
├── TestChannel.lua       # Channel模块测试用例
├── TestDelegate.lua      # Delegate模块测试用例
├── TestMultiDelegate.lua # MultiDelegate模块测试用例
├── TestObservable.lua    # Observable模块测试用例
├── TestEventLoop.lua     # EventLoop模块测试用例
├── TestHistoryManager.lua # HistoryManager模块测试用例
├── TestProtoDispatcher.lua # ProtoDispatcher模块测试用例
├── TestInterface.lua     # Interface模块测试用例
├── TestXmlParser.lua     # XmlParser模块测试用例
├── TestMsgPackFile.lua   # MsgPackFile模块测试用例
├── RunAllTests.lua       # 运行所有测试的脚本
└── README.md             # 说明文档
```

## 测试框架API

### TestFramework.addTestCase(name, testFunc)
添加一个测试用例到测试框架中。

参数:
- `name`: 测试用例名称
- `testFunc`: 测试函数

### TestFramework.runTest(name)
运行指定名称的测试用例。

### TestFramework.runAllTests()
运行所有已注册的测试用例。

### 断言函数

#### TestFramework.assertEquals(actual, expected, message)
断言两个值相等。

#### TestFramework.assertTrue(condition, message)
断言条件为真。

#### TestFramework.assertFalse(condition, message)
断言条件为假。

#### TestFramework.assertNotNil(value, message)
断言值不为nil。

#### TestFramework.assertNil(value, message)
断言值为nil。

## 编写测试用例

1. 创建一个新的测试文件，命名为`Test{ModuleName}.lua`
2. 引入测试框架: `local TestFramework = require("UnluaTest.init")`
3. 引入要测试的模块: `local Module = require("Path.To.Module")`
4. 编写测试函数
5. 使用`TestFramework.addTestCase()`注册测试用例
6. 返回测试函数以便其他文件引用

示例:
```lua
local TestFramework = require("UnluaTest.init")
local MyModule = require("Path.To.MyModule")

function testMyFunction()
    local result = MyModule.myFunction("input")
    TestFramework.assertEquals(result, "expected output")
end

TestFramework.addTestCase("MyModule.myFunction", testMyFunction)

return {
    testMyFunction = testMyFunction
}
```

## 运行测试

### 运行所有测试
```lua
require("UnluaTest.RunAllTests")
```

### 运行单个测试模块
```lua
require("UnluaTest.TestModuleName")
local TestFramework = require("UnluaTest.init")
TestFramework.runAllTests()
```

### 运行单个测试用例
```lua
require("UnluaTest.TestModuleName")
local TestFramework = require("UnluaTest.init")
TestFramework.runTest("TestCaseName")
```

## 各模块测试说明

### Utility模块
- **TableEx**: 表操作工具函数测试
- **Log**: 日志功能测试
- **LuaHelper**: Lua辅助函数测试
- **JsonFile**: JSON文件读写测试
- **CsvParser**: CSV解析测试
- **IniParser**: INI文件解析测试
- **Interface**: 接口基类测试
- **XmlParser**: XML文件解析测试
- **MsgPackFile**: MsgPack文件读写测试

### Core模块
- **EventDispatcher**: 事件分发机制测试
- **HttpHelper**: HTTP请求辅助函数测试
- **WebSocket**: WebSocket连接测试
- **Channel**: 通道通信测试
- **Delegate**: 委托模式测试
- **MultiDelegate**: 多委托模式测试
- **Observable**: 观察者模式测试
- **EventLoop**: 事件循环测试
- **HistoryManager**: 历史管理器测试
- **ProtoDispatcher**: 协议分发器测试

## 注意事项

1. 测试框架使用模拟(mock)技术来隔离外部依赖
2. 测试用例应尽量保持独立，避免相互依赖
3. 测试函数命名应清晰表达测试意图
4. 每个测试文件应返回其测试函数，便于其他文件引用