
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return {} end
ss.splatbomb = {
    Merge = {
        IsSubWeaponThrowable = true,
    },

    -- Parameters are from Splatoon 2 ver. 5.2.0, https://leanny.github.io/splat2new/parameters.html
    Parameters = {
        BringCloseRateCrossVec = 0.7,
        BringCloseRateMoveVec = 0.7,
        Burst_Damage_Far = 0.3,
        Burst_Damage_Near = 1.8,
        Burst_KnockBackCoreImpact = 3,
        Burst_KnockBackKb = 0.8,
        Burst_KnockBackRadius = 120,
        Burst_PaintR = 40,
        Burst_Radius_Far = 70,
        Burst_Radius_Near = 40,
        Burst_SeFrm = 10,
        Burst_SplashAroundFuzzyRate = 2,
        Burst_SplashNum = 15,
        Burst_SplashOfstY = 5,
        Burst_SplashPaintR = 10,
        Burst_SplashPitH = 45,
        Burst_SplashPitL = 5,
        Burst_SplashVelH = 5.4,
        Burst_SplashVelL = 4.8,
        Burst_WaitFrm = 30,
        Burst_WarnFrm = 30,
        CollisionSeSilentFrame = 4,
        CollisionSeVelDotGndNrm = 0.08,
        CollisionSeVelDotGndTimes = 1.2,
        CrossPaintRadius = 20,
        CrossPaintRayLength = 20,
        CrossPaintRayRadius = 1,
        EffectShakeRange = 100,
        Fly_AirFrm = 4,
        Fly_CeilingKf_Y = 1,
        Fly_CeilingKr_Y = 0.5,
        Fly_Gravity = 0.16,
        Fly_InitPit = 0.4,
        Fly_InitRol = 0.12,
        Fly_RotI = 20,
        Fly_RotKd = 0.98015, -- Assume that angle velocity is multiplied by this once per frame
        Fly_VelKd = 0.94134, -- Assume that velocity is multiplied by this once per frame
        Fly_WallKf_XZ = 0.7,
        Fly_WallKf_Y = 0.2,
        Fly_WallKr = 0.2,
        ForceSleepFrame = 900,
        InkConsume = 0.7,
        InkRecoverStop = 60,
        Land_AbsorveRt = 0.1,
        Land_GndKf = 0.2,
        Land_GndKr = 0.05,
        Land_GravGndK = 0.5,
        Land_GravH = 0.08,
        Land_GravKf = 0.1,
        Land_GravL = 0.016,
        Land_NrmGndKf = 0.1,
        Land_RotI = 10,
        Land_RotKd = 0.96059,
        Land_VelKdXZ = 0.92237,
        Land_VelKdY = 0.92237,
        Shape_SphereD = 5,
        Shape_SphereR = 2,

        -- Parameters from Player_Spec_BombDistance_Up.param
        BombThrow_VelZ_Low = 2.8,
        BombThrow_VelZ_Mid = 3.5,
        BombThrow_VelZ_High = 4.2,

        -- FIXME: This is idle; it's estimated by some experiments
        Fly_InitVel_Estimated = 9.5,
    },
    Units = {
        BringCloseRateCrossVec = "ratio",
        BringCloseRateMoveVec = "ratio",
        Burst_Damage_Far = "hp",
        Burst_Damage_Near = "hp",
        Burst_KnockBackCoreImpact = "-",
        Burst_KnockBackKb = "ratio",
        Burst_KnockBackRadius = "du",
        Burst_PaintR = "du",
        Burst_Radius_Far = "du",
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
        CollisionSeSilentFrame = "f",
        CollisionSeVelDotGndNrm = "-",
        CollisionSeVelDotGndTimes = "-",
        CrossPaintRadius = "du",
        CrossPaintRayLength = "du",
        CrossPaintRayRadius = "du",
        EffectShakeRange = "du",
        Fly_AirFrm = "f",
        Fly_CeilingKf_Y = "-",
        Fly_CeilingKr_Y = "-",
        Fly_Gravity = "du/f^2",
        Fly_InitPit = "rad",
        Fly_InitRol = "rad",
        Fly_RotI = "-",
        Fly_RotKd = "ratio",
        Fly_VelKd = "ratio",
        Fly_WallKf_XZ = "-",
        Fly_WallKf_Y = "-",
        Fly_WallKr = "-",
        ForceSleepFrame = "f",
        InkConsume = "ink",
        InkRecoverStop = "f",
        Land_AbsorveRt = "ratio",
        Land_GndKf = "ratio",
        Land_GndKr = "ratio",
        Land_GravGndK = "ratio",
        Land_GravH = "du/f^2",
        Land_GravKf = "ratio",
        Land_GravL = "du/f^2",
        Land_NrmGndKf = "ratio",
        Land_RotI = "-",
        Land_RotKd = "ratio",
        Land_VelKdXZ = "ratio",
        Land_VelKdY = "ratio",
        Shape_SphereD = "du",
        Shape_SphereR = "du",

        BombThrow_VelZ_Low = "du/f",
        BombThrow_VelZ_Mid = "du/f",
        BombThrow_VelZ_High = "du/f",

        Fly_InitVel_Estimated = "du/f",
    },
    BurstSound = "SplatoonSWEPs.BombExplosion",
    GetDamage = function(dist, ent)
        local params = ss.splatbomb.Parameters
        local rnear = params.Burst_Radius_Near
        local dnear = params.Burst_Damage_Near
        local dfar = params.Burst_Damage_Far
        return dist < rnear and dnear or dfar
    end,
}

ss.ConvertUnits(ss.splatbomb.Parameters, ss.splatbomb.Units)

local module = ss.splatbomb.Merge
local p = ss.splatbomb.Parameters
function module:SharedSecondaryAttack(throwable)

end

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

if SERVER then
    function module:ServerSecondaryAttack(throwable)
        local e = ents.Create "ent_splatoonsweps_splatbomb"
        e:SetOwner(self:GetOwner())
        e:SetNWInt("inkcolor", self:GetNWInt "inkcolor")
        e:SetInkColorProxy(self:GetInkColorProxy())
        e:SetPos(self:GetShootPos())
        e:Spawn()
        e:EmitSound "SplatoonSWEPs.SubWeaponThrown"

        local ph = e:GetPhysicsObject()
        if IsValid(ph) then
            local dir = self:GetAimVector()
            ph:AddVelocity(self:GetSubWeaponInitVelocity() + self:GetVelocity())
            ph:AddAngleVelocity(Vector(-math.deg(p.Fly_InitRol), math.deg(p.Fly_InitPit), 0) * ss.SecToFrame)
            ph:SetAngles(dir:Angle())
        end

        self:ConsumeInk(p.InkConsume)
        self:SetReloadDelay(p.InkRecoverStop)
    end
else
    function module:DrawOnSubTriggerDown()

    end

    function module:ClientSecondaryAttack(throwable)

    end
end
