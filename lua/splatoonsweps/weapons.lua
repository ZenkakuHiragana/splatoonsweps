
-- Functions for weapon settings.

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

---@alias Parameters
---| Parameters.Shooter
---| Parameters.Blaster
---| Parameters.Charger
---| Parameters.Splatling
---| Parameters.Roller
---| Parameters.Slosher

---@alias SubParameters
---| SubParameters.BurstBomb
---| SubParameters.Disruptor
---| SubParameters.Inkmine
---| SubParameters.PointSensor
---| SubParameters.Seeker
---| SubParameters.SplashWall
---| SubParameters.SplatBomb
---| SubParameters.Sprinkler
---| SubParameters.SquidBeakon
---| SubParameters.SuctionBomb

---@alias SpecialParameters
---| SpecialParameters.Bombrush
---| SpecialParameters.Bubbler
---| SpecialParameters.Echolocator

---@class ISubWeaponDef
---@field Merge      table<string, any>
---@field Parameters SubParameters
---@field Units      table<string, string>
---@field BurstSound string?
---@field GetDamage (fun(distance: number, ent: Entity?): number)?

---@class ISpecialWeaponDef
---@field PointsNeeded integer
---@field Merge        table<string, any>
---@field Parameters   SpecialParameters
---@field Units        table<string, string>

---@class ss.InkQueue
---@field Data                   Projectile
---@field InitTime               number
---@field IsCarriedByLocalPlayer boolean
---@field Owner                  Entity?
---@field Parameters             Parameters
---@field Trace                  ss.InkQueueTrace
---@field CurrentSpeed           number
---@field BlasterRemoval         boolean
---@field BlasterHitWall         boolean
---@field Exploded               boolean

---@class ss.InkQueueTrace : Trace, HullTrace
---@field LengthSum number
---@field LifeTime  number

---@class Projectile
---@field AirResist              number   Air resistance.  Horizontal velocity at next frame = Current horizontal velocity * AirResist
---@field Color                  number   Ink color ID
---@field ColRadiusEntity        number   Collision radius against entities
---@field ColRadiusWorld         number   Collision radius against the world
---@field DoDamage               boolean  Whether or not the ink deals damage
---@field DamageMax              number   Maximum damage
---@field DamageMaxDistance      number   Ink travel distance to start decaying damage
---@field DamageMin              number   Minimum damage
---@field DamageMinDistance      number   Ink travel distance to end decaying damage
---@field Gravity                number   Gravity acceleration
---@field ID                     number   Ink identifier to avoid multiple damages at once
---@field InitDir                Vector   (Auto set) Initial direction of velocity
---@field InitPos                Vector   Initial position
---@field InitSpeed              number   (Auto set) Initial speed
---@field InitVel                Vector   Initial velocity
---@field IsCritical             boolean  Whether or not the ink is critical (true to change the hit effect)
---@field PaintFarDistance       number   Ink travel distance to end shrinking paint radius
---@field PaintFarRadius         number   Painting radius when hit
---@field PaintFarRatio          number   Painting aspect ratio at the end
---@field PaintNearDistance      number   Ink travel distance to start shrinking paint radius
---@field PaintNearRadius        number   Painting radius when hit
---@field PaintNearRatio         number   Painting aspect ratio at the beginning
---@field PaintRatioFarDistance  number   Ink travel distance to end changing paint aspect ratio
---@field PaintRatioNearDistance number   Ink travel distance to start changing paint aspect ratio
---@field Range                  number   (For Chargers) Ink travel distance limit
---@field ScatterSplashCount     integer? (For Sloshing Maching) Number of scatte splashes spawned so far
---@field ScatterSplashTime      number?  (For Sloshing Machine) Time to seek when to spawn next scatter splash
---@field SplashColRadius        number   Collision radius against entities/world for splashes created from the ink
---@field SplashDrawRadius       number?  Draw radius for splashes created from the ink
---@field SplashCount            number   (Variable) Current number of splashes the ink has dropped so far
---@field SplashInitRate         number   Determines the position of the first splash the ink drops = SplashLength * SplashInitRate
---@field SplashLength           number   Length between two splashes from the ink
---@field SplashNum              number   Number of total splashes the ink will drop
---@field SplashPaintRadius      number   Painting radius splashes will paint
---@field SplashRatio            number   Painting aspect ratio for splashes
---@field StraightFrame          number   The ink travels without affecting gravity for this frames
---@field Type                   number   The shape of the paintings
---@field WallPaintFirstLength   number   (For Chargers) Determines the position of the first paint for the vertical wall paint
---@field WallPaintLength        number   (For Chargers) Length between two paints for the vertical wall paint
---@field WallPaintMaxNum        number   (For Chargers) Number of paints for the vertical wall paint
---@field WallPaintRadius        number   (For Chargers) Painting radius for the vertical wall paint
---@field WallPaintUseSplashNum  boolean  (For Chargers) True to use the rest of splash count (SplashNum - SplashCount) instead of WallPaintMaxNum
---@field Weapon                 SplatoonWeaponBase The weapon entity which created the ink
---@field Yaw                    number   Determines the angle of the paintings in degrees
---@field Charge                 number   (For Chargers) Fired at this %

---@class Parameters.Shooter
---@field mRepeatFrame                  number
---@field mTripleShotSpan               number
---@field mInitVel                      number
---@field mDegRandom                    number
---@field mDegJumpRandom                number
---@field mSplashSplitNum               number
---@field mKnockBack                    number
---@field mInkConsume                   number
---@field mInkRecoverStop               number
---@field mMoveSpeed                    number
---@field mDamageMax                    number
---@field mDamageMin                    number
---@field mDamageMinFrame               number
---@field mStraightFrame                number
---@field mGuideCheckCollisionFrame     number
---@field mCreateSplashNum              number
---@field mCreateSplashLength           number
---@field mDrawRadius                   number
---@field mColRadius                    number
---@field mPaintNearDistance            number
---@field mPaintFarDistance             number
---@field mPaintNearRadius              number
---@field mPaintFarRadius               number
---@field mSplashDrawRadius             number
---@field mSplashColRadius              number
---@field mSplashPaintRadius            number
---@field mArmorTypeGachihokoDamageRate number?
---@field mDegBias                      number
---@field mDegBiasKf                    number
---@field mDegJumpBias                  number
---@field mDegJumpBiasFrame             number

---@class Parameters.Blaster : Parameters.Shooter
---@field mExplosionFrame                              number
---@field mExplosionSleep                              boolean
---@field mDamageNear                                  number
---@field mCollisionRadiusNear                         number
---@field mDamageMiddle                                number
---@field mCollisionRadiusMiddle                       number
---@field mDamageFar                                   number
---@field mCollisionRadiusFar                          number
---@field mShotCollisionHitDamageRate                  number
---@field mShotCollisionRadiusRate                     number
---@field mKnockBackRadius                             number
---@field mMoveLength                                  number
---@field mSphereSplashDropOn                          boolean
---@field mSphereSplashDropInitSpeed                   number
---@field mSphereSplashDropCollisionRadius             number
---@field mSphereSplashDropDrawRadius                  number
---@field mSphereSplashDropPaintRadius                 number
---@field mSphereSplashDropPaintShotCollisionHitRadius number
---@field mBoundPaintMaxRadius                         number
---@field mBoundPaintMinRadius                         number
---@field mBoundPaintMinDistanceXZ                     number
---@field mWallHitPaintRadius                          number
---@field mPreDelayFrm_HumanMain                       number
---@field mPreDelayFrm_SquidMain                       number
---@field mPostDelayFrm_Main                           number

---@class Parameters.Splatling : Parameters.Shooter
---@field mMinChargeFrame                     number
---@field mFirstPeriodMaxChargeFrame          number
---@field mSecondPeriodMaxChargeFrame         number
---@field mFirstPeriodMaxChargeShootingFrame  number
---@field mSecondPeriodMaxChargeShootingFrame number
---@field mWaitShootingFrame                  number
---@field mEmptyChargeTimes                   number
---@field mInitVelMinCharge                   number
---@field mInitVelFirstPeriodMaxCharge        number
---@field mInitVelSecondPeriodMinCharge       number
---@field mInitVelSecondPeriodMaxCharge       number
---@field mDamageMaxMaxCharge                 number
---@field mMoveSpeed_Charge                   number
---@field mVelGnd_DownRt_Charge               number
---@field mVelGnd_Bias_Charge                 number
---@field mJumpGnd_Charge                     number
---@field mInitVelSpeedRateRandom             number
---@field mInitVelSpeedBias                   number
---@field mInitVelDegRandom                   number
---@field mInitVelDegBias                     number
---@field mPaintDepthScaleBias                number

