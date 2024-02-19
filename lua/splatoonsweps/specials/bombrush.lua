
AddCSLuaFile()
---@class ss
local ss = SplatoonSWEPs
if not ss then return end
---@type ISpecialWeaponDef
ss.bombrush = {
    PointsNeeded = 180,
    Merge = {},
    ---@class SpecialParameters.Bombrush
    Parameters = {
        Duration = 360,
    },
    Units = {
        Duration = "f",
    },
}

ss.ConvertUnits(ss.bombrush.Parameters, ss.bombrush.Units)

---@type SplatoonWeaponBase
local module = ss.bombrush.Merge
local p = ss.bombrush.Parameters
function module:GetSpecialDuration() return p.Duration end
function module:OnSpecialEnd() self:ResetSpecialState() end
function module:OnSpecialStart()
    self:AddSchedule(self:GetSpecialDuration(), 1, function()
        if not self:GetSpecialActivated() then return end
        self:OnSpecialEnd()
    end)
end
