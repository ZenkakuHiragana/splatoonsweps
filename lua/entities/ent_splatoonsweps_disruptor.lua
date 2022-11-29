
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_burstbomb"

local ss = SplatoonSWEPs
if not ss then return end
ENT.Model = Model "models/splatoonsweps/subs/disruptor/disruptor.mdl"
ENT.SubWeaponName = "disruptor"

if CLIENT then return end
function ENT:PhysicsCollide(data, collider)
    self:StopSound "SplatoonSWEPs.SubWeaponThrown"
    self:EmitSound(ss.disruptor.BurstSound)
    SafeRemoveEntity(self)

    local c = self:GetNWInt "inkcolor"
    local e = EffectData()
    local p = ss.disruptor.Parameters
    e:SetOrigin(self:GetPos())
    e:SetRadius(p.Burst_Radius)
    e:SetColor(c)
    util.Effect("SplatoonSWEPsDisruptor", e)

    for _, t in ipairs(ents.FindInSphere(self:GetPos(), p.Burst_Radius)) do
        local w = ss.IsValidInkling(t)
        if (t:IsPlayer() or t:IsNPC() or t:IsNextBot()) and not (w and ss.IsAlly(self, w)) then
            t:EmitSound "SplatoonSWEPs.DisruptorTaken"
            t:SetNWBool("SplatoonSWEPs: IsDisrupted", true)
            t:SetNWFloat("SplatoonSWEPs: DisruptorEndTime", CurTime() + ss.PointSensorDuration)

            local name = "SplatoonSWEPs: Timer for Disruptor duration " .. t:EntIndex()
            local effectname = "SplatoonSWEPs: Timer for emitting effects of Disruptor " .. t:EntIndex()
            timer.Create(name, 0, 0, function()
                if IsValid(t) and t:GetNWBool "SplatoonSWEPs: IsDisrupted" then
                    if CurTime() < t:GetNWFloat "SplatoonSWEPs: DisruptorEndTime" then return end
                    t:SetNWBool("SplatoonSWEPs: IsDisrupted", false)
                    t:EmitSound "SplatoonSWEPs.DisruptorWornOff"
                end

                timer.Remove(name)
                timer.Remove(effectname)
            end)

            local mins = t:OBBMins()
            local maxs = t:OBBMaxs()
            local r = math.max(-mins.x, -mins.y, maxs.x, maxs.y) * 0.1
            timer.Create(effectname, 0.125, 0, function()
                if not IsValid(t) then return end
                e = EffectData()
                e:SetOrigin(t:GetPos())
                e:SetRadius(r)
                e:SetColor(c)
                util.Effect("SplatoonSWEPsDisruptor", e)

                if not t:IsNPC() then return end
                t:SetMoveVelocity(Vector())
                t:SetVelocity(Vector())
            end)
        end
    end
end