---@class Parameters.Charger
---@field mMinDistance                           number
---@field mMaxDistance                           number
---@field mMaxDistanceScoped                     number
---@field mFullChargeDistance                    number
---@field mFullChargeDistanceScoped              number
---@field mMinChargeFrame                        number
---@field mMaxChargeFrame                        number
---@field mEmptyChargeTimes                      number
---@field mFreezeFrmL                            number
---@field mInitVelL                              number
---@field mFreezeFrmH                            number
---@field mInitVelH                              number
---@field mInitVelF                              number
---@field mInkConsume                            number
---@field mMoveSpeed                             number
---@field mVelGnd_DownRt                         number
---@field mVelGnd_Bias                           number
---@field mJumpGnd                               number
---@field mMaxChargeSplashPaintRadius            number
---@field mPaintNearR_WeakRate                   number
---@field mPaintRateLastSplash                   number
---@field mMinChargeDamage                       number
---@field mMaxChargeDamage                       number
---@field mFullChargeDamage                      number
---@field mSplashBetweenMaxSplashPaintRadiusRate number
---@field mSplashBetweenMinSplashPaintRadiusRate number
---@field mSplashDepthMinChargeScaleRateByWidth  number
---@field mSplashDepthMaxChargeScaleRateByWidth  number
---@field mSplashNearFootOccurChargeRate         number
---@field mSplashSplitNum                        number
---@field mSniperCameraMoveStartChargeRate       number
---@field mSniperCameraMoveEndChargeRate         number
---@field mSniperCameraFovy                      number
---@field mSniperCameraFovy_RTScope              number
---@field mSniperCameraPlayerAlphaChargeRate     number
---@field mSniperCameraPlayerInvisibleChargeRate number
---@field mMinChargeColRadiusForPlayer           number
---@field mMaxChargeColRadiusForPlayer           number
---@field mMinChargeHitSplashNum                 number
---@field mMaxChargeHitSplashNum                 number
---@field mMaxHitSplashNumChargeRate             number

---@class Parameters.Roller
---@field mSwingLiftFrame                    number
---@field mSplashNum                         number
---@field mSplashInitSpeedBase               number
---@field mSplashInitSpeedRandomZ            number
---@field mSplashInitSpeedRandomX            number
---@field mSplashInitVecYRate                number
---@field mSplashDeg                         number
---@field mSplashSubNum                      number
---@field mSplashSubInitSpeedBase            number
---@field mSplashSubInitSpeedRandomZ         number
---@field mSplashSubInitSpeedRandomX         number
---@field mSplashSubInitVecYRate             number
---@field mSplashSubDeg                      number
---@field mSplashPositionWidth               number
---@field mSplashInsideDamageRate            number
---@field mCorePaintWidthHalf                number
---@field mCorePaintSlowMoveWidthHalf        number
---@field mSlowMoveSpeed                     number
---@field mCoreColWidthHalf                  number
---@field mInkConsumeCore                    number
---@field mInkConsumeSplash                  number
---@field mInkRecoverCoreStop                number
---@field mInkRecoverSplashStop              number
---@field mMoveSpeed                         number
---@field mCoreColRadius                     number
---@field mCoreDamage                        number
---@field mTargetEffectScale                 number
---@field mTargetEffectVelRate               number
---@field mSplashStraightFrame               number
---@field mSplashDamageMaxDist               number
---@field mSplashDamageMinDist               number
---@field mSplashDamageMaxValue              number
---@field mSplashDamageMinValue              number
---@field mSplashOutsideDamageMaxDist        number
---@field mSplashOutsideDamageMinDist        number
---@field mSplashOutsideDamageMaxValue       number
---@field mSplashOutsideDamageMinValue       number
---@field mSplashDamageRateBias              number
---@field mSplashDrawRadius                  number
---@field mSplashPaintNearD                  number
---@field mSplashPaintNearR                  number
---@field mSplashPaintFarD                   number
---@field mSplashPaintFarR                   number
---@field mSplashCollisionRadiusForField     number
---@field mSplashCollisionRadiusForPlayer    number
---@field mSplashCoverApertureFreeFrame      number
---@field mSplashSubStraightFrame            number
---@field mSplashSubDamageMaxDist            number
---@field mSplashSubDamageMinDist            number
---@field mSplashSubDamageMaxValue           number
---@field mSplashSubDamageMinValue           number
---@field mSplashSubDamageRateBias           number
---@field mSplashSubDrawRadius               number
---@field mSplashSubPaintNearD               number
---@field mSplashSubPaintNearR               number
---@field mSplashSubPaintFarD                number
---@field mSplashSubPaintFarR                number
---@field mSplashSubCollisionRadiusForField  number
---@field mSplashSubCollisionRadiusForPlayer number
---@field mSplashSubCoverApertureFreeFrame   number
---@field mSplashPaintType                   number
---@field mArmorTypeObjectDamageRate         number
---@field mArmorTypeGachihokoDamageRate      number?
---@field mPaintBrushType                    boolean
---@field mPaintBrushRotYDegree              number
---@field mPaintBrushSwingRepeatFrame        number
---@field mPaintBrushNearestBulletLoopNum    number
---@field mPaintBrushNearestBulletOrderNum   number
---@field mPaintBrushNearestBulletRadius     number
---@field mDropSplashDrawRadius              number
---@field mDropSplashPaintRadius             number

