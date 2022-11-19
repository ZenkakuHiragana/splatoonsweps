
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return {} end
ss.splashwall = {
    Merge = {
        IsSubWeaponThrowable = false,
    },
    Parameters = {
        mMaxHp = 6.00000000,
        mLength = Vector "45.00000000 39.00000000 10.00000000",
        mPreparationDurationFrame = 30,
        mNoDamageRunningDurationFrame = 370,
        mDamage = 0.5,
        mBoundVelLen = 2,
        mBoundVelY = 0,
        mBoundVelYZeroFrame = 5,
        mPaintRepeatFrame = 6,
        mPaintWidth = 10,
        mPaintMoveSphereCheckOffsetX = 25,
        mPaintMoveSphereCheckOffsetY = 40,
        mDestroyWaitFrame = 30,
        mImmediateDestroyDamage = 1000,
        mImmediateDestroyDamageThreshold = 999,
        mHitEffectLimitSpanFrame = 8,
        mConveyerRadius = 5,
        Fly_AirFrm = 4,
        Fly_Gravity = 0.16,
        Fly_RotKd = 0.98,
        Fly_VelKd = 0.94134,
        mInkConsume = 0.6,
        mInkRecoverStop = 80, -- 160 after ver. 2.2.0

        Fly_InitVel_Estimated = 6,
    },
    Units = {
        mMaxHp = "hp",
        mLength = "du",
        mPreparationDurationFrame = "f",
        mNoDamageRunningDurationFrame = "f",
        mDamage = "hp",
        mBoundVelLen = "du",
        mBoundVelY = "du/f",
        mBoundVelYZeroFrame = "f",
        mPaintRepeatFrame = "f",
        mPaintWidth = "du",
        mPaintMoveSphereCheckOffsetX = "du",
        mPaintMoveSphereCheckOffsetY = "du",
        mDestroyWaitFrame = "f",
        mImmediateDestroyDamage = "hp",
        mImmediateDestroyDamageThreshold = "hp",
        mHitEffectLimitSpanFrame = "f",
        mConveyerRadius = "du",
        Fly_AirFrm = "f",
        Fly_Gravity = "du/f^2",
        Fly_RotKd = "ratio",
        Fly_VelKd = "ratio",
        mInkConsume = "ink",
        mInkRecoverStop = "f",

        Fly_InitVel_Estimated = "du/f",
    },
}

ss.ConvertUnits(ss.splashwall.Parameters, ss.splashwall.Units)

local module = ss.splashwall.Merge
local p = ss.splashwall.Parameters
function module:CanSecondaryAttack()
    return self:GetInk() >= p.mInkConsume
end

function module:GetSubWeaponInkConsume()
    return p.mInkConsume
end

function module:GetSubWeaponInitVelocity()
    local initspeed = p.Fly_InitVel_Estimated
    local dir = self:GetAimVector()
    dir.z = 0
    dir:Normalize()
    return dir * initspeed
end

if CLIENT then return end
function module:ServerSecondaryAttack(throwable)
    if IsValid(self.ExistingSplashWall) then return end
    local e = ents.Create "ent_splatoonsweps_splashwall"
    e.Weapon = self
    e:SetOwner(self:GetOwner())
    e:SetNWInt("inkcolor", self:GetNWInt "inkcolor")
    e:SetInkColorProxy(self:GetInkColorProxy())
    e:SetPos(self:GetShootPos())
    e:SetAngles(Angle(0, self:GetAimVector():Angle().yaw, 0))
    e:Spawn()
    e:EmitSound "SplatoonSWEPs.SubWeaponThrown"
    local ph = e:GetPhysicsObject()
    if IsValid(ph) then
        ph:AddVelocity(self:GetSubWeaponInitVelocity() + self:GetVelocity())
    end

    self.ExistingSplashWall = e
    self:ConsumeInk(p.mInkConsume)
    self:SetReloadDelay(p.mInkRecoverStop)
end
