
local ss = SplatoonSWEPs
if not ss then return end
SWEP.Base = "weapon_splatoonsweps_shooter"
SWEP.IsCharger = true
SWEP.FlashDuration = .25
SWEP.DelayAfterShot = 7 * ss.FrameToSec -- Hotfix: Chargers can shoot too often

function SWEP:GetColRadius(prog)
    prog = prog or self:GetChargeProgress(CLIENT)
    return Lerp(prog,
        self.Parameters.mMinChargeColRadiusForPlayer,
        self.Parameters.mMaxChargeColRadiusForPlayer)
end

function SWEP:GetDamage(ping)
    local prog
    if not ping or isbool(ping) then
        prog = self:GetChargeProgress(ping)
    else
        prog = ping
    end
    return ss.Lerp3(prog,
        self.Parameters.mMinChargeDamage,
        self.Parameters.mMaxChargeDamage,
        self.Parameters.mFullChargeDamage)
end

function SWEP:GetRange(ping)
    local prog
    if not ping or isbool(ping) then
        prog = self:GetChargeProgress(ping)
    else
        prog = ping
    end
    if self.Scoped then
        return ss.Lerp3(prog,
            self.Parameters.mMinDistance,
            self.Parameters.mMaxDistanceScoped,
            self.Parameters.mFullChargeDistanceScoped)
    else
        return ss.Lerp3(prog,
            self.Parameters.mMinDistance,
            self.Parameters.mMaxDistance,
            self.Parameters.mFullChargeDistance)
    end
end

function SWEP:GetInkVelocity(prog)
    prog = prog or self:GetChargeProgress()
    return ss.Lerp3(prog,
        self.Parameters.mInitVelL,
        self.Parameters.mInitVelH,
        self.Parameters.mInitVelF)
end

function SWEP:GetChargeProgress(ping)
    local p = self.Parameters
    local max = p.mMaxChargeFrame
    local min = p.mMinChargeFrame
    local dt = CurTime() - self:GetCharge() - min -- Time difference ranges from -min to (max - min)
    if ping then dt = dt + self:Ping() end
    return math.Clamp(dt / (max - min), 0, 1)
end

function SWEP:GetScopedProgress(ping)
    if not self.Scoped then return 0 end
    if CLIENT and GetViewEntity() ~= self:GetOwner() then return 0 end
    local prog = self:GetChargeProgress(ping)
    local p = self.Parameters
    local startmove = p.mSniperCameraMoveStartChargeRate
    local endmove = p.mSniperCameraMoveEndChargeRate
    if prog < startmove then return 0 end
    return math.Clamp((prog - startmove) / (endmove - startmove), 0, 1)
end

function SWEP:ResetCharge()
    self:SetCharge(math.huge)
    self.FullChargeFlag = false
    self.NotEnoughInk = false
    self.JumpPower = ss.InklingJumpPower
    if ss.mp and SERVER then return end
    if not self.LoopSounds.AimSound.SoundPatch then return end
    self.LoopSounds.AimSound.SoundPatch:Stop()
    self.LoopSounds.AimSound.SoundPatch:ChangePitch(1)
end

SWEP.SharedDeploy = SWEP.ResetCharge
SWEP.SharedHolster = SWEP.ResetCharge
function SWEP:PlayChargeSound()
    if ss.mp and (SERVER or not IsFirstTimePredicted()) then return end
    local prog = self:GetChargeProgress()
    if not (ss.sp and SERVER and not self:GetOwner():IsPlayer()) and 0 < prog and prog < 1 then
        local currentpitch = self.LoopSounds.AimSound.SoundPatch:GetPitch()
        local desiredpitch = prog * 99 + 1
        local minimumpitch = math.ceil(1 / ss.GetTimeScale())
        local pitch = math.max(currentpitch, desiredpitch, minimumpitch)
        self.LoopSounds.AimSound.SoundPatch:PlayEx(1, pitch)
    else
        self.LoopSounds.AimSound.SoundPatch:Stop()
        self.LoopSounds.AimSound.SoundPatch:ChangePitch(1)
    end
end

