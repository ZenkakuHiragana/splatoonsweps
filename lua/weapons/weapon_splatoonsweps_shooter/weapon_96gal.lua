
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 1.8)
SWEP.ShootSound = "SplatoonSWEPs.96"
SWEP.Special = "echolocator"
SWEP.Sub = "sprinkler"
SWEP.Variations = {{
    Customized = true,
    Skin = 1,
    Special = "kraken",
    Sub = "splashwall",
    Suffix = "deco",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 12,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 4.5,
    mDegJumpRandom = 12,
    mSplashSplitNum = 5,
    mKnockBack = 0,
    mInkConsume = 0.025,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.4,
    mDamageMax = 0.62,
    mDamageMin = 0.31,
    mDamageMinFrame = 18,
    mStraightFrame = 6,
    mGuideCheckCollisionFrame = 9,
    mCreateSplashNum = 4,
    mCreateSplashLength = 50,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 21,
    mPaintFarRadius = 18.5,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 14.5,
    mDegBias = 0.25,
    mDegBiasKf = 0.2,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
