
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.Bodygroup = {0}
SWEP.SplashSound = "SplatoonSWEPs.RollerSplashMedium"
SWEP.RollSoundName = ss.OctoBrushRun
SWEP.Special = "squidbeakon"
SWEP.Sub = "kraken"
SWEP.Variations = {{
    Bodygroup = {1},
    Customized = true,
    Special = "inkzooka",
    Sub = "splatbomb",
    Suffix = "nouveau",
}}

ss.SetPrimary(SWEP, {
    mSwingLiftFrame = 1,
    mSplashNum = 3,
    mSplashInitSpeedBase = 5.6,
    mSplashInitSpeedRandomZ = 1,
    mSplashInitSpeedRandomX = 0.5,
    mSplashInitVecYRate = -0.02,
    mSplashDeg = 2.8,
    mSplashSubNum = 2,
    mSplashSubInitSpeedBase = 3,
    mSplashSubInitSpeedRandomZ = 1.8,
    mSplashSubInitSpeedRandomX = 0.6,
    mSplashSubInitVecYRate = -0.02,
    mSplashSubDeg = 1,
    mSplashPositionWidth = 1,
    mSplashInsideDamageRate = 1,
    mCorePaintWidthHalf = 9,
    mCorePaintSlowMoveWidthHalf = 9,
    mSlowMoveSpeed = 1.2,
    mCoreColWidthHalf = 4,
    mInkConsumeCore = 0.0018,
    mInkConsumeSplash = 0.032,
    mInkRecoverCoreStop = 20,
    mInkRecoverSplashStop = 30,
    mMoveSpeed = 1.68,
    mCoreColRadius = 4,
    mCoreDamage = 0.25,
    mTargetEffectScale = 1.7,
    mTargetEffectVelRate = 0.8,
    mSplashStraightFrame = 7,
    mSplashDamageMaxDist = 50,
    mSplashDamageMinDist = 150,
    mSplashDamageMaxValue = 0.37,
    mSplashDamageMinValue = 0.185,
    mSplashOutsideDamageMaxDist = 10,
    mSplashOutsideDamageMinDist = 80,
    mSplashOutsideDamageMaxValue = 1.4,
    mSplashOutsideDamageMinValue = 0.3,
    mSplashDamageRateBias = 1,
    mSplashDrawRadius = 4,
    mSplashPaintNearD = 100,
    mSplashPaintNearR = 18,
    mSplashPaintFarD = 100,
    mSplashPaintFarR = 18,
    mSplashCollisionRadiusForField = 8,
    mSplashCollisionRadiusForPlayer = 12,
    mSplashCoverApertureFreeFrame = -1,
    mSplashSubStraightFrame = 4,
    mSplashSubDamageMaxDist = 50,
    mSplashSubDamageMinDist = 150,
    mSplashSubDamageMaxValue = 0.37,
    mSplashSubDamageMinValue = 0.185,
    mSplashSubDamageRateBias = 1,
    mSplashSubDrawRadius = 2,
    mSplashSubPaintNearD = 12,
    mSplashSubPaintNearR = 8,
    mSplashSubPaintFarD = 50,
    mSplashSubPaintFarR = 12,
    mSplashSubCollisionRadiusForField = 6,
    mSplashSubCollisionRadiusForPlayer = 8,
    mSplashSubCoverApertureFreeFrame = -1,
    mSplashPaintType = 1,
    mArmorTypeObjectDamageRate = 0.4,
    mArmorTypeGachihokoDamageRate = 0.5,
    mPaintBrushType = true,
    mPaintBrushRotYDegree = 5,
    mPaintBrushSwingRepeatFrame = 10,
    mPaintBrushNearestBulletLoopNum = 6,
    mPaintBrushNearestBulletOrderNum = 2,
    mPaintBrushNearestBulletRadius = 20,
    mDropSplashDrawRadius = 0.5,
    mDropSplashPaintRadius = 0,
})
