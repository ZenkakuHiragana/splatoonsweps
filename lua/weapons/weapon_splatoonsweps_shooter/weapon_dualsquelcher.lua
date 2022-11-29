
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(-4, 0, 0)
SWEP.ADSOffset = Vector(-1, 0, 1.8)
SWEP.Bodygroup = {0}
SWEP.ShootSound = "SplatoonSWEPs.Dual"
SWEP.Special = "echolocator"
SWEP.Sub = "splatbomb"
SWEP.Variations = {{
    Bodygroup = {1},
    Customized = true,
    Special = "killerwail",
    Sub = "squidbeakon",
    Suffix = "custom",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 6,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 4,
    mDegJumpRandom = 12,
    mSplashSplitNum = 8,
    mKnockBack = 0,
    mInkConsume = 0.012,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.5,
    mDamageMax = 0.28,
    mDamageMin = 0.14,
    mDamageMinFrame = 18,
    mStraightFrame = 6,
    mGuideCheckCollisionFrame = 9,
    mCreateSplashNum = 2,
    mCreateSplashLength = 105,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 21,
    mPaintFarRadius = 18.5,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
