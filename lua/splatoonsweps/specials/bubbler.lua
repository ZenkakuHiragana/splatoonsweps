
AddCSLuaFile()
---@class ss
local ss = SplatoonSWEPs
if not ss then return end
---@type ISpecialWeaponDef
ss.bubbler = {
    PointsNeeded = 10,
    Merge = {
        BloodColor = BLOOD_COLOR_RED,
    },
    ---@class SpecialParameters.Bubbler
    Parameters = {
        Duration = 360,
    },
    Units = {
        Duration = "f",
    },
}

ss.ConvertUnits(ss.bubbler.Parameters, ss.bubbler.Units)

---@type SplatoonWeaponBase
local module = ss.bubbler.Merge
local p = ss.bubbler.Parameters
function module:GetSpecialDuration() return p.Duration end
function module:OnSpecialEnd()
    self:SetNWBool("IsUsingSpecial", false)
    if SERVER and self.BloodColor and IsValid(self:GetOwner()) then
        self:GetOwner():SetBloodColor(self.BloodColor)
    end
end
function module:OnSpecialStart()
    local e = EffectData()
    e:SetEntity(self)
    e:SetColor(self:GetNWInt "inkcolor")
    local Owner = self:GetOwner()
    if SERVER then
        self.BloodColor = Owner:GetBloodColor()
        Owner:SetBloodColor(DONT_BLEED)
    end
    ss.UtilEffectPredicted(Owner, "SplatoonSWEPsBubbler", e)
    ss.EmitSoundPredicted(Owner, self, "SplatoonSWEPs.BubblerStart")
    local start = self:GetNWInt "SpecialBasePoints"
    local pointsneeded = ss.GetTurfInkedInRaw(ss.bubbler.PointsNeeded)
    self:AddSchedule(0, function()
        if not self:GetNWBool "IsUsingSpecial" then return true end
        local frac = (CurTime() - self:GetSpecialStartTime()) / self:GetSpecialDuration()
        self:SetNWInt("SpecialBasePoints", start + pointsneeded * frac)
    end)
    self:AddSchedule(self:GetSpecialDuration(), 1, function()
        if not self:GetNWBool "IsUsingSpecial" then return end
        ss.EmitSoundPredicted(self:GetOwner(), self, "SplatoonSWEPs.BubblerEnd")
        self:ResetSpecialState()
        self:OnSpecialEnd()
    end)
end
