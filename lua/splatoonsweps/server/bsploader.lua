
local ss = SplatoonSWEPs
if not ss then return end

ss.BSP = {}
local LUMP = { -- Lump names. most of these are unused in SplatoonSWEPs.
    [1]  = "ENTITIES",
    [2]  = "PLANES",
    [3]  = "TEXDATA",
    [4]  = "VERTEXES",
    [5]  = "VISIBLITY",
    [6]  = "NODES",
    [7]  = "TEXINFO",
    [8]  = "FACES",
    [9]  = "LIGHTING",
    [10] = "OCCLUSION",
    [11] = "LEAFS",
    [12] = "FACEIDS",
    [13] = "EDGES",
    [14] = "SURFEDGES",
    [15] = "MODELS",
    [16] = "WORLDLIGHTS",
    [17] = "LEAFFACES",
    [18] = "LEAFBRUSHES",
    [19] = "BRUSHES",
    [20] = "BRUSHSIDES",
    [21] = "AREAS",
    [22] = "AREAPORTALS",
    [23] = "PORTALS",        -- unused in version 20
    [24] = "CLUSTERS",       --
    [25] = "PORTALVERTS",    --
    [26] = "CLUSTERPORTALS", -- unused in version 20
    [27] = "DISPINFO",
    [28] = "ORIGINALFACES",
    [29] = "PHYSDISP",
    [30] = "PHYSCOLLIDE",
    [31] = "VERTNORMALS",
    [32] = "VERTNORMALINDICES",
    [33] = "DISP_LIGHTMAP_ALPHAS",
    [34] = "DISP_VERTS",
    [35] = "DISP_LIGHMAP_SAMPLE_POSITIONS",
    [36] = "GAME_LUMP",
    [37] = "LEAFWATERDATA",
    [38] = "PRIMITIVES",
    [39] = "PRIMVERTS",
    [40] = "PRIMINDICES",
    [41] = "PAKFILE",
    [42] = "CLIPPORTALVERTS",
    [43] = "CUBEMAPS",
    [44] = "TEXDATA_STRING_DATA",
    [45] = "TEXDATA_STRING_TABLE",
    [46] = "OVERLAYS",
    [47] = "LEAFMINDISTTOWATER",
    [48] = "FACE_MACRO_TEXTURE_INFO",
    [49] = "DISP_TRIS",
    [50] = "PHYSCOLLIDESURFACE",
    [51] = "WATEROVERLAYS",
    [52] = "LIGHTMAPEDGES",
    [53] = "LIGHTMAPPAGEINFOS",
    [54] = "LIGHTING_HDR",              -- only used in version 20+ BSP files
    [55] = "WORLDLIGHTS_HDR",           --
    [56] = "LEAF_AMBIENT_LIGHTING_HDR", --
    [57] = "LEAF_AMBIENT_LIGHTING",     -- only used in version 20+ BSP files
    [58] = "XZIPPAKFILE",
    [59] = "FACES_HDR",
    [60] = "MAP_FLAGS",
    [61] = "OVERLAY_FADES",
    [62] = "OVERLAY_SYSTEM_LEVELS",
    [63] = "PHYSLEVEL",
    [64] = "DISP_MULTIBLEND",
}
local BuiltinTypeSizes = {
    Angle = 12,
    Bool = 1,
    Byte = 1,
    Float = 4,
    Long = 4,
    SByte = 1,
    Short = 2,
    ShortVector = 6,
    ULong = 4,
    UShort = 2,
    Vector = 12,
}
local StructureDefinitions = {
    BSPHeader = {
        "Long       identifier",
        "Long       version",
        "LumpHeader lumps 64",
        "Long       mapRevision",
    },
    LumpHeader = {
        "Long fileOffset",
        "Long fileLength",
        "Long version",
        "Long fourCC",
    },
    CDispSubNeighbor = {
        "UShort neighbor",            -- Index into DISPINFO, 0xFFFF for no neighbor
        "Byte   neighborOrientation", -- (CCW) rotation of the neighbor with reference to this displacement
        "Byte   span",                -- Where the neighbor fits onto this side of our displacement
        "Byte   neighborSpan",        -- Where we fit onto our neighbor
        "Byte   padding",
    },
    CDispNeighbor = {
        "CDispSubNeighbor subneighbors 2",
    },
    CDispCornerNeighbors = {
        "UShort neighbors 4", -- Indices of neighbors
        "Byte   numNeighbors",
        "Byte   padding",
    },
    dgamelump_t = {
        "Long   id",
        "UShort flags",
        "UShort version",
        "Long   fileOffset",
        "Long   fileLength",
    },
    StaticPropCommon = {
        size = 31,
        "Vector origin",
        "Angle  angle",
        "UShort propType",
        "UShort firstLeaf",
        "UShort leafCount",
        "Byte   solid",
        -- Different entries are following, depending on game lump version.
        -- But they are all unused in Splatoon SWEPs so just skip them.
    },
    ENTITIES = "String",
    PLANES = {
        size = 12 + 4 + 4,
        "Vector normal",
        "Float  dist",
        "Long   axisType"
    },
    VERTEXES  = "Vector",
    EDGES     = { size = 2 + 2, "UShort", "UShort" },
    SURFEDGES = "Long",
    FACES = {
        size = 56,
        "UShort planeNum",
        "Byte   side",
        "Bool   onNode",
        "Long   firstEdge",
        "Short  numEdges",
        "Short  texInfo",
        "Short  dispInfo",
        "Short  surfaceFogVolumeID",
        "Byte   styles 4",
        "Long   lightOffset",
        "Float  area",
        "Long   lightmapTextureMinsInLuxels 2",
        "Long   lightmapTextureSizeInLuxels 2",
        "Long   originalFace",
        "UShort numPrimitives",
        "UShort firstPrimitiveID",
        "ULong  smoothingGroups",
    },
    ORIGINALFACES = "FACES",
    BRUSHES = {
        size = 4 + 4 + 4,
        "Long firstSide",
        "Long numSides",
        "Long contents",
    },
    BRUSHSIDES = {
        size = 2 + 2 + 2 + 2,
        "UShort planeNum",
        "Short  texInfo",
        "Short  dispInfo",
        "Short  bevel",
    },
    NODES = {
        size = 32,
        "Long        planeNum",
        "Long        children 2",
        "ShortVector mins",
        "ShortVector maxs",
        "UShort      firstFace",
        "UShort      numFaces",
        "Short       area",
        "Short       padding",
    },
    LEAFS = {
        size = 32,
        "Long        contents",
        "Short       cluster",
        "Short       areaAndFlags", -- area: lower 9 bits, flags: upper 7 bits
        "ShortVector mins",
        "ShortVector maxs",
        "UShort      firstLeafFace",
        "UShort      numLeafFaces",
        "UShort      firstLeafBrush",
        "UShort      numLeafBrushes",
        "Short       leafWaterDataID",
        -- Also need the following when version <= 19
        -- "CompressedLightCube ambientLighting", -- 24 bytes
        "Short       padding",
    },
    LEAFFACES = "UShort",
    LEAFBRUSHES = "UShort",
    TEXINFO = {
        size = 72,
        "Vector textureVecS",
        "Float  textureOffsetS",
        "Vector textureVecT",
        "Float  textureOffsetT",
        "Vector lightmapVecS",
        "Float  lightmapOffsetS",
        "Vector lightmapVecT",
        "Float  lightmapOffsetT",
        "Long   flags",
        "Long   texData",
    },
    TEXDATA = {
        size = 4 * 3 + 4 + 4 + 4 + 4 + 4,
        "Vector reflectivity",
        "Long   nameStringTableID",
        "Long   width",
        "Long   height",
        "Long   viewWidth",
        "Long   viewHeight",
    },
    TEXDATA_STRING_TABLE = "Long",
    TEXDATA_STRING_DATA = "String",
    MODELS = {
        size = 48,
        "Vector mins",
        "Vector maxs",
        "Vector origin",
        "Long   headNode",
        "Long   firstFace",
        "Long   numFaces",
    },
    DISPINFO = {
        size = 176,
        "Vector               startPosition",
        "Long                 dispVertStart",
        "Long                 dispTriStart",
        "Long                 power",
        "Long                 minTesselation",
        "Float                smoothingAngle",
        "Long                 contents",
        "UShort               mapFace",
        "UShort               padding",
        "Long                 lightmapAlphaTest",
        "Long                 lightmapSamplesPositionStart",
        "CDispNeighbor        edgeNeighbors   4", -- Probably these are
        "CDispCornerNeighbors cornerNeighbors 4", -- not correctly parsed
        "ULong                allowedVerts    10",
    },
    DISP_VERTS = {
        size = 20,
        "Vector vec",
        "Float  dist",
        "Float  alpha",
    },
    DISP_TRIS = "UShort",
    GAME_LUMP = {
        size = -1, -- Negative size means this is a single lump
        "Long        lumpCount",
        "dgamelump_t nil lumpCount",
    }
}
local GameLumpContents = {
    sprp = { -- Static Props
        "Long            dictEntries",
        "String128  name dictEntries",
        "Long            leafEntries",
        "UShort     leaf leafEntries",
        "Long            propEntries",
        "StaticProp prop propEntries", -- Size depends on game lump version
    },
}

