
AddCSLuaFile()
---@class ss
local ss = SplatoonSWEPs
if not ss then return end
---@type ISpecialWeaponDef
ss.echolocator = {
    PointsNeeded = 200,
    Merge = {},
    ---@class SpecialParameters.Echolocator
    Parameters = {},
    Units = {},
}

ss.ConvertUnits(ss.echolocator.Parameters, ss.echolocator.Units)

---@type SplatoonWeaponBase
local module = ss.echolocator.Merge
function module:GetSpecialDuration() return 0 end
function module:OnSpecialStart()
    self:ResetSpecialState()
    ss.EmitSoundPredicted(self:GetOwner(), self, "SplatoonSWEPs.Echolocator")
    local color = self:GetNWInt "inkcolor"
    local e = EffectData()
    e:SetOrigin(self:GetOwner():EyePos())
    e:SetColor(color)
    ss.UtilEffectPredicted(self:GetOwner(), "SplatoonSWEPsEcholocator", e)
    if CLIENT then return end
    self:AddSchedule(0.75, 1, function()
        ss.MarkEntity(color, ents.GetAll(), ss.EcholocatorDuration)
        for _, ply in ipairs(player.GetAll()) do
            if not ply:Alive() then continue end
            local w = ss.IsValidInkling(ply) ---@type Weapon?
            if w and ss.IsAlly(color, w) then continue end
            ss.EmitSound(ply, "SplatoonSWEPs.PointSensorTaken")
        end
    end)
end
