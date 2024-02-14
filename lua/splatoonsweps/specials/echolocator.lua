
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
function module:OnSpecialEnd() end
function module:OnSpecialStart()
    self:ResetSpecialState()
    local Owner = self:GetOwner()
    local color = self:GetNWInt "inkcolor"
    local e = EffectData()
    e:SetOrigin(Owner:EyePos())
    e:SetColor(color)
    ss.UtilEffectPredicted(Owner, "SplatoonSWEPsEcholocator", e)
    ss.EmitSoundPredicted(Owner, self, "SplatoonSWEPs.Echolocator")
    if CLIENT then return end
    self:AddSchedule(0.75, 1, function()
        local victims = ents.GetAll()
        table.RemoveByValue(victims, Owner)
        ss.MarkEntity(color, victims, ss.EcholocatorDuration)
        for _, ply in ipairs(player.GetAll()) do
            if not ply:Alive() then continue end
            local w = ss.IsValidInkling(ply) ---@type Weapon?
            if w and ss.IsAlly(color, w) then continue end
            if ply == Owner and ss.GetOption "ff" then continue end
            ss.EmitSound(ply, "SplatoonSWEPs.PointSensorTaken")
        end
    end)
end
