
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
    if SERVER then
        self.BloodColor = Owner:GetBloodColor()
        Owner:SetBloodColor(DONT_BLEED)
    end

    ss.EmitSoundPredicted(Owner, self, "SplatoonSWEPs.BubblerStart")
    ss.SetInvincibleDuration(Owner, self:GetSpecialDuration())

    local color = self:GetNWInt "inkcolor"
    local start = self:GetNWInt "SpecialBasePoints"
    local pointsneeded = ss.GetTurfInkedInRaw(ss.bubbler.PointsNeeded)
    self:AddSchedule(0, function()
        if not self:GetNWBool "IsUsingSpecial" then return true end
        local frac = (CurTime() - self:GetSpecialStartTime()) / self:GetSpecialDuration()
        self:SetNWInt("SpecialBasePoints", start + pointsneeded * frac) -- Decreasing special gauge

        -- Spreading the Bubbler
        if CLIENT then return end
        local delay = p.SpreadDelay
        local endtime = ss.InvincibleEntities[Owner]
        local remaining = endtime and (endtime - CurTime()) or 0
        if remaining < delay then return end
        for ply in pairs(ss.PlayerFilters[color]) do
            if ply == Owner or ss.IsInvincible(ply) then continue end
            local w = ss.IsValidInkling(ply)
            if not w then continue end
            if ply:GetPos():DistToSqr(Owner:GetPos()) > p.SpreadRadius * p.SpreadRadius then continue end
            local name = "SplatoonSWEPs: Bubbler Spread " .. ply:EntIndex()
            if timer.Exists(name) then continue end
            local soundpos = (ply:WorldSpaceCenter() + Owner:WorldSpaceCenter()) / 2
            sound.Play("SplatoonSWEPs.BubblerSpread", soundpos)
            timer.Create(name, delay, 1, function()
                timer.Remove(name)
                if IsValid(self) and IsValid(Owner) and IsValid(ply) and IsValid(w) and ss.InvincibleEntities[Owner] then
                    w:EmitSound "SplatoonSWEPs.BubblerStart"
                    ss.SetInvincibleDuration(ply, ss.InvincibleEntities[Owner] - CurTime())
                end
            end)
        end

        for _, ent in ipairs(ents.FindInBox(Owner:WorldSpaceAABB())) do
            if ent == Owner then continue end ---@cast ent ENT.SplatBomb
            if not ent.IsSplatoonBomb then continue end
            if ss.IsAlly(ent, self) then continue end
            ss.ProtectedCall(ent.Disappear, ent)
        end
    end)

    self:AddSchedule(self:GetSpecialDuration(), 1, function()
        if not self:GetNWBool "IsUsingSpecial" then return end
        self:ResetSpecialState()
        self:OnSpecialEnd()
        ss.EmitSoundPredicted(Owner, self, "SplatoonSWEPs.BubblerEnd")
    end)
end
