
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.Bodygroup = {0, 0}
SWEP.RTScopeNum = 4                      -- Submaterial number for RT scope option.
SWEP.ScopeAng = Angle()                  -- Scoped viewmodel angles [deg]
SWEP.ScopePos = Vector(-11.5, 3.1, 2.55) -- Scoped viewmodel position [Hammer units]
SWEP.ShootSound = "SplatoonSWEPs.Eliter3K"
SWEP.ShootSound2 = "SplatoonSWEPs.Eliter3KFull"
SWEP.Special = "echolocator"
SWEP.Sub = "burstbomb"
SWEP.Variations = {
    {
        Bodygroup = {1, 0},
        Customized = true,
        Special = "kraken",
        Sub = "squidbeakon",
        Suffix = "custom",
    },
    {
        Bodygroup = {0, 1},
        Scoped = true,
        Suffix = "scope",
    },
    {
        Bodygroup = {1, 1},
        Customized = true,
        Scoped = true,
        Special = "kraken",
        Sub = "squidbeakon",
        Suffix = "scope_custom",
    },
}

ss.SetPrimary(SWEP, {
    mMinDistance = 90,
    mMaxDistance = 340,
    mMaxDistanceScoped = 374,
    mFullChargeDistance = 340,
    mFullChargeDistanceScoped = 374,
    mMinChargeFrame = 8,
    mMaxChargeFrame = 100,
    mEmptyChargeTimes = 3,
    mFreezeFrmL = 1,
    mInitVelL = 12,
    mFreezeFrmH = 1,
    mInitVelH = 64,
    mInitVelF = 64,
    mInkConsume = 0.3,
    mMoveSpeed = 0.15,
    mVelGnd_DownRt = 0.2,
    mVelGnd_Bias = 0.5,
    mJumpGnd = 0.7,
    mMaxChargeSplashPaintRadius = 18.5,
    mPaintNearR_WeakRate = 0.45,
    mPaintRateLastSplash = 1.6,
    mMinChargeDamage = 0.4,
    mMaxChargeDamage = 1.2,
    mFullChargeDamage = 1.8,
    mSplashBetweenMaxSplashPaintRadiusRate = 1.58,
    mSplashBetweenMinSplashPaintRadiusRate = 1.32,
    mSplashDepthMinChargeScaleRateByWidth = 3,
    mSplashDepthMaxChargeScaleRateByWidth = 1,
    mSplashNearFootOccurChargeRate = 0.1,
    mSplashSplitNum = 1,
    mSniperCameraMoveStartChargeRate = 0.5,
    mSniperCameraMoveEndChargeRate = 1,
    mSniperCameraFovy = 20,
    mSniperCameraPlayerAlphaChargeRate = 0.5,
    mSniperCameraPlayerInvisibleChargeRate = 0.85,
    mMinChargeColRadiusForPlayer = 1,
    mMaxChargeColRadiusForPlayer = 1,
    mMinChargeHitSplashNum = 0,
    mMaxChargeHitSplashNum = 8,
    mMaxHitSplashNumChargeRate = 0.324,
})

function SWEP:HideRTScope(alpha)
    cam.Start2D()
    draw.NoTexture()
    surface.SetDrawColor(ColorAlpha(color_black, alpha * 225))
    surface.DrawRect(0, 0, 512, 512)
    cam.End2D()
end