function SWEP:ShouldChargeWeapon()
    if self:GetOwner():IsPlayer() then
        return self:GetOwner():KeyDown(IN_ATTACK)
    else
        return CurTime() - self:GetCharge() < self.Parameters.mMaxChargeFrame * 2
    end
end

function SWEP:SharedInit()
    local p = self.Parameters
    self.LoopSounds.AimSound = {SoundName = ss.ChargerAim}
    self.AirTimeFraction = 1 - 1 / p.mEmptyChargeTimes
    self:SetAimTimer(CurTime())
    self:ResetCharge()
    self:AddSchedule(0, function()
        local prog = self:GetChargeProgress()
        if prog == 1 and not self.FullChargeFlag then
            if CLIENT then
                self.CrosshairFlashTime = CurTime() - self:Ping()
                ss.EmitSound(self:GetOwner(), ss.ChargerBeep)
            end

            self.FullChargeFlag = true
            if self.Scoped and self:IsMine() and not (CLIENT and self:IsTPS() and self:GetNWBool "usertscope") then return end
            local e = EffectData()
            e:SetEntity(self)
            e:SetFlags(0)
            ss.UtilEffectPredicted(self:GetOwner(), "SplatoonSWEPsMuzzleFlash", e)
            return
        end

        self.FullChargeFlag = prog == 1
    end)

    table.Merge(self.Projectile, {
        AirResist = 1,
        Gravity = ss.InkDropGravity,
        SplashColRadius = p.mSplashColRadius,
    })
end

function SWEP:SharedPrimaryAttack()
    local p = self.Parameters
    if not IsValid(self:GetOwner()) then return end

    self:SetReloadDelay(p.mInkRecoverStop)
    if self:GetCharge() < math.huge then -- Hold +attack to charge
        local prog = self:GetChargeProgress()
        self:SetAimTimer(CurTime() + ss.AimDuration)
        self.JumpPower = Lerp(prog, ss.InklingJumpPower, p.mJumpGnd)
        if prog > 0 then
            local EnoughInk = self:GetInk() >= prog * p.mInkConsume
            if not self:GetOwner():OnGround() or not EnoughInk then
                if EnoughInk or self:GetNWBool "canreloadstand" then
                    self:SetCharge(self:GetCharge() + FrameTime() * self.AirTimeFraction)
                else
                    local ts = ss.GetTimeScale(self:GetOwner())
                    local elapsed = prog * p.mMaxChargeFrame / ts
                    local min = p.mMinChargeFrame / ts
                    self:SetCharge(CurTime() + FrameTime() - elapsed - min)
                end

                if (ss.sp or CLIENT) and not (self.NotEnoughInk or EnoughInk) then
                    self.NotEnoughInk = true
                    ss.EmitSound(self:GetOwner(), ss.TankEmpty)
                end
            end
        end

        self:PlayChargeSound()
    else -- First attempt
        if CurTime() > self:GetAimTimer() then
            self:SetSplashInitMul(0)
        end

        self.FullChargeFlag = false
        self.LoopSounds.AimSound.SoundPatch:PlayEx(0, 100)
        self:SetAimTimer(CurTime() + ss.AimDuration)
        self:SetCharge(CurTime())
        self:SetWeaponAnim(ACT_VM_IDLE)
        ss.SetChargingEye(self)

        if not self:IsFirstTimePredicted() then return end
        local e = EffectData()
        e:SetEntity(self)
        util.Effect("SplatoonSWEPsChargerLaser", e, true, self.IgnorePrediction)
        self:EmitSound "SplatoonSWEPs.ChargerPreFire"
    end
end

function SWEP:KeyPress(ply, key)
    if not ss.KeyMaskFind[key] or key == IN_ATTACK then return end
    self:ResetCharge()
    self:SetCooldown(CurTime())
end

