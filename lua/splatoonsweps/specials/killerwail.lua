
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
        DamagePerFrame       = 0.1,
        Duration             = 360, -- Duration of holding it
        CooldownAfterFire    = 60,  -- Duration between deployment and letting us move again
        CooldownBeforeFire   = 60,  -- Duration between activation and letting us fire it
        NotificationDuration = 60,  -- Duration between deployment and causing damage
        AttackDuration       = 180, -- Duration of firing main shockwaves
        AttackGrowthTime     = 20,  -- Time to grow radius of the shockwaves
        Radius               = 40,  -- min/max components of TraceHull, apparent radius is 2 * Radius / sqrt(pi)
    },
    Units = {
        DamagePerFrame = "hp",
        Duration = "f",
        CooldownAfterFire = "f",
        CooldownBeforeFire = "f",
        NotificationDuration = "f",
        AttackDuration = "f",
        AttackGrowthTime = "f",
        Radius = "du",
    },
}

ss.ConvertUnits(ss.killerwail.Parameters, ss.killerwail.Units)

---@type SplatoonWeaponBase
local module = ss.killerwail.Merge
local p = ss.killerwail.Parameters
function module:GetSpecialDuration() return p.Duration end
function module:CanSpecialAttack()
    if self:GetInFence() then return false end
    local Owner = self:GetOwner()
    if not (IsValid(Owner) and Owner:IsPlayer()) then return end ---@cast Owner Player
    return ss.CanUnduck(Owner)
end
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
