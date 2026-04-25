/**
 * 乐高样式公共库
 * 统一管理乐高配色、材质生成器和突点创建函数
 */

// ========== 乐高配色（饱和鲜艳） ==========
const LEGO_COLORS = {
    red:    new BABYLON.Color3(0.85, 0.15, 0.15),
    blue:   new BABYLON.Color3(0.10, 0.35, 0.75),
    yellow: new BABYLON.Color3(1.00, 0.80, 0.05),
    green:  new BABYLON.Color3(0.15, 0.60, 0.25),
    white:  new BABYLON.Color3(0.95, 0.95, 0.95),
    black:  new BABYLON.Color3(0.08, 0.08, 0.08),
    gray:   new BABYLON.Color3(0.55, 0.55, 0.58),
    darkGray: new BABYLON.Color3(0.30, 0.30, 0.33),
    orange: new BABYLON.Color3(0.95, 0.50, 0.10),
    purple: new BABYLON.Color3(0.55, 0.25, 0.70),
    tan:    new BABYLON.Color3(0.88, 0.75, 0.55),
    lime:   new BABYLON.Color3(0.70, 0.85, 0.20)
};

/**
 * 乐高材质生成器
 * @param {string} name - 材质名称
 * @param {BABYLON.Color3} color - 材质颜色
 * @param {BABYLON.Scene} scene - 场景对象
 * @returns {BABYLON.StandardMaterial} 乐高材质对象
 */
function legoMat(name, color, scene) {
    const m = new BABYLON.StandardMaterial(name, scene);
    m.diffuseColor = color;
    m.specularColor = new BABYLON.Color3(0.15, 0.15, 0.15);
    m.specularPower = 32;
    return m;
}

/**
 * 创建乐高突点（带材质缓存优化）
 * @param {number} x - X 坐标
 * @param {number} z - Z 坐标
 * @param {BABYLON.Color3} color - 突点颜色
 * @param {number} y - 基础 Y 坐标（默认 0）
 * @param {number} diameter - 突点直径（默认 0.45）
 * @param {number} height - 突点高度（默认 0.12）
 * @param {BABYLON.Scene} scene - 场景对象
 * @returns {BABYLON.Mesh} 突点网格对象
 */
function createStud(x, z, color, y = 0, diameter = 0.45, height = 0.12, scene) {
    const stud = BABYLON.MeshBuilder.CreateCylinder(
        `stud_${x}_${z}_${Math.random()}`,
        { diameter: diameter, height: height, tessellation: 12 },
        scene
    );
    stud.position.set(x, y + height / 2, z);
    
    // 材质缓存优化：相同颜色共享材质
    if (!color._studMat) {
        color._studMat = legoMat(`studMat_${color.toHexString()}`, color, scene);
    }
    stud.material = color._studMat;
    
    return stud;
}