---@class Parameters.Slosher
---@field mSwingLiftFrame                                       number
---@field mSwingRepeatFrame                                     number
---
---@field mFirstGroupBulletNum                                  number
---@field mFirstGroupBulletFirstInitSpeedBase                   number
---@field mFirstGroupBulletFirstInitSpeedJumpingBase            number
---@field mFirstGroupBulletAfterInitSpeedOffset                 number
---@field mFirstGroupBulletInitSpeedRandomZ                     number
---@field mFirstGroupBulletInitSpeedRandomX                     number
---@field mFirstGroupBulletInitVecYRate                         number
---@field mFirstGroupBulletFirstDrawRadius                      number
---@field mFirstGroupBulletAfterDrawRadiusOffset                number
---@field mFirstGroupBulletFirstPaintNearD                      number
---@field mFirstGroupBulletFirstPaintNearR                      number
---@field mFirstGroupBulletFirstPaintNearRate                   number
---@field mFirstGroupBulletFirstPaintFarD                       number
---@field mFirstGroupBulletFirstPaintFarR                       number
---@field mFirstGroupBulletFirstPaintFarRate                    number
---@field mFirstGroupBulletSecondAfterPaintNearD                number
---@field mFirstGroupBulletSecondAfterPaintNearR                number
---@field mFirstGroupBulletSecondAfterPaintNearRate             number
---@field mFirstGroupBulletSecondAfterPaintFarD                 number
---@field mFirstGroupBulletSecondAfterPaintFarR                 number
---@field mFirstGroupBulletSecondAfterPaintFarRate              number
---@field mFirstGroupBulletFirstCollisionRadiusForField         number
---@field mFirstGroupBulletAfterCollisionRadiusForFieldOffset   number
---@field mFirstGroupBulletFirstCollisionRadiusForPlayer        number
---@field mFirstGroupBulletAfterCollisionRadiusForPlayerOffset  number
---@field mFirstGroupBulletFirstDamageMaxValue                  number
---@field mFirstGroupBulletFirstDamageMinValue                  number
---@field mFirstGroupBulletDamageRateBias                       number
---@field mFirstGroupBulletAfterDamageRateOffset                number
---@field mFirstGroupSplashFirstOccur                           boolean
---@field mFirstGroupSplashFromSecondToLastOneOccur             boolean
---@field mFirstGroupSplashLastOccur                            boolean
---@field mFirstGroupSplashMaxNum                               number
---@field mFirstGroupSplashDrawRadius                           number
---@field mFirstGroupSplashColRadius                            number
---@field mFirstGroupSplashPaintRadius                          number
---@field mFirstGroupSplashDepthScaleRateByWidth                number
---@field mFirstGroupSplashBetween                              number
---@field mFirstGroupSplashFirstDropRandomRateMin               number
---@field mFirstGroupSplashFirstDropRandomRateMax               number
---@field mFirstGroupBulletUnuseOneEmitterBulletNum             number
---@field mFirstGroupCenterLine                                 boolean
---@field mFirstGroupSideLine                                   boolean
---
---@field mSecondGroupBulletNum                                 number
---@field mSecondGroupBulletFirstInitSpeedBase                  number
---@field mSecondGroupBulletFirstInitSpeedJumpingBase           number
---@field mSecondGroupBulletAfterInitSpeedOffset                number
---@field mSecondGroupBulletInitSpeedRandomZ                    number
---@field mSecondGroupBulletInitSpeedRandomX                    number
---@field mSecondGroupBulletInitVecYRate                        number
---@field mSecondGroupBulletFirstDrawRadius                     number
---@field mSecondGroupBulletAfterDrawRadiusOffset               number
---@field mSecondGroupBulletFirstPaintNearD                     number
---@field mSecondGroupBulletFirstPaintNearR                     number
---@field mSecondGroupBulletFirstPaintNearRate                  number
---@field mSecondGroupBulletFirstPaintFarD                      number
---@field mSecondGroupBulletFirstPaintFarR                      number
---@field mSecondGroupBulletFirstPaintFarRate                   number
---@field mSecondGroupBulletSecondAfterPaintNearD               number
---@field mSecondGroupBulletSecondAfterPaintNearR               number
---@field mSecondGroupBulletSecondAfterPaintNearRate            number
---@field mSecondGroupBulletSecondAfterPaintFarD                number
---@field mSecondGroupBulletSecondAfterPaintFarR                number
---@field mSecondGroupBulletSecondAfterPaintFarRate             number
---@field mSecondGroupBulletFirstCollisionRadiusForField        number
---@field mSecondGroupBulletAfterCollisionRadiusForFieldOffset  number
---@field mSecondGroupBulletFirstCollisionRadiusForPlayer       number
---@field mSecondGroupBulletAfterCollisionRadiusForPlayerOffset number
---@field mSecondGroupBulletFirstDamageMaxValue                 number
---@field mSecondGroupBulletFirstDamageMinValue                 number
---@field mSecondGroupBulletDamageRateBias                      number
---@field mSecondGroupBulletAfterDamageRateOffset               number
---@field mSecondGroupSplashFirstOccur                          boolean
---@field mSecondGroupSplashFromSecondToLastOneOccur            boolean
---@field mSecondGroupSplashLastOccur                           boolean
---@field mSecondGroupSplashMaxNum                              number
---@field mSecondGroupSplashDrawRadius                          number
---@field mSecondGroupSplashColRadius                           number
---@field mSecondGroupSplashPaintRadius                         number
---@field mSecondGroupSplashDepthScaleRateByWidth               number
---@field mSecondGroupSplashBetween                             number
---@field mSecondGroupSplashFirstDropRandomRateMin              number
---@field mSecondGroupSplashFirstDropRandomRateMax              number
---@field mSecondGroupBulletUnuseOneEmitterBulletNum            number
---@field mSecondGroupCenterLine                                boolean
---@field mSecondGroupSideLine                                  boolean
---
---@field mThirdGroupBulletNum                                  number
---@field mThirdGroupBulletFirstInitSpeedBase                   number
---@field mThirdGroupBulletFirstInitSpeedJumpingBase            number
---@field mThirdGroupBulletAfterInitSpeedOffset                 number
---@field mThirdGroupBulletInitSpeedRandomZ                     number
---@field mThirdGroupBulletInitSpeedRandomX                     number
---@field mThirdGroupBulletInitVecYRate                         number
---@field mThirdGroupBulletFirstDrawRadius                      number
---@field mThirdGroupBulletAfterDrawRadiusOffset                number
---@field mThirdGroupBulletFirstPaintNearD                      number
---@field mThirdGroupBulletFirstPaintNearR                      number
---@field mThirdGroupBulletFirstPaintNearRate                   number
---@field mThirdGroupBulletFirstPaintFarD                       number
---@field mThirdGroupBulletFirstPaintFarR                       number
---@field mThirdGroupBulletFirstPaintFarRate                    number
---@field mThirdGroupBulletSecondAfterPaintNearD                number
---@field mThirdGroupBulletSecondAfterPaintNearR                number
---@field mThirdGroupBulletSecondAfterPaintNearRate             number
---@field mThirdGroupBulletSecondAfterPaintFarD                 number
---@field mThirdGroupBulletSecondAfterPaintFarR                 number
---@field mThirdGroupBulletSecondAfterPaintFarRate              number
---@field mThirdGroupBulletFirstCollisionRadiusForField         number
---@field mThirdGroupBulletAfterCollisionRadiusForFieldOffset   number
---@field mThirdGroupBulletFirstCollisionRadiusForPlayer        number
---@field mThirdGroupBulletAfterCollisionRadiusForPlayerOffset  number
---@field mThirdGroupBulletFirstDamageMaxValue                  number
---@field mThirdGroupBulletFirstDamageMinValue                  number
---@field mThirdGroupBulletDamageRateBias                       number
---@field mThirdGroupBulletAfterDamageRateOffset                number
---@field mThirdGroupSplashFirstOccur                           boolean
---@field mThirdGroupSplashFromSecondToLastOneOccur             boolean
---@field mThirdGroupSplashLastOccur                            boolean
---@field mThirdGroupSplashMaxNum                               number
---@field mThirdGroupSplashDrawRadius                           number
---@field mThirdGroupSplashColRadius                            number
---@field mThirdGroupSplashPaintRadius                          number
---@field mThirdGroupSplashDepthScaleRateByWidth                number
---@field mThirdGroupSplashBetween                              number
---@field mThirdGroupSplashFirstDropRandomRateMin               number
---@field mThirdGroupSplashFirstDropRandomRateMax               number
---@field mThirdGroupBulletUnuseOneEmitterBulletNum             number
---@field mThirdGroupCenterLine                                 boolean
---@field mThirdGroupSideLine                                   boolean
---
---@field mFirstGroupBulletAfterFrameOffset                     number
---@field mSecondGroupBulletFirstFrameOffset                    number
---@field mSecondGroupBulletAfterFrameOffset                    number
---@field mThirdGroupBulletFirstFrameOffset                     number
---@field mThirdGroupBulletAfterFrameOffset                     number
---@field mFrameOffsetMaxMoveLength                             number
---@field mFrameOffsetMaxDegree                                 number
---@field mLineNum                                              number
---@field mLineDegree                                           number
---@field mGuideCenterGroup                                     number
---@field mGuideCenterBulletNumInGroup                          number
---@field mGuideCenterCheckCollisionFrame                       number
---@field mGuideSideGroup                                       number
---@field mGuideSideBulletNumInGroup                            number
---@field mGuideSideCheckCollisionFrame                         number
---@field mShotRandomDegreeExceptBulletForGuide                 number
---@field mShotRandomBiasExceptBulletForGuide                   number
---@field mFreeStateGravity                                     number
---@field mFreeStateAirResist                                   number
---@field mDropSplashDrawRadius                                 number
---@field mDropSplashColRadius                                  number
---@field mDropSplashPaintRadius                                number
---@field mDropSplashPaintRate                                  number
---@field mDropSplashOffsetX                                    number
---@field mDropSplashOffsetZ                                    number
---@field mTailSolidFrame                                       number
---@field mTailMaxLength                                        number
---@field mTailMinLength                                        number
---
---@field mSpiralSplashGroup                                    number
---@field mSpiralSplashBulletNumInGroup                         number
---@field mSpiralSplashInitSpeed                                number
---@field mSpiralSplashSpeedBaseDist                            number
---@field mSpiralSplashSpeedMaxDist                             number
---@field mSpiralSplashSpeedMaxRate                             number
---@field mSpiralSplashLifeFrame                                number
---@field mSpiralSplashMinSpanFrame                             number
---@field mSpiralSplashMinSpanBulletCounter                     number
---@field mSpiralSplashMaxSpanFrame                             number
---@field mSpiralSplashMaxSpanBulletCounter                     number
---@field mSpiralSplashSameTimeBulletNum                        number
---@field mSpiralSplashRoundSplitNum                            number
---@field mSpiralSplashColRadiusForField                        number
---@field mSpiralSplashColRadiusForPlayer                       number
---@field mSpiralSplashMaxDamage                                number
---@field mSpiralSplashMinDamage                                number
---@field mSpiralSplashMaxDamageDist                            number
---@field mSpiralSplashMinDamageDist                            number
---@field mScatterSplashGroup                                   number
---@field mScatterSplashBulletNumInGroup                        number
---@field mScatterSplashInitSpeed                               number
---@field mScatterSplashMinSpanBulletCounter                    number
---@field mScatterSplashMinSpanFrame                            number
---@field mScatterSplashMaxSpanBulletCounter                    number
---@field mScatterSplashMaxSpanFrame                            number
---@field mScatterSplashMaxNum                                  number
---@field mScatterSplashUpDegree                                number
---@field mScatterSplashDownDegree                              number
---@field mScatterSplashDegreeBias                              number
---@field mScatterSplashColRadius                               number
---@field mScatterSplashPaintRadius                             number
---@field mScatterSplashInitPosMinOffset                        number
---@field mScatterSplashInitPosMaxOffset                        number
---
---@field mInkConsume                                           number
---@field mInkRecoverStop                                       number
---@field mMoveSpeed                                            number
---@field mBulletStraightFrame                                  number
---@field mBulletPaintBaseDist                                  number
---@field mBulletPaintMaxDist                                   number
---@field mBulletPaintMaxRate                                   number
---@field mPaintTextureCenterOffsetRate                         number
---@field mBulletDamageMaxDist                                  number
---@field mBulletDamageMinDist                                  number
---@field mBulletCollisionRadiusForPlayerInitRate               number
---@field mBulletCollisionRadiusForPlayerSwellFrame             number
---@field mBulletCollisionPlayerSameTeamNotHitFrame             number
---@field mBulletCollisionRadiusForFieldInitRate                number
---@field mBulletCollisionRadiusForFieldSwellFrame              number
---@field mHitWallSplashOnlyCenter                              boolean
---@field mHitWallSplashFirstLength                             number
---@field mHitWallSplashBetweenLength                           number
---@field mHitWallSplashMinusYRate                              number
---@field mHitWallSplashDistanceRate                            number
---@field mHitPlayerDrapDrawRadius                              number
---@field mHitPlayerDrapCollisionRadius                         number
---@field mHitPlayerDrapPaintRadiusRate                         number
---@field mHitPlayerDrapHitPlayerOffset                         number
---@field mHitPlayerDrapHitObjectOffset                         number
---@field mPostDelayFrm_Main                                    number

