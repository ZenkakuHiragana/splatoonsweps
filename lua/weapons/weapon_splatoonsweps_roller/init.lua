
local ss = SplatoonSWEPs
if not ss then return end
AddCSLuaFile "shared.lua"
include "shared.lua"

function SWEP:NPCBurstSettings()
    return 1, 1, self.NPCDelay
end
