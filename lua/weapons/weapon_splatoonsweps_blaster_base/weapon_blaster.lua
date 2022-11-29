
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 2)
SWEP.ShootSound = "SplatoonSWEPs.52"
SWEP.Special = "killerwail"
SWEP.Sub = "disruptor"
SWEP.Variations = {{
    Customized = true,
    Skin = 1,
    Special = "bubbler",
    Sub = "pointsensor",
    Suffix = "custom",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 50,
    mTripleShotSpan = 0,
    mInitVel = 9.4,
    mDegRandom = 0,
    mDegJumpRandom = 10,
    mSplashSplitNum = 1,
    mKnockBack = 0,
    mInkConsume = 0.08,
    mInkRecoverStop = 40,
    mMoveSpeed = 0.45,
    mDamageMax = 1.25,
    mDamageMin = 1.25,
    mDamageMinFrame = 10,
    mStraightFrame = 9,
    mGuideCheckCollisionFrame = 13,
    mCreateSplashNum = 9,
    mCreateSplashLength = 11,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13.5,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,

    mExplosionFrame = 13,
    mExplosionSleep = true,
    mDamageNear = 1.25,
    mCollisionRadiusNear = 5,
    mDamageMiddle = 0.65,
    mCollisionRadiusMiddle = 18,
    mDamageFar = 0.5,
    mCollisionRadiusFar = 37.5,
    mShotCollisionHitDamageRate = 0.5,
    mShotCollisionRadiusRate = 0.5,
    mKnockBackRadius = 37.5,
    mMoveLength = 23.5,
    mSphereSplashDropOn = true,
    mSphereSplashDropInitSpeed = 0,
    mSphereSplashDropCollisionRadius = 4,
    mSphereSplashDropDrawRadius = 6,
    mSphereSplashDropPaintRadius = 34,
    mSphereSplashDropPaintShotCollisionHitRadius = 22,
    mBoundPaintMaxRadius = 25,
    mBoundPaintMinRadius = 20,
    mBoundPaintMinDistanceXZ = 90,
    mWallHitPaintRadius = 20,
    mPreDelayFrm_HumanMain = 10,
    mPreDelayFrm_SquidMain = 15,
    mPostDelayFrm_Main = 30,
})
