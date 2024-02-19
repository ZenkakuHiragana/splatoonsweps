
local ss = SplatoonSWEPs
if not ss then return end

local SWEP = SWEP
---@cast SWEP SWEP.Special
---@class SWEP.Special : SplatoonWeaponBase
---@field SharedInitSpecial fun(self)

SWEP.Base = "weapon_splatoonsweps_inklingbase"
SWEP.IsSpecial = true
SWEP.Range = 65536
SWEP.NPCDelay = 1
SWEP.Primary = {
    Ammo = "AR2AltFire",
    Automatic = false,
    ClipSize = 1,
    DefaultClip = 5,
}

function SWEP:SharedInit()
    ss.ProtectedCall(self.SharedInitSpecial, self)
    self:SetNWEntity("Activator", NULL)
    self:AddSchedule(0, function()
        local activator = self:GetNWEntity "Activator" ---@cast activator SplatoonWeaponBase
        if not IsValid(activator) then return end
        if not activator.Sub or self.Sub == activator.Sub then return end
        self.Sub = activator.Sub
        table.Merge(self, ss[activator.Sub].Merge)
    end)
end

function SWEP:SharedDeploy()
    self:SetSpecialActivated(true)
end

function SWEP:SharedHolster()
    return Either(IsValid(self:GetNWEntity "Activator"), false, nil)
end

function SWEP:Reload()
    local activator = self:GetNWEntity "Activator"
    if IsValid(activator) then return end
    self:DefaultReload(ACT_RELOAD)
end
