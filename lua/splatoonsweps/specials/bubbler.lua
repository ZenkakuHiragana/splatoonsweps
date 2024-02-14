
AddCSLuaFile()
---@class ss
local ss = SplatoonSWEPs
if not ss then return end
---@type ISpecialWeaponDef
ss.bubbler = {
    PointsNeeded = 180,
    Merge = {
        BloodColor = BLOOD_COLOR_RED,
    },
    ---@class SpecialParameters.Bubbler
    Parameters = {
        Duration = 300,
        SpreadRadius = 30,
        SpreadDelay = 30,
    },
    Units = {
        Duration = "f",
        SpreadRadius = "du",
        SpreadDelay = "f",
    },
}

ss.ConvertUnits(ss.bubbler.Parameters, ss.bubbler.Units)

---@type SplatoonWeaponBase
local module = ss.bubbler.Merge
local p = ss.bubbler.Parameters
function module:GetSpecialDuration() return p.Duration end
function module:OnSpecialEnd()
    self:SetNWBool("IsUsingSpecial", false)
    local Owner = self:GetOwner()
    if SERVER and self.BloodColor and IsValid(Owner) then
        ss.SetInvincibleDuration(Owner, -1)
        Owner:SetBloodColor(self.BloodColor)
    end
end
function module:OnSpecialStart()
    local Owner = self:GetOwner()
    local start = self:GetNWInt "SpecialBasePoints"
    local pointsneeded = ss.GetTurfInkedInRaw(ss.bubbler.PointsNeeded)
    if SERVER then
        self.BloodColor = Owner:GetBloodColor()
        local ent = ents.Create "ent_splatoonsweps_bubbler" --[[@as ENT.Bubbler]]
        ent:SetOwner(Owner)
        ent:SetEndTime(CurTime() + self:GetSpecialDuration())
        ent:Spawn()
    end

    self:AddSchedule(0, function()
        if not self:GetNWBool "IsUsingSpecial" then return true end
        local frac = (CurTime() - self:GetSpecialStartTime()) / self:GetSpecialDuration()
        self:SetNWInt("SpecialBasePoints", start + pointsneeded * frac) -- Decreasing special gauge
    end)

    self:AddSchedule(self:GetSpecialDuration(), 1, function()
        if not self:GetNWBool "IsUsingSpecial" then return end
        self:ResetSpecialState()
        self:OnSpecialEnd()
    end)
end
