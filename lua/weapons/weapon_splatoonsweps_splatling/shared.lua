
local ss = SplatoonSWEPs
if not ss then return end
SWEP.Base = "weapon_splatoonsweps_shooter"
SWEP.IsSplatling = true
SWEP.FlashDuration = .25

function SWEP:GetChargeProgress(ping)
    local p = self.Parameters
    local ts = ss.GetTimeScale(self:GetOwner())
    local frac = CurTime() - self:GetCharge() - p.mMinChargeFrame / ts
    if ping then frac = frac + self:Ping() end
    return math.Clamp(frac / p.mSecondPeriodMaxChargeFrame * ts, 0, 1)
end

local rand = "SplatoonSWEPs: Spread"
function SWEP:GetInitVelocity(nospread)
    local p = self.Parameters
    local frac = ss.GetBiasedRandom(self:GetBiasVelocity(), rand)
    local v = 1 + (nospread and 0 or frac * p.mInitVelSpeedRateRandom)
    local prog = self:GetFireInk() > 0 and self:GetFireAt() or self:GetChargeProgress(CLIENT)
    if prog < self.MediumCharge then
        return v * Lerp(prog / self.MediumCharge, p.mInitVelMinCharge, p.mInitVelFirstPeriodMaxCharge)
    else
        return v * Lerp(prog - self.MediumCharge, p.mInitVelSecondPeriodMinCharge, p.mInitVelSecondPeriodMaxCharge)
    end
end

local randsign = "SplatoonSWEPs: Init rate sign"
function SWEP:GetSplashInitRate()
    local rate = self:GetBase().GetSplashInitRate(self)
    if util.SharedRandom(randsign, 0, 3, CurTime() - 1) < 1 then return rate end

    local p = self.Parameters
    local diff = ss.RandomSign(rand) * 0.5 / p.mSplashSplitNum
    return math.max(rate + diff, 0)
end

function SWEP:GetRange()
    local p = self.Parameters
    return ss.GetRange(self:GetInitVelocity(true),
    p.mStraightFrame, p.mGuideCheckCollisionFrame, ss.ShooterAirResist)
end

function SWEP:GetSpreadAmount()
    local sx, sy = self:GetBase().GetSpreadAmount(self)
    return sx, (self.Parameters.mDegRandom + sy) / 2
end

function SWEP:ResetCharge()
    self:SetCharge(math.huge)
    self:SetFireInk(0)
    self.FullChargeFlag = false
    self.NotEnoughInk = false
    self.JumpPower = ss.InklingJumpPower
    if ss.mp and CLIENT and not IsFirstTimePredicted() then return end
    if not self.LoopSounds.AimSound.SoundPatch then return end
    self.LoopSounds.AimSound.SoundPatch:Stop()
    self.LoopSounds.SpinupSound1.SoundPatch:Stop()
    self.LoopSounds.SpinupSound2.SoundPatch:Stop()
    self.LoopSounds.SpinupSound3.SoundPatch:Stop()
end

SWEP.SharedHolster = SWEP.ResetCharge
function SWEP:PlayChargeSound()
    if ss.mp and CLIENT and not IsFirstTimePredicted() then return end
    local prog = self:GetChargeProgress(SERVER)
    if prog == 1 then
        self.LoopSounds.AimSound.SoundPatch:Stop()
        self.LoopSounds.SpinupSound1.SoundPatch:Stop()
        self.LoopSounds.SpinupSound2.SoundPatch:Stop()
        self.LoopSounds.SpinupSound3.SoundPatch:Play()
    elseif prog > 0 then
        self.LoopSounds.AimSound.SoundPatch:PlayEx(.75, math.max(self.LoopSounds.AimSound.SoundPatch:GetPitch(), prog * 90 + 1))
        self.LoopSounds.SpinupSound3.SoundPatch:Stop()
        local p = self.LoopSounds.SpinupSound2.SoundPatch:GetPitch()
        if prog < self.MediumCharge then
            self.LoopSounds.SpinupSound1.SoundPatch:PlayEx(1, math.max(p, 100 + prog * 25))
            self.LoopSounds.SpinupSound2.SoundPatch:Stop()
            self.LoopSounds.SpinupSound2.SoundPatch:ChangePitch(1)
        else
            prog = (prog - self.MediumCharge) / (1 - self.MediumCharge)
            self.LoopSounds.SpinupSound2.SoundPatch:PlayEx(1, math.max(p, 80 + prog * 20))
            self.LoopSounds.SpinupSound1.SoundPatch:Stop()
            self.LoopSounds.SpinupSound1.SoundPatch:ChangePitch(1)
        end
    end
