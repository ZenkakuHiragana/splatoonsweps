
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(0, 0, 1.5)
SWEP.Bodygroup = {0}
SWEP.ShootSound = "SplatoonSWEPs.Splash-o-matic"
SWEP.Special = "bombrush"
SWEP.Sub = "suctionbomb"
SWEP.Variations = {{
        Bodygroup = {1},
        Customized = true,
        Special = "inkzooka",
        Sub = "burstbomb",
        Suffix = "neo",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 5,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 3,
    mDegJumpRandom = 12,
    mSplashSplitNum = 7,
    mKnockBack = 0,
    mInkConsume = 0.007,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.72,
    mDamageMax = 0.26,
    mDamageMin = 0.13,
    mDamageMinFrame = 15,
    mStraightFrame = 3,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 1.5,
    mCreateSplashLength = 80,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 22,
    mPaintFarRadius = 19,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13.2,
    mDegBias = 0.4,
    mDegBiasKf = 0.1,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
