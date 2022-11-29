
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(5, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 3.8)
SWEP.Bodygroup = {[0] = 0}
SWEP.ShootSound = "SplatoonSWEPs.L-3"
SWEP.Special = "killerwail"
SWEP.Sub = "disruptor"
SWEP.Variations = {{
    Bodygroup = {[0] = 1},
    Customized = true,
    Special = "kraken",
    Sub = "burstbomb",
    Suffix = "d",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 4,
    mTripleShotSpan = 8,
    mInitVel = 22,
    mDegRandom = 1,
    mDegJumpRandom = 6,
    mSplashSplitNum = 10,
    mKnockBack = 0,
    mInkConsume = 0.01,
    mInkRecoverStop = 25,
    mMoveSpeed = 0.5,
    mDamageMax = 0.29,
    mDamageMin = 0.145,
    mDamageMinFrame = 15,
    mStraightFrame = 5,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 1.5,
    mCreateSplashLength = 116,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 22,
    mPaintFarRadius = 22,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 15,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