---@param initvel       number Initial speed
---@param straightframe number Go straight without gravity for this seconds
---@param guideframe    number
---@param airresist     number
---@return number
function ss.GetRange(initvel, straightframe, guideframe, airresist)
    return ss.GetBulletPos(Vector(initvel), straightframe, airresist, 0, guideframe).x
end

---@param self SplatoonWeaponBase
function ss.SetChargingEye(self)
    local ply = self:GetOwner()
    local mdl = ply:GetModel()
    local skin = ss.ChargingEyeSkin[mdl]
    if skin and ply:GetSkin() ~= skin then
        ply:SetSkin(skin)
    elseif ss.TwilightPlayermodels[mdl] then
        -- Eye animation for Twilight's Octoling playermodel
        local l = ply:GetFlexIDByName "Blink_L"
        local r = ply:GetFlexIDByName "Blink_R"
        if l then ply:SetFlexWeight(l, .3) end
        if r then ply:SetFlexWeight(r, 1) end
    end
end

---@param self SplatoonWeaponBase
function ss.SetNormalEye(self)
    local ply = self:GetOwner()
    local mdl = ply:GetModel()
    local f = ply:GetFlexIDByName "Blink_R"
    local IsTwilightModel = ss.TwilightPlayermodels[mdl]
    local skin = ss.ChargingEyeSkin[mdl]
    if skin and ply:GetSkin() == skin then
        local s = 0
        if self:GetNWInt "playermodel" == ss.PLAYER.NOCHANGE then
            if CLIENT then
                s = GetConVar "cl_playerskin":GetInt()
            else
                s = self.BackupPlayerInfo.Playermodel.Skin
            end
        end

        if ply:GetSkin() == s then return end
        ply:SetSkin(s)
    elseif IsTwilightModel and f and ply:GetFlexWeight(f) == 1 then
        local l = ply:GetFlexIDByName "Blink_L"
        local r = ply:GetFlexIDByName "Blink_R"
        if l then ply:SetFlexWeight(l, 0) end
        if r then ply:SetFlexWeight(r, 0) end
    end
end

---@return Projectile
function ss.MakeProjectileStructure()
    local PRFarD  = 100 * ss.ToHammerUnits
    local PRNearD =  50 * ss.ToHammerUnits
    return { -- Used in ss.AddInk(), describes how a projectile is.
        AirResist = 0,                    -- Air resistance.  Horizontal velocity at next frame = Current horizontal velocity * AirResist
        Color = 1,                        -- Ink color ID
        ColRadiusEntity = 1,              -- Collision radius against entities
        ColRadiusWorld = 1,               -- Collision radius against the world
        DoDamage = true,                  -- Whether or not the ink deals damage
        DamageMax = 0,                    -- Maximum damage
        DamageMaxDistance = 0,            -- Ink travel distance to start decaying damage
        DamageMin = 0,                    -- Minimum damage
        DamageMinDistance = 0,            -- Ink travel distance to end decaying damage
        Gravity = 0,                      -- Gravity acceleration
        ID = CurTime(),                   -- Ink identifier to avoid multiple damages at once
        InitDir = Vector(),               -- (Auto set) Initial direction of velocity
        InitPos = Vector(),               -- Initial position
        InitSpeed = 0,                    -- (Auto set) Initial speed
        InitVel = Vector(),               -- Initial velocity
        IsCritical = false,               -- Whether or not the ink is critical (true to change the hit effect)
        PaintFarDistance = 0,             -- Ink travel distance to end shrinking paint radius
        PaintFarRadius = 0,               -- Painting radius when hit
        PaintFarRatio = 3,                -- Painting aspect ratio at the end
        PaintNearDistance = 0,            -- Ink travel distance to start shrinking paint radius
        PaintNearRadius = 0,              -- Painting radius when hit
        PaintNearRatio = 1,               -- Painting aspect ratio at the beginning
        PaintRatioFarDistance = PRFarD,   -- Ink travel distance to end changing paint aspect ratio
        PaintRatioNearDistance = PRNearD, -- Ink travel distance to start changing paint aspect ratio
        Range = nil,                      -- (For Chargers) Ink travel distance limit
        SplashColRadius = 0,              -- Collision radius against entities/world for splashes created from the ink
        SplashCount = 0,                  -- (Variable) Current number of splashes the ink has dropped so far
        SplashInitRate = 0,               -- Determines the position of the first splash the ink drops = SplashLength * SplashInitRate
        SplashLength = 0,                 -- Length between two splashes from the ink
        SplashNum = 0,                    -- Number of total splashes the ink will drop
        SplashPaintRadius = 0,            -- Painting radius splashes will paint
        SplashRatio = 1,                  -- Painting aspect ratio for splashes
        StraightFrame = 0,                -- The ink travels without affecting gravity for this frames
        Type = 1,                         -- The shape of the paintings
        WallPaintFirstLength = 0,         -- (For Chargers) Determines the position of the first paint for the vertical wall paint
        WallPaintLength = 0,              -- (For Chargers) Length between two paints for the vertical wall paint
        WallPaintMaxNum = 0,              -- (For Chargers) Number of paints for the vertical wall paint
        WallPaintRadius = 0,              -- (For Chargers) Painting radius for the vertical wall paint
        WallPaintUseSplashNum = false,    -- (For Chargers) True to use the rest of splash count (SplashNum - SplashCount) instead of WallPaintMaxNum
        Weapon = NULL,                    -- The weapon entity which created the ink
        Yaw = 0,                          -- Determines the angle of the paintings in degrees
    }
end

---@return ss.InkQueueTrace
function ss.MakeInkQueueTraceStructure()
    return {
        collisiongroup = COLLISION_GROUP_NONE,
        endpos = Vector(),
        filter = NULL,
        LengthSum = 0,
        LifeTime = 0,
        mask = ss.SquidSolidMask,
        maxs = ss.vector_one * 1,
        mins = ss.vector_one * -1,
        start = Vector(),
    }
end

---@return ss.InkQueue
function ss.MakeInkQueueStructure()
    return {
        Data = {},
        InitTime = CurTime(),
        IsCarriedByLocalPlayer = false,
        Parameters = {},
        Trace = ss.MakeInkQueueTraceStructure(),
    }
end

---@param weapon SplatoonWeaponBase
---@param parameters Parameters
function ss.SetPrimary(weapon, parameters)
    local maxink = ss.GetMaxInkAmount()
    ss.ProtectedCall(ss.DefaultParams[weapon.Base], weapon)
    weapon.Primary = {
        Ammo = "Ink",
        Automatic = true,
        ClipSize = maxink,
        DefaultClip = 0,
    }

    table.Merge(weapon.Parameters, parameters or {})
    ss.ConvertUnits(weapon.Parameters, ss.Units)
    ss.ProtectedCall(ss.CustomPrimary[weapon.Base], weapon)
end

ss.DefaultParams = {}
ss.CustomPrimary = {}
---@param weapon SWEP.Shooter
function ss.DefaultParams.weapon_splatoonsweps_shooter(weapon)
    weapon.Parameters = {
        mRepeatFrame = 6, ---The repeat frame
        mTripleShotSpan = 0,
        mInitVel = 22,
        mDegRandom = 6,
        mDegJumpRandom = 15,
        mSplashSplitNum = 5,
        mKnockBack = 0,
        mInkConsume = 0.009,
        mInkRecoverStop = 20,
        mMoveSpeed = 0.72,
        mDamageMax = 0.35,
        mDamageMin = 0.175,
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
        mArmorTypeGachihokoDamageRate = 1,
        mDegBias = 0.25,
        mDegBiasKf = 0.02,
        mDegJumpBias = 0.4,
        mDegJumpBiasFrame = 60,
    }
end

---@param weapon SWEP.Shooter
function ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
    local p = weapon.Parameters
    weapon.NPCDelay = p.mRepeatFrame
    weapon.Primary.Automatic = p.mTripleShotSpan == 0
    weapon.Range = ss.GetRange(p.mInitVel, p.mStraightFrame,
    p.mGuideCheckCollisionFrame, ss.ShooterAirResist)
end

---@param weapon SWEP.Blaster
function ss.DefaultParams.weapon_splatoonsweps_blaster_base(weapon)
    ss.DefaultParams.weapon_splatoonsweps_shooter(weapon)
    table.Merge(weapon.Parameters, {
        mExplosionFrame = 13,
        mExplosionSleep = true,
        mDamageNear = 0.8,
        mCollisionRadiusNear = 10,
        mDamageMiddle = 0.65,
        mCollisionRadiusMiddle = 18,
        mDamageFar = 0.5,
        mCollisionRadiusFar = 37.5,
        mShotCollisionHitDamageRate = 0.5,
        mShotCollisionRadiusRate = 0.5,
        mKnockBackRadius = 37.5,
        mMoveLength = 23.5,
        mSphereSplashDropOn = true,
        mSphereSplashDropInitSpeed = 0,
        mSphereSplashDropCollisionRadius = 4,
        mSphereSplashDropDrawRadius = 6,
        mSphereSplashDropPaintRadius = 34,
        mSphereSplashDropPaintShotCollisionHitRadius = 22,
        mBoundPaintMaxRadius = 25,
        mBoundPaintMinRadius = 20,
        mBoundPaintMinDistanceXZ = 90,
        mWallHitPaintRadius = 20,
        mPreDelayFrm_HumanMain = 10,
        mPreDelayFrm_SquidMain = 15,
        mPostDelayFrm_Main = 30,
    })
end

---@param weapon SWEP.Blaster
function ss.CustomPrimary.weapon_splatoonsweps_blaster_base(weapon)
    ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
end

