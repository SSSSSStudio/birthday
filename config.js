<![CDATA[// 生日页面配置文件（加密版）
// 名字和祝福语使用 Base64 编码

const birthdayConfigs = {
    // 示例用户 1
    "abc123": {
        name: "5bCP5aO9",  // 小明 (Base64 编码)
        message: "55Sf5LqG5a2m5Lmg77yM5ZCn5a625bCP5aO9",  // 生日快乐！祝小明
        candleCount: 5,
        theme: "pink"
    },
    // 示例用户 2
    "xyz789": {
        name: "5bCP5bel",  // 小红 (Base64 编码)
        message: "55Sf5LqG5a2m5Lmg77yM5a6J5YWo5LqG5bm/5rqQ",  // 生日快乐！天天开心
        candleCount: 3,
        theme: "blue"
    },
    // 示例用户 3
    "test001": {
        name: "566h55qE5Lq6",  // 测试用户
        message: "6L+Z6YeM55Sf5LqG5a2m5Lmg",  // 恭喜生日快乐
        candleCount: 7,
        theme: "gold"
    }
};

// 解码函数
function decodeBase64(str) {
    try {
        return decodeURIComponent(escape(atob(str)));
    } catch (e) {
        return str;  // 如果解码失败，返回原文
    }
}

// 编码函数（用于生成配置时使用）
function encodeBase64(str) {
    return btoa(unescape(encodeURIComponent(str)));
}

// 根据 ID 获取配置
function getConfigById(id) {
    const config = birthdayConfigs[id];
    if (!config) return null;
    
    // 解密后返回
    return {
        name: decodeBase64(config.name),
        message: decodeBase64(config.message),
        candleCount: config.candleCount,
        theme: config.theme
    };
}
]]>