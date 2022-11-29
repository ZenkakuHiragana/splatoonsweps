
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(0, 0, .5)
SWEP.ShootSound = "SplatoonSWEPs.Aerospray"
SWEP.Special = "inkzooka"
SWEP.Sub = "seeker"
SWEP.Variations = {
    {
        ClassName = "aerospray_rg",
        Customized = true,
        Skin = 1,
        Special = "inkstrike",
        Sub = "inkmine",
    },
    {
        ClassName = "aerospray_pg",
        SheldonsPicks = true,
        Skin = 2,
        Special = "kraken",
        Sub = "burstbomb",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 4,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 12,
    mDegJumpRandom = 18,
    mSplashSplitNum = 8,
    mKnockBack = 0,
    mInkConsume = 0.005,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.72,
    mDamageMax = 0.245,
    mDamageMin = 0.1225,
    mDamageMinFrame = 15,
    mStraightFrame = 3,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 1,
    mCreateSplashLength = 117,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 22,
    mPaintFarRadius = 19,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13.5,
    mDegBias = 0.4,
    mDegBiasKf = 0.1,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
