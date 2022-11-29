
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(-4, 0, 0)
SWEP.ADSOffset = Vector(-1, 0, 1.8)
SWEP.Bodygroup = {0}
SWEP.ShootSound = "SplatoonSWEPs.Jet"
SWEP.Special = "inkstrike"
SWEP.Sub = "splashwall"
SWEP.Variations = {{
    Bodygroup = {1},
    Customized = true,
    Special = "kraken",
    Sub = "burstbomb",
    Suffix = "custom",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 8,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 3,
    mDegJumpRandom = 10,
    mSplashSplitNum = 8,
    mKnockBack = 0,
    mInkConsume = 0.017,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.4,
    mDamageMax = 0.31,
    mDamageMin = 0.155,
    mDamageMinFrame = 15,
    mStraightFrame = 8,
    mGuideCheckCollisionFrame = 11,
    mCreateSplashNum = 3,
    mCreateSplashLength = 85,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 12,
    mDegBias = 0.25,
    mDegBiasKf = 0.1,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
