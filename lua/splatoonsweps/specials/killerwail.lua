
AddCSLuaFile()
---@class ss
local ss = SplatoonSWEPs
if not ss then return end
---@type ISpecialWeaponDef
ss.killerwail = {
    PointsNeeded = 160,
    Merge = {
        SuppressPrimaryAttackSpecial   = false,
        SuppressSecondaryAttackSpecial = true,
        SuppressSquidSpecial           = true,
        SwitchWeaponOnSpecial          = true,
        SwitchSpecialWeaponTo          = "weapon_splatoonsweps_killerwail",
    },
    ---@class SpecialParameters.KillerWail
    Parameters = {
        DamagePerFrame = 0.1,
        Duration = 360,
        CooldownAfterFire = 60,
        CooldownBeforeFire = 60,
        Radius = 40,
    },
    Units = {
        DamagePerFrame = "hp",
        Duration = "f",
        CooldownAfterFire = "f",
        CooldownBeforeFire = "f",
        Radius = "du",
    },
}

ss.ConvertUnits(ss.killerwail.Parameters, ss.killerwail.Units)

---@type SplatoonWeaponBase
local module = ss.killerwail.Merge
local p = ss.killerwail.Parameters
function module:GetSpecialDuration() return p.Duration end
function module:OnSpecialEnd(switchTo) ---@cast switchTo SplatoonWeaponBase
    if IsValid(switchTo) and switchTo.IsSplatoonWeapon and switchTo.IsSpecial then return end
    self:SetCooldown(math.max(self:GetCooldown(), CurTime() + p.CooldownAfterFire))
    self:SetNextPrimaryFire(CurTime() + p.CooldownAfterFire)
    self:SetNextSecondaryFire(CurTime() + p.CooldownAfterFire)
    self:ResetSpecialState()
end
function module:OnSpecialStart()
    self:AddSchedule(self:GetSpecialDuration(), 1, function()
        if not self:GetSpecialActivated() then return end
        self:OnSpecialEnd()
    end)
end

