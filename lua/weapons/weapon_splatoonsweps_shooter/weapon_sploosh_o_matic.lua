
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(0, 0, 1.5)
SWEP.Bodygroup = {0}
SWEP.ShootSound = "SplatoonSWEPs.Sploosh-o-matic"
SWEP.Skin = 1
SWEP.Special = "killerwail"
SWEP.Sub = "squidbeakon"
SWEP.Variations = {
    {
        Customized = true,
        Skin = 0,
        Special = "kraken",
        Sub = "pointsensor",
        Suffix = "neo",
    },
    {
        Bodygroup = {1},
        SheldonsPicks = true,
        Skin = 2,
        Special = "inkzooka",
        Sub = "splatbomb",
        Suffix = "7",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 5,
    mTripleShotSpan = 0,
    mInitVel = 20,
    mDegRandom = 12,
    mDegJumpRandom = 18,
    mSplashSplitNum = 4,
    mKnockBack = 0,
    mInkConsume = 0.007,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.72,
    mDamageMax = 0.38,
    mDamageMin = 0.19,
    mDamageMinFrame = 15,
    mStraightFrame = 2,
    mGuideCheckCollisionFrame = 6,
    mCreateSplashNum = 1.5,
    mCreateSplashLength = 55,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 24,
    mPaintFarRadius = 19,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 12,
    mDegBias = 0.4,
    mDegBiasKf = 0.1,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
