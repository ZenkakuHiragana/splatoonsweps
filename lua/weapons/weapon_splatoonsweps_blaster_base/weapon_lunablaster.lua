
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(-2, 1.5, -45)
SWEP.ADSOffset = Vector(-5, 0, -0.7)
SWEP.Bodygroup = {0}
SWEP.IronSightsPos = {
    Vector(), -- right
    Vector(), -- left
    Vector(), -- top-right
    Vector(), -- top-left
    Vector(0, 6, -4.5), -- center
}
SWEP.ShootSound = "SplatoonSWEPs.SplattershotJr"
SWEP.Special = "inkzooka"
SWEP.Sub = "inkmine"
SWEP.Variations = {{
    Bodygroup = {1},
    Customized = true,
    Special = "bombrush",
    Sub = "splatbomb",
    Suffix = "neo",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 40,
    mTripleShotSpan = 0,
    mInitVel = 8.5,
    mDegRandom = 0,
    mDegJumpRandom = 10,
    mSplashSplitNum = 1,
    mKnockBack = 0,
    mInkConsume = 0.06,
    mInkRecoverStop = 30,
    mMoveSpeed = 0.5,
    mDamageMax = 1.25,
    mDamageMin = 1.25,
    mDamageMinFrame = 10,
    mStraightFrame = 7,
    mGuideCheckCollisionFrame = 11,
    mCreateSplashNum = 6,
    mCreateSplashLength = 13,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 14,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,

    mExplosionFrame = 11,
    mExplosionSleep = true,
    mDamageNear = 1.25,
    mCollisionRadiusNear = 5,
    mDamageMiddle = 0.65,
    mCollisionRadiusMiddle = 20,
    mDamageFar = 0.5,
    mCollisionRadiusFar = 40,
    mShotCollisionHitDamageRate = 0.5,
    mShotCollisionRadiusRate = 0.5,
    mKnockBackRadius = 40,
    mMoveLength = 25,
    mSphereSplashDropOn = true,
    mSphereSplashDropInitSpeed = 0,
    mSphereSplashDropCollisionRadius = 4,
    mSphereSplashDropDrawRadius = 6,
    mSphereSplashDropPaintRadius = 40,
    mSphereSplashDropPaintShotCollisionHitRadius = 24,
    mBoundPaintMaxRadius = 25,
    mBoundPaintMinRadius = 20,
    mBoundPaintMinDistanceXZ = 90,
    mWallHitPaintRadius = 20,
    mPreDelayFrm_HumanMain = 10,
    mPreDelayFrm_SquidMain = 15,
    mPostDelayFrm_Main = 30,
})
