<![CDATA[# Birthday App

定制生日祝福页面（加密配置版）

## 使用方式

在 URL 后添加 `?id=用户ID` 参数访问定制页面

示例：`https://yourname.github.io/birthday/?id=abc123`

## 添加新用户

1. 打开 `config.js` 文件
2. 在浏览器控制台中使用 `encodeBase64('名字')` 获取加密后的名字
3. 添加新配置：

```javascript
"新ID": {
    name: "加密后的名字",
    message: "加密后的祝福语",
    candleCount: 5,
    theme: "pink"
}
```

## 测试账号

| ID | 名字 | 祝福语 |
|---|---|---|
| abc123 | 小明 | 生日快乐！祝小明 |
| xyz789 | 小红 | 生日快乐！天天开心 |
| test001 | 测试用户 | 恭喜生日快乐 |

## 本地预览

直接用浏览器打开 `index.html` 文件

## 隐私保护

- 名字和祝福语使用 Base64 编码
- 用户需要知道正确的 ID 才能访问
- 无法通过配置文件直接看到明文信息
]]>