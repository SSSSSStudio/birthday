// ========== 余额管理 ==========
let balance = parseInt(sessionStorage.getItem('balance') || '100', 10);
const balanceText = document.getElementById('balanceText');
function refreshBalance() {
    balanceText.textContent = balance;
    sessionStorage.setItem('balance', String(balance));
}
refreshBalance();

// ========== Babylon 初始化 ==========
const canvas = document.getElementById('renderCanvas');
const engine = new BABYLON.Engine(canvas, true, { preserveDrawingBuffer: true, stencil: true });
const scene = new BABYLON.Scene(engine);
scene.clearColor = new BABYLON.Color4(0.55, 0.78, 0.95, 1.0);

const camera = new BABYLON.ArcRotateCamera(
    "camera", -Math.PI / 4, Math.PI / 3.2, 16,
    new BABYLON.Vector3(0, 0.5, 0), scene
);
camera.lowerRadiusLimit = 12;
camera.upperRadiusLimit = 22;
camera.lowerBetaLimit = Math.PI / 4;
camera.upperBetaLimit = Math.PI / 2.5;

const ambient = new BABYLON.HemisphericLight("amb", new BABYLON.Vector3(0, 1, 0), scene);
ambient.intensity = 0.7;
ambient.groundColor = new BABYLON.Color3(0.4, 0.35, 0.3);
const dirLight = new BABYLON.DirectionalLight("dir", new BABYLON.Vector3(-0.5, -1, -0.4), scene);
dirLight.intensity = 0.5;

// ========== 乐高工具 ==========
const LEGO_COLORS = {
    red: new BABYLON.Color3(0.85, 0.15, 0.15),
    blue: new BABYLON.Color3(0.15, 0.4, 0.85),
    yellow: new BABYLON.Color3(1.0, 0.85, 0.1),
    green: new BABYLON.Color3(0.2, 0.7, 0.25),
    white: new BABYLON.Color3(0.95, 0.95, 0.92),
    black: new BABYLON.Color3(0.12, 0.12, 0.12),
    tan: new BABYLON.Color3(0.93, 0.82, 0.55),
    darkGray: new BABYLON.Color3(0.35, 0.35, 0.38),
    purple: new BABYLON.Color3(0.55, 0.25, 0.75),
    orange: new BABYLON.Color3(1.0, 0.55, 0.1)
};
function legoMat(name, color) {
    const m = new BABYLON.StandardMaterial(name, scene);
    m.diffuseColor = color;
    m.specularColor = new BABYLON.Color3(0.15, 0.15, 0.15);
    return m;
}
function createStud(x, z, color, y = 0.2) {
    const s = BABYLON.MeshBuilder.CreateCylinder("stud_" + x + "_" + z + "_" + Math.random(),
        { diameter: 0.45, height: 0.12, tessellation: 12 }, scene);
    s.position.set(x, y + 0.06, z);
    s.material = legoMat("studMat_" + Math.random(), color);
    return s;
}

// ========== 房间 + 出门点 + 柜台 ==========
const ROOM_W = 14, ROOM_D = 18, ROOM_H = 4.5;
const SHOP_BOUND_X = ROOM_W / 2 - 0.6;
const SHOP_BOUND_Z = ROOM_D / 2 - 0.6;
const EXIT_X = 0;
const EXIT_Z = ROOM_D / 2 - 1.2;
const COUNTERS = [
    { x: -4, price: 5,  color: LEGO_COLORS.red,    label: '5元' },
    { x:  0, price: 10, color: LEGO_COLORS.blue,   label: '10元' },
    { x:  4, price: 20, color: LEGO_COLORS.yellow, label: '20元' }
];

// ===== 地板 =====
const floor = BABYLON.MeshBuilder.CreateBox("floor", { width: ROOM_W, height: 0.2, depth: ROOM_D }, scene);
floor.position.y = 0.1;
floor.material = legoMat("floorMat", LEGO_COLORS.tan);
for (let x = -ROOM_W / 2 + 1; x < ROOM_W / 2; x += 1.3) {
    for (let z = -ROOM_D / 2 + 1; z < ROOM_D / 2; z += 1.3) {
        createStud(x, z, LEGO_COLORS.tan, 0.2);
    }
}

// ===== 墙壁 =====
// 给"会挡相机视线"的物体（前墙、门梁、左右墙）每个独立材质，便于单独调透明度
const wallMat = legoMat("wallMat", LEGO_COLORS.white); // 后墙等不会挡视线的可共用
const backWall = BABYLON.MeshBuilder.CreateBox("backWall", { width: ROOM_W, height: ROOM_H, depth: 0.3 }, scene);
backWall.position.set(0, ROOM_H / 2, -ROOM_D / 2);
backWall.material = wallMat;

// 左右墙独立材质 + 加入"近物淡出"列表（相机 alpha=-PI/4，看向 +X+Z 方向，靠近角色的右侧/下侧墙容易挡视线）
const leftWallMat = legoMat("leftWallMat", LEGO_COLORS.white);
const leftWall = BABYLON.MeshBuilder.CreateBox("leftWall", { width: 0.3, height: ROOM_H, depth: ROOM_D }, scene);
leftWall.position.set(-ROOM_W / 2, ROOM_H / 2, 0);
leftWall.material = leftWallMat;

const rightWallMat = legoMat("rightWallMat", LEGO_COLORS.white);
const rightWall = BABYLON.MeshBuilder.CreateBox("rightWall", { width: 0.3, height: ROOM_H, depth: ROOM_D }, scene);
rightWall.position.set(ROOM_W / 2, ROOM_H / 2, 0);
rightWall.material = rightWallMat;

const doorW = 2.4;
const sideW = (ROOM_W - doorW) / 2;

// 前墙左右段（最容易挡视线）
const frontLeftMat = legoMat("frontLeftMat", LEGO_COLORS.white);
const frontLeft = BABYLON.MeshBuilder.CreateBox("frontLeft", { width: sideW, height: ROOM_H, depth: 0.3 }, scene);
frontLeft.position.set(-(ROOM_W / 4 + doorW / 4), ROOM_H / 2, ROOM_D / 2);
frontLeft.material = frontLeftMat;

const frontRightMat = legoMat("frontRightMat", LEGO_COLORS.white);
const frontRight = BABYLON.MeshBuilder.CreateBox("frontRight", { width: sideW, height: ROOM_H, depth: 0.3 }, scene);
frontRight.position.set(ROOM_W / 4 + doorW / 4, ROOM_H / 2, ROOM_D / 2);
frontRight.material = frontRightMat;

const lintelMat = legoMat("lintelMat", LEGO_COLORS.red);
const lintel = BABYLON.MeshBuilder.CreateBox("lintel", { width: doorW + 0.4, height: 0.6, depth: 0.3 }, scene);
lintel.position.set(0, ROOM_H - 0.3, ROOM_D / 2);
lintel.material = lintelMat;

// "角色与相机之间的墙"列表：每项 { mat, axis, sign, near, far }
// 相机固定在角色的 (+X, -Z) 方向（alpha=-π/4, beta≈π/3.2 时计算得出 ≈ (+9, +8, -9)）
// 所以会挡住角色的墙是：后墙(-Z方向)、右墙(+X方向)
// 当角色靠近这些墙时，墙处于"角色和相机之间"，需要透明化
//
// axis: 'x' | 'z'，用于判断角色坐标
// sign: -1 | +1，墙位于哪一侧（+X 墙就是 +1，-Z 墙就是 -1）
// near/far: 角色坐标 * sign >= near 时完全透明，<= far 时完全不透明，中间线性插值
//
// 注意：后墙、窗户、招牌、LUCKY 字母都需要同步透明（它们都贴在后墙位置）
// 因此这些物体改用独立材质（在下方 backWallExtraMats 集合中），并和后墙一起淡出
const backWallExtraMats = []; // 占位，后面创建窗户/招牌时会 push 进来
const fadeTargets = [
    // 后墙：当角色 z 投影 >= 4（即 z <= -4，贴近后墙/柜台）时透明
    { mat: wallMat,       axis: 'z', sign: -1, near: 4, far: 1 },
    // 右墙
    { mat: rightWallMat,  axis: 'x', sign: +1, near: 4, far: 1 }
];
// 后墙装饰物（窗户、招牌、字母）的材质会在下方创建后追加到 fadeTargets，
// 跟随后墙的淡入淡出。
// 前墙左右段、门梁、左墙保持完全不透明（不会挡相机视线）
[frontLeftMat, frontRightMat, lintelMat, leftWallMat].forEach(m => { m.alpha = 1.0; });

// 后墙装饰：窗户、招牌、LUCKY 字母 —— 都贴在后墙上，需要和后墙同步淡出
// 收集所有装饰物的材质，加入"跟随后墙"组
[-3, 3].forEach(wx => {
    const win = BABYLON.MeshBuilder.CreateBox("win" + wx, { width: 1.2, height: 1, depth: 0.1 }, scene);
    win.position.set(wx, 2.2, -ROOM_D / 2 + 0.2);
    const wm = legoMat("winMat" + wx, LEGO_COLORS.blue);
    win.material = wm;
    backWallExtraMats.push(wm);
});

const sign = BABYLON.MeshBuilder.CreateBox("sign", { width: 6, height: 1.2, depth: 0.15 }, scene);
sign.position.set(0, 3.4, -ROOM_D / 2 + 0.2);
const signMat = legoMat("signMat", LEGO_COLORS.purple);
signMat.emissiveColor = new BABYLON.Color3(0.3, 0.1, 0.4);
sign.material = signMat;
backWallExtraMats.push(signMat);

const letterColors = [LEGO_COLORS.red, LEGO_COLORS.yellow, LEGO_COLORS.green, LEGO_COLORS.blue, LEGO_COLORS.orange];
for (let i = 0; i < 5; i++) {
    const letter = BABYLON.MeshBuilder.CreateBox("letter" + i, { width: 0.6, height: 0.6, depth: 0.1 }, scene);
    letter.position.set(-1.6 + i * 0.8, 3.4, -ROOM_D / 2 + 0.32);
    const lm = legoMat("letterMat" + i, letterColors[i]);
    lm.emissiveColor = letterColors[i].scale(0.4);
    letter.material = lm;
    backWallExtraMats.push(lm);
}

// 把所有"贴后墙"的装饰物材质加入 fadeTargets，跟随后墙的 axis/sign 联动
backWallExtraMats.forEach(m => {
    fadeTargets.push({ mat: m, axis: 'z', sign: -1, near: 4, far: 1 });
});

// ===== 柜台 =====
COUNTERS.forEach(cfg => {
    const counter = BABYLON.MeshBuilder.CreateBox("counter_" + cfg.price,
        { width: 2.4, height: 1.0, depth: 1.2 }, scene);
    counter.position.set(cfg.x, 0.6, -ROOM_D / 2 + 1.5);
    counter.material = legoMat("counterMat_" + cfg.price, LEGO_COLORS.darkGray);

    const top = BABYLON.MeshBuilder.CreateBox("counterTop_" + cfg.price,
        { width: 2.6, height: 0.12, depth: 1.4 }, scene);
    top.position.set(cfg.x, 1.16, -ROOM_D / 2 + 1.5);
    top.material = legoMat("counterTopMat_" + cfg.price, cfg.color);

    for (let ix = -1; ix <= 1; ix += 1) {
        for (let iz = -0.3; iz <= 0.3; iz += 0.6) {
            createStud(cfg.x + ix * 0.9, -ROOM_D / 2 + 1.5 + iz, cfg.color, 1.22);
        }
    }
    for (let k = 0; k < 5; k++) {
        const card = BABYLON.MeshBuilder.CreateBox("ticket_" + cfg.price + "_" + k,
            { width: 0.35, height: 0.5, depth: 0.04 }, scene);
        card.position.set(cfg.x - 0.8 + k * 0.4, 1.55, -ROOM_D / 2 + 1.5);
        const cm = legoMat("ticketMat_" + cfg.price + "_" + k, cfg.color);
        cm.emissiveColor = cfg.color.scale(0.3);
        card.material = cm;
    }
    const priceTag = BABYLON.MeshBuilder.CreateBox("priceTag_" + cfg.price,
        { width: 1.4, height: 0.6, depth: 0.1 }, scene);
    priceTag.position.set(cfg.x, 2.4, -ROOM_D / 2 + 0.5);
    const pm = legoMat("priceTagMat_" + cfg.price, LEGO_COLORS.white);
    pm.emissiveColor = new BABYLON.Color3(0.5, 0.5, 0.5);
    priceTag.material = pm;
    const priceBar = BABYLON.MeshBuilder.CreateBox("priceBar_" + cfg.price,
        { width: 1.2, height: 0.25, depth: 0.05 }, scene);
    priceBar.position.set(cfg.x, 2.4, -ROOM_D / 2 + 0.6);
    const pbm = legoMat("priceBarMat_" + cfg.price, cfg.color);
    pbm.emissiveColor = cfg.color.scale(0.5);
    priceBar.material = pbm;
});

// ===== 出门触发点 =====
const exitTrigger = BABYLON.MeshBuilder.CreateBox("exitTrigger",
    { width: 1.0, height: 0.4, depth: 1.0 }, scene);
exitTrigger.position.set(EXIT_X, 0.55, EXIT_Z);
const exitMat = legoMat("exitMat", LEGO_COLORS.green);
exitMat.emissiveColor = new BABYLON.Color3(0.1, 0.4, 0.1);
exitTrigger.material = exitMat;
for (let sx = -0.25; sx <= 0.25; sx += 0.5) {
    for (let sz = -0.25; sz <= 0.25; sz += 0.5) {
        createStud(EXIT_X + sx, EXIT_Z + sz, LEGO_COLORS.green, 0.75);
    }
}
let exitAnimT = 0;
scene.onBeforeRenderObservable.add(() => {
    exitAnimT += 0.02;
    exitTrigger.rotation.y += 0.02;
    exitTrigger.position.y = 0.55 + Math.sin(exitAnimT * 2.5) * 0.1;
});

// ===== 吊灯 =====
for (let lx of [-4, 0, 4]) {
    const pl = new BABYLON.PointLight("pl" + lx,
        new BABYLON.Vector3(lx, ROOM_H - 0.5, 0), scene);
    pl.diffuse = new BABYLON.Color3(1, 0.95, 0.8);
    pl.intensity = 0.8;
    pl.range = 10;
    const bulb = BABYLON.MeshBuilder.CreateSphere("bulb" + lx, { diameter: 0.5 }, scene);
    bulb.position.set(lx, ROOM_H - 0.3, 0);
    const bm = legoMat("bulbMat" + lx, LEGO_COLORS.yellow);
    bm.emissiveColor = new BABYLON.Color3(0.9, 0.8, 0.3);
    bulb.material = bm;
}

// ========== 乐高小人 ==========
function createLegoCharacter() {
    const group = new BABYLON.TransformNode("character", scene);
    const skin = new BABYLON.Color3(1.0, 0.82, 0.15);
    const shirt = LEGO_COLORS.red;
    const pants = LEGO_COLORS.blue;
    const hairColor = new BABYLON.Color3(0.22, 0.14, 0.08);
    const legMat = legoMat("legMat", pants);

    const legLG = new BABYLON.TransformNode("legLG", scene);
    legLG.parent = group; legLG.position.set(-0.13, 0.55, 0);
    const legL = BABYLON.MeshBuilder.CreateBox("legL", { width: 0.26, height: 0.55, depth: 0.3 }, scene);
    legL.position.y = -0.275; legL.material = legMat; legL.parent = legLG;

    const legRG = new BABYLON.TransformNode("legRG", scene);
    legRG.parent = group; legRG.position.set(0.13, 0.55, 0);
    const legR = BABYLON.MeshBuilder.CreateBox("legR", { width: 0.26, height: 0.55, depth: 0.3 }, scene);
    legR.position.y = -0.275; legR.material = legMat; legR.parent = legRG;

    const belt = BABYLON.MeshBuilder.CreateBox("belt", { width: 0.56, height: 0.06, depth: 0.32 }, scene);
    belt.position.set(0, 0.58, 0);
    belt.material = legoMat("beltMat", LEGO_COLORS.black);
    belt.parent = group;

    const torsoG = new BABYLON.TransformNode("torsoG", scene);
    torsoG.parent = group; torsoG.position.set(0, 0.6, 0);
    const torso = BABYLON.MeshBuilder.CreateCylinder("torso",
        { height: 0.7, diameterTop: 0.48, diameterBottom: 0.62, tessellation: 4 }, scene);
    torso.rotation.y = Math.PI / 4; torso.position.y = 0.35; torso.scaling.z = 0.62;
    torso.material = legoMat("torsoMat", shirt); torso.parent = torsoG;

    const shoulder = BABYLON.MeshBuilder.CreateBox("shoulder",
        { width: 0.62, height: 0.12, depth: 0.36 }, scene);
    shoulder.position.y = 0.72;
    shoulder.material = legoMat("shoulderMat", shirt);
    shoulder.parent = torsoG;

    function createArm(side) {
        const armG = new BABYLON.TransformNode("armG_" + side, scene);
        armG.parent = torsoG; armG.position.set(side * 0.35, 0.68, 0);
        const upper = BABYLON.MeshBuilder.CreateCylinder("arm_" + side,
            { diameter: 0.2, height: 0.55, tessellation: 10 }, scene);
        upper.position.set(side * 0.04, -0.28, 0.02);
        upper.rotation.z = side * 0.25; upper.rotation.x = -0.2;
        upper.material = legoMat("armMat" + side, shirt); upper.parent = armG;
        const hand = BABYLON.MeshBuilder.CreateCylinder("hand_" + side,
            { diameter: 0.24, height: 0.18, tessellation: 10 }, scene);
        hand.position.set(side * 0.14, -0.55, 0.12);
        hand.rotation.z = side * 0.25;
        hand.material = legoMat("handMat" + side, skin);
        hand.parent = armG;
        return armG;
    }
    const armL = createArm(-1);
    const armR = createArm(1);

    const neck = BABYLON.MeshBuilder.CreateCylinder("neck",
        { diameter: 0.22, height: 0.12, tessellation: 10 }, scene);
    neck.position.set(0, 1.38, 0);
    neck.material = legoMat("neckMat", skin); neck.parent = group;

    const head = BABYLON.MeshBuilder.CreateCylinder("head",
        { diameter: 0.55, height: 0.6, tessellation: 16 }, scene);
    head.position.set(0, 1.75, 0);
    const headMat = legoMat("headMat", skin);
    head.material = headMat; head.parent = group;

    const headStud = BABYLON.MeshBuilder.CreateCylinder("headStud",
        { diameter: 0.3, height: 0.1, tessellation: 14 }, scene);
    headStud.position.set(0, 2.1, 0); headStud.material = headMat; headStud.parent = group;

    const hair = BABYLON.MeshBuilder.CreateBox("hair",
        { width: 0.62, height: 0.22, depth: 0.62 }, scene);
    hair.position.set(0, 2.02, 0);
    hair.material = legoMat("hairMat", hairColor); hair.parent = group;
    const bangs = BABYLON.MeshBuilder.CreateBox("bangs",
        { width: 0.56, height: 0.15, depth: 0.12 }, scene);
    bangs.position.set(0, 1.95, 0.26); bangs.material = hair.material; bangs.parent = group;

    const eyeMat = legoMat("eyeMat", LEGO_COLORS.black);
    const eyeL = BABYLON.MeshBuilder.CreateSphere("eyeL", { diameter: 0.06 }, scene);
    eyeL.position.set(-0.1, 1.82, 0.27); eyeL.material = eyeMat; eyeL.parent = group;
    const eyeR = BABYLON.MeshBuilder.CreateSphere("eyeR", { diameter: 0.06 }, scene);
    eyeR.position.set(0.1, 1.82, 0.27); eyeR.material = eyeMat; eyeR.parent = group;
    const mouth = BABYLON.MeshBuilder.CreateBox("mouth",
        { width: 0.14, height: 0.03, depth: 0.02 }, scene);
    mouth.position.set(0, 1.7, 0.28);
    mouth.material = legoMat("mouthMat", new BABYLON.Color3(0.5, 0.1, 0.1));
    mouth.parent = group;

    group.metadata = { legL: legLG, legR: legRG, armL, armR };
    return group;
}

const character = createLegoCharacter();
character.position.set(EXIT_X, 0, EXIT_Z - 2.5);
character.rotation.y = Math.PI;

// ========== 摇杆 ==========
const joystickBase = document.getElementById('joystickBase');
const joystickThumb = document.getElementById('joystickThumb');
const JOYSTICK_RADIUS = 55;
let joystickActive = false;
let joystickPointerId = null;
const joystickCenter = { x: 0, y: 0 };
let moveInput = { x: 0, z: 0, magnitude: 0 };

const camAlpha = camera.alpha;
const forwardX = -Math.cos(camAlpha);
const forwardZ = -Math.sin(camAlpha);
const rightX = -Math.sin(camAlpha);
const rightZ = Math.cos(camAlpha);

function updateJoystickCenter() {
    const r = joystickBase.getBoundingClientRect();
    joystickCenter.x = r.left + r.width / 2;
    joystickCenter.y = r.top + r.height / 2;
}
function setThumb(dx, dy) {
    joystickThumb.style.transform = `translate(calc(-50% + ${dx}px), calc(-50% + ${dy}px))`;
}
function onJoyMove(cx, cy) {
    const dx = cx - joystickCenter.x;
    const dy = cy - joystickCenter.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const clamped = Math.min(dist, JOYSTICK_RADIUS);
    const angle = Math.atan2(dy, dx);
    const tx = Math.cos(angle) * clamped;
    const ty = Math.sin(angle) * clamped;
    setThumb(tx, ty);
    const sx = clamped > 0 ? tx / JOYSTICK_RADIUS : 0;
    const sy = clamped > 0 ? -ty / JOYSTICK_RADIUS : 0;
    moveInput.x = sx * rightX + sy * forwardX;
    moveInput.z = sx * rightZ + sy * forwardZ;
    moveInput.magnitude = Math.min(clamped / JOYSTICK_RADIUS, 1);
}
function joyEnd() {
    joystickActive = false;
    joystickPointerId = null;
    setThumb(0, 0);
    moveInput.x = 0; moveInput.z = 0; moveInput.magnitude = 0;
}
joystickBase.addEventListener('pointerdown', (e) => {
    joystickActive = true;
    joystickPointerId = e.pointerId;
    updateJoystickCenter();
    try { joystickBase.setPointerCapture(e.pointerId); } catch (_) { }
    onJoyMove(e.clientX, e.clientY);
});
joystickBase.addEventListener('pointermove', (e) => {
    if (!joystickActive || e.pointerId !== joystickPointerId) return;
    onJoyMove(e.clientX, e.clientY);
});
joystickBase.addEventListener('pointerup', joyEnd);
joystickBase.addEventListener('pointercancel', joyEnd);
window.addEventListener('resize', updateJoystickCenter);
setTimeout(updateJoystickCenter, 50);

// ========== UI 引用 ==========
const exitButton = document.getElementById('exitButton');
const buyButton = document.getElementById('buyButton');
const fadeOverlay = document.getElementById('fadeOverlay');
const scratchModal = document.getElementById('scratchModal');
const scratchTitle = document.getElementById('scratchTitle');
const scratchPrice = document.getElementById('scratchPrice');
const scratchCanvas = document.getElementById('scratchCanvas');           // 上层：灰色涂层（可擦）
const scratchPrizeCanvas = document.getElementById('scratchPrizeCanvas'); // 下层：奖项内容
const scratchResult = document.getElementById('scratchResult');
const scratchClose = document.getElementById('scratchClose');
const scratchAgain = document.getElementById('scratchAgain');
const ctx2d = scratchCanvas.getContext('2d');           // 涂层 ctx
const ctxPrize = scratchPrizeCanvas.getContext('2d');   // 奖项 ctx

// ========== 主循环：行走 + 触发检测 ==========
const WALK_SPEED = 0.12;
let walkTime = 0;
let exitCooldown = true;
setTimeout(() => { exitCooldown = false; }, 1500);

scene.onBeforeRenderObservable.add(() => {
    const meta = character.metadata;
    if (moveInput.magnitude > 0.05) {
        const targetAngle = Math.atan2(moveInput.x, moveInput.z);
        let cur = character.rotation.y;
        let diff = targetAngle - cur;
        while (diff > Math.PI) diff -= Math.PI * 2;
        while (diff < -Math.PI) diff += Math.PI * 2;
        character.rotation.y += diff * 0.2;

        const speed = WALK_SPEED * moveInput.magnitude;
        let nx = character.position.x + moveInput.x * speed;
        let nz = character.position.z + moveInput.z * speed;
        nx = Math.max(-SHOP_BOUND_X, Math.min(SHOP_BOUND_X, nx));
        nz = Math.max(-SHOP_BOUND_Z, Math.min(SHOP_BOUND_Z, nz));
        character.position.x = nx;
        character.position.z = nz;

        walkTime += 0.25 * moveInput.magnitude;
        const swing = Math.sin(walkTime) * 0.5;
        if (meta.legL) meta.legL.rotation.x = swing;
        if (meta.legR) meta.legR.rotation.x = -swing;
        if (meta.armL) meta.armL.rotation.x = -swing * 0.6;
        if (meta.armR) meta.armR.rotation.x = swing * 0.6;
        character.position.y = Math.abs(Math.sin(walkTime * 2)) * 0.04;
    } else {
        walkTime *= 0.85;
        if (meta.legL) meta.legL.rotation.x *= 0.85;
        if (meta.legR) meta.legR.rotation.x *= 0.85;
        if (meta.armL) meta.armL.rotation.x *= 0.85;
        if (meta.armR) meta.armR.rotation.x *= 0.85;
        character.position.y *= 0.85;
    }

    camera.target.x = character.position.x;
    camera.target.y = 0.5;
    camera.target.z = character.position.z;

    if (!exitCooldown) {
        const dxE = character.position.x - EXIT_X;
        const dzE = character.position.z - EXIT_Z;
        if (Math.sqrt(dxE * dxE + dzE * dzE) < 1.0) {
            exitButton.style.display = 'block';
        } else {
            exitButton.style.display = 'none';
        }
    }

    let nearestCfg = null;
    let nearestDist = 2.2;
    COUNTERS.forEach(cfg => {
        const dxC = character.position.x - cfg.x;
        const dzC = character.position.z - (-ROOM_D / 2 + 1.5 + 0.6);
        const d = Math.sqrt(dxC * dxC + dzC * dzC);
        if (d < nearestDist) { nearestDist = d; nearestCfg = cfg; }
    });
    if (nearestCfg && !scratchModal.classList.contains('show')) {
        buyButton.style.display = 'block';
        buyButton.textContent = `🎟️ 购买 ${nearestCfg.label} 刮刮乐`;
        buyButton.dataset.price = nearestCfg.price;
    } else {
        buyButton.style.display = 'none';
        delete buyButton.dataset.price;
    }
});

