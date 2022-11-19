
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_burstbomb"

local ss = SplatoonSWEPs
if not ss then return end
ENT.Model = Model "models/splatoonsweps/subs/pointsensor/pointsensor.mdl"
ENT.SubWeaponName = "pointsensor"

if CLIENT then return end
function ENT:PhysicsCollide(data, collider)
    self:StopSound "SplatoonSWEPs.SubWeaponThrown"
    self:EmitSound(ss.pointsensor.BurstSound)
    SafeRemoveEntity(self)

    local hit = false
    local p = ss.pointsensor.Parameters
    local e = EffectData()
    e:SetOrigin(self:GetPos())
    e:SetRadius(p.Burst_Radius)
    e:SetColor(self:GetNWInt "inkcolor")
    util.Effect("SplatoonSWEPsPointSensor", e)

    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), p.Burst_Radius)) do
        local w = ss.IsValidInkling(ent)
        if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and not (w and ss.IsAlly(self, w)) then
            hit = true
            ent:EmitSound "SplatoonSWEPs.PointSensorTaken"
            ent:SetNWBool("SplatoonSWEPs: IsMarked", true)
            ent:SetNWInt("SplatoonSWEPs: PointSensorMarkedBy", self:GetNWInt "inkcolor")
            ent:SetNWFloat("SplatoonSWEPs: PointSensorEndTime", CurTime() + ss.PointSensorDuration)
            local name = "SplatoonSWEPs: Timer for Point Sensor duration " .. ent:EntIndex()
            timer.Create(name, 0, 0, function()
                if not IsValid(ent) then timer.Remove(name) return end
                if not ent:GetNWBool "SplatoonSWEPs: IsMarked" then timer.Remove(name) return end
                if CurTime() < ent:GetNWFloat "SplatoonSWEPs: PointSensorEndTime" then return end
                ent:SetNWBool("SplatoonSWEPs: IsMarked", false)
                ent:EmitSound "SplatoonSWEPs.PointSensorLeft"
                timer.Remove(name)
            end)
        end
    end

    if not hit then return end
    local ply = {}
    for _, ent in ipairs(player.GetAll()) do
        local w = ss.IsValidInkling(ent)
        if w and ss.IsAlly(self, w) then
            table.insert(ply, ent)
        end
    end

    ss.EmitSound(ply, "SplatoonSWEPs.PointSensorHit")
end
