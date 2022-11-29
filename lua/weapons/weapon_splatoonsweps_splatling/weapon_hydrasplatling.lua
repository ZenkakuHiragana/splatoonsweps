
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ChargeSound = {"SplatoonSWEPs.HydraSplatling", "SplatoonSWEPs.HydraSplatling2", "SplatoonSWEPs.HydraSplatlingFull"}
SWEP.ShootSound = "SplatoonSWEPs.52"
SWEP.Special = "echolocator"
SWEP.Sub = "splatbomb"
SWEP.Variations = {{
    Bodygroup = {1},
    Customized = true,
    Special = "bubbler",
    Sub = "sprinkler",
    Suffix = "custom",
}}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 4,
    mTripleShotSpan = 0,

    mDegRandom = 3,
    mDegJumpRandom = 6,
    mSplashSplitNum = 8,
    mKnockBack = 0,
    mInkConsume = 0.35,
    mInkRecoverStop = 40,
    mMoveSpeed = 0.6,
    mDamageMax = 0.28,
    mDamageMin = 0.14,
    mDamageMinFrame = 8,
    mStraightFrame = 8,
    mGuideCheckCollisionFrame = 11,
    mCreateSplashNum = 1,
    mCreateSplashLength = 235,
    mDrawRadius = 1.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 12,
    mDegBias = 0.3,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.3,
    mDegJumpBiasFrame = 45,

    mMinChargeFrame = 8,
    mFirstPeriodMaxChargeFrame = 108,
    mSecondPeriodMaxChargeFrame = 135,
    mFirstPeriodMaxChargeShootingFrame = 108,
    mSecondPeriodMaxChargeShootingFrame = 216,
    mWaitShootingFrame = 0,
    mEmptyChargeTimes = 3,
    mInitVelMinCharge = 10.5,
    mInitVelFirstPeriodMaxCharge = 24,
    mInitVelSecondPeriodMinCharge = 24,
    mInitVelSecondPeriodMaxCharge = 24,
    mDamageMaxMaxCharge = 0.35,
    mMoveSpeed_Charge = 0.4,
    mVelGnd_DownRt_Charge = 0.05,
    mVelGnd_Bias_Charge = 0.9,
    mJumpGnd_Charge = 0.6,
    mInitVelSpeedRateRandom = 0.14,
    mInitVelSpeedBias = 0.2,
    mInitVelDegRandom = 2,
    mInitVelDegBias = 0.4,
    mPaintDepthScaleBias = 1.2,
})
