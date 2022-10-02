
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_throwable"

local ss = SplatoonSWEPs
if not ss then return end
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.IsSplatoonBomb = true
ENT.Model = Model "models/splatoonsweps/subs/burstbomb/burstbomb.mdl"
ENT.SubWeaponName = "burstbomb"

function ENT:Initialize()
    local p = ss[self.SubWeaponName].Parameters
    self.Parameters = p
    self.StraightFrame = p.Fly_AirFrm
    self.AirResist = p.Fly_VelKd - 1
    self.AngleAirResist = p.Fly_RotKd - 1
    self.Gravity = p.Fly_Gravity
    local base = self.BaseClass
    while base.ClassName ~= "ent_splatoonsweps_throwable" do base = base.BaseClass end
    base.Initialize(self)
    if CLIENT then return end
    local ph = self:GetPhysicsObject()
    if not IsValid(ph) then return end
    ph:SetMass(0.001)
end

if CLIENT then return end
function ENT:PhysicsCollide(data, collider)
    local params = ss.burstbomb.Parameters
    local rmid = params.Burst_Radius_Middle
    local dmid = params.Burst_Damage_Middle
    local dfar = params.Burst_Damage_Far
    local ddirecthit = dfar + dmid
    ss.burstbomb.GetDamage = function(dist, ent)
        if ent == data.HitEntity then return ddirecthit end
        if dist < rmid then return dmid end
        return dfar
    end

    ss.MakeBombExplosion(self:GetPos(), -data.HitNormal, self, self:GetNWInt "inkcolor", "burstbomb")
    self:StopSound "SplatoonSWEPs.SubWeaponThrown"
    SafeRemoveEntity(self)
end