end

function SWEP:ShouldChargeWeapon()
    if self:GetOwner():IsPlayer() then
        return self:GetOwner():KeyDown(IN_ATTACK)
    else
        return CurTime() - self:GetCharge() < self.Parameters.mSecondPeriodMaxChargeFrame + .5
    end
end

function SWEP:SharedDeploy()
    self:SetSplashInitMul(1)
    self:GenerateSplashInitTable()
    self:ResetCharge()
end

function SWEP:SharedInit()
    self.LoopSounds.AimSound = {SoundName = ss.ChargerAim}
    self.LoopSounds.SpinupSound1 = {SoundName = self.ChargeSound[1]}
    self.LoopSounds.SpinupSound2 = {SoundName = self.ChargeSound[2]}
    self.LoopSounds.SpinupSound3 = {SoundName = self.ChargeSound[3]}
    self.SplashInitTable = {}

    local p = self.Parameters
    self.AirTimeFraction = 1 - 1 / p.mEmptyChargeTimes
    self.MediumCharge = (p.mFirstPeriodMaxChargeFrame - p.mMinChargeFrame) / (p.mSecondPeriodMaxChargeFrame - p.mMinChargeFrame)
    self.SpinupEffectTime = CurTime()
    self:SetAimTimer(CurTime())
    self:SharedDeploy()
    table.Merge(self.Projectile, {
        AirResist = ss.ShooterAirResist,
        ColRadiusEntity = p.mColRadius,
        ColRadiusWorld = p.mColRadius,
        DamageMax = p.mDamageMax,
        DamageMaxDistance = p.mDamageMinFrame, -- Swapped from shooters
        DamageMin = p.mDamageMin,
        DamageMinDistance = p.mGuideCheckCollisionFrame, -- Swapped from shooters
        Gravity = ss.ShooterGravityMul * ss.InkDropGravity,
        PaintFarDistance = p.mPaintFarDistance,
        PaintFarRadius = p.mPaintFarRadius,
        PaintNearDistance = p.mPaintNearDistance,
        PaintNearRadius = p.mPaintNearRadius,
        SplashColRadius = p.mSplashColRadius,
        SplashLength = p.mCreateSplashLength,
        SplashPaintRadius = p.mSplashPaintRadius,
        StraightFrame = p.mStraightFrame,
    })
end

function SWEP:SharedPrimaryAttack()
    if not IsValid(self:GetOwner()) then return end
    if self:GetCharge() < math.huge then -- Hold +attack to charge
        local p = self.Parameters
        local prog = self:GetChargeProgress(CLIENT)
        self:SetAimTimer(CurTime() + ss.AimDuration)
        self:SetReloadDelay(FrameTime())
        self:PlayChargeSound()
        self.JumpPower = Lerp(prog, ss.InklingJumpPower, p.mJumpGnd_Charge)
        if prog == 0 then return end
        local EnoughInk = self:GetInk() >= prog * p.mInkConsume
        if not self:GetOwner():OnGround() or not EnoughInk then
            if EnoughInk or self:GetNWBool "canreloadstand" then
                self:SetCharge(self:GetCharge() + FrameTime() * self.AirTimeFraction)
            else
                local ts = ss.GetTimeScale(self:GetOwner())
                local elapsed = prog * p.mSecondPeriodMaxChargeFrame / ts
                local min = p.mMinChargeFrame / ts
                local ping = CLIENT and self:Ping() or 0
                self:SetCharge(CurTime() + FrameTime() - elapsed - min + ping)
            end

            if (ss.sp or CLIENT) and not (self.NotEnoughInk or EnoughInk) then
                self.NotEnoughInk = true
                ss.EmitSound(self:GetOwner(), ss.TankEmpty)
            end
        end
    else -- First attempt
        self.FullChargeFlag = false
        self.LoopSounds.AimSound.SoundPatch:PlayEx(0, 1)
        self.LoopSounds.SpinupSound1.SoundPatch:Play()
        self:SetAimTimer(CurTime() + ss.AimDuration)
        self:SetCharge(CurTime())
        self:SetWeaponAnim(ACT_VM_IDLE)
        ss.SetChargingEye(self)
    end
