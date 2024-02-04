
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
        Duration = 360,
        SpreadRadius = 30,
    },
    Units = {
        Duration = "f",
        SpreadRadius = "du",
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
    if SERVER then
        self.BloodColor = Owner:GetBloodColor()
        Owner:SetBloodColor(DONT_BLEED)
    end

    local color = self:GetNWInt "inkcolor"
    local e = EffectData()
    e:SetEntity(self)
    e:SetColor(color)
    ss.UtilEffectPredicted(Owner, "SplatoonSWEPsBubbler", e)
    ss.EmitSoundPredicted(Owner, self, "SplatoonSWEPs.BubblerStart")
    ss.SetInvincibleDuration(Owner, self:GetSpecialDuration())

    local start = self:GetNWInt "SpecialBasePoints"
    local pointsneeded = ss.GetTurfInkedInRaw(ss.bubbler.PointsNeeded)
    self:AddSchedule(0, function() -- Decreasing special gauge
        if not self:GetNWBool "IsUsingSpecial" then return true end
        local frac = (CurTime() - self:GetSpecialStartTime()) / self:GetSpecialDuration()
        self:SetNWInt("SpecialBasePoints", start + pointsneeded * frac)

        if CLIENT then return end
        local delay = 0.5
        for ply in pairs(ss.EntityFilters[color]) do
            if ply == Owner or ss.IsInvincible(ply) then return end
            local w = ss.IsValidInkling(ply)
            if not w then continue end
            if ply:GetPos():DistToSqr(Owner:GetPos()) > p.SpreadRadius * p.SpreadRadius then continue end
            local name = "SplatoonSWEPs: Bubbler Spread " .. ply:EntIndex()
            if timer.Exists(name) then continue end
            self:EmitSound "SplatoonSWEPs.BubblerSpread"
            timer.Create(name, delay, 1, function()
                if not (IsValid(self) and IsValid(Owner) and IsValid(w)) then return end
                local eff = EffectData()
                eff:SetEntity(w)
                eff:SetColor(color)
                util.Effect("SplatoonSWEPsBubbler", e, nil, true)
                w:EmitSound "SplatoonSWEPs.BubblerStart"
                ss.SetInvincibleDuration(ply, ss.InvincibleEntities[Owner] - CurTime())
            end)
        end
    end)

    self:AddSchedule(self:GetSpecialDuration(), 1, function()
        if not self:GetNWBool "IsUsingSpecial" then return end
        self:ResetSpecialState()
        self:OnSpecialEnd()
    end)
end
