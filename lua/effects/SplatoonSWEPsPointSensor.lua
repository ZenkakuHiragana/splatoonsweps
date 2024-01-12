
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.PointSensor
---@class EFFECT.PointSensor : EFFECT

function EFFECT:Init(e)
    self:SetModel(mdl)
    local color = ss.GetColor(e:GetColor())
    local p = CreateParticleSystemNoEntity(ss.Particles.PointSensor, e:GetOrigin(), Angle())
    p:SetControlPoint(1, color:ToVector())
    p:SetControlPoint(2, ss.vector_one)
end

function EFFECT:Render()
end