// ========== 渲染循环 ==========
engine.runRenderLoop(() => scene.render());
window.addEventListener('resize', () => engine.resize());

// ========== 异步加载 + 平滑淡入 ==========
// 等场景所有资源（mesh、材质、贴图）真正 ready，并且第一帧成功渲染后再淡出 loading 蒙层
// 避免出现"白屏一闪 → 卡顿 → 突然出现场景"的糟糕体验
function fadeOutLoading() {
    // 双 requestAnimationFrame：确保第一帧已经被浏览器实际绘制
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            fadeOverlay.classList.add('hidden');
            // CSS transition 是 0.7s，留 100ms 余量后彻底移除（防止挡住交互）
            setTimeout(() => { fadeOverlay.style.display = 'none'; }, 800);
        });
    });
}

// 兜底：3s 后无论场景是否 ready 都强制淡出（防止某些资源加载失败导致永远卡在 loading）
const loadingFallbackTimer = setTimeout(() => {
    console.warn('[lottery_shop] scene ready timeout, force fade out');
    fadeOutLoading();
}, 3000);

// 等场景真正 ready（材质/贴图/mesh 全部就绪）
scene.executeWhenReady(() => {
    // 再等一帧渲染完成，避免淡出后还看到一帧空场景
    scene.onAfterRenderObservable.addOnce(() => {
        clearTimeout(loadingFallbackTimer);
        fadeOutLoading();
    });
});

// ========== 出门 ==========
exitButton.addEventListener('click', () => {
    fadeOverlay.style.display = 'block';
    fadeOverlay.style.opacity = '0';
    fadeOverlay.classList.remove('hidden');
    requestAnimationFrame(() => { fadeOverlay.style.opacity = '1'; });
    sessionStorage.setItem('balance', String(balance));
    sessionStorage.setItem('returnFromShop', '1');
    setTimeout(() => { window.location.href = 'index.html'; }, 700);
});

// ========== 刮刮乐（多格机制）==========
// 设计：每张刮刮乐有 N 个独立格子（cells），每格独立 roll，单格中奖概率 60%。
// 中奖时按 PRIZE_WEIGHTS 从该价位的奖品权重表中按权重随机抽一个奖品（金额）。
// 总奖金 = 所有中奖格子的金额之和。
//
// 价位 → 格子数 + 中奖时的奖品权重表（权重和不要求归一，内部会归一）
//   amt 设计原则：让单张期望回报 ≈ 0.85~0.95 倍价格（让玩家略微亏一点点，
//   但仍然有大奖可能，符合真实彩票感）
// 玩法说明：
//   - mode: 'symbol'（默认）—— 每格直接显示奖品 emoji + 金额，中奖格按权重抽奖品
//   - mode: 'lucky_number' —— 顶部显示"中奖号码"，每格显示"数字 + 金额"，
//                              数字与中奖号码相同则该格中奖（按对应金额）
//   - numberRange: [min, max] —— lucky_number 模式下数字的范围
const SCRATCH_SPEC = {
    5:  { cells: 3, mode: 'symbol', prizes: [
            { s: '✨', amt: 2,    w: 50 },  // 高频小奖
            { s: '⭐', amt: 5,    w: 25 },  // 回本
            { s: '🌟', amt: 20,   w: 10 },  // 中奖
            { s: '💎', amt: 200,  w: 1  }   // 大奖
        ]},
    10: { cells: 4, mode: 'symbol', prizes: [
            { s: '✨', amt: 3,    w: 50 },
            { s: '⭐', amt: 10,   w: 25 },
            { s: '🌟', amt: 50,   w: 10 },
            { s: '💎', amt: 500,  w: 1  }
        ]},
    20: { cells: 6, mode: 'lucky_number', numberRange: [1, 30], prizes: [
            { amt: 8,    w: 50 },   // 高频小奖：与中奖号对上得 8 元
            { amt: 30,   w: 25 },   // 回本+
            { amt: 150,  w: 10 },   // 大奖
            { amt: 2000, w: 1  }    // 头奖
        ]}
};
// 整张刮刮乐的中奖概率（不是单格）：60% 概率中奖，40% 概率全部"谢谢惠顾"
const CARD_WIN_PROB = 0.6;

// 按权重抽奖品
function pickPrizeByWeight(prizes) {
    let total = 0;
    for (const p of prizes) total += p.w;
    let r = Math.random() * total;
    for (const p of prizes) {
        r -= p.w;
        if (r <= 0) return p;
    }
    return prizes[prizes.length - 1];
}

