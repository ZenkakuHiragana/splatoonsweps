
local ss = SplatoonSWEPs
if not ss then return end
AddCSLuaFile "shared.lua"
include "shared.lua"

local SWEP = SWEP
---@cast SWEP SWEP.Roller
---@class SWEP.Special : SplatoonWeaponBase

function SWEP:NPCBurstSettings()
    return 1, 1, self.NPCDelay
end
