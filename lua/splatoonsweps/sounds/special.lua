
AddCSLuaFile()

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Special weapons
--------------------------------------------------------------------------------

sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs.Echolocator",
    level = 85,
    sound = "splatoonsweps/weapons/special/echolocator.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs.BubblerStart",
    level = 85,
    sound = "splatoonsweps/weapons/special/bubblerstart.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs.BubblerEnd",
    level = 85,
    sound = "splatoonsweps/weapons/special/bubblerend.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_STATIC,
    name = "SplatoonSWEPs.BubblerHit",
    level = 85,
    sound = "splatoonsweps/weapons/special/bubblerhit.wav",
    volume = 1,
    pitch = 100,
}
