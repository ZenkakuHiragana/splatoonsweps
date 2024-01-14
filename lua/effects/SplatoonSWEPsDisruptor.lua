
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Disruptor
---@class EFFECT.Disruptor : EFFECT
---@field Target Entity?
---@field Particle CNewParticleEffect?

function EFFECT:Init(e)
    self:SetModel(mdl)
    local pos = e:GetOrigin()
    local ang = Angle(0, EyeAngles().yaw, 0)
    local color = ss.GetColor(e:GetColor())
    if e:GetFlags() > 0 then
        local ent = e:GetEntity()
        local dz = ent:WorldSpaceCenter() - ent:GetPos()
        local radius = (ent:OBBMaxs():Length2D() + ent:OBBMins():Length2D()) / 2
        self.Target = ent
        self.Particle = CreateParticleSystem(self.Target, ss.Particles.DisruptorMarker, PATTACH_ABSORIGIN_FOLLOW, nil, dz)
        self.Particle:SetControlPoint(1, color:ToVector())
        self.Particle:SetControlPoint(2, ss.vector_one * radius)
    else
        local p = CreateParticleSystemNoEntity(ss.Particles.Disruptor, pos, ang)
        p:SetControlPoint(1, color:ToVector())
    end
end

function EFFECT:Think()
    if not (self.Target and self.Particle) then return false end
    if not IsValid(self.Particle) then return false end
    if not IsValid(self.Target) or self.Target:Health() <= 0 or not ss.DisruptedEntities[self.Target] then
        self.Particle:StopEmissionAndDestroyImmediately()
        return false
    end
    return true
end

function EFFECT:Render()
end
