
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 2)
SWEP.ShootSound = "SplatoonSWEPs.96"
SWEP.Special = "inkstrike"
SWEP.Sub = "splashwall"
SWEP.Variations = {
    {
        Customized = true,
        Skin = 1,
        Special = "kraken",
        Sub = "splatbomb",
        Suffix = "custom",
    },
    {
        SheldonsPicks = true,
        Skin = 2,
        Special = "killerwail",
        Sub = "burstbomb",
        Suffix = "grim",
    }
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 60,
    mTripleShotSpan = 0,
    mInitVel = 10.8,
    mDegRandom = 0,
    mDegJumpRandom = 10,
    mSplashSplitNum = 1,
    mKnockBack = 0,
    mInkConsume = 0.1,
    mInkRecoverStop = 50,
    mMoveSpeed = 0.4,
    mDamageMax = 1.25,
    mDamageMin = 1.25,
    mDamageMinFrame = 10,
    mStraightFrame = 11,
    mGuideCheckCollisionFrame = 15,
    mCreateSplashNum = 9,
    mCreateSplashLength = 15,
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

    mExplosionFrame = 15,
    mExplosionSleep = true,
    mDamageNear = 1.25,
    mCollisionRadiusNear = 5,
    mDamageMiddle = 0.6,
    mCollisionRadiusMiddle = 15,
    mDamageFar = 0.5,
    mCollisionRadiusFar = 35,
    mShotCollisionHitDamageRate = 0.5,
    mShotCollisionRadiusRate = 0.5,
    mKnockBackRadius = 35,
    mMoveLength = 22,
    mSphereSplashDropOn = true,
    mSphereSplashDropInitSpeed = 0,
    mSphereSplashDropCollisionRadius = 4,
    mSphereSplashDropDrawRadius = 6,
    mSphereSplashDropPaintRadius = 32,
    mSphereSplashDropPaintShotCollisionHitRadius = 20,
    mBoundPaintMaxRadius = 25,
    mBoundPaintMinRadius = 20,
    mBoundPaintMinDistanceXZ = 90,
    mWallHitPaintRadius = 18,
    mPreDelayFrm_HumanMain = 10,
    mPreDelayFrm_SquidMain = 15,
    mPostDelayFrm_Main = 30,
})