end

function SWEP:KeyPress(ply, key)
    if key == IN_JUMP then self:SetJump(CurTime()) end
    if not ss.KeyMaskFind[key] or key == IN_ATTACK then return end
    self:ResetCharge()
    self:SetCooldown(CurTime())
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

    if ply:OnGround() and CurTime() - self:GetJump() < p.mDegJumpBiasFrame then
        self:SetJump(self:GetJump() - FrameTime() / 2)
    end

    if CurTime() > self:GetAimTimer() then
        ss.SetNormalEye(self)
    end

    if self:GetFireInk() > 0 then -- It's firing
        if not self:CheckCanStandup() then return end
        if self:GetThrowing() then return end
        if CLIENT and (ss.sp or not self:IsMine()) then return end
        if self:GetNextPrimaryFire() > CurTime() then return end

        local ts = ss.GetTimeScale(ply)
        local AlreadyAiming = CurTime() < self:GetAimTimer()
        local crouchdelay = math.min(p.mRepeatFrame, ss.CrouchDelay)
        self:CreateInk()
        self:SetNextPrimaryFire(CurTime() + p.mRepeatFrame / ts)
        self:SetAimTimer(CurTime() + ss.AimDuration)
        self:SetFireInk(self:GetFireInk() - 1)
        self:ConsumeInk(self.TakeAmmo)
        self:SetReloadDelay(p.mInkRecoverStop)
        self:SetCooldown(math.max(self:GetCooldown(), CurTime() + crouchdelay / ts))

        if CurTime() - self:GetJump() > p.mDegJumpBiasFrame then
            if not AlreadyAiming then self:SetBiasVelocity(0) end
            self:SetBiasVelocity(math.min(self:GetBiasVelocity() + p.mDegBiasKf, p.mInitVelSpeedBias))
        end

        if not self:IsFirstTimePredicted() then return end
        local e = EffectData()
        e:SetEntity(self)
        ss.UtilEffectPredicted(ply, "SplatoonSWEPsSplatlingMuzzleFlash", e, true, self.IgnorePrediction)
    else -- Just released MOUSE1
        if self:GetCharge() == math.huge then return end
        if self:ShouldChargeWeapon() then return end
        if CurTime() - self:GetCharge() < p.mMinChargeFrame then return end
        local duration
        local prog = self:GetChargeProgress()
        local d1 = p.mFirstPeriodMaxChargeShootingFrame
        local d2 = p.mSecondPeriodMaxChargeShootingFrame
        if prog < self.MediumCharge then
            duration = d1 * prog / self.MediumCharge
        else
            local frac = (prog - self.MediumCharge) / (1 - self.MediumCharge)
            duration = Lerp(frac, d1, d2)
        end

        self:SetFireAt(prog)
        self:ResetCharge()
        self:SetFireInk(math.floor(duration / p.mRepeatFrame) + 1)
        self.TakeAmmo = p.mInkConsume * prog / self:GetFireInk()
        self.Projectile.DamageMax = prog == 1 and p.mDamageMaxMaxCharge or p.mDamageMax
    end
end

function SWEP:CustomDataTables()
    self:AddNetworkVar("Bool", "ADS")
    self:AddNetworkVar("Float", "AimTimer")
    self:AddNetworkVar("Float", "Bias")
    self:AddNetworkVar("Float", "BiasVelocity")
    self:AddNetworkVar("Float", "Charge")
    self:AddNetworkVar("Float", "FireAt")
    self:AddNetworkVar("Float", "Jump")
    self:AddNetworkVar("Int", "FireInk")
    self:AddNetworkVar("Int", "SplashInitMul")
end

function SWEP:CustomMoveSpeed()
    if self:GetFireInk() > 0 then return self.Parameters.mMoveSpeed end
    if self:GetCharge() < math.huge then
        return Lerp(self:GetChargeProgress(), self.InklingSpeed, self.Parameters.mMoveSpeed_Charge)
    end
end

function SWEP:CustomActivity()
    local at = self:GetAimTimer()
    if CLIENT and self:IsCarriedByLocalPlayer() then at = at - self:Ping() end
    if CurTime() > at then return "crossbow" end
    local aimpos = select(3, self:GetFirePosition())
    return (aimpos == 3 or aimpos == 4) and "rpg" or "crossbow"
end

function SWEP:UpdateAnimation(ply, vel, max) end
