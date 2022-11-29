
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ChargeSound = {"SplatoonSWEPs.MiniSplatling", "SplatoonSWEPs.MiniSplatling2", "SplatoonSWEPs.MiniSplatlingFull"}
SWEP.ShootSound = "SplatoonSWEPs.Octoshot"
SWEP.Special = "inkzooka"
SWEP.Sub = "suctionbomb"
SWEP.Variations = {
    {
        Customized = true,
        Skin = 1,
        Special = "bubbler",
        Sub = "disruptor",
        Suffix = "zink",
    },
    {
        SheldonsPicks = true,
        Skin = 2,
        Special = "bombrush",
        Sub = "burstbomb",
        Suffix = "refurbished",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 4,
    mTripleShotSpan = 0,

    mDegRandom = 4,
    mDegJumpRandom = 8,
    mSplashSplitNum = 5,
    mKnockBack = 0,
    mInkConsume = 0.15,
    mInkRecoverStop = 30,
    mMoveSpeed = 0.8,
    mDamageMax = 0.28,
    mDamageMin = 0.14,
    mDamageMinFrame = 8,
    mStraightFrame = 8,
    mGuideCheckCollisionFrame = 11,
    mCreateSplashNum = 1.8,
    mCreateSplashLength = 85,
    mDrawRadius = 1.5,
    mColRadius = 2,
    mPaintNearDistance = 10,
    mPaintFarDistance = 200,
    mPaintNearRadius = 22,
    mPaintFarRadius = 21,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 14,
    mDegBias = 0.3,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.3,
    mDegJumpBiasFrame = 45,

    mMinChargeFrame = 8,
    mFirstPeriodMaxChargeFrame = 20,
    mSecondPeriodMaxChargeFrame = 30,
    mFirstPeriodMaxChargeShootingFrame = 36,
    mSecondPeriodMaxChargeShootingFrame = 72,
    mWaitShootingFrame = 0,
    mEmptyChargeTimes = 6,
    mInitVelMinCharge = 10.5,
    mInitVelFirstPeriodMaxCharge = 15,
    mInitVelSecondPeriodMinCharge = 15,
    mInitVelSecondPeriodMaxCharge = 15,
    mDamageMaxMaxCharge = 0.28,
    mMoveSpeed_Charge = 0.7,
    mVelGnd_DownRt_Charge = 0.05,
    mVelGnd_Bias_Charge = 0.9,
    mJumpGnd_Charge = 0.9,
    mInitVelSpeedRateRandom = 0.1,
    mInitVelSpeedBias = 0.2,
    mInitVelDegRandom = 1.2,
    mInitVelDegBias = 0.4,
    mPaintDepthScaleBias = 1,
})
