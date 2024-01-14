
local ENT = ENT
---@cast ENT ENT.Disruptor
---@class ENT.Disruptor : ENT.BurstBomb
---@field BaseClass ENT.BurstBomb

AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_burstbomb"

---@class ss
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
    e:SetFlags(0)
    util.Effect("SplatoonSWEPsDisruptor", e)

    for _, t in ipairs(ents.FindInSphere(self:GetPos(), p.Burst_Radius)) do
        local w = ss.IsValidInkling(t) ---@type Weapon?
        if (t:IsPlayer() or t:IsNPC() or t:IsNextBot()) and not (w and ss.IsAlly(self, w)) then
            t:EmitSound "SplatoonSWEPs.DisruptorTaken"
            ss.ChangeDisruptedEntityState(t, true)

            local mins = t:OBBMins()
            local maxs = t:OBBMaxs()
            local r = math.max(-mins.x, -mins.y, maxs.x, maxs.y) * 0.1
            e = EffectData()
            e:SetOrigin(t:GetPos())
            e:SetRadius(r)
            e:SetColor(c)
            e:SetFlags(1)
            e:SetEntity(t)
            util.Effect("SplatoonSWEPsDisruptor", e)

            local name = "SplatoonSWEPs: Timer for Disruptor duration " .. t:EntIndex()
            local npcname = "SplatoonSWEPs: Disruptor NPC movement " .. t:EntIndex()
            timer.Create(name, 0, 0, function()
                if IsValid(t) and ss.DisruptedEntities[t] then
                    if CurTime() < ss.DisruptedEntities[t] + ss.PointSensorDuration then return end
                    t:EmitSound "SplatoonSWEPs.DisruptorWornOff"
                    ss.ChangeDisruptedEntityState(t, false)
                end

                timer.Remove(name)
                if timer.Exists(npcname) then timer.Remove(npcname) end
            end)
            if t:IsNPC() then ---@cast t NPC
                timer.Create(npcname, 0.125, 0, function()
                    if not IsValid(t) then return end
                    t:SetMoveVelocity(Vector())
                    t:SetVelocity(Vector())
                    t:ClearSchedule()
                end)
            end
        end
    end
end
