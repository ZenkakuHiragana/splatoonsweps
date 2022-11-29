
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ChargeSound = {"SplatoonSWEPs.HeavySplatling", "SplatoonSWEPs.HeavySplatling2", "SplatoonSWEPs.HeavySplatlingFull"}
SWEP.ShootSound = "SplatoonSWEPs.Zap"
SWEP.Special = "inkstrike"
SWEP.Sub = "splashwall"
SWEP.Variations = {
    {
        Customized = true,
        Skin = 1,
        Special = "kraken",
        Sub = "pointsensor",
        Suffix = "deco",
    },
    {
        SheldonsPicks = true,
        Skin = 2,
        Special = "killerwail",
        Sub = "sprinkler",
        Suffix = "remix",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 4,
    mTripleShotSpan = 0,

    mDegRandom = 3.5,
    mDegJumpRandom = 7,
    mSplashSplitNum = 8,
    mKnockBack = 0,
    mInkConsume = 0.25,
    mInkRecoverStop = 40,
    mMoveSpeed = 0.7,
    mDamageMax = 0.28,
    mDamageMin = 0.14,
    mDamageMinFrame = 8,
    mStraightFrame = 8,
    mGuideCheckCollisionFrame = 11,
    mCreateSplashNum = 1,
    mCreateSplashLength = 200,
    mDrawRadius = 1.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 14,
    mDegBias = 0.3,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.3,
    mDegJumpBiasFrame = 45,

    mMinChargeFrame = 8,
    mFirstPeriodMaxChargeFrame = 50,
    mSecondPeriodMaxChargeFrame = 75,
    mFirstPeriodMaxChargeShootingFrame = 72,
    mSecondPeriodMaxChargeShootingFrame = 144,
    mWaitShootingFrame = 0,
    mEmptyChargeTimes = 4,
    mInitVelMinCharge = 10.5,
    mInitVelFirstPeriodMaxCharge = 21,
    mInitVelSecondPeriodMinCharge = 21,
    mInitVelSecondPeriodMaxCharge = 21,
    mDamageMaxMaxCharge = 0.28,
    mMoveSpeed_Charge = 0.55,
    mVelGnd_DownRt_Charge = 0.05,
    mVelGnd_Bias_Charge = 0.9,
    mJumpGnd_Charge = 0.8,
    mInitVelSpeedRateRandom = 0.12,
    mInitVelSpeedBias = 0.2,
    mInitVelDegRandom = 1.6,
    mInitVelDegBias = 0.4,
    mPaintDepthScaleBias = 1.4,
})
