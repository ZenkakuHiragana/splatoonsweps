
-- Functions for weapon settings.

local ss = SplatoonSWEPs
if not ss then return end

function ss.GetRange(initvel, straightframe, guideframe, airresist)
    return ss.GetBulletPos(Vector(initvel), straightframe, airresist, 0, guideframe).x
end

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

function ss.MakeInkQueueStructure()
    return {
        Data = {},
        InitTime = CurTime(),
        IsCarriedByLocalPlayer = false,
        Parameters = {},
        Trace = ss.MakeInkQueueTraceStructure(),
    }
end

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
function ss.DefaultParams.weapon_splatoonsweps_shooter(weapon)
    weapon.Parameters = {
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

function ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
    local p = weapon.Parameters
    weapon.NPCDelay = p.mRepeatFrame
    weapon.Primary.Automatic = p.mTripleShotSpan == 0
    weapon.Range = ss.GetRange(p.mInitVel, p.mStraightFrame,
    p.mGuideCheckCollisionFrame, ss.ShooterAirResist)
end

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

function ss.CustomPrimary.weapon_splatoonsweps_blaster_base(weapon)
    ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
end

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

function ss.CustomPrimary.weapon_splatoonsweps_splatling(weapon)
    local p = weapon.Parameters
    ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
    weapon.Range = ss.GetRange(p.mInitVelSecondPeriodMaxCharge,
    p.mStraightFrame, p.mGuideCheckCollisionFrame, ss.ShooterAirResist)
end

function ss.DefaultParams.weapon_splatoonsweps_charger(weapon)
    ss.DefaultParams.weapon_splatoonsweps_shooter(weapon)
    table.Merge(weapon.Parameters, {
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
        mSniperCameraPlayerAlphaChargeRate = 0.5,
        mSniperCameraPlayerInvisibleChargeRate = 0.85,
        mMinChargeColRadiusForPlayer = 1,
        mMaxChargeColRadiusForPlayer = 1,
        mMinChargeHitSplashNum = 0,
        mMaxChargeHitSplashNum = 8,
        mMaxHitSplashNumChargeRate = 0.54,
    })
end

function ss.CustomPrimary.weapon_splatoonsweps_charger(weapon)
    local p = weapon.Parameters
    ss.CustomPrimary.weapon_splatoonsweps_shooter(weapon)
    weapon.Range = weapon.Scoped and p.mFullChargeDistanceScoped or p.mFullChargeDistance
    weapon.NPCDelay = p.mMinChargeFrame
end

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

function ss.CustomPrimary.weapon_splatoonsweps_roller(weapon)
    local p = weapon.Parameters
    weapon.Primary.Automatic = false
    weapon.NPCDelay = p.mSwingLiftFrame
    weapon.Range = ss.GetRange(p.mSplashInitSpeedBase,
    p.mSplashStraightFrame, p.mSplashStraightFrame * 1.5, ss.RollerAirResist)
end

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

function ss.CustomPrimary.weapon_splatoonsweps_slosher_base(weapon)
    local p = weapon.Parameters
    local number = p.mGuideCenterGroup
    local order = ({"First", "Second", "Third"})[number]
    local spawncount = p.mGuideCenterBulletNumInGroup
    local base = p["m" .. order .. "GroupBulletFirstInitSpeedBase"]
    local initvel = base + spawncount * p["m" .. order .. "GroupBulletAfterInitSpeedOffset"]
    weapon.Primary.Automatic = false
    weapon.NPCDelay = p.mSwingLiftFrame
    weapon.Range = ss.GetRange(initvel, p.mBulletStraightFrame,
    p.mGuideCenterCheckCollisionFrame, p.mFreeStateAirResist)
end

-- event = 5xyy, x = option index, yy = effect type
-- yy = 0 : SplatoonSWEPsMuzzleSplash
--     x = 0 : Attach to muzzle
--     x = 1 : Go backward (for charger)
-- yy = 1 : SplatoonSWEPsMuzzleRing
-- yy = 2 : SplatoonSWEPsMuzzleMist
-- yy = 3 : SplatoonSWEPsMuzzleFlash
-- yy = 4 : SplatoonSWEPsRollerSplash
-- yy = 5 : SplatoonSWEPsBrushSwing1
-- yy = 6 : SplatoonSWEPsBrushSwing2
-- yy = 7 : SplatoonSWEPsSlosherSplash
function ss.FireAnimationEvent(self, pos, ang, event, options)
    if 5000 <= event and event < 6000 then
        event = event - 5000
        local vararg = options:Split " "
        ss.tablepush(vararg, math.floor(event / 100))
        ss.ProtectedCall(ss.DispatchEffect[event % 100], self, vararg, pos, ang)
    end

    return true
end

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
    if self.IsSplatoonWeapon and self:IsCarriedByLocalPlayer() and self:GetOwner():ShouldDrawLocalPlayer() then
        tpslag = 128
    end

    local attachment = options[2] or "muzzle"
    local attindex = self:LookupAttachment(attachment)
    if attindex <= 0 then attindex = 1 end

    ang = angle_zero
    local a, s, r = 7, 2, 25
    if options[2] == "CHARGER" then
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
    local numpieces = options[1]
    local da, r1, r2, t1, t2 = math.Rand(0, 360), 40, 30, 6, 13
    local tpslag = self:IsCarriedByLocalPlayer() and
    self:GetOwner():ShouldDrawLocalPlayer() and 128 or 0
    e:SetColor(self:GetNWInt "inkcolor")
    e:SetEntity(self)

    if options[2] == "CHARGER" then
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