// 为整张刮刮乐生成所有格子的结果
// 规则：整张 60% 中奖。
//
// symbol 模式（5/10 元）：
//   - 未中奖：所有格子都是 null（"谢谢惠顾"）
//   - 中奖：随机选 1~N 个格子作为中奖格，每个中奖格按权重抽具体奖品（emoji + 金额）
//
// lucky_number 模式（20 元）：
//   - 顶部展示一个"中奖号码"（在 numberRange 内随机）
//   - 每个格子有自己的"号码"和"对应金额"
//   - 未中奖：所有格子的号码都 ≠ 中奖号码（用其他号码填充，金额仍随机）
//   - 中奖：随机选 1~N 个格子，把它们的号码设为中奖号码，金额按权重抽；
//     其他格子号码为非中奖号（金额仍随机展示，但因为号码不对所以不算中奖）
//
// 每项格式：
//   symbol 模式：     { prize: {s, amt} | null }
//   lucky_number 模式：{ prize: {amt} | null, number: int, displayAmt: int }
//                     prize 非空 = 该格中奖（号码 = winNumber，amt 是奖金），
//                     null = 该格号码 ≠ winNumber（不算中奖）
//                     number 是格子上要显示的号码，displayAmt 是格子上要显示的金额
function rollScratchCard(price) {
    const spec = SCRATCH_SPEC[price] || SCRATCH_SPEC[5];
    const cells = spec.cells;
    const mode = spec.mode || 'symbol';
    const result = [];

    // 先全部初始化为未中奖
    for (let i = 0; i < cells; i++) result.push({ prize: null });

    // 判定整张是否中奖
    const isWin = Math.random() < CARD_WIN_PROB;

    // ===== lucky_number 模式：先确定中奖号码和每格的展示号码 =====
    let winNumber = null;
    if (mode === 'lucky_number') {
        const [minN, maxN] = spec.numberRange || [1, 30];
        winNumber = minN + Math.floor(Math.random() * (maxN - minN + 1));

        // 给每格预设一个"非中奖号码"和一个随机展示金额（让玩家有期待感）
        for (let i = 0; i < cells; i++) {
            // 抽一个不等于 winNumber 的号码
            let n;
            do {
                n = minN + Math.floor(Math.random() * (maxN - minN + 1));
            } while (n === winNumber);
            result[i].number = n;
            // 展示金额从 prizes 表里随机抽一个（按权重）
            result[i].displayAmt = pickPrizeByWeight(spec.prizes).amt;
        }
    }

    // 未中奖：保持全 null（lucky_number 模式下号码已设为非中奖号码）
    if (!isWin) {
        return { cells: result, spec, winNumber };
    }

    // ===== 中奖：决定中奖格数量 =====
    let winCount = 1;
    while (winCount < cells && Math.random() < 0.35) {
        winCount++;
    }

    // 随机选 winCount 个不重复的格子索引作为中奖格
    const indices = [];
    for (let i = 0; i < cells; i++) indices.push(i);
    for (let i = indices.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [indices[i], indices[j]] = [indices[j], indices[i]];
    }
    const winIndices = indices.slice(0, winCount);

    // 给每个中奖格设置奖品
    winIndices.forEach(idx => {
        const prize = pickPrizeByWeight(spec.prizes);
        result[idx].prize = prize;
        if (mode === 'lucky_number') {
            // 中奖格的号码必须 = 中奖号码，展示金额 = 实际中奖金额
            result[idx].number = winNumber;
            result[idx].displayAmt = prize.amt;
        }
    });

    return { cells: result, spec, winNumber };
}

// 当前张刮刮乐的状态
let currentPrice = 5;
let drawingScratch = false;
// 当前张：cellLayout = [{ x, y, w, h, prize, scratched }, ...]
let cellLayout = [];
let cardSettled = false; // 整张是否已结算（所有格子都刮完）
let cardTotalWin = 0;     // 当前张已中奖总金额（实时累计）
let cardActive = false;   // 是否有未结算的张正在进行（用于关闭/再来一张时强制结算）

function settleCardIfNeeded(reason) {
    // reason: 'auto' | 'close' | 'again'
    if (!cardActive) return;
    if (cardSettled) return;
    // 强制把所有未刮的格子也算上（防止用户没刮完就关）
    cardSettled = true;
    cardActive = false;
    // 中奖总额已经在每格刮开时累加；如果有格子没刮开但有 prize，也要补加
    cellLayout.forEach(c => {
        if (!c.scratched && c.prize) {
            cardTotalWin += c.prize.amt;
            c.scratched = true;
        }
    });
    if (cardTotalWin > 0) {
        balance += cardTotalWin;
        refreshBalance();
    }
    // 显示结算文案
    const totalEl = document.getElementById('scratchResult');
    if (totalEl) {
        if (cardTotalWin > 0) {
            totalEl.textContent = `🎉 本张共中奖 ${cardTotalWin} 元（已加入余额）`;
        } else {
            totalEl.textContent = '😢 本张未中奖，再来一张试试？';
        }
    }
}

// 绘制下层奖项 canvas（按格子布局）
function drawPrizeLayer() {
    const W = scratchPrizeCanvas.width;
    const H = scratchPrizeCanvas.height;
    ctxPrize.globalCompositeOperation = 'source-over';
    ctxPrize.clearRect(0, 0, W, H);

    // 米色背景 + 装饰边框
    ctxPrize.fillStyle = '#fff8dc';
    ctxPrize.fillRect(0, 0, W, H);
    ctxPrize.strokeStyle = '#c89800';
    ctxPrize.lineWidth = 4;
    ctxPrize.strokeRect(6, 6, W - 12, H - 12);

    const isLuckyNumber = currentSpec && currentSpec.mode === 'lucky_number';

    if (isLuckyNumber) {
        // ===== lucky_number 模式：顶部展示"中奖号码" =====
        // 标题
        ctxPrize.fillStyle = '#a07000';
        ctxPrize.font = 'bold 12px sans-serif';
        ctxPrize.textAlign = 'center';
        ctxPrize.textBaseline = 'middle';
        ctxPrize.fillText('★ 中 奖 号 码 ★', W / 2, 16);

        // 中奖号码大字（带金色背景）
        const numBoxW = 80, numBoxH = 36;
        const numBoxX = (W - numBoxW) / 2;
        const numBoxY = 26;
        ctxPrize.fillStyle = '#ffd966';
        ctxPrize.fillRect(numBoxX, numBoxY, numBoxW, numBoxH);
        ctxPrize.strokeStyle = '#c89800';
        ctxPrize.lineWidth = 2;
        ctxPrize.strokeRect(numBoxX, numBoxY, numBoxW, numBoxH);
        ctxPrize.fillStyle = '#c44';
        ctxPrize.font = 'bold 28px sans-serif';
        ctxPrize.fillText(String(currentWinNumber ?? '?'), W / 2, numBoxY + numBoxH / 2 + 1);

        // 提示文字
        ctxPrize.fillStyle = '#a07000';
        ctxPrize.font = '10px sans-serif';
        ctxPrize.fillText('刮开下方格子，号码相同即中奖', W / 2, numBoxY + numBoxH + 8);
    } else {
        // ===== symbol 模式：常规标题 =====
        ctxPrize.fillStyle = '#a07000';
        ctxPrize.font = 'bold 14px sans-serif';
        ctxPrize.textAlign = 'center';
        ctxPrize.textBaseline = 'middle';
        ctxPrize.fillText('★ LUCKY DRAW ★', W / 2, 22);
    }

    // 画每个格子的奖项内容
    cellLayout.forEach((c, idx) => {
        // 格子背景框
        ctxPrize.fillStyle = '#fff';
        ctxPrize.fillRect(c.x, c.y, c.w, c.h);
        ctxPrize.strokeStyle = '#c89800';
        ctxPrize.lineWidth = 2;
        ctxPrize.strokeRect(c.x, c.y, c.w, c.h);

        // 格子编号小标
        ctxPrize.fillStyle = '#bbb';
        ctxPrize.font = 'bold 9px sans-serif';
        ctxPrize.textAlign = 'center';
        ctxPrize.textBaseline = 'middle';
        ctxPrize.fillText('#' + (idx + 1), c.x + c.w / 2, c.y + 9);

        if (isLuckyNumber) {
            // 显示号码（大）+ 金额（小）
            const isHit = c.prize != null; // 中奖格：号码 = winNumber
            // 号码
            ctxPrize.fillStyle = isHit ? '#c44' : '#444';
            ctxPrize.font = 'bold 22px sans-serif';
            ctxPrize.fillText(String(c.number ?? '-'), c.x + c.w / 2, c.y + c.h / 2 - 6);
            // 金额（中奖格高亮）
            ctxPrize.fillStyle = isHit ? '#c44' : '#888';
            ctxPrize.font = 'bold 12px sans-serif';
            ctxPrize.fillText(
                (c.displayAmt ?? 0) + '元',
                c.x + c.w / 2,
                c.y + c.h / 2 + 16
            );
            // 命中提示
            if (isHit) {
                ctxPrize.fillStyle = '#c44';
                ctxPrize.font = 'bold 9px sans-serif';
                ctxPrize.fillText('★中★', c.x + c.w / 2, c.y + c.h - 8);
            }
        } else {
            // symbol 模式：原有逻辑
            if (c.prize) {
                ctxPrize.fillStyle = '#c44';
                ctxPrize.font = 'bold 26px sans-serif';
                ctxPrize.fillText(c.prize.s, c.x + c.w / 2, c.y + c.h / 2 - 4);
                ctxPrize.fillStyle = '#c44';
                ctxPrize.font = 'bold 14px sans-serif';
                ctxPrize.fillText(c.prize.amt + '元', c.x + c.w / 2, c.y + c.h / 2 + 18);
            } else {
                ctxPrize.fillStyle = '#999';
                ctxPrize.font = '20px sans-serif';
                ctxPrize.fillText('🚫', c.x + c.w / 2, c.y + c.h / 2 - 2);
                ctxPrize.fillStyle = '#999';
                ctxPrize.font = 'bold 11px sans-serif';
                ctxPrize.fillText('谢谢', c.x + c.w / 2, c.y + c.h / 2 + 16);
            }
        }
    });
}

