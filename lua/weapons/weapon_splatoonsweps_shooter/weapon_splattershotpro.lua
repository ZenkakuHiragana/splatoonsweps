
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(-3.5, 0, 3)
SWEP.ShootSound = "SplatoonSWEPs.SplattershotPro"
SWEP.Special = "inkstrike"
SWEP.Sub = "splatbomb"
SWEP.Variations = {
    {
        Customized = true,
        Skin = 1,
        Special = "inkzooka",
        Sub = "pointsensor",
        Suffix = "forge",
    },
    {
        SheldonsPicks = true,
        Skin = 2,
        Special = "bombrush",
        Sub = "suctionbomb",
        Suffix = "berry",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 8,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 3,
    mDegJumpRandom = 12,
    mSplashSplitNum = 8,
    mKnockBack = 0,
    mInkConsume = 0.02,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.5,
    mDamageMax = 0.42,
    mDamageMin = 0.21,
    mDamageMinFrame = 18,
    mStraightFrame = 6,
    mGuideCheckCollisionFrame = 9,
    mCreateSplashNum = 3,
    mCreateSplashLength = 70,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 12.5,
    mDegBias = 0.25,
    mDegBiasKf = 0.1,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
