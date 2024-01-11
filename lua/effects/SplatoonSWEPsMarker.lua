
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Marker
---@class EFFECT.Marker : EFFECT
---@field Particle CNewParticleEffect

function EFFECT:Init(e)
    self:SetModel(mdl)
    local ent = e:GetEntity()
    local a = Angle(0, EyeAngles().yaw + 90, 0)
    local colorid = e:GetColor()
    local color = ss.GetColor(colorid)
    local radius = e:GetRadius()
    if e:GetFlags() > 0 then
        local offset = e:GetOrigin()
        self.Particle = CreateParticleSystemNoEntity("splatoonsweps_marker_off_1", offset, a)
        self.Particle:SetControlPoint(1, color:ToVector())
        self.Particle:SetControlPoint(2, ss.vector_one * radius / 64)
        self.Particle:SetControlPoint(3, Vector())
        self.Particle:SetControlPointOrientation(3, a:Forward(), a:Right(), a:Up())
    elseif IsValid(ent) then
        local dz = vector_up * (ent:OBBMaxs().z - ent:OBBMins().z) / 2
        self:SetPos(ent:GetPos() + dz)
        self.Particle = CreateParticleSystem(ent, "splatoonsweps_marker_ring", PATTACH_ABSORIGIN_FOLLOW, nil, dz)
        self.Particle:SetControlPoint(1, color:ToVector())
        self.Particle:SetControlPoint(2, ss.vector_one * radius / 2)
        local endtime = e:GetScale()
        function self:Think()
            if IsValid(ent) then self:SetPos(ent:GetPos() + dz) end
            if not IsValid(ent) or ent:Health() == 0 or CurTime() > endtime then
                self.Particle:StopEmissionAndDestroyImmediately()
                local e2 = EffectData()
                e2:SetOrigin(self:GetPos())
                e2:SetRadius(radius)
                e2:SetColor(colorid)
                e2:SetFlags(1)
                util.Effect("SplatoonSWEPsMarker", e2)
                self:EmitSound "SplatoonSWEPs.PointSensorLeft"
                return false
            end
            return true
        end
    end
end

function EFFECT:Render()
end
