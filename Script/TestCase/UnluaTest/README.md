# UnluaTest Framework

## 概述

UnluaTest 是一个为 Unlua 项目中的 Lua 模块设计的单元测试框架。它提供了完整的测试用例管理、断言函数和测试运行器，帮助开发者编写和运行测试用例。

## 目录结构

```
TestCase/
├── TestFramework.lua     # 核心测试框架（断言、测试管理）
├── TestRunner.lua        # 测试运行器（加载和运行测试套件）
└── UnluaTest/            # 测试用例目录
    ├── init.lua          # 测试框架引用入口
    ├── RunAllTests.lua   # 运行所有测试的脚本
    ├── README.md         # 说明文档
    │
    ├── TestTableEx.lua       # TableEx 模块测试用例
    ├── TestLog.lua           # Log 模块测试用例
    ├── TestLuaHelper.lua     # LuaHelper 模块测试用例
    ├── TestJsonFile.lua      # JsonFile 模块测试用例
    ├── TestCsvParser.lua     # CsvParser 模块测试用例
    ├── TestIniParser.lua     # IniParser 模块测试用例
    ├── TestXmlParser.lua     # XmlParser 模块测试用例
    ├── TestMsgPackFile.lua   # MsgPackFile 模块测试用例
    ├── TestInterface.lua     # Interface 模块测试用例
    │
    ├── TestEventDispatcher.lua # EventDispatcher 模块测试用例
    ├── TestHttpHelper.lua    # HttpHelper 模块测试用例
    ├── TestWebSocket.lua     # WebSocket 模块测试用例
    ├── TestChannel.lua       # Channel 模块测试用例
    ├── TestDelegate.lua      # Delegate 模块测试用例
    ├── TestMultiDelegate.lua # MultiDelegate 模块测试用例
    ├── TestObservable.lua    # Observable 模块测试用例
    ├── TestEventLoop.lua     # EventLoop 模块测试用例
    ├── TestHistoryManager.lua # HistoryManager 模块测试用例
    └── TestProtoDispatcher.lua # ProtoDispatcher 模块测试用例
```

## 测试框架 API

### 核心功能

- `TestFramework.addTestCase(name, testFunc)` - 添加测试用例
- `TestFramework.runTest(name)` - 运行单个测试用例
- `TestFramework.runAllTests()` - 运行所有测试用例
- `TestFramework.clear()` - 清空所有测试用例和结果
- `TestFramework.getStatistics()` - 获取测试统计信息

### 断言函数

- `TestFramework.assertEquals(actual, expected, message)` - 断言两个值相等
- `TestFramework.assertTrue(condition, message)` - 断言条件为真
- `TestFramework.assertFalse(condition, message)` - 断言条件为假
- `TestFramework.assertNotNil(value, message)` - 断言值不为 nil
- `TestFramework.assertNil(value, message)` - 断言值为 nil
- `TestFramework.assertContainsKey(table, key, message)` - 断言表包含指定的键
- `TestFramework.assertNotContainsKey(table, key, message)` - 断言表不包含指定的键
- `TestFramework.assertError(func, message)` - 断言函数抛出错误
- `TestFramework.assertNoError(func, message)` - 断言函数不抛出错误

### 测试运行器 API

- `TestRunner.loadTests(testModules)` - 加载指定的测试模块列表
- `TestRunner.runAll()` - 运行所有已加载的测试
- `TestRunner.runTestSuite(testModules)` - 加载并运行测试套件（一站式方法）

## 编写测试用例

### 标准测试用例模板

1. 创建一个新的测试文件，命名为 `Test{ModuleName}.lua`
2. 引入测试框架: `local TestFramework = require("TestCase.UnluaTest.init")`
3. 引入要测试的模块: `local Module = require("Path.To.Module")`
4. 编写测试函数
5. 使用 `TestFramework.addTestCase()` 注册测试用例
6. 返回测试函数以便其他文件引用

### 示例

```lua
---
-- MyModule 测试用例
--

local TestFramework = require("TestCase.UnluaTest.init")
local MyModule = require("Path.To.MyModule")

-- 测试函数1：正常流程
local function testMyFunction()
    local result = MyModule.myFunction("input")
    TestFramework.assertEquals(result, "expected output")
end

-- 测试函数2：边界条件
local function testMyFunctionWithNil()
    local result = MyModule.myFunction(nil)
    TestFramework.assertNil(result, "Should handle nil input")
end

-- 测试函数3：异常情况
local function testMyFunctionError()
    TestFramework.assertError(function()
        MyModule.myFunction("invalid")
    end, "Should throw error for invalid input")
end

-- 注册测试用例
TestFramework.addTestCase("MyModule.myFunction", testMyFunction)
TestFramework.addTestCase("MyModule.myFunctionWithNil", testMyFunctionWithNil)
TestFramework.addTestCase("MyModule.myFunctionError", testMyFunctionError)

-- 导出测试函数（可选）
return {
    testMyFunction = testMyFunction,
    testMyFunctionWithNil = testMyFunctionWithNil,
    testMyFunctionError = testMyFunctionError
}
```

### 集成到测试套件

在 `RunAllTests.lua` 中添加新的测试模块：

```lua
local testModules = {
    -- ... 现有的测试模块 ...
    "TestCase.UnluaTest.TestMyModule",  -- 添加新测试模块
}
```

## 运行测试

### 方式1：自动运行（推荐）

在 `GI_G01GameInstance_C.lua` 中已配置自动运行：

```lua
function M:ReceiveInit()
    LuaHelper.DisableGlobalVariable()
    EventLoop.Startup();
    self:RunTest();  -- 自动运行所有测试
end
```

### 方式2：手动运行所有测试

```lua
require("TestCase.UnluaTest.RunAllTests")
```

### 方式3：使用测试运行器

```lua
local TestRunner = require("TestCase.TestRunner")

local testModules = {
    "TestCase.UnluaTest.TestTableEx",
    "TestCase.UnluaTest.TestLog",
    -- ... 其他测试模块
}

local success = TestRunner.runTestSuite(testModules)
```

### 方式4：直接使用测试框架

```lua
-- 加载测试框架
local TestFramework = require("TestCase.TestFramework")

-- 注册测试用例
TestFramework.addTestCase("MyTest", function()
    TestFramework.assertEquals(1 + 1, 2)
end)

-- 运行所有测试
TestFramework.runAllTests()
```

### 方式5：运行单个测试模块

```lua
require("TestCase.UnluaTest.TestTableEx")
local TestFramework = require("TestCase.UnluaTest.init")
TestFramework.runAllTests()
```

### 方式6：运行单个测试用例

```lua
require("TestCase.UnluaTest.TestTableEx")
local TestFramework = require("TestCase.UnluaTest.init")
TestFramework.runTest("TableEx.DeepCopy")
```

## 测试覆盖模块

### Utility 工具模块（9个）

| 测试文件 | 测试模块 | 主要测试内容 |
|---------|---------|------------|
| `TestTableEx.lua` | TableEx | 表操作：CheckTable, DeepCopy, Length, GetKeys, Merge, Map |
| `TestLog.lua` | Log | 日志功能：Config, Error, Warning, Info, PrintT, Printf |
| `TestLuaHelper.lua` | LuaHelper | Lua 辅助函数：XpCall 等 |
| `TestJsonFile.lua` | JsonFile | JSON 文件读写操作 |
| `TestCsvParser.lua` | CsvParser | CSV 文件解析 |
| `TestIniParser.lua` | IniParser | INI 配置文件解析 |
| `TestXmlParser.lua` | XmlParser | XML 文件解析 |
| `TestMsgPackFile.lua` | MsgPackFile | MsgPack 文件读写 |
| `TestInterface.lua` | Interface | 接口基类功能 |

### Core 核心模块（13个）

| 测试文件 | 测试模块 | 主要测试内容 |
|---------|---------|------------|
| `TestDelegate.lua` | Delegate | 委托模式：Bind, BindObject, Unbind, Execute, IsValid |
| `TestMultiDelegate.lua` | MultiDelegate | 多委托模式 |
| `TestObservable.lua` | Observable | 观察者模式：Register, Deregister, Notify |
| `TestEventDispatcher.lua` | EventDispatcher | 事件分发机制 |
| `TestEventLoop.lua` | EventLoop | 事件循环：Startup, Tick, Shutdown |
| `TestHttpHelper.lua` | HttpHelper | HTTP 请求辅助 |
| `TestWebSocket.lua` | WebSocket | WebSocket 连接管理 |
| `TestChannel.lua` | Channel | 通道通信 |
| `TestHistoryManager.lua` | HistoryManager | 历史记录管理 |
| `TestProtoDispatcher.lua` | ProtoDispatcher | 协议分发器 |

**总计：22 个测试模块**

## 测试框架特性

### ✨ 核心特性

1. **完整的断言库**：10 个断言函数，覆盖常见测试场景
2. **测试套件管理**：支持批量加载和运行测试
3. **详细的测试报告**：清晰的通过/失败统计和错误信息
4. **Mock 支持**：使用 `package.loaded` 进行依赖注入
5. **独立性保证**：测试用例相互独立，避免干扰

### 📊 测试输出示例

```
============================================================
Running all tests...
============================================================
✅ Test 'TableEx.CheckTable' passed
✅ Test 'TableEx.DeepCopy' passed
❌ Test 'TableEx.Length' failed: Expected 3, but got 2
...

============================================================
Test Results Summary
============================================================
✅ Passed: 20
❌ Failed: 2
📊 Total:  22
============================================================
⚠️  Some tests failed!
============================================================
```

## 最佳实践

### 测试编写建议

1. **命名规范**
   - 测试文件：`Test{ModuleName}.lua`
   - 测试函数：`test{FeatureName}`
   - 测试用例名：`ModuleName.FeatureName`

2. **测试覆盖**
   - 正常流程测试
   - 边界条件测试
   - 异常情况测试

3. **Mock 使用**
   ```lua
   -- Mock 外部依赖
   package.loaded["Utility.Interface"] = function(name)
       -- Mock 实现
   end
   ```

4. **测试独立性**
   - 每个测试函数应该独立运行
   - 避免测试之间的依赖关系
   - 使用局部变量避免全局污染

5. **清晰的断言消息**
   ```lua
   TestFramework.assertEquals(result, expected, "Result should match expected value")
   ```

## 注意事项

1. 测试框架使用模拟(mock)技术来隔离外部依赖
2. 测试用例应尽量保持独立，避免相互依赖
3. 测试函数命名应清晰表达测试意图
4. 每个测试文件应返回其测试函数，便于其他文件引用