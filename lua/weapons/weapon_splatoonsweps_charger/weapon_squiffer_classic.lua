
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ScopeAng = Angle()              -- Scoped viewmodel angles [deg]
SWEP.ScopePos = Vector(-10, 6, 1.96) -- Scoped viewmodel position [Hammer units]
SWEP.ShootSound = "SplatoonSWEPs.Squiffer"
SWEP.ShootSound2 = SWEP.ShootSound
SWEP.Special = "bubbler"
SWEP.Sub = "pointsensor"
SWEP.Variations = {
    {
        ClassName = "squiffer_new",
        Customized = true,
        Skin = 1,
        Special = "inkzooka",
        Sub = "inkmine",
    },
    {
        ClassName = "squiffer_fresh",
        SheldonsPicks = true,
        Skin = 2,
        Special = "kraken",
        Sub = "suctionbomb",
    },
}

ss.SetPrimary(SWEP, {
    mMinDistance = 90,
    mMaxDistance = 180,
    mMaxDistanceScoped = 180,
    mFullChargeDistance = 180,
    mFullChargeDistanceScoped = 180,
    mMinChargeFrame = 8,
    mMaxChargeFrame = 45,
    mEmptyChargeTimes = 4,
    mFreezeFrmL = 1,
    mInitVelL = 12,
    mFreezeFrmH = 1,
    mInitVelH = 36,
    mInitVelF = 36,
    mInkConsume = 0.105,
    mMoveSpeed = 0.3,
    mVelGnd_DownRt = 0.2,
    mVelGnd_Bias = 0.5,
    mJumpGnd = 0.7,
    mMaxChargeSplashPaintRadius = 18.5,
    mPaintNearR_WeakRate = 0.45,
    mPaintRateLastSplash = 1.6,
    mMinChargeDamage = 0.4,
    mMaxChargeDamage = 0.8,
    mFullChargeDamage = 1.4,
    mSplashBetweenMaxSplashPaintRadiusRate = 1.58,
    mSplashBetweenMinSplashPaintRadiusRate = 1.32,
    mSplashDepthMinChargeScaleRateByWidth = 3,
    mSplashDepthMaxChargeScaleRateByWidth = 1,
    mSplashNearFootOccurChargeRate = 0.25,
    mSplashSplitNum = 1,
    mSniperCameraMoveStartChargeRate = 0,
    mSniperCameraMoveEndChargeRate = 0,
    mSniperCameraFovy = 38,
    mSniperCameraPlayerAlphaChargeRate = 0.5,
    mSniperCameraPlayerInvisibleChargeRate = 0.85,
    mMinChargeColRadiusForPlayer = 1,
    mMaxChargeColRadiusForPlayer = 1,
    mMinChargeHitSplashNum = 0,
    mMaxChargeHitSplashNum = 8,
    mMaxHitSplashNumChargeRate = 0.81,
})
