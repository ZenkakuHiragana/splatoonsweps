
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(5, 0, 0)
SWEP.ADSOffset = Vector(-5, 0, 3.8)
SWEP.Bodygroup = {[0] = 0}
SWEP.ShootSound = "SplatoonSWEPs.H-3"
SWEP.Special = "echolocator"
SWEP.Sub = "suctionbomb"
SWEP.Variations = {
    {
        Bodygroup = {[0] = 1},
        Customized = true,
        Special = "inkzooka",
        Sub = "pointsensor",
        Suffix = "d",
    },
    {
        Bodygroup = {[0] = 2},
        SheldonsPicks = true,
        Special = "bubbler",
        Sub = "splashwall",
        Suffix = "cherry",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 5,
    mTripleShotSpan = 20,
    mInitVel = 22,
    mDegRandom = 1,
    mDegJumpRandom = 6,
    mSplashSplitNum = 5,
    mKnockBack = 0,
    mInkConsume = 0.016,
    mInkRecoverStop = 30,
    mMoveSpeed = 0.45,
    mDamageMax = 0.41,
    mDamageMin = 0.205,
    mDamageMinFrame = 15,
    mStraightFrame = 5,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 3.5,
    mCreateSplashLength = 54,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 22,
    mPaintFarRadius = 22,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 14.5,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
