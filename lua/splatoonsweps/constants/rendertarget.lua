AddCSLuaFile()
local TEXTUREFLAGS = include "textureflags.lua"
local MINIMUM   = 0 -- 2048x2048,       32MB
local SMALL     = 1 -- 4096x4096,       128MB
local DSMALL    = 2 -- 2x4096x4096,     256MB
local MEDIUM    = 3 -- 8192x8192,       512MB
local DMEDIUM   = 4 -- 2x8192x8192,     1GB
local LARGE     = 5 -- 16384x16384,     2GB
return {
    RESOLUTION = {
        MINIMUM = MINIMUM,
        SMALL   = SMALL,
        DSMALL  = DSMALL,
        MEDIUM  = MEDIUM,
        DMEDIUM = DMEDIUM,
        LARGE   = LARGE,
    },
    Size = {
        [MINIMUM] = 2048,
        [SMALL  ] = 4096,
        [DSMALL ] = 5792,
        [MEDIUM ] = 8192,
        [DMEDIUM] = 11586,
        [LARGE  ] = 16384,
    },
    SizeFromPixels = {
        [2048 ] = MINIMUM,
        [4096 ] = SMALL,
        [5792 ] = DSMALL,
        [8192 ] = MEDIUM,
        [11586] = DMEDIUM,
        [16384] = LARGE,
    },
    Name = {
        BaseTexture   = "splatoonsweps_basetexture",
        Bumpmap       = "splatoonsweps_bumpmap",
        Lightmap      = "splatoonsweps_lightmap",
        RenderTarget  = "splatoonsweps_rendertarget",
        RTScope       = "splatoonsweps_rtscope",
        WaterMaterial = "splatoonsweps_watermaterial",
    },
    Flags = {
        BaseTexture = bit.bor(
            TEXTUREFLAGS.NOMIP,
            TEXTUREFLAGS.NOLOD,
            TEXTUREFLAGS.ALL_MIPS,
            TEXTUREFLAGS.PROCEDURAL,
            TEXTUREFLAGS.RENDERTARGET,
            TEXTUREFLAGS.NODEPTHBUFFER
        ),
        Bumpmap = bit.bor(
            TEXTUREFLAGS.NORMAL,
            TEXTUREFLAGS.NOMIP,
            TEXTUREFLAGS.NOLOD,
            TEXTUREFLAGS.ALL_MIPS,
            TEXTUREFLAGS.PROCEDURAL,
            TEXTUREFLAGS.RENDERTARGET,
            TEXTUREFLAGS.NODEPTHBUFFER
        ),
        Lightmap = bit.bor(
            TEXTUREFLAGS.NOMIP,
            TEXTUREFLAGS.NOLOD,
            TEXTUREFLAGS.ALL_MIPS,
            TEXTUREFLAGS.PROCEDURAL,
            TEXTUREFLAGS.RENDERTARGET,
            TEXTUREFLAGS.NODEPTHBUFFER
        ),
    },
}