-- Read a value or structure from bsp file.
-- The offset should correctly be set before call.
-- arg should be one of the following:
--   - String for one of these:
--     - a call of File:Read%s(), e.g. "Long", "Float"
--     - Additional built-in types: "Vector", "ShortVector", "Angle", or "SByte" (signed byte)
--     - "String" for null-terminated string
--     - "String%d" for a null-terminated string but padded to %d bytes.
--     - Structure name defined at StructureDefinitions
--   - Table representing a structure
--     Table containing a sequence of strings formatted as
--     "<type> <fieldname> <array amount (optional)>"
--     e.g. "Vector normal", "Byte fourCC 4"
--     Array amount can be a field name previously defined in the same structure.
--     e.g. { "Long edgeCount", "UShort edgeIndices edgeCount" }
--   - Number for File:Read(%d)
--   - Function for custom procedure, passing (bsp, currentTable, ...)
local function read(bsp, arg, ...)
    if isfunction(arg) then return arg(bsp, ...) end
    if isnumber(arg) then return bsp:Read(arg) end
    if istable(arg) then
        local structure = {}
        for _, varstring in ipairs(arg) do
            local vartype, varname, arraysize = unpack(string.Explode(" +", varstring, true))
            if varname == nil or varname == "" or varname == "nil" then varname = #structure + 1 end
            if arraysize == nil or arraysize == "" then arraysize = 1 end
            if isstring(arraysize) and structure[arraysize] or tonumber(arraysize) > 1 then
                arraysize = structure[arraysize] or tonumber(arraysize)
                for i = 1, arraysize do
                    if isstring(varname) then
                        structure[varname] = structure[varname] or {}
                        structure[varname][i] = read(bsp, vartype, structure, ...)
                    else
                        structure[varname] = read(bsp, vartype, structure, ...)
                        varname = varname + 1
                    end
                end
            else
                structure[varname] = read(bsp, vartype, structure, ...)
            end
        end
        return structure
    elseif arg == "Angle" then
        local pitch = bsp:ReadFloat()
        local yaw   = bsp:ReadFloat()
        local roll  = bsp:ReadFloat()
        return Angle(pitch, yaw, roll)
    elseif arg == "SByte" then
        local n = bsp:ReadByte()
        return n - (n > 127 and 256 or 0)
    elseif arg == "ShortVector" then
        local x = bsp:ReadShort()
        local y = bsp:ReadShort()
        local z = bsp:ReadShort()
        return Vector(x, y, z)
    elseif arg:StartWith "String" then
        local str = ""
        local chr = read(bsp, 1)
        local minlen = tonumber(arg:sub(#"String" + 1)) or 0
        local MAX_STRING_LENGTH = 1024
        while chr ~= "\x00" and #str < MAX_STRING_LENGTH do
            str = str .. chr
            chr = read(bsp, 1)
        end
        for _ = 1, minlen - (#str + 1) do
            read(bsp, 1)
        end
        return str
    elseif arg == "Vector" then
        local x = bsp:ReadFloat()
        local y = bsp:ReadFloat()
        local z = bsp:ReadFloat()
        return Vector(x, y, z)
    elseif isfunction(bsp["Read" .. arg]) then
        return bsp["Read" .. arg](bsp)
    else
        return read(bsp, assert(StructureDefinitions[arg],
            "SplatoonSWEPs/BSPLoader: Need a correct structure name"), ...)
    end
end

function StructureDefinitions.StaticProp(bsp, struct, header)
    local offset = struct.dictEntries * 128 + struct.leafEntries * 2 + 4 * 3
    local nextlump = header.fileOffset + header.fileLength
    local staticPropOffset = header.fileOffset + offset
    local sizeofStaticPropLump = (nextlump - staticPropOffset) / struct.propEntries
    local t = read(bsp, "StaticPropCommon")
    bsp:Skip(sizeofStaticPropLump - StructureDefinitions.StaticPropCommon.size)
    return t
end

local function getGameLumpStr(id)
    local a = bit.band(0xFF, bit.rshift(id, 24))
    local b = bit.band(0xFF, bit.rshift(id, 16))
    local c = bit.band(0xFF, bit.rshift(id, 8))
    local d = bit.band(0xFF, id)
    return string.char(a, b, c, d)
end

local function readLump(bsp, header, lumpname)
    local t = {}
    local offset = header.fileOffset
    local length = header.fileLength
    local struct = StructureDefinitions[lumpname]

    -- get length per struct
    local strlen = istable(struct) and struct.size or length
    if StructureDefinitions[struct] then
        strlen = StructureDefinitions[struct].size
    elseif BuiltinTypeSizes[struct] then
        strlen = BuiltinTypeSizes[struct]
    end

    bsp:Seek(offset)
    local numElements = length / strlen
    if numElements > 0 then
        for i = 1, numElements do
            t[i] = read(bsp, struct, header)
        end
    else
        t = read(bsp, struct, header)
    end

    return t
end

function ss.LoadBSP()
    local bsp = file.Open(string.format("maps/%s.bsp", game.GetMap()), "rb", "GAME")
    if not bsp then return end

    local t = { header = read(bsp, "BSPHeader") }
    for i = 1, #LUMP do
        local lumpname = LUMP[i]
        if StructureDefinitions[lumpname] then
            t[lumpname] = readLump(bsp, t.header.lumps[i], lumpname)
        end
    end

    for _, header in ipairs(t.GAME_LUMP) do
        local idstr = getGameLumpStr(header.id)
        local gamelump = GameLumpContents[idstr]
        if gamelump then
            bsp:Seek(header.fileOffset)
            t[idstr] = read(bsp, gamelump, header)
        end
    end

    return t
end
