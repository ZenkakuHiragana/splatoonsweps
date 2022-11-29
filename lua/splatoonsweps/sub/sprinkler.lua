
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return {} end
ss.sprinkler = {
    Merge = {
        IsSubWeaponThrowable = true,
    },
    Parameters = {
        BringCloseRateCrossVec = 0.7,
        BringCloseRateMoveVec = 0.7,
        Col_OffsetY = 5,
        Col_Radius = 10,
        ConveyerRadius = 5,
        DamageRateBias = 0.5,
        DamageRateInitial = 1,
        DamageRateNormalFrame = 450,
        DestroyWaitFrame = 0,
        Fly_Gravity = 0.16,
        Fly_InitPit = 0.4,
        Fly_InitRol = 0.12,
        Fly_RotI = 20,
        Fly_RotKd = 0.98015,
        Fly_VelKd = 0.94134,
        GndColOnMovingObj_OffsetY = 3,
        GndColOnMovingObj_Radius = 3,
        InkConsume = 0.7, -- 0.6 in Splatoon 2
        InkRecoverStop = 60,
        MaxHp = 1.2,
        ObjectDamageRateHigh = 10,
        ObjectDamageRateMid = 10,
        PaintRadius = 25,
        Period_First = 300,
        Period_FirstHigh = 600,
        Period_FirstMid = 450,
        Period_FirstToSecond = 30,
        Period_Second = 900,
        Period_SecondHigh = 1020,
        Period_SecondMid = 960,
        Period_SecondToThird = 60,
        Shape_SphereD = 5,
        Shape_SphereR = 2,
        SleepPlayerDeath = true,
        Spout_RandomDeg = 2,
        Spout_RotateMaxSpeedDegree_First = 33,
        Spout_RotateMaxSpeedDegree_Second = 11,
        Spout_RotateMaxSpeedDegree_Third = 1,
        Spout_RotateMaxSpeedFrame = 10,
        Spout_Span_First = 4,
        Spout_Span_Second = 6,
        Spout_Span_Third = 10,
        Spout_SplashCollisionR_First = 2,
        Spout_SplashCollisionR_Second = 2,
        Spout_SplashCollisionR_Third = 2,
        Spout_SplashDamage = 0.3, -- 0.2 in Splatoon 2
        Spout_SplashDegBias = 0.333,
        Spout_SplashDrawR_First = 4,
        Spout_SplashDrawR_Second = 4,
        Spout_SplashDrawR_Third = 4,
        Spout_SplashPaintR_First = 12.5,
        Spout_SplashPaintR_MaxHeight = 80,
        Spout_SplashPaintR_MinHeight = 200,
        Spout_SplashPaintR_MinRate = 0.7,
        Spout_SplashPaintR_Second = 11.2,
        Spout_SplashPaintR_Third = 10,
        Spout_SplashPitH = 55,
        Spout_SplashPitL = 35,
        Spout_SplashVelH_First = 7,
        Spout_SplashVelH_Second = 6.4,
        Spout_SplashVelH_Third = 5.6,
        Spout_SplashVelL_First = 2.5,
        Spout_SplashVelL_Second = 2.2,
        Spout_SplashVelL_Third = 1.8,
        Spout_WaitFrame = 30,

        -- Added by me
        Spout_AirResist = 0.1,   -- Air resistance of splashes
        Spout_Gravity = 1,       -- Gravity acceleration of splashes
        Spout_FarRatio = 1.5,    -- Painting aspect ratio for splashes at the end
        Spout_FarRatioD = 50,    -- Ink travel distance to end changing the painting aspect ratio
        Spout_NearRatio = 1,     -- Painting aspect ratio for splashes at the beginning
        Spout_NearRatioD = 25,   -- Ink travel distance to start changing the painting aspect ratio
        Spout_StraightFrame = 4, -- Ink travels without affecting gravity for this frames
        InitInkRadius = 8,       -- Painting radius at the landing point

        -- Taken from Splat bomb
        Fly_InitVel_Estimated = 9.5,
        Fly_AirFrm = 4,
    },
    Units = {
        BringCloseRateCrossVec = "ratio",
        BringCloseRateMoveVec = "ratio",
        Col_OffsetY = "du",
        Col_Radius = "du",
        ConveyerRadius = "du",
        DamageRateBias = "ratio",
        DamageRateInitial = "ratio",
        DamageRateNormalFrame = "f",
        DestroyWaitFrame = "f",
        Fly_Gravity = "du/f^2",
        Fly_InitPit = "rad",
        Fly_InitRol = "rad",
        Fly_RotI = "-",
        Fly_RotKd = "ratio",
        Fly_VelKd = "ratio",
        GndColOnMovingObj_OffsetY = "du",
        GndColOnMovingObj_Radius = "du",
        InkConsume = "ink",
        InkRecoverStop = "f",
        MaxHp = "hp",
        ObjectDamageRateHigh = "ratio",
        ObjectDamageRateMid = "ratio",
        PaintRadius = "du",
        Period_First = "-",
        Period_FirstHigh = "-",
        Period_FirstMid = "-",
        Period_FirstToSecond = "-",
        Period_Second = "-",
        Period_SecondHigh = "-",
        Period_SecondMid = "-",
        Period_SecondToThird = "-",
        Shape_SphereD = "du",
        Shape_SphereR = "du",
        SleepPlayerDeath = "-",
        Spout_RandomDeg = "deg",
        Spout_RotateMaxSpeedDegree_First = "deg",
        Spout_RotateMaxSpeedDegree_Second = "deg",
        Spout_RotateMaxSpeedDegree_Third = "deg",
        Spout_RotateMaxSpeedFrame = "f",
        Spout_Span_First = "f",
        Spout_Span_Second = "f",
        Spout_Span_Third = "f",
        Spout_SplashCollisionR_First = "du",
        Spout_SplashCollisionR_Second = "du",
        Spout_SplashCollisionR_Third = "du",
        Spout_SplashDamage = "hp",
        Spout_SplashDegBias = "-",
        Spout_SplashDrawR_First = "du",
        Spout_SplashDrawR_Second = "du",
        Spout_SplashDrawR_Third = "du",
        Spout_SplashPaintR_First = "du",
        Spout_SplashPaintR_MaxHeight = "du",
        Spout_SplashPaintR_MinHeight = "du",
        Spout_SplashPaintR_MinRate = "ratio",
        Spout_SplashPaintR_Second = "du",
        Spout_SplashPaintR_Third = "du",
        Spout_SplashPitH = "deg",
        Spout_SplashPitL = "deg",
        Spout_SplashVelH_First = "du/f",
        Spout_SplashVelH_Second = "du/f",
        Spout_SplashVelH_Third = "du/f",
        Spout_SplashVelL_First = "du/f",
        Spout_SplashVelL_Second = "du/f",
        Spout_SplashVelL_Third = "du/f",
        Spout_WaitFrame = "f",

        Spout_AirResist = "-",
        Spout_Gravity = "du/f^2",
        Spout_FarRatio = "-",
        Spout_FarRatioD = "du",
        Spout_NearRatio = "-",
        Spout_NearRatioD = "du",
        Spout_StraightFrame = "f",
        InitInkRadius = "du",

        Fly_InitVel_Estimated = "du/f",
        Fly_AirFrm = "f",
    },
    BurstSound = "SplatoonSWEPs.SubWeaponPut",
}

ss.ConvertUnits(ss.sprinkler.Parameters, ss.sprinkler.Units)

local module = ss.sprinkler.Merge
local p = ss.sprinkler.Parameters
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
    local e = ents.Create "ent_splatoonsweps_sprinkler"
    e.Weapon = self
    e.DestroyOnLand = self.ExistingSprinkler
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
        ph:AddAngleVelocity(Vector(1000, 1000) + VectorRand() * 600)
        ph:SetAngles(dir:Angle())
    end

    self.ExistingSprinkler = e
    self:ConsumeInk(p.InkConsume)
    self:SetReloadDelay(p.InkRecoverStop)
end
