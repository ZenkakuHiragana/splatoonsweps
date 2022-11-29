
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
local ScopePos = Vector(-5, 5.98, 1.13)
SWEP.Bodygroup = {0}
SWEP.RTScopeNum = 10                -- Submaterial number for RT scope option.
SWEP.ScopeAng = Angle()             -- Scoped viewmodel angles [deg]
SWEP.ScopePos = Vector(-5, 6, 2.42) -- Scoped viewmodel position [Hammer units]
SWEP.ShootSound = "SplatoonSWEPs.SplatCharger"
SWEP.ShootSound2 = "SplatoonSWEPs.SplatChargerFull"
SWEP.Special = "bombrush"
SWEP.Sub = "splatbomb"
SWEP.Variations = {
    {
        Bodygroup = {1},
        Customized = true,
        Special = "killerwail",
        Sub = "sprinkler",
        Suffix = "kelp",
    },
    {
        Bodygroup = {2},
        RTScopeNum = 11,
        SheldonsPicks = true,
        Skin = 1,
        Special = "echolocator",
        Sub = "splashwall",
        Suffix = "bento",
    },
    {
        ClassName = "herocharger",
        IsHeroWeapon = true,
        ScopePos = Vector(-5, 6.03, .2),
    },
    {
        Bodygroup = {3},
        ClassName = "splatterscope",
        Scoped = true,
        ScopePos = ScopePos,
    },
    {
        Bodygroup = {4},
        ClassName = "splatterscope_kelp",
        Customized = true,
        Scoped = true,
        ScopePos = ScopePos,
        Special = "killerwail",
        Sub = "sprinkler",
    },
    {
        Bodygroup = {5},
        ClassName = "splatterscope_bento",
        RTScopeNum = 11,
        SheldonsPicks = true,
        Skin = 1,
        Scoped = true,
        ScopePos = ScopePos,
        Special = "echolocator",
        Sub = "splashwall",
    },
}

ss.SetPrimary(SWEP, {
    mMinDistance = 90,
    mMaxDistance = 250,
    mMaxDistanceScoped = 275,
    mFullChargeDistance = 250,
    mFullChargeDistanceScoped = 275,
    mMinChargeFrame = 8,
    mMaxChargeFrame = 60,
    mEmptyChargeTimes = 3,
    mFreezeFrmL = 1,
    mInitVelL = 12,
    mFreezeFrmH = 1,
    mInitVelH = 48,
    mInitVelF = 48,
    mInkConsume = 0.18,
    mMoveSpeed = 0.2,
    mVelGnd_DownRt = 0.2,
    mVelGnd_Bias = 0.5,
    mJumpGnd = 0.7,
    mMaxChargeSplashPaintRadius = 18.5,
    mPaintNearR_WeakRate = 0.45,
    mPaintRateLastSplash = 1.6,
    mMinChargeDamage = 0.4,
    mMaxChargeDamage = 1,
    mFullChargeDamage = 1.6,
    mSplashBetweenMaxSplashPaintRadiusRate = 1.58,
    mSplashBetweenMinSplashPaintRadiusRate = 1.32,
    mSplashDepthMinChargeScaleRateByWidth = 3,
    mSplashDepthMaxChargeScaleRateByWidth = 1,
    mSplashNearFootOccurChargeRate = 0.166,
    mSplashSplitNum = 1,
    mSniperCameraMoveStartChargeRate = 0.5,
    mSniperCameraMoveEndChargeRate = 1,
    mSniperCameraFovy = 28,
    mSniperCameraPlayerAlphaChargeRate = 0.5,
    mSniperCameraPlayerInvisibleChargeRate = 0.85,
    mMinChargeColRadiusForPlayer = 1,
    mMaxChargeColRadiusForPlayer = 1,
    mMinChargeHitSplashNum = 0,
    mMaxChargeHitSplashNum = 8,
    mMaxHitSplashNumChargeRate = 0.54,
})

function SWEP:HideRTScope(alpha)
    self.RTMaterial:SetVector("$envmaptint", ss.vector_one * alpha)
end
