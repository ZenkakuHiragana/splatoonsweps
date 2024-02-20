
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.BubblerSpread
---@class EFFECT.BubblerSpread : EFFECT

function EFFECT:Init(e)
    self:SetModel(mdl)
    local target = Entity(e:GetMaterialIndex())
    local color = ss.GetColor(e:GetColor())
    local p = CreateParticleSystem(e:GetEntity(), ss.Particles.BubblerSpread, PATTACH_POINT_FOLLOW)
    p:SetControlPoint(1, color:ToVector())
    p:SetControlPoint(2, e:GetOrigin())
    if IsValid(target) then p:SetControlPointEntity(2, target) end
end

function EFFECT:Render()
end
