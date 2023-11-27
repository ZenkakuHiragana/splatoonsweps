
---@class ss
local ss = SplatoonSWEPs
if not ss then return end

---Pixels with alpha value greater than this threshold will be considered as swimmable
local MASK_THRESHOLD_SWIM = 47

---Pixels with alpha value greater than this threshold will be counted as turf inked
local MASK_THRESHOLD_TURF = 76
local PAINT_TEXTURES_ROOT = "materials/splatoonsweps/paints/"

---Reads the alpha channel of given paint texture to build a mask,
---assuming the texture is uncompressed vtf and has no metadata.
---This is considered as some kind of what $alphatest and $alphatestreference do.
---@param category string
---@param variant integer
---@param threshold integer
---@return ss.InkShotMask
local function BuildInkShotMask(category, variant, threshold)
    local path = string.format(PAINT_TEXTURES_ROOT .. "%s/a%d.vtf", category, variant)
    local vtf = file.Open(path, "rb", "GAME")
    local mask = { width = 0, height = 0 } ---@type ss.InkShotMask
    if not vtf then return mask end
    vtf:Seek(0x10)
    mask.width = vtf:ReadUShort()
    mask.height = vtf:ReadUShort()
    vtf:Seek(0x50)
    local bin = vtf:Read(mask.width * mask.height * 4)
    vtf:Close()

    for y = 1, mask.height do
        for x = 1, mask.width do
            local offset = (x + (y - 1) * mask.width) * 4
            mask[x] = mask[x] or {}
            mask[x][y] = bin:byte(offset, offset) > threshold
        end
    end

    return mask
end

---Precaches materials of given "category" - a group of paint texture variants 
---@param category string
local function LoadPaintTextureCategory(category)
    ss.InkShotTypes[category] = {}
    local numVariants = #ss.InkShotMaskSwim
    local fmt = string.format(PAINT_TEXTURES_ROOT .. "%s/%%d-%%%%d.vmt", category)
    local fmtn = string.format(PAINT_TEXTURES_ROOT .. "%s/%%d-%%%%dn.vmt", category)
    local variant, fmt2, fmt2n = 1, fmt:format(1), fmtn:format(1)
    while file.Exists(fmt2:format(1), "GAME") do
        numVariants = numVariants + 1
        table.insert(ss.InkShotTypes[category], numVariants)
        ss.InkShotMaskSwim[numVariants] = BuildInkShotMask(category, variant, MASK_THRESHOLD_SWIM)
        ss.InkShotMaskTurf[numVariants] = BuildInkShotMask(category, variant, MASK_THRESHOLD_TURF)
        if CLIENT then
            ss.InkShotMaterials[numVariants] = {}
            ss.InkShotNormals[numVariants] = {}
        end

        local alpha, path, pathn = 1, fmt2:format(1), fmt2n:format(1)
        while file.Exists(path, "GAME") do
            if CLIENT then
                ss.InkShotMaterials[#ss.InkShotMaterials][alpha] = Material(path:sub(11))
                ss.InkShotNormals[#ss.InkShotNormals][alpha] = Material(pathn:sub(11))
            end
            alpha = alpha + 1
            path, pathn = fmt2:format(alpha), fmt2n:format(alpha)
        end
        variant = variant + 1
        fmt2, fmt2n = fmt:format(variant), fmtn:format(variant)
    end
end

function ss.PrecachePaintTextures()
    table.Empty(ss.InkShotTypes)
    table.Empty(ss.InkShotMaskSwim)
    table.Empty(ss.InkShotMaskTurf)
    if CLIENT then
        table.Empty(ss.InkShotMaterials)
        table.Empty(ss.InkShotNormals)
    end

    local _, folders = file.Find("materials/splatoonsweps/paints/*", "GAME", "nameasc")
    for _, category in ipairs(folders or {}) do
        LoadPaintTextureCategory(category)
    end

    ---@type integer
    ss.INK_TYPE_BITS = select(2, math.frexp(#ss.InkShotMaskSwim))
end

---@param offset number? Additional random seed
---@return integer
function ss.GetDropType(offset)
    local t = ss.InkShotTypes["drop"]
    local i = util.SharedRandom("SplatoonSWEPs: Ink type", 1, #t, CurTime() + (offset or 0))
    return t[math.min(math.floor(i), #t)]
end

---@param offset number? Additional random seed
---@return integer
function ss.GetShooterInkType(offset)
    local t = ss.InkShotTypes["shot"]
    local i = util.SharedRandom("SplatoonSWEPs: Ink type", 1, #t, CurTime() * 2 + (offset or 0))
    return t[math.min(math.floor(i), #t)]
end

---@param offset number? Additional random seed
---@return integer
function ss.GetRollerRollInkType(offset)
    local t = ss.InkShotTypes["roller"]
    local i = util.SharedRandom("SplatoonSWEPs: Ink type", 1, #t, CurTime() * 3 + (offset or 0))
    return t[math.min(math.floor(i), #t)]
end

---@return integer
function ss.GetExplosionInkType()
    return ss.InkShotTypes["explosion"][1]
end
