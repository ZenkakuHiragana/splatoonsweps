
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSOffset = Vector(0, 0, 1.5)
SWEP.ShootSound = "SplatoonSWEPs.Splattershot"
SWEP.Special = "bombrush"
SWEP.Sub = "burstbomb"
SWEP.Variations = {
    {
        Customized = true,
        Skin = 1,
        Special = "inkzooka",
        Sub = "suctionbomb",
        Suffix = "tentatek",
    },
    {
        SheldonsPicks = true,
        Skin = 2,
        Special = "inkstrike",
        Sub = "splatbomb",
        Suffix = "wasabi",
    },
    {
        ClassName = "heroshot",
        IsHeroShot = true,
        IsHeroWeapon = true,
    },
    {
        ClassName = "octoshot",
        IsOctoShot = true,
        ShootSound = "SplatoonSWEPs.Octoshot",
        Skin = 1,
        Special = "inkzooka",
        Sub = "suctionbomb",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 6,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 6,
    mDegJumpRandom = 15,
    mSplashSplitNum = 5,
    mKnockBack = 0,
    mInkConsume = 0.009,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.72,
    mDamageMax = 0.36,
    mDamageMin = 0.18,
    mDamageMinFrame = 15,
    mStraightFrame = 4,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 2,
    mCreateSplashLength = 75,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 13,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})
