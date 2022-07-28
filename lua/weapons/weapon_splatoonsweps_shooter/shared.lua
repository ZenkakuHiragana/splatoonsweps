
local ss = SplatoonSWEPs
if not ss then return end
SWEP.Base = "weapon_splatoonsweps_inklingbase"
SWEP.IsShooter = true
SWEP.HeroColor = {ss.GetColor(8), ss.GetColor(11), ss.GetColor(2), ss.GetColor(5)}

local FirePosition = 10
local randsplash = "SplatoonSWEPs: SplashNum"
function SWEP:GetRange() return self.Range end
function SWEP:GetInitVelocity() return self.Parameters.mInitVel end
function SWEP:GetSplashInitRate()
    return self.SplashInitTable[self:GetSplashInitMul()] / self.Parameters.mSplashSplitNum
end

function SWEP:GetFirePosition(ping)
    if not IsValid(self:GetOwner()) then return self:GetPos(), self:GetForward(), 0 end
    local aim = self:GetAimVector() * self:GetRange(ping)
    local ang = aim:Angle()
    local shootpos = self:GetShootPos()
    local col = ss.vector_one * self.Parameters.mColRadius
    local dy = FirePosition * (self:GetNWBool "lefthand" and -1 or 1)
    local dp = -Vector(0, dy, FirePosition) dp:Rotate(ang)
    local t = {}
    t.start, t.endpos = shootpos, shootpos + aim
    t.mins, t.maxs = -col, col
    t.filter = ss.MakeAllyFilter(self)
    t.mask = ss.SquidSolidMask
    t.collisiongroup = COLLISION_GROUP_NONE

    local tr = util.TraceLine(t)
    local pos = shootpos + dp
    local min = {dir = 1, dist = math.huge, pos = pos}

    t.start, t.endpos = pos, tr.HitPos
    local trtest = util.TraceHull(t)
    if self:GetNWBool "avoidwalls" and tr.HitPos:DistToSqr(shootpos) > trtest.HitPos:DistToSqr(pos) * 9 then
        for dir, negate in ipairs {false, "y", "z", "yz", 0} do -- right, left, up
            if negate then
                if negate == 0 then
                    dp = vector_up * -FirePosition
                    pos = shootpos
                else
                    dp = -Vector(0, dy, FirePosition)
                    for i = 1, negate:len() do
                        local s = negate:sub(i, i)
                        dp[s] = -dp[s]
                    end
                    dp:Rotate(ang)
                    pos = shootpos + dp
                end

                t.start = pos
                trtest = util.TraceHull(t)
            end

            if not trtest.StartSolid then
                local dist = math.floor(trtest.HitPos:DistToSqr(tr.HitPos))
                if dist < min.dist then
                    min.dir, min.dist, min.pos = dir, dist, pos
                end
            end
        end
    end

    return min.pos, (tr.HitPos - min.pos):GetNormalized(), min.dir
end

function SWEP:GetSpreadJumpFraction()
    local frac = CurTime() - self:GetJump()
    if CLIENT then frac = frac + self:Ping() end
    return math.Clamp(frac / self.Parameters.mDegJumpBiasFrame, 0, 1)
end

function SWEP:GetSpreadAmount()
    return Lerp(self:GetSpreadJumpFraction(),
    self.Parameters.mDegJumpRandom, self.Parameters.mDegRandom), ss.mDegRandomY
end

function SWEP:GenerateSplashInitTable()
    local n, t = self.Parameters.mSplashSplitNum, self.SplashInitTable
    local step = self.Parameters.mTripleShotSpan and 3 or 1
    for i = 0, n - 1 do t[i + 1] = i * step % n end
    for i = 1, n do
        local k = math.floor(util.SharedRandom(randsplash, i, n))
        t[i], t[k] = t[k], t[i]
    end
end

