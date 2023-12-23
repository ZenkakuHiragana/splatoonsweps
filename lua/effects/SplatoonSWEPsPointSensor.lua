
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.PointSensor
---@class EFFECT.PointSensor : EFFECT

function EFFECT:Init(e)
    self:SetModel(mdl)
    local color = ss.GetColor(e:GetColor())
    local p = CreateParticleSystemNoEntity("splatoonsweps_pointsensor", e:GetOrigin(), Angle())
    p:SetControlPoint(1, color:ToVector())
end

function EFFECT:Render()
end