// 绘制上层灰色涂层 canvas
function drawCoverLayer() {
    const W = scratchCanvas.width;
    const H = scratchCanvas.height;
    ctx2d.globalCompositeOperation = 'source-over';
    ctx2d.clearRect(0, 0, W, H);

    // 上方留出 36px 标题区不画涂层（让玩家能看到提示）
    cellLayout.forEach(c => {
        // 银灰色渐变涂层
        const grad = ctx2d.createLinearGradient(c.x, c.y, c.x + c.w, c.y + c.h);
        grad.addColorStop(0, '#9aa0a6');
        grad.addColorStop(0.5, '#bcc1c6');
        grad.addColorStop(1, '#8a8f93');
        ctx2d.fillStyle = grad;
        ctx2d.fillRect(c.x, c.y, c.w, c.h);

        // 涂层提示
        ctx2d.fillStyle = 'rgba(255,255,255,0.85)';
        ctx2d.font = 'bold 14px sans-serif';
        ctx2d.textAlign = 'center';
        ctx2d.textBaseline = 'middle';
        ctx2d.fillText('🪙 刮开', c.x + c.w / 2, c.y + c.h / 2);
    });
}

// 计算单张刮刮乐的格子布局（自适应行列）
// mode: 'symbol' 顶部标题占 36px；'lucky_number' 顶部要放中奖号码框，占 78px
function computeCellLayout(cellsCount, mode) {
    const W = scratchPrizeCanvas.width;   // 320
    const H = scratchPrizeCanvas.height;  // 240
    const TOP_PAD = mode === 'lucky_number' ? 78 : 36;
    const PAD = 10;
    const SIDE_PAD = 12;
    const BOT_PAD = 12;

    // 选择行列数
    let cols, rows;
    if (cellsCount <= 3) { cols = cellsCount; rows = 1; }
    else if (cellsCount === 4) { cols = 2; rows = 2; }
    else if (cellsCount <= 6) { cols = 3; rows = 2; }
    else { cols = 3; rows = Math.ceil(cellsCount / 3); }

    const cellW = (W - SIDE_PAD * 2 - PAD * (cols - 1)) / cols;
    const cellH = (H - TOP_PAD - BOT_PAD - PAD * (rows - 1)) / rows;

    const layout = [];
    for (let i = 0; i < cellsCount; i++) {
        const r = Math.floor(i / cols);
        const c = i % cols;
        layout.push({
            x: SIDE_PAD + c * (cellW + PAD),
            y: TOP_PAD + r * (cellH + PAD),
            w: cellW,
            h: cellH,
            prize: null,
            scratched: false,
            number: null,    // lucky_number 模式下：该格的展示号码
            displayAmt: null // lucky_number 模式下：该格的展示金额
        });
    }
    return layout;
}

function openScratch(price) {
    // 如果上一张没结算，先强制结算（其实正常路径下 buyScratch 已经先 settle 了）
    settleCardIfNeeded('again');

    currentPrice = price;
    cardSettled = false;
    cardActive = true;
    cardTotalWin = 0;

    const spec = SCRATCH_SPEC[price] || SCRATCH_SPEC[5];
    const card = rollScratchCard(price);

    // 缓存当前张的 spec 和中奖号码（drawPrizeLayer 需要读取）
    currentSpec = spec;
    currentWinNumber = card.winNumber ?? null;

    // 根据 cells 数和模式计算布局，并把每格数据注入
    cellLayout = computeCellLayout(spec.cells, spec.mode);
    cellLayout.forEach((c, idx) => {
        const src = card.cells[idx];
        c.prize = src.prize;
        c.number = src.number ?? null;
        c.displayAmt = src.displayAmt ?? null;
    });

    const isLN = spec.mode === 'lucky_number';
    scratchTitle.textContent = isLN
        ? `🎟️ ${price} 元对号刮刮乐（${spec.cells} 格）`
        : `🎟️ ${price} 元刮刮乐（${spec.cells} 格）`;
    scratchPrice.textContent = isLN
        ? `余额：${balance} 元 · 号码相同即中奖`
        : `余额：${balance} 元`;
    scratchResult.textContent = isLN
        ? '刮开格子，号码与上方"中奖号码"相同即中对应金额'
        : '依次刮开每个格子查看奖项';
    scratchModal.classList.add('show');

    drawPrizeLayer();
    drawCoverLayer();
}

buyButton.addEventListener('click', () => {
    const price = parseInt(buyButton.dataset.price || '0', 10);
    if (!price) return;
    if (balance < price) {
        alert('余额不足，需要 ' + price + ' 元');
        return;
    }
    // 如果当前张未结算（玩家点了再来一张？），先结算累加余额
    settleCardIfNeeded('again');
    balance -= price;
    refreshBalance();
    openScratch(price);
});

