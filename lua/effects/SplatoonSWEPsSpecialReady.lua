
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.SpecialReady
---@class EFFECT.SpecialReady : EFFECT

local DELTA_Z = {
    [ss.PLAYER.PEARL] = 28,
    [ss.PLAYER.MARINA] = 16,
    [ss.PLAYER.CALLIE] = 24,
    [ss.PLAYER.MARIE] = 24,
    [ss.PLAYER.BOY] = 24,
    [ss.PLAYER.GIRL] = 24,
}
function EFFECT:Init(e)
    self:SetModel(mdl)
    local w = e:GetEntity()
    local ply = w:GetOwner()
    local dz = ply:EyePos() - ply:GetPos()
    local pm = w:GetNWInt "playermodel"
    if DELTA_Z[pm] then dz.z = dz.z - DELTA_Z[pm] end
    local color = ss.GetColor(e:GetColor())
    local p = CreateParticleSystem(ply, ss.Particles.SpecialReady, PATTACH_ABSORIGIN_FOLLOW, nil, dz)
    p:SetControlPoint(1, color:ToVector())
    ply:EmitSound "SplatoonSWEPs_Player.SpecialReady"
end

function EFFECT:Render()
end
