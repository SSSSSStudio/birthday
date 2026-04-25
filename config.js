// Birthday page configuration
// Names and messages are Base64 encoded

const birthdayConfigs = {
    "abc123": {
        name: "5bCP5piO",
        message: "55Sf5pel5b+r5LmQ77yB56WdIOWwj+aYjg==",
        candleCount: 5,
        theme: "pink"
    },
    "xyz789": {
        name: "5bCP57qi",
        message: "55Sf5pel5b+r5LmQ77yB5aSp5aSp5byA5b+D",
        candleCount: 3,
        theme: "blue"
    },
    "test001": {
        name: "5rWL6K+V55So5oi3",
        message: "5oGt5Zac55Sf5pel5b+r5LmQ",
        candleCount: 7,
        theme: "gold"
    }
};

function decodeBase64(str) {
    try {
        return decodeURIComponent(escape(atob(str)));
    } catch (e) {
        return str;
    }
}

function encodeBase64(str) {
    return btoa(unescape(encodeURIComponent(str)));
}

function getConfigById(id) {
    const config = birthdayConfigs[id];
    if (!config) return null;
    return {
        name: decodeBase64(config.name),
        message: decodeBase64(config.message),
        candleCount: config.candleCount,
        theme: config.theme
    };
}
