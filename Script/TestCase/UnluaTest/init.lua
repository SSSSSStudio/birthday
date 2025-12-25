---
-- UnluaTest 测试用例初始化
-- 此文件现在仅作为测试框架的引用入口
-- 实际的测试框架已迁移到 Framework/UnitTest/TestFramework.lua
--

-- 加载核心测试框架
local TestFramework = require("Framework.UnitTest.TestFramework")

-- 为了保持向后兼容，直接返回测试框架
return TestFramework
