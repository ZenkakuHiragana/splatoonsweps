
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return {} end
ss.suctionbomb = {
    Merge = {
        IsSubWeaponThrowable = true,
    },

    -- Parameters are from Splatoon 2 ver. 5.2.0, https://leanny.github.io/splat2new/parameters.html
    Parameters = {
        BringCloseRateCrossVec = 0.7,
        BringCloseRateMoveVec = 0.7,
        Burst_Damage_Far = 0.3,
        Burst_Damage_Middle = 0.3,
        Burst_Damage_Near = 1.8,
        Burst_KnockBackCoreImpact = 3,
        Burst_KnockBackKb = 0.8,
        Burst_KnockBackRadius = 120,
        Burst_PaintR = 50,
        Burst_Radius_Far = 80,
        Burst_Radius_Middle = 80,
        Burst_Radius_Near = 50,
        Burst_SeFrm = 10,
        Burst_SplashAroundFuzzyRate = 2,
        Burst_SplashNum = 15,
        Burst_SplashOfstY = 5,
        Burst_SplashPaintR = 10,
        Burst_SplashPitH = 45,
        Burst_SplashPitL = 5,
        Burst_SplashVelH = 6.4,
        Burst_SplashVelL = 4.8,
        Burst_WaitFrm = 90,
        Burst_WarnFrm = 30,
        CollisionSeVelDotGndNrm = 0.08,
        Conveyer_Radius = 5,
        CrossPaintRadius = 25,
        CrossPaintRayLength = 25,
        CrossPaintRayRadius = 1,
        EffectShakeRange = 100,
        Fly_AirFrm = 4,
        Fly_Gravity = 0.16,
        Fly_InitPit = 0.4,
        Fly_InitRol = 0.12,
        Fly_RotI = 20,
        Fly_RotKd = 0.98015,
        Fly_VelKd = 0.94134,
        InkConsume = 0.7,
        InkRecoverStop = 60,
        Shape_SphereD = 5,
        Shape_SphereR = 2,
        WallCheckOffsetY = 4.5,

        -- Taken from Splat bomb
        Fly_InitVel_Estimated = 9.5,
    },
    Units = {
        BringCloseRateCrossVec = "ratio",
        BringCloseRateMoveVec = "ratio",
        Burst_Damage_Far = "hp",
        Burst_Damage_Middle = "hp",
        Burst_Damage_Near = "hp",
        Burst_KnockBackCoreImpact = "-",
        Burst_KnockBackKb = "ratio",
        Burst_KnockBackRadius = "du",
        Burst_PaintR = "du",
        Burst_Radius_Far = "du",
        Burst_Radius_Middle = "du",
        Burst_Radius_Near = "du",
        Burst_SeFrm = "f",
        Burst_SplashAroundFuzzyRate = "ratio",
        Burst_SplashNum = "num",
        Burst_SplashOfstY = "du",
        Burst_SplashPaintR = "du",
        Burst_SplashPitH = "deg",
        Burst_SplashPitL = "deg",
        Burst_SplashVelH = "du/f",
        Burst_SplashVelL = "du/f",
        Burst_WaitFrm = "f",
        Burst_WarnFrm = "f",
        CollisionSeVelDotGndNrm = "-",
        Conveyer_Radius = "du",
        CrossPaintRadius = "du",
        CrossPaintRayLength = "du",
        CrossPaintRayRadius = "du",
        EffectShakeRange = "du",
        Fly_AirFrm = "f",
        Fly_Gravity = "du/f^2",
        Fly_InitPit = "rad",
        Fly_InitRol = "rad",
        Fly_RotI = "-",
        Fly_RotKd = "ratio",
        Fly_VelKd = "ratio",
        InkConsume = "ink",
        InkRecoverStop = "f",
        Shape_SphereD = "du",
        Shape_SphereR = "du",
        WallCheckOffsetY = "du",

        Fly_InitVel_Estimated = "du/f",
    },
    BurstSound = "SplatoonSWEPs.BombExplosion",
    GetDamage = function(dist, ent)
        local params = ss.suctionbomb.Parameters
        local rnear = params.Burst_Radius_Near
        local dnear = params.Burst_Damage_Near
        local dfar = params.Burst_Damage_Far
        return dist < rnear and dnear or dfar
    end,
}

ss.ConvertUnits(ss.suctionbomb.Parameters, ss.suctionbomb.Units)

local module = ss.suctionbomb.Merge
local p = ss.suctionbomb.Parameters
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
    local e = ents.Create "ent_splatoonsweps_suctionbomb"
    e:SetOwner(self:GetOwner())
    e:SetNWInt("inkcolor", self:GetNWInt "inkcolor")
    e:SetInkColorProxy(self:GetInkColorProxy())
    e:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
    e:SetAngles((-self:GetAimVector()):Angle())
    e:Spawn()
    e:EmitSound "SplatoonSWEPs.SubWeaponThrown"

    local ph = e:GetPhysicsObject()
    if IsValid(ph) then
        ph:AddVelocity(self:GetSubWeaponInitVelocity() + self:GetVelocity())
    end

    self:ConsumeInk(p.InkConsume)
    self:SetReloadDelay(p.InkRecoverStop)
end