SWEP.GetEffectCharge = ss.GetEffectUInt
SWEP.SetEffectCharge = ss.SetEffectUInt
function SWEP:CollectEffectData(effect, data)
    local prog  = self.GetEffectCharge(data) / 255
    local col   = self:GetColRadius(prog)
    local range = self:GetRange(prog)
    local splashInit = bit.rshift(bit.band(ss.GetEffectFlags(data), 0x38), 3)
    local splashPaintRadiusRate = Lerp(prog,
        self.Parameters.mSplashBetweenMaxSplashPaintRadiusRate,
        self.Parameters.mSplashBetweenMinSplashPaintRadiusRate)
    local splashLength = splashPaintRadiusRate
    * self.Parameters.mMaxChargeSplashPaintRadius
    * Lerp(prog, self.Parameters.mPaintNearR_WeakRate, 1)
    * Lerp(prog,
        self.Parameters.mSplashDepthMinChargeScaleRateByWidth,
        self.Parameters.mSplashDepthMaxChargeScaleRateByWidth)
    table.Merge(effect.Ink.Data, effect.IsDrop and {
        ColRadiusEntity = self.Parameters.mSplashColRadius,
        ColRadiusWorld  = self.Parameters.mSplashColRadius,
        DrawRadius      = self.Parameters.mSplashDrawRadius,
        StraightFrame   = 0,
        SplashNum       = 0,
        SplashLength    = 0,
        SplashInitRate  = 0,
        AirResist       = self.Parameters.AirResist,
        Gravity         = self.Parameters.Gravity,
    } or {
        ColRadiusEntity = col,
        ColRadiusWorld  = col,
        DrawRadius      = self.Parameters.mDrawRadius,
        StraightFrame   = range / effect.Ink.Data.InitSpeed,
        SplashNum       = range / splashLength,
        SplashLength    = splashLength,
        SplashInitRate  = splashInit + 1 / splashPaintRadiusRate,
        AirResist       = self.Parameters.AirResist,
        Gravity         = self.Parameters.Gravity,
    })
end

