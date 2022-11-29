
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.Bodygroup = {0}
SWEP.IsBamboozler = true
SWEP.ScopeAng = Angle(2, 0, 0)     -- Scoped viewmodel angles [deg]
SWEP.ScopePos = Vector(-8.5, 6, 3) -- Scoped viewmodel position [Hammer units]
SWEP.ShootSound = "SplatoonSWEPs.Bamboozler"
SWEP.ShootSound2 = "SplatoonSWEPs.BamboozlerFull"
SWEP.Special = "killerwail"
SWEP.Sub = "splashwall"
SWEP.Variations = {
    {
        Bodygroup = {1},
        ClassName = "bamboozler14_mk2",
        Customized = true,
        Special = "echolocator",
        Sub = "disruptor",
    },
    {
        Bodygroup = {1},
        ClassName = "bamboozler14_mk3",
        SheldonsPicks = true,
        Skin = 1,
        Special = "inkstrike",
        Sub = "burstbomb",
    },
}

ss.SetPrimary(SWEP, {
    mMinDistance = 200,
    mMaxDistance = 200,
    mMaxDistanceScoped = 200,
    mFullChargeDistance = 200,
    mFullChargeDistanceScoped = 200,
    mMinChargeFrame = 8,
    mMaxChargeFrame = 20,
    mEmptyChargeTimes = 5,
    mFreezeFrmL = 1,
    mInitVelL = 40,
    mFreezeFrmH = 1,
    mInitVelH = 40,
    mInitVelF = 40,
    mInkConsume = 0.08,
    mMoveSpeed = 0.4,
    mVelGnd_DownRt = 0.2,
    mVelGnd_Bias = 0.5,
    mJumpGnd = 0.7,
    mMaxChargeSplashPaintRadius = 12,
    mPaintNearR_WeakRate = 0.7,
    mPaintRateLastSplash = 1.5,
    mMinChargeDamage = 0.3,
    mMaxChargeDamage = 0.8,
    mFullChargeDamage = 0.8,
    mSplashBetweenMaxSplashPaintRadiusRate = 3,
    mSplashBetweenMinSplashPaintRadiusRate = 1.5,
    mSplashDepthMinChargeScaleRateByWidth = 3.5,
    mSplashDepthMaxChargeScaleRateByWidth = 3,
    mSplashNearFootOccurChargeRate = 1.01,
    mSplashSplitNum = 3,
    mSniperCameraMoveStartChargeRate = 0,
    mSniperCameraMoveEndChargeRate = 0,
    mSniperCameraFovy = 38,
    mSniperCameraPlayerAlphaChargeRate = 0.5,
    mSniperCameraPlayerInvisibleChargeRate = 0.85,
    mMinChargeColRadiusForPlayer = 2,
    mMaxChargeColRadiusForPlayer = 2,
    mMinChargeHitSplashNum = 0,
    mMaxChargeHitSplashNum = 5,
    mMaxHitSplashNumChargeRate = 1,
})