---@param weapon SWEP.Splatling
function ss.DefaultParams.weapon_splatoonsweps_splatling(weapon)
    ss.DefaultParams.weapon_splatoonsweps_shooter(weapon)
    table.Merge(weapon.Parameters, {
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
end

---@param weapon SWEP.Splatling
function ss.CustomPrimary.weapon_splatoonsweps_splatling(weapon)
    local p = weapon.Parameters
    ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
    weapon.Range = ss.GetRange(p.mInitVelSecondPeriodMaxCharge,
    p.mStraightFrame, p.mGuideCheckCollisionFrame, ss.ShooterAirResist)
end

---@param weapon SWEP.Charger
function ss.DefaultParams.weapon_splatoonsweps_charger(weapon)
    weapon.Parameters = {
        mMinDistance = 90,
        mMaxDistance = 200,
        mMaxDistanceScoped = 200,
        mFullChargeDistance = 260,
        mFullChargeDistanceScoped = 286,
        mMinChargeFrame = 8,
        mMaxChargeFrame = 60,
        mEmptyChargeTimes = 3,
        mFreezeFrmL = 1,
        mInitVelL = 12,
        mFreezeFrmH = 1,
        mInitVelH = 35.29,
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
        mSniperCameraFovy_RTScope = 11,
        mSniperCameraPlayerAlphaChargeRate = 0.5,
        mSniperCameraPlayerInvisibleChargeRate = 0.85,
        mMinChargeColRadiusForPlayer = 1,
        mMaxChargeColRadiusForPlayer = 1,
        mMinChargeHitSplashNum = 0,
        mMaxChargeHitSplashNum = 8,
        mMaxHitSplashNumChargeRate = 0.54,
    }
end

---@param weapon SWEP.Charger
function ss.CustomPrimary.weapon_splatoonsweps_charger(weapon)
    local p = weapon.Parameters
    weapon.Range = weapon.Scoped and p.mFullChargeDistanceScoped or p.mFullChargeDistance
    weapon.NPCDelay = p.mMinChargeFrame
end

---@param weapon SWEP.Roller
function ss.DefaultParams.weapon_splatoonsweps_roller(weapon)
    weapon.Parameters = {
        mSwingLiftFrame = 20,
        mSplashNum = 12,
        mSplashInitSpeedBase = 8.2,
        mSplashInitSpeedRandomZ = 3,
        mSplashInitSpeedRandomX = 0.4,
        mSplashInitVecYRate = 0,
        mSplashDeg = 2.2,
        mSplashSubNum = 0,
        mSplashSubInitSpeedBase = 17.5,
        mSplashSubInitSpeedRandomZ = 3.5,
        mSplashSubInitSpeedRandomX = 0,
        mSplashSubInitVecYRate = 0,
        mSplashSubDeg = 7,
        mSplashPositionWidth = 8,
        mSplashInsideDamageRate = 0.4,
        mCorePaintWidthHalf = 26,
        mCorePaintSlowMoveWidthHalf = 13,
        mSlowMoveSpeed = 0,
        mCoreColWidthHalf = 10,
        mInkConsumeCore = 0.001,
        mInkConsumeSplash = 0.09,
        mInkRecoverCoreStop = 20,
        mInkRecoverSplashStop = 45,
        mMoveSpeed = 1.2,
        mCoreColRadius = 4,
        mCoreDamage = 1.4,
        mTargetEffectScale = 1.5,
        mTargetEffectVelRate = 1.2,
        mSplashStraightFrame = 4,
        mSplashDamageMaxDist = 65,
        mSplashDamageMinDist = 105,
        mSplashDamageMaxValue = 1.25,
        mSplashDamageMinValue = 0.25,
        mSplashOutsideDamageMaxDist = 95,
        mSplashOutsideDamageMinDist = 105,
        mSplashOutsideDamageMaxValue = 0.5,
        mSplashOutsideDamageMinValue = 0.25,
        mSplashDamageRateBias = 1,
        mSplashDrawRadius = 3,
        mSplashPaintNearD = 10,
        mSplashPaintNearR = 20,
        mSplashPaintFarD = 200,
        mSplashPaintFarR = 17,
        mSplashCollisionRadiusForField = 6,
        mSplashCollisionRadiusForPlayer = 8.5,
        mSplashCoverApertureFreeFrame = -1,
        mSplashSubStraightFrame = 4,
        mSplashSubDamageMaxDist = 35,
        mSplashSubDamageMinDist = 90,
        mSplashSubDamageMaxValue = 1.25,
        mSplashSubDamageMinValue = 0.25,
        mSplashSubDamageRateBias = 1,
        mSplashSubDrawRadius = 3,
        mSplashSubPaintNearD = 10,
        mSplashSubPaintNearR = 18,
        mSplashSubPaintFarD = 200,
        mSplashSubPaintFarR = 15,
        mSplashSubCollisionRadiusForField = 9,
        mSplashSubCollisionRadiusForPlayer = 9,
        mSplashSubCoverApertureFreeFrame = -1,
        mSplashPaintType = 1,
        mArmorTypeObjectDamageRate = 0.4,
        mArmorTypeGachihokoDamageRate = 0.3,
        mPaintBrushType = false,
        mPaintBrushRotYDegree = 0,
        mPaintBrushSwingRepeatFrame = 6,
        mPaintBrushNearestBulletLoopNum = 6,
        mPaintBrushNearestBulletOrderNum = 2,
        mPaintBrushNearestBulletRadius = 20,
        mDropSplashDrawRadius = 0.5,
        mDropSplashPaintRadius = 0,
    }
end

---@param weapon SWEP.Roller
function ss.CustomPrimary.weapon_splatoonsweps_roller(weapon)
    local p = weapon.Parameters
    weapon.Primary.Automatic = false
    weapon.NPCDelay = p.mSwingLiftFrame
    weapon.Range = ss.GetRange(p.mSplashInitSpeedBase,
    p.mSplashStraightFrame, p.mSplashStraightFrame * 1.5, ss.RollerAirResist)
end

---@param weapon SWEP.Slosher
function ss.DefaultParams.weapon_splatoonsweps_slosher_base(weapon)
    weapon.Parameters = {
        mSwingLiftFrame = 15,
        mSwingRepeatFrame = 30,
        mFirstGroupBulletNum = 0,
        mFirstGroupBulletFirstInitSpeedBase = 12,
        mFirstGroupBulletFirstInitSpeedJumpingBase = 10,
        mFirstGroupBulletAfterInitSpeedOffset = 4,
        mFirstGroupBulletInitSpeedRandomZ = 0,
        mFirstGroupBulletInitSpeedRandomX = 0,
        mFirstGroupBulletInitVecYRate = 0.1,
        mFirstGroupBulletFirstDrawRadius = 12,
        mFirstGroupBulletAfterDrawRadiusOffset = 4,
        mFirstGroupBulletFirstPaintNearD = 50,
        mFirstGroupBulletFirstPaintNearR = 13,
        mFirstGroupBulletFirstPaintNearRate = 1.2,
        mFirstGroupBulletFirstPaintFarD = 150,
        mFirstGroupBulletFirstPaintFarR = 13,
        mFirstGroupBulletFirstPaintFarRate = 1.2,
        mFirstGroupBulletSecondAfterPaintNearD = 50,
        mFirstGroupBulletSecondAfterPaintNearR = 19,
        mFirstGroupBulletSecondAfterPaintNearRate = 1,
        mFirstGroupBulletSecondAfterPaintFarD = 150,
        mFirstGroupBulletSecondAfterPaintFarR = 19,
        mFirstGroupBulletSecondAfterPaintFarRate = 1,
        mFirstGroupBulletFirstCollisionRadiusForField = 5,
        mFirstGroupBulletAfterCollisionRadiusForFieldOffset = 1,
        mFirstGroupBulletFirstCollisionRadiusForPlayer = 7,
        mFirstGroupBulletAfterCollisionRadiusForPlayerOffset = 1,
        mFirstGroupBulletFirstDamageMaxValue = 0.7,
        mFirstGroupBulletFirstDamageMinValue = 0.3,
        mFirstGroupBulletDamageRateBias = 1,
        mFirstGroupBulletAfterDamageRateOffset = 0,
        mFirstGroupSplashFirstOccur = false,
        mFirstGroupSplashFromSecondToLastOneOccur = false,
        mFirstGroupSplashLastOccur = false,
        mFirstGroupSplashMaxNum = 0,
        mFirstGroupSplashDrawRadius = 3,
        mFirstGroupSplashColRadius = 1.5,
        mFirstGroupSplashPaintRadius = 9,
        mFirstGroupSplashDepthScaleRateByWidth = 2,
        mFirstGroupSplashBetween = 25,
        mFirstGroupSplashFirstDropRandomRateMin = 0.5,
        mFirstGroupSplashFirstDropRandomRateMax = 0.55,
        mFirstGroupBulletUnuseOneEmitterBulletNum = 0,
        mFirstGroupCenterLine = true,
        mFirstGroupSideLine = false,

        mSecondGroupBulletNum = 0,
        mSecondGroupBulletFirstInitSpeedBase = 18,
        mSecondGroupBulletFirstInitSpeedJumpingBase = 16,
        mSecondGroupBulletAfterInitSpeedOffset = -3.5,
        mSecondGroupBulletInitSpeedRandomZ = 0,
        mSecondGroupBulletInitSpeedRandomX = 0,
        mSecondGroupBulletInitVecYRate = 0.1,
        mSecondGroupBulletFirstDrawRadius = 21,
        mSecondGroupBulletAfterDrawRadiusOffset = -6.5,
        mSecondGroupBulletFirstPaintNearD = 50,
        mSecondGroupBulletFirstPaintNearR = 37,
        mSecondGroupBulletFirstPaintNearRate = 1,
        mSecondGroupBulletFirstPaintFarD = 150,
        mSecondGroupBulletFirstPaintFarR = 32,
        mSecondGroupBulletFirstPaintFarRate = 1,
        mSecondGroupBulletSecondAfterPaintNearD = 85,
        mSecondGroupBulletSecondAfterPaintNearR = 12,
        mSecondGroupBulletSecondAfterPaintNearRate = 1.3,
        mSecondGroupBulletSecondAfterPaintFarD = 120,
        mSecondGroupBulletSecondAfterPaintFarR = 16,
        mSecondGroupBulletSecondAfterPaintFarRate = 1.2,
        mSecondGroupBulletFirstCollisionRadiusForField = 8,
        mSecondGroupBulletAfterCollisionRadiusForFieldOffset = -2,
        mSecondGroupBulletFirstCollisionRadiusForPlayer = 10,
        mSecondGroupBulletAfterCollisionRadiusForPlayerOffset = -2,
        mSecondGroupBulletFirstDamageMaxValue = 0.7,
        mSecondGroupBulletFirstDamageMinValue = 0.3,
        mSecondGroupBulletDamageRateBias = 1,
        mSecondGroupBulletAfterDamageRateOffset = 0,
        mSecondGroupSplashFirstOccur = true,
        mSecondGroupSplashFromSecondToLastOneOccur = false,
        mSecondGroupSplashLastOccur = false,
        mSecondGroupSplashMaxNum = 4,
        mSecondGroupSplashDrawRadius = 3,
        mSecondGroupSplashColRadius = 1.5,
        mSecondGroupSplashPaintRadius = 0,
        mSecondGroupSplashDepthScaleRateByWidth = 1,
        mSecondGroupSplashBetween = 1000,
        mSecondGroupSplashFirstDropRandomRateMin = 1,
        mSecondGroupSplashFirstDropRandomRateMax = 1,
        mSecondGroupBulletUnuseOneEmitterBulletNum = 1,
        mSecondGroupCenterLine = true,
        mSecondGroupSideLine = false,

        mThirdGroupBulletNum = 0,
        mThirdGroupBulletFirstInitSpeedBase = 9,
        mThirdGroupBulletFirstInitSpeedJumpingBase = 8.5,
        mThirdGroupBulletAfterInitSpeedOffset = -2,
        mThirdGroupBulletInitSpeedRandomZ = 0,
        mThirdGroupBulletInitSpeedRandomX = 0,
        mThirdGroupBulletInitVecYRate = 0.1,
        mThirdGroupBulletFirstDrawRadius = 6,
        mThirdGroupBulletAfterDrawRadiusOffset = -1,
        mThirdGroupBulletFirstPaintNearD = 20,
        mThirdGroupBulletFirstPaintNearR = 10,
        mThirdGroupBulletFirstPaintNearRate = 1.4,
        mThirdGroupBulletFirstPaintFarD = 80,
        mThirdGroupBulletFirstPaintFarR = 10,
        mThirdGroupBulletFirstPaintFarRate = 1.4,
        mThirdGroupBulletSecondAfterPaintNearD = 20,
        mThirdGroupBulletSecondAfterPaintNearR = 8,
        mThirdGroupBulletSecondAfterPaintNearRate = 1.4,
        mThirdGroupBulletSecondAfterPaintFarD = 80,
        mThirdGroupBulletSecondAfterPaintFarR = 9.5,
        mThirdGroupBulletSecondAfterPaintFarRate = 1.4,
        mThirdGroupBulletFirstCollisionRadiusForField = 4,
        mThirdGroupBulletAfterCollisionRadiusForFieldOffset = -1,
        mThirdGroupBulletFirstCollisionRadiusForPlayer = 6,
        mThirdGroupBulletAfterCollisionRadiusForPlayerOffset = -1,
        mThirdGroupBulletFirstDamageMaxValue = 0.4,
        mThirdGroupBulletFirstDamageMinValue = 0.2,
        mThirdGroupBulletDamageRateBias = 1,
        mThirdGroupBulletAfterDamageRateOffset = 0,
        mThirdGroupSplashFirstOccur = false,
        mThirdGroupSplashFromSecondToLastOneOccur = false,
        mThirdGroupSplashLastOccur = true,
        mThirdGroupSplashMaxNum = 2,
        mThirdGroupSplashDrawRadius = 3,
        mThirdGroupSplashColRadius = 1.5,
        mThirdGroupSplashPaintRadius = 7,
        mThirdGroupSplashDepthScaleRateByWidth = 2,
        mThirdGroupSplashBetween = 15,
        mThirdGroupSplashFirstDropRandomRateMin = 0,
        mThirdGroupSplashFirstDropRandomRateMax = 0.3,
        mThirdGroupBulletUnuseOneEmitterBulletNum = 0,
        mThirdGroupCenterLine = true,
        mThirdGroupSideLine = false,

        mFirstGroupBulletAfterFrameOffset = 0,
        mSecondGroupBulletFirstFrameOffset = 0,
        mSecondGroupBulletAfterFrameOffset = 0,
        mThirdGroupBulletFirstFrameOffset = 0,
        mThirdGroupBulletAfterFrameOffset = 0,

        mFrameOffsetMaxMoveLength = 30,
        mFrameOffsetMaxDegree = 10,
        mLineNum = 1,
        mLineDegree = 0,
        mGuideCenterGroup = 2,
        mGuideCenterBulletNumInGroup = 1,
        mGuideCenterCheckCollisionFrame = 12,
        mGuideSideGroup = 1,
        mGuideSideBulletNumInGroup = 1,
        mGuideSideCheckCollisionFrame = 8,
        mShotRandomDegreeExceptBulletForGuide = 4.5,
        mShotRandomBiasExceptBulletForGuide = 0.4,

        mFreeStateGravity = 0.5,
        mFreeStateAirResist = 0.12,

        mDropSplashDrawRadius = 2,
        mDropSplashColRadius = 2,
        mDropSplashPaintRadius = 0,
        mDropSplashPaintRate = 3,
        mDropSplashOffsetX = 3,
        mDropSplashOffsetZ = -7,
        mTailSolidFrame = 5,
        mTailMaxLength = 40,
        mTailMinLength = 5,

        mSpiralSplashGroup = 0,
        mSpiralSplashBulletNumInGroup = 1,
        mSpiralSplashInitSpeed = 5,
        mSpiralSplashSpeedBaseDist = -15,
        mSpiralSplashSpeedMaxDist = -85,
        mSpiralSplashSpeedMaxRate = 1,
        mSpiralSplashLifeFrame = 7,
        mSpiralSplashMinSpanFrame = 1,
        mSpiralSplashMinSpanBulletCounter = 40,
        mSpiralSplashMaxSpanFrame = 1,
        mSpiralSplashMaxSpanBulletCounter = 1,
        mSpiralSplashSameTimeBulletNum = 2,
        mSpiralSplashRoundSplitNum = 8,
        mSpiralSplashColRadiusForField = 3,
        mSpiralSplashColRadiusForPlayer = 3,
        mSpiralSplashMaxDamage = 0.6,
        mSpiralSplashMinDamage = 0.2,
        mSpiralSplashMaxDamageDist = 10,
        mSpiralSplashMinDamageDist = 40,

        mScatterSplashGroup = 0,
        mScatterSplashBulletNumInGroup = 1,
        mScatterSplashInitSpeed = 5,
        mScatterSplashMinSpanBulletCounter = 1,
        mScatterSplashMinSpanFrame = 1,
        mScatterSplashMaxSpanBulletCounter = 1,
        mScatterSplashMaxSpanFrame = 2,
        mScatterSplashMaxNum = 25,
        mScatterSplashUpDegree = 60,
        mScatterSplashDownDegree = 70,
        mScatterSplashDegreeBias = 0.5,
        mScatterSplashColRadius = 3,
        mScatterSplashPaintRadius = 6,
        mScatterSplashInitPosMinOffset = 2,
        mScatterSplashInitPosMaxOffset = 15,

        mInkConsume = 0.07,
        mInkRecoverStop = 40,
        mMoveSpeed = 0.5,
        mBulletStraightFrame = 2,
        mBulletPaintBaseDist = -15,
        mBulletPaintMaxDist = -85,
        mBulletPaintMaxRate = 0.8,
        mPaintTextureCenterOffsetRate = 0,
        mBulletDamageMaxDist = -15,
        mBulletDamageMinDist = -85,
        mBulletCollisionRadiusForPlayerInitRate = 0.1,
        mBulletCollisionRadiusForPlayerSwellFrame = 5,
        mBulletCollisionPlayerSameTeamNotHitFrame = 2,
        mBulletCollisionRadiusForFieldInitRate = 0.1,
        mBulletCollisionRadiusForFieldSwellFrame = 4,
        mHitWallSplashOnlyCenter = true,
        mHitWallSplashFirstLength = 24,
        mHitWallSplashBetweenLength = 13,
        mHitWallSplashMinusYRate = 0.45,
        mHitWallSplashDistanceRate = 1.3333,

        mHitPlayerDrapDrawRadius = 6,
        mHitPlayerDrapCollisionRadius = 4,
        mHitPlayerDrapPaintRadiusRate = 0,
        mHitPlayerDrapHitPlayerOffset = 10,
        mHitPlayerDrapHitObjectOffset = 0,
        mPostDelayFrm_Main = 5,
    }
end

---@param weapon SWEP.Slosher
function ss.CustomPrimary.weapon_splatoonsweps_slosher_base(weapon)
    local p = weapon.Parameters
    local number = p.mGuideCenterGroup
    local spawncount = p.mGuideCenterBulletNumInGroup
    local base = ({
        p.mFirstGroupBulletFirstInitSpeedBase,
        p.mSecondGroupBulletFirstInitSpeedBase,
        p.mThirdGroupBulletFirstInitSpeedBase,
    })[number]
    local offset = ({
        p.mFirstGroupBulletAfterInitSpeedOffset,
        p.mSecondGroupBulletAfterInitSpeedOffset,
        p.mThirdGroupBulletAfterInitSpeedOffset,
    })[number]
    local initvel = base + spawncount * offset
    weapon.Primary.Automatic = false
    weapon.NPCDelay = p.mSwingLiftFrame
    weapon.Range = ss.GetRange(initvel, p.mBulletStraightFrame,
    p.mGuideCenterCheckCollisionFrame, p.mFreeStateAirResist)
end

---event = 5xyy, x = option index, yy = effect type
--- - yy = 0 : SplatoonSWEPsMuzzleSplash
---   - x = 0 : Attach to muzzle
---   - x = 1 : Go backward (for charger)
--- - yy = 1 : SplatoonSWEPsMuzzleRing
--- - yy = 2 : SplatoonSWEPsMuzzleMist
--- - yy = 3 : SplatoonSWEPsMuzzleFlash
--- - yy = 4 : SplatoonSWEPsRollerSplash
--- - yy = 5 : SplatoonSWEPsBrushSwing1
--- - yy = 6 : SplatoonSWEPsBrushSwing2
--- - yy = 7 : SplatoonSWEPsSlosherSplash
---@param self SplatoonWeaponBase|ENT.Sprinkler
---@param pos Vector
---@param ang Angle
---@param event integer
---@param options string
---@return boolean
function ss.FireAnimationEvent(self, pos, ang, event, options)
    if 5000 <= event and event < 6000 then
        event = event - 5000
        local vararg = options:Split " "
        ss.tablepush(vararg, math.floor(event / 100))
        ss.ProtectedCall(ss.DispatchEffect[event % 100], self, vararg, pos, ang)
    end

    return true
end

---@type (fun(self: SplatoonWeaponBase, options: table, pos: Vector, ang: Angle))[]
ss.DispatchEffect = {}
local SplatoonSWEPsMuzzleSplash = 0
local SplatoonSWEPsMuzzleRing = 1
local SplatoonSWEPsMuzzleMist = 2
local SplatoonSWEPsMuzzleFlash = 3
local SplatoonSWEPsRollerSplash = 4
local SplatoonSWEPsBrushSwing1 = 5
local SplatoonSWEPsBrushSwing2 = 6
local SplatoonSWEPsSlosherSplash = 7
local sd, e = ss.DispatchEffect, EffectData()
sd[SplatoonSWEPsMuzzleSplash] = function(self, options, pos, ang)
    local tpslag = 0
    if self.IsSplatoonWeapon and self:IsCarriedByLocalPlayer()
    and self:GetOwner() --[[@as Player]]:ShouldDrawLocalPlayer() then
        tpslag = 128
    end

    local attachment = options[2] or "muzzle"
    local attindex = self:LookupAttachment(attachment)
    if attindex <= 0 then attindex = 1 end

    ang = angle_zero
    local a, s, r = 7, 2, 25
    if options[2] == "CHARGER" then ---@cast self SWEP.Charger
        attindex = self:LookupAttachment "muzzle"
        r, s = Lerp(self:GetFireAt(), 20, 60) / 2, 6
        if options[1] == 1 then
            if self:GetFireAt() < .3 then return end
            ang = -Angle(150)
        end
    end

    e:SetAngles(ang) -- Angle difference
    e:SetAttachment(a) -- Effect duration
    e:SetColor(self:GetNWInt "inkcolor") -- Splash color
    e:SetEntity(self) -- Enitity attach to
    e:SetFlags(tpslag + attindex - 1) -- Splash mode
    e:SetScale(s) -- Splash length
    e:SetRadius(r) -- Splash radius
    util.Effect("SplatoonSWEPsMuzzleSplash", e, true, self.IgnorePrediction)
end

sd[SplatoonSWEPsMuzzleRing] = function(self, options, pos, ang)
    local numpieces = options[1] ---@type integer
    local da, r1, r2, t1, t2 = math.Rand(0, 360), 40, 30, 6, 13
    local tpslag = self:IsCarriedByLocalPlayer() and
    self:GetOwner() --[[@as Player]]:ShouldDrawLocalPlayer() and 128 or 0
    e:SetColor(self:GetNWInt "inkcolor")
    e:SetEntity(self)

    if options[2] == "CHARGER" then ---@cast self SWEP.Charger
        r2 = Lerp(self:GetFireAt(), 20, 70)
        r1 = r2 * 2
        t2 = Lerp(self:GetFireAt(), 3, 7)
        t1 = t2 * .75
        if self:GetFireAt() < .3 then numpieces = numpieces - 1 end
    end

    for i = 0, 4 do
        e:SetAttachment(t1) -- Effect duration[frames]
        e:SetFlags(tpslag + 1) -- 1: Refract effect
        e:SetRadius(r1) -- Effect scale
        e:SetScale(i * 72 + da) -- Initial rotation
        util.Effect("SplatoonSWEPsMuzzleRing", e, true, self.IgnorePrediction)
        if i <= numpieces then
            e:SetAttachment(t2)
            e:SetFlags(tpslag) -- 0: Splash effect
            e:SetRadius(r2)
            util.Effect("SplatoonSWEPsMuzzleRing", e, true, self.IgnorePrediction)
        end
    end
end

sd[SplatoonSWEPsMuzzleMist] = function(self, options, pos, ang)
    if not self.IsShooter then return end ---@cast self SWEP.Shooter
    local mdl = self:IsTPS() and self or self:GetViewModel()
    local dir = ang:Right()
    if not self:IsTPS() then
        if self:GetNWBool "lefthand" then dir = -dir end
        if self:GetADS() then dir = ang:Forward() end
    end

    pos, ang = self:GetMuzzlePosition()
    e:SetAttachment(self:LookupAttachment "muzzle")
    e:SetColor(self:GetNWInt "inkcolor")
    e:SetEntity(mdl)
    e:SetFlags(PATTACH_POINT_FOLLOW)
    e:SetOrigin(vector_origin)
    e:SetScale(self:IsTPS() and 6 or 3)
    e:SetStart(self:TranslateToViewmodelPos(pos) + dir * 100)
    util.Effect("SplatoonSWEPsMuzzleMist", e, true, self.IgnorePrediction)
end

sd[SplatoonSWEPsMuzzleFlash] = function(self, options, pos, ang)
    e:SetEntity(self)
    e:SetFlags(1)
    util.Effect("SplatoonSWEPsMuzzleFlash", e, true, self.IgnorePrediction)
end

sd[SplatoonSWEPsRollerSplash] = function(self, options, pos, ang)
    e:SetEntity(self)
    e:SetFlags(0)
    util.Effect("SplatoonSWEPsRollerSplash", e, true, self.IgnorePrediction)

    local color = self:GetNWInt "inkcolor"
    e:SetAttachment(4)
    e:SetColor(color)
    e:SetFlags(2) -- 2: Roller's setup, don't follow the muzzle position
    e:SetRadius(50)
    for i = -3, 3 do
        e:SetScale(10 * i) -- Roller's setup, initial position offset
        util.Effect("SplatoonSWEPsMuzzleRing", e, true, self.IgnorePrediction)
    end
end

---@param self SplatoonWeaponBase
---@param sign integer
local function MakeSwingEffect(self, sign)
    local color = self:GetNWInt "inkcolor"
    sign = self:GetNWBool "lefthand" and -sign or sign
    e:SetEntity(self)
    e:SetAttachment(18)
    e:SetColor(color)
    e:SetFlags(4) -- 4: Brush's setup
    e:SetRadius(75)
    e:SetScale(sign)
    util.Effect("SplatoonSWEPsMuzzleRing", e, true, self.IgnorePrediction)
    e:SetFlags(1) -- Particle effects for brushes
    util.Effect("SplatoonSWEPsRollerSplash", e, true, self.IgnorePrediction)
end

sd[SplatoonSWEPsBrushSwing1] = function(self, options, pos, ang)
    MakeSwingEffect(self, 1)
end

sd[SplatoonSWEPsBrushSwing2] = function(self, options, pos, ang)
    MakeSwingEffect(self, -1)
end

sd[SplatoonSWEPsSlosherSplash] = function(self, options, pos, ang)
    e:SetEntity(self)
    e:SetFlags(2) -- Particle effects for sloshers
    util.Effect("SplatoonSWEPsRollerSplash", e, true, self.IgnorePrediction)
end
