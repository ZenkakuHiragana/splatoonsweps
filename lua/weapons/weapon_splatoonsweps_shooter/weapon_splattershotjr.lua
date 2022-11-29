
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(1, 0, 0)
SWEP.ADSOffset = Vector(-2, 0, 3)
SWEP.Bodygroup = {0}
SWEP.ShootSound = "SplatoonSWEPs.SplattershotJr"
SWEP.Special = "bubbler"
SWEP.Sub = "splatbomb"
SWEP.Variations = {{
    Bodygroup = {1},
    Customized = true,
    Special = "echolocator",
    Sub = "disruptor",
    Suffix = "custom",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 5,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 12,
    mDegJumpRandom = 18,
    mSplashSplitNum = 7,
    mKnockBack = 0,
    mInkConsume = 0.005,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.72,
    mDamageMax = 0.28,
    mDamageMin = 0.14,
    mDamageMinFrame = 15,
    mStraightFrame = 3,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 1.5,
    mCreateSplashLength = 80,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 21,
    mPaintFarRadius = 18.5,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13.2,
    mDegBias = 0.4,
    mDegBiasKf = 0.1,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