function SWEP:Move(ply)
    local p = self.Parameters
    if ply:IsPlayer() then
        if self:GetNWBool "toggleads" then
            if ply:KeyPressed(IN_USE) then
                self:SetADS(not self:GetADS())
            end
        else
            self:SetADS(ply:KeyDown(IN_USE))
        end
    end

    if CurTime() > self:GetAimTimer() then -- It's no longer aiming
        ss.SetNormalEye(self)
    end

    if self:GetCharge() == math.huge then return end
    if self:ShouldChargeWeapon() then return end
    if CurTime() - self:GetCharge() < p.mMinChargeFrame then return end

    local prog = self:GetChargeProgress()
    local proj = self.Projectile
    local inkconsume = math.max(p.mMinChargeFrame / p.mMaxChargeFrame, prog) * p.mInkConsume
    local ShootSound = prog > .75 and self.ShootSound2 or self.ShootSound
    local pitch = (prog > .75 and 115 or 100) - prog * 20
    local pos, dir = self:GetFirePosition()
    local colradius = self:GetColRadius()
    local initspeed = self:GetInkVelocity()
    local maxrate = p.mSplashBetweenMaxSplashPaintRadiusRate
    local minrate = p.mSplashBetweenMinSplashPaintRadiusRate
    local maxratio = p.mSplashDepthMaxChargeScaleRateByWidth
    local minratio = p.mSplashDepthMinChargeScaleRateByWidth
    local maxwallnum = p.mMaxChargeHitSplashNum
    local minwallnum = p.mMinChargeHitSplashNum
    local paintmaxradius = p.mMaxChargeSplashPaintRadius
    local paintratio = Lerp(prog, p.mPaintNearR_WeakRate, 1)
    local paintradius = paintratio * paintmaxradius
    local ratio = Lerp(prog, minratio, maxratio)
    local range = self:GetRange()
    local splashlength_ratio = Lerp(prog, maxrate, minrate)
    local splashlength = splashlength_ratio * paintradius * ratio
    local splashrate_add = 1 / splashlength_ratio
    if self.IsBamboozler then splashrate_add = splashrate_add * 0.5 end
    local _, splashrate = math.modf(self:GetSplashInitMul() / p.mSplashSplitNum)
    local wallpaintradius = paintradius / p.mPaintRateLastSplash
    local wallfrac = prog / p.mMaxHitSplashNumChargeRate
    table.Merge(proj, {
        Charge = prog,
        Color = self:GetNWInt "inkcolor",
        ColRadiusEntity = colradius,
        ColRadiusWorld = colradius,
        DamageMax = self:GetDamage(),
        DamageMin = 0,
        ID = CurTime() + self:EntIndex(),
        InitPos = pos,
        InitVel = dir * initspeed,
        IsCritical = not self.IsBamboozler and prog == 1,
        PaintFarRadius = paintradius,
        PaintFarRatio = ratio,
        PaintNearRadius = paintradius,
        PaintNearRatio = ratio,
        Range = range,
        SplashInitRate = splashrate + splashrate_add,
        SplashLength = splashlength,
        SplashNum = math.floor(range / splashlength),
        SplashPaintRadius = paintradius,
        SplashRatio = ratio,
        StraightFrame = range / initspeed,
        Type = ss.GetDropType(),
        WallPaintFirstLength = wallpaintradius,
        WallPaintLength = wallpaintradius,
        WallPaintMaxNum = math.Round(Lerp(wallfrac, minwallnum, maxwallnum)),
        WallPaintRadius = wallpaintradius,
        Yaw = self:GetAimVector():Angle().yaw,
    })

    if self:IsFirstTimePredicted() then
        local Recoil = 0.2
        local rnda = Recoil * -1
        local rndb = Recoil * math.Rand(-1, 1)
        self.ViewPunch = Angle(rnda, rndb, rnda)
        self.ModifyWeaponSize = SysTime()

        local e = EffectData()
        local splashInit = bit.lshift(bit.band(self:GetSplashInitMul(), 0x07), 3)
        ss.SetEffectEntity(e, self)
        ss.SetEffectFlags(e, self, ss.INK_EFFECT_TYPE.CHARGER, splashInit)
        ss.SetEffectInitPos(e, proj.InitPos)
        ss.SetEffectInitDir(e, dir)
        ss.SetEffectInitSpeed(e, initspeed)
        self.SetEffectCharge(math.floor(prog * 256))
        ss.UtilEffectPredicted(ply, "SplatoonSWEPsChargerInk", e, true, self.IgnorePrediction)
        ss.AddInk(p, proj)

        if prog > p.mSplashNearFootOccurChargeRate then
            ss.CreateDrop(p, pos, proj.Color, self, proj.SplashColRadius,
            proj.SplashPaintRadius / math.max(p.mPaintRateLastSplash, proj.SplashRatio),
            proj.SplashRatio, proj.Yaw + 90)
        end
    end

    ss.EmitSoundPredicted(ply, self, ShootSound, 80, pitch)
    self:SetCooldown(CurTime() + self.DelayAfterShot)
    self:SetFireAt(prog)
    self:ConsumeInk(inkconsume)
    self:SetSplashInitMul(self:GetSplashInitMul() + 1)
    self:ResetCharge()
    self:SetWeaponAnim(ACT_VM_PRIMARYATTACK)

    ss.SuppressHostEventsMP(ply)
    self:ResetSequence "fire" -- This is needed in multiplayer to prevent delaying muzzle effects.
    ply:SetAnimation(PLAYER_ATTACK1)
    ss.EndSuppressHostEventsMP(ply)
end

function SWEP:CustomDataTables()
    self:AddNetworkVar("Bool", "ADS")
    self:AddNetworkVar("Float", "AimTimer")
    self:AddNetworkVar("Float", "Charge")
    self:AddNetworkVar("Float", "FireAt")
    self:AddNetworkVar("Int", "SplashInitMul")
    if not self.Scoped then return end

    local getads = self.GetADS
    local startmove = self.Parameters.mSniperCameraMoveStartChargeRate
    function self:GetADS(org)
        if org then return getads(self) end
        return getads(self) or self:GetChargeProgress() > startmove
    end
end

function SWEP:CustomMoveSpeed()
    if self:GetKey() ~= IN_ATTACK then return end
    return Lerp(self:GetChargeProgress(), self.InklingSpeed, self.Parameters.mMoveSpeed)
end

function SWEP:GetAnimWeight()
    return (self:GetFireAt() + .5) / 1.5
end