function SWEP:SharedInit()
    self.SplashInitTable = {} -- A random permutation table for splash init
    self:SetAimTimer(CurTime())
    self:SetNextPlayEmpty(CurTime())
    self:SetSplashInitMul(1)

    local p = self.Parameters
    table.Merge(self.Projectile, {
        AirResist = ss.ShooterAirResist,
        ColRadiusEntity = p.mColRadius,
        ColRadiusWorld = p.mColRadius,
        DamageMax = p.mDamageMax,
        DamageMaxDistance = p.mGuideCheckCollisionFrame,
        DamageMin = p.mDamageMin,
        DamageMinDistance = p.mDamageMinFrame,
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

function SWEP:SharedDeploy()
    self:SetSplashInitMul(1)
    self:GenerateSplashInitTable()
    if self.Parameters.mTripleShotSpan > 0 then
        self.TripleSchedule:SetDone(0)
    end
end

function SWEP:GetSpread()
    local DegRandX, DegRandY = self:GetSpreadAmount()
    local rx = ss.GetBiasedRandom(self:GetBias(), "SplatoonSWEPs: Spread X") * DegRandX
    local ry = ss.GetBiasedRandom(self:GetBias(), "SplatoonSWEPs: Spread Y") * DegRandY
    return rx, ry
end

function SWEP:CreateInk()
    local p = self.Parameters
    local pos, dir = self:GetFirePosition()
    local right = self:GetOwner():GetRight()
    local ang = dir:Angle()
    local rx, ry = self:GetSpread()
    local splashnum = math.floor(p.mCreateSplashNum)
    local AlreadyAiming = CurTime() < self:GetAimTimer()
    if CurTime() - self:GetJump() < p.mDegJumpBiasFrame then
        self:SetBias(p.mDegJumpBias)
    else
        if not AlreadyAiming then self:SetBias(0) end
        self:SetBias(math.min(self:GetBias() + p.mDegBiasKf, p.mDegBias))
    end

    if util.SharedRandom(randsplash, 0, 1) < p.mCreateSplashNum % 1 then
        splashnum = splashnum + 1
    end

    ang:RotateAroundAxis(right:Cross(dir), rx)
    ang:RotateAroundAxis(right, ry)
    table.Merge(self.Projectile, {
        Color = self:GetNWInt "inkcolor",
        ID = CurTime() + self:EntIndex(),
        InitPos = pos,
        InitVel = ang:Forward() * self:GetInitVelocity(),
        SplashInitRate = self:GetSplashInitRate(),
        SplashNum = splashnum,
        Type = ss.GetShooterInkType(),
        Yaw = ang.yaw,
    })

    self:SetSplashInitMul(self:GetSplashInitMul() + 1)
    self:SetWeaponAnim(ACT_VM_PRIMARYATTACK)
    ss.EmitSoundPredicted(self:GetOwner(), self, self.ShootSound)
    ss.SuppressHostEventsMP(self:GetOwner())
    self:ResetSequence "fire" -- This is needed in multiplayer to prevent delaying muzzle effects.
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    ss.EndSuppressHostEventsMP(self:GetOwner())

    if self:GetSplashInitMul() > p.mSplashSplitNum then
        self:SetSplashInitMul(1)
        self:GenerateSplashInitTable()
    end

    if self:IsFirstTimePredicted() then
        local Recoil = 0.2
        local rnda = Recoil * -1
        local rndb = Recoil * math.Rand(-1, 1)
        self.ViewPunch = Angle(rnda, rndb, rnda)

        local e = EffectData()
        local proj = self.Projectile
        ss.SetEffectColor(e, proj.Color)
        ss.SetEffectColRadius(e, proj.ColRadiusWorld)
        ss.SetEffectDrawRadius(e, self.IsBlaster and p.mSphereSplashDropDrawRadius or p.mDrawRadius)
        ss.SetEffectEntity(e, self)
        ss.SetEffectFlags(e, self)
        ss.SetEffectInitPos(e, proj.InitPos)
        ss.SetEffectInitVel(e, proj.InitVel)
        ss.SetEffectSplash(e, Angle(proj.SplashColRadius, p.mSplashDrawRadius, proj.SplashLength))
        ss.SetEffectSplashInitRate(e, Vector(proj.SplashInitRate))
        ss.SetEffectSplashNum(e, proj.SplashNum)
        ss.SetEffectStraightFrame(e, proj.StraightFrame)
        ss.UtilEffectPredicted(self:GetOwner(), "SplatoonSWEPsShooterInk", e, true, self.IgnorePrediction)
        ss.AddInk(p, proj)
    end
end

function SWEP:PlayEmptySound()
    local nextempty = self.Parameters.mRepeatFrame * 2 / ss.GetTimeScale(self:GetOwner())
    if self:GetPreviousHasInk() then
        if ss.sp or CLIENT and IsFirstTimePredicted() then
            self:GetOwner():EmitSound(ss.TankEmpty)
        end

        self:SetNextPlayEmpty(CurTime() + nextempty)
        self:SetPreviousHasInk(false)
        self.PreviousHasInk = false
    elseif CurTime() > self:GetNextPlayEmpty() then
        self:EmitSound "SplatoonSWEPs.EmptyShot"
        self:SetNextPlayEmpty(CurTime() + nextempty)
    end
end

function SWEP:SharedPrimaryAttack(able, auto)
    if not IsValid(self:GetOwner()) then return end
    local p = self.Parameters
    local ts = ss.GetTimeScale(self:GetOwner())
    self:SetNextPrimaryFire(CurTime() + p.mRepeatFrame / ts)
    self:ConsumeInk(p.mInkConsume)
    self:SetReloadDelay(p.mInkRecoverStop)
    self:SetCooldown(math.max(self:GetCooldown(),
    CurTime() + math.min(p.mRepeatFrame, ss.CrouchDelay) / ts))

    if not able then
        if p.mTripleShotSpan > 0 then self:SetCooldown(CurTime()) end
        self:SetAimTimer(CurTime() + ss.AimDuration)
        self:PlayEmptySound()
        return
    end

    self:CreateInk()
    self:SetPreviousHasInk(true)
    self:SetAimTimer(CurTime() + ss.AimDuration)
    if self:IsFirstTimePredicted() then self.ModifyWeaponSize = SysTime() end
    if p.mTripleShotSpan > 0 then
        local d = self.TripleSchedule:GetDone()
        if d == 1 or d == 2 then return end
        self:SetCooldown(CurTime() + (p.mRepeatFrame * 2 + p.mTripleShotSpan) / ts)
        self:SetAimTimer(self:GetCooldown())
        self.TripleSchedule:SetDone(1)
    end
end

function SWEP:CustomDataTables()
    self:AddNetworkVar("Bool", "ADS")
    self:AddNetworkVar("Bool", "PreviousHasInk")
    self:AddNetworkVar("Float", "AimTimer")
    self:AddNetworkVar("Float", "Bias")
    self:AddNetworkVar("Float", "Jump")
    self:AddNetworkVar("Float", "NextPlayEmpty")
    self:AddNetworkVar("Int", "SplashInitMul")

    if self.Parameters.mTripleShotSpan > 0 then
        self.TripleSchedule = self:AddNetworkSchedule(0, function(_, schedule)
            if schedule:GetDone() == 1 or schedule:GetDone() == 2 then
                if self:GetNextPrimaryFire() > CurTime() then
                    schedule:SetDone(schedule:GetDone() - 1)
                else
                    self:PrimaryAttack(true)
                end

                return
            end

            schedule:SetDone(3)
        end)
        self.TripleSchedule:SetDone(3)
    end
end

function SWEP:CustomActivity()
    local at = self:GetAimTimer()
    if CLIENT and self:IsCarriedByLocalPlayer() then at = at - self:Ping() end
    if CurTime() > at then return end

    local aimpos = select(3, self:GetFirePosition())
    aimpos = (aimpos == 3 or aimpos == 4) and "rpg" or "crossbow"

    local m = self:GetOwner():GetModel()
    local aim = self:GetADS() and not (ss.DrLilRobotPlayermodels[m] or ss.TwilightPlayermodels[m])
    return aim and "ar2" or aimpos
end

function SWEP:CustomMoveSpeed()
    if CurTime() > self:GetAimTimer() then return end
    return self.Parameters.mMoveSpeed
end

function SWEP:Move(ply)
    if ply:IsPlayer() then
        if self:GetNWBool "toggleads" then
            if ply:KeyPressed(IN_USE) then
                self:SetADS(not self:GetADS())
            end
        else
            self:SetADS(ply:KeyDown(IN_USE))
        end
    end

    if not ply:OnGround() then return end
    if CurTime() - self:GetJump() < self.Parameters.mDegJumpBiasFrame then
        self:SetJump(self:GetJump() - FrameTime() / 2)
    end
end

function SWEP:KeyPress(ply, key)
    if key == IN_JUMP then self:SetJump(CurTime()) end
end

function SWEP:GetAnimWeight()
    return (self.Parameters.mRepeatFrame + .5) / 1.5
end

function SWEP:UpdateAnimation(ply, vel, max)
    ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, self:GetAnimWeight())
end
