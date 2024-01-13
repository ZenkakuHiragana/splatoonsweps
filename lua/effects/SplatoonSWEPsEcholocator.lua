
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Echolocator
---@class EFFECT.Echolocator : EFFECT

function EFFECT:Init(e)
    self:SetModel(mdl)
    local pos = e:GetOrigin()
    local id = e:GetColor()
    local color = ss.GetColor(id)
    local p = CreateParticleSystemNoEntity(ss.Particles.Echolocator, pos)
    p:SetControlPoint(1, color:ToVector())
    p:SetControlPoint(2, ss.vector_one)

    for _, ent in ipairs(ents.GetAll()) do
        if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then continue end
        local w = ss.IsValidInkling(ent)
        if w and ss.IsAlly(id, w) then continue end
        local ang = Angle(-math.Rand(15, 180 - 15), math.Rand(-180, 180), 0)
        p = CreateParticleSystemNoEntity(ss.Particles.EcholocatorSquid, pos + AngleRand():Forward() * 24)
        p:SetControlPoint(1, color:ToVector())
        p:SetControlPoint(2, ent:WorldSpaceCenter())
        p:SetControlPointForwardVector(0, ang:Forward())
    end
end

function EFFECT:Render()
end
