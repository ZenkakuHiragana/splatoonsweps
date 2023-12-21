
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
