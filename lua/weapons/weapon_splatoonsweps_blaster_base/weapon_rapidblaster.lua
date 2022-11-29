
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(5, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 4)
SWEP.ShootSound = "SplatoonSWEPs.Sploosh-o-matic"
SWEP.Special = "bubbler"
SWEP.Sub = "inkmine"
SWEP.Variations = {{
    Customized = true,
    Skin = 1,
    Special = "bombrush",
    Sub = "suctionbomb",
    Suffix = "deco",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 35,
    mTripleShotSpan = 0,
    mInitVel = 12,
    mDegRandom = 0,
    mDegJumpRandom = 10,
    mSplashSplitNum = 1,
    mKnockBack = 0,
    mInkConsume = 0.08,
    mInkRecoverStop = 25,
    mMoveSpeed = 0.55,
    mDamageMax = 0.8,
    mDamageMin = 0.8,
    mDamageMinFrame = 15,
    mStraightFrame = 11,
    mGuideCheckCollisionFrame = 15,
    mCreateSplashNum = 10,
    mCreateSplashLength = 15.4,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 11,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,

    mExplosionFrame = 15,
    mExplosionSleep = true,
    mDamageNear = 0.8,
    mCollisionRadiusNear = 5,
    mDamageMiddle = 0.5,
    mCollisionRadiusMiddle = 10,
    mDamageFar = 0.25,
    mCollisionRadiusFar = 35,
    mShotCollisionHitDamageRate = 0.5,
    mShotCollisionRadiusRate = 0.5,
    mKnockBackRadius = 35,
    mMoveLength = 16,
    mSphereSplashDropOn = true,
    mSphereSplashDropInitSpeed = 0,
    mSphereSplashDropCollisionRadius = 4,
    mSphereSplashDropDrawRadius = 6,
    mSphereSplashDropPaintRadius = 28,
    mSphereSplashDropPaintShotCollisionHitRadius = 18,
    mBoundPaintMaxRadius = 23,
    mBoundPaintMinRadius = 18,
    mBoundPaintMinDistanceXZ = 90,
    mWallHitPaintRadius = 17,
    mPreDelayFrm_HumanMain = 8,
    mPreDelayFrm_SquidMain = 17,
    mPostDelayFrm_Main = 26,
})
