
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return {} end
ss.pointsensor = {
    Merge = {
        IsSubWeaponThrowable = true,
    },
    Parameters = {
        Burst_Radius = 70,
        EffectShakeRange = 70,
        Fly_Gravity = 0.16,
        Fly_InitYaw = 0.4,
        Fly_RotI = 20,
        Fly_RotKd = 0.98015,
        Fly_VelKd = 0.94134,
        InkConsume = 0.4,
        InkRecoverStop = 50,

        -- Taken from Splat bomb
        Fly_InitVel_Estimated = 9.5,
        Fly_AirFrm = 4,
    },
    Units = {
        Burst_Radius = "du",
        EffectShakeRange = "du",
        Fly_Gravity = "du/f^2",
        Fly_InitYaw = "rad",
        Fly_RotI = "-",
        Fly_RotKd = "ratio",
        Fly_VelKd = "ratio",
        InkConsume = "ink",
        InkRecoverStop = "f",

        Fly_InitVel_Estimated = "du/f",
        Fly_AirFrm = "f",
    },
    BurstSound = "SplatoonSWEPs.PointSensor",
}

ss.ConvertUnits(ss.pointsensor.Parameters, ss.pointsensor.Units)

local module = ss.pointsensor.Merge
local p = ss.pointsensor.Parameters
function module:CanSecondaryAttack()
    return self:GetInk() >= p.InkConsume
end

function module:GetSubWeaponInkConsume()
    return p.InkConsume
end

function module:GetSubWeaponInitVelocity()
    local initspeed = p.Fly_InitVel_Estimated
    return self:GetAimVector() * initspeed - ss.GetGravityDirection() * initspeed * 0.25
end

if CLIENT then return end
function module:ServerSecondaryAttack(throwable)
    local e = ents.Create "ent_splatoonsweps_pointsensor"
    e:SetOwner(self:GetOwner())
    e:SetNWInt("inkcolor", self:GetNWInt "inkcolor")
    e:SetInkColorProxy(self:GetInkColorProxy())
    e:SetPos(self:GetShootPos() + self:GetAimVector() * 20)
    e:Spawn()
    e:EmitSound "SplatoonSWEPs.SubWeaponThrown"

    local ph = e:GetPhysicsObject()
    if IsValid(ph) then
        local dir = self:GetAimVector()
        ph:AddVelocity(self:GetSubWeaponInitVelocity() + self:GetVelocity())
        ph:AddAngleVelocity(Vector(0, 0, math.deg(p.Fly_InitYaw)) * ss.SecToFrame)
        ph:SetAngles(Angle(0, dir:Angle().yaw, 0))
    end

    self:ConsumeInk(p.InkConsume)
    self:SetReloadDelay(p.InkRecoverStop)
end
