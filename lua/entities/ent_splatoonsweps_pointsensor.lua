
local ENT = ENT
---@cast ENT ENT.PointSensor
---@class ENT.PointSensor : ENT.BurstBomb
---@field BaseClass ENT.BurstBomb
---@field EffectDispatched boolean

AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_burstbomb"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
ENT.Model = Model "models/splatoonsweps/subs/pointsensor/pointsensor.mdl"
ENT.SubWeaponName = "pointsensor"
ENT.EffectDispatched = false

if CLIENT then return end
function ENT:PhysicsCollide(data, collider)
    self:StopSound "SplatoonSWEPs.SubWeaponThrown"
    self:EmitSound(ss.pointsensor.BurstSound)
    SafeRemoveEntity(self)

    if self.EffectDispatched then return end
    self.EffectDispatched = true
    local p = ss.pointsensor.Parameters
    local e = EffectData()
    e:SetOrigin(self:GetPos())
    e:SetRadius(p.Burst_Radius)
    e:SetColor(self:GetNWInt "inkcolor")
    util.Effect("SplatoonSWEPsPointSensor", e)
    ss.MarkEntity(self:GetNWInt "inkcolor",
        ents.FindInSphere(self:GetPos(), p.Burst_Radius),
        ss.PointSensorDuration)
end
