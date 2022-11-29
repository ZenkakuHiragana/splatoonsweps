
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 1.8)
SWEP.ShootSound = "SplatoonSWEPs.52"
SWEP.Special = "killerwail"
SWEP.Sub = "splashwall"
SWEP.Variations = {{
    Customized = true,
    Skin = 1,
    Special = "inkstrike",
    Sub = "seeker",
    Suffix = "deco",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 9,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 6,
    mDegJumpRandom = 15,
    mSplashSplitNum = 5,
    mKnockBack = 0,
    mInkConsume = 0.012,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.6,
    mDamageMax = 0.52,
    mDamageMin = 0.26,
    mDamageMinFrame = 15,
    mStraightFrame = 4,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 3,
    mCreateSplashLength = 50,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 21,
    mPaintFarRadius = 18.5,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13.5,
    mDegBias = 0.25,
    mDegBiasKf = 0.12,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
