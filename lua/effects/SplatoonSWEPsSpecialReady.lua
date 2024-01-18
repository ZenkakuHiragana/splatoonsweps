
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.SpecialReady
---@class EFFECT.SpecialReady : EFFECT
---@field Particle CNewParticleEffect
---@field Entity Entity

local DELTA_Z = {
    [ss.PLAYER.PEARL] = 4,
    [ss.PLAYER.MARINA] = -2,
    [ss.PLAYER.OCTO] = -4,
    [ss.PLAYER.CALLIE] = -4,
    [ss.PLAYER.MARIE] = -4,
    [ss.PLAYER.BOY] = -4,
    [ss.PLAYER.GIRL] = -4,
}
function EFFECT:Init(e)
    self:SetModel(mdl)
    local w = e:GetEntity()
    if not IsValid(w) then return end
    local ply = w:GetOwner()
    if not IsValid(ply) then return end
    local dz = ply:EyePos() - ply:GetPos()
    local pm = w:GetNWInt "playermodel"
    if DELTA_Z[pm] then dz.z = dz.z - DELTA_Z[pm] end
    local color = ss.GetColor(e:GetColor())
    self.Particle = CreateParticleSystem(ply, ss.Particles.SpecialReady, PATTACH_ABSORIGIN_FOLLOW, nil, dz)
    self.Particle:SetControlPoint(1, color:ToVector())
    self.Entity = w
    self.Entity:EmitSound "SplatoonSWEPs_Player.SpecialReady"
end

function EFFECT:Think()
    local ent = self.Entity ---@cast ent SplatoonWeaponBase
    if not (IsValid(ent) and IsValid(self.Particle)) then return false end
    self.Particle:SetShouldDraw(not ent:ShouldDrawSquid())
    return true
end

function EFFECT:Render()
end