function scratchAt(x, y) {
    ctx2d.globalCompositeOperation = 'destination-out';
    ctx2d.beginPath();
    ctx2d.arc(x, y, 18, 0, Math.PI * 2);
    ctx2d.fill();
}
function getScratchPos(e) {
    const r = scratchCanvas.getBoundingClientRect();
    const cx = e.clientX;
    const cy = e.clientY;
    return {
        x: (cx - r.left) * (scratchCanvas.width / r.width),
        y: (cy - r.top) * (scratchCanvas.height / r.height)
    };
}

// 检查每个格子的涂层刮开比例：超过 60% 视为该格已开奖
function checkCellsScratched() {
    if (!cardActive || cardSettled) return;
    const W = scratchCanvas.width;
    const fullData = ctx2d.getImageData(0, 0, W, scratchCanvas.height).data;
    let newWinThisCheck = 0;
    let newWinAmounts = [];

    cellLayout.forEach((c, idx) => {
        if (c.scratched) return;
        // 在该格区域内计算被刮开的像素比例
        let cleared = 0;
        let total = 0;
        const xStart = Math.max(0, Math.floor(c.x));
        const yStart = Math.max(0, Math.floor(c.y));
        const xEnd = Math.min(W, Math.floor(c.x + c.w));
        const yEnd = Math.min(scratchCanvas.height, Math.floor(c.y + c.h));
        for (let yy = yStart; yy < yEnd; yy += 2) {
            for (let xx = xStart; xx < xEnd; xx += 2) {
                const i = (yy * W + xx) * 4 + 3; // alpha 通道
                total++;
                if (fullData[i] < 50) cleared++;
            }
        }
        const ratio = total > 0 ? cleared / total : 0;
        if (ratio > 0.55) {
            c.scratched = true;
            // 把该格的涂层完全清除（视觉上更整齐）
            ctx2d.globalCompositeOperation = 'destination-out';
            ctx2d.fillStyle = '#000';
            ctx2d.fillRect(c.x, c.y, c.w, c.h);
            if (c.prize) {
                cardTotalWin += c.prize.amt;
                newWinAmounts.push(c.prize.amt);
                newWinThisCheck++;
            }
        }
    });

    // 实时显示当前进度
    const allScratched = cellLayout.every(c => c.scratched);
    if (newWinThisCheck > 0) {
        scratchResult.textContent = `🎉 已中 ${cardTotalWin} 元（继续刮其他格子）`;
    } else if (allScratched) {
        // 全部刮完，自动结算
        if (cardTotalWin > 0) {
            balance += cardTotalWin;
            refreshBalance();
            scratchResult.textContent = `🎉 本张共中奖 ${cardTotalWin} 元（已加入余额）`;
        } else {
            scratchResult.textContent = '😢 本张未中奖，再来一张试试？';
        }
        cardSettled = true;
        cardActive = false;
    }
}

scratchCanvas.addEventListener('pointerdown', (e) => {
    if (cardSettled) return; // 已结算的张不能再刮
    drawingScratch = true;
    try { scratchCanvas.setPointerCapture(e.pointerId); } catch (_) { }
    const p = getScratchPos(e);
    scratchAt(p.x, p.y);
});
scratchCanvas.addEventListener('pointermove', (e) => {
    if (!drawingScratch) return;
    const p = getScratchPos(e);
    scratchAt(p.x, p.y);
});
scratchCanvas.addEventListener('pointerup', () => {
    drawingScratch = false;
    checkCellsScratched();
});
scratchCanvas.addEventListener('pointerleave', () => {
    drawingScratch = false;
    checkCellsScratched();
});

scratchClose.addEventListener('click', () => {
    // 关闭时强制结算（防止玩家没刮完就关导致奖金丢失）
    settleCardIfNeeded('close');
    scratchModal.classList.remove('show');
});
scratchAgain.addEventListener('click', () => {
    if (balance < currentPrice) {
        alert('余额不足，需要 ' + currentPrice + ' 元');
        return;
    }
    // 强制结算上一张，把奖金加进余额
    settleCardIfNeeded('again');
    balance -= currentPrice;
    refreshBalance();
    openScratch(currentPrice);
});

// ========== 角色位置驱动的墙体透明 ==========
// 相机固定视角（alpha=-π/4, beta≈π/3.2）→ 相机位于角色的 (+X, -Z) 方向
// 所以"角色和相机之间的墙"就是后墙(-Z) 和右墙(+X)：
//   - 角色越靠近后墙（z 越小，sign=-1, 角色 z * -1 越大）→ 后墙越透明
//   - 角色越靠近右墙（x 越大，sign=+1）→ 右墙越透明
// 计算方式：角色"贴墙距离" = (角色坐标 * sign) 越大表示越靠近该墙
//   实际"贴墙距离" 应该是 (墙坐标 - 角色坐标) * sign，结果越小越靠近
//   为简化，我们直接用 角色坐标 * sign 的值与阈值比较：
//     当 角色坐标 * sign >= near 时，墙完全透明（角色贴墙）
//     当 角色坐标 * sign <= far 时，墙完全不透明（角色远离）
//     中间线性插值
fadeTargets.forEach(t => {
    t.mat.alpha = 1.0;
    t.mat.backFaceCulling = false;
    // 启用 alpha 混合并标记为透明物体（避免和不透明物体的渲染顺序问题）
    t.mat.transparencyMode = BABYLON.Material.MATERIAL_ALPHABLEND;
});

scene.onBeforeRenderObservable.add(() => {
    const charX = character.position.x;
    const charZ = character.position.z;
    fadeTargets.forEach(t => {
        const coord = t.axis === 'x' ? charX : charZ;
        const projected = coord * t.sign; // 在墙的方向上的投影位置（越大越接近墙）
        let alpha;
        if (projected >= t.near) {
            alpha = 0.15; // 角色贴墙，墙几乎透明
        } else if (projected <= t.far) {
            alpha = 1.0;  // 角色远离墙，墙完全不透明
        } else {
            // 线性插值
            const k = (projected - t.far) / (t.near - t.far);
            alpha = 1.0 - k * (1.0 - 0.15);
        }
        if (Math.abs(t.mat.alpha - alpha) > 0.005) {
            t.mat.alpha = alpha;
        }
    });
});

// 5 秒后隐藏顶部 hint
setTimeout(() => {
    const h = document.getElementById('hint');
    if (h) {
        h.style.transition = 'opacity 0.6s';
        h.style.opacity = '0';
        setTimeout(() => { h.style.display = 'none'; }, 700);
    }
}, 5000);
