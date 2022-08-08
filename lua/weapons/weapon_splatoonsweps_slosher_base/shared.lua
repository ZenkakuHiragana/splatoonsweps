
local ss = SplatoonSWEPs
if not ss then return end
SWEP.Base = "weapon_splatoonsweps_inklingbase"
SWEP.IsSlosher = true

local FirePosition = 10
function SWEP:GetRange() return self.Range end
function SWEP:GetFirePosition(ping)
    if not IsValid(self:GetOwner()) then return self:GetPos(), self:GetForward(), 0 end
    local aim = self:GetAimVector() * self:GetRange(ping)
    local ang = aim:Angle()
    local shootpos = self:GetShootPos()
    local col = ss.vector_one * self.Parameters.mFirstGroupBulletFirstCollisionRadiusForField
    local dy = FirePosition * (self:GetNWBool "lefthand" and -1 or 1)
    local dp = -Vector(0, dy, FirePosition) dp:Rotate(ang)
    local t = ss.SquidTrace
    t.start, t.endpos = shootpos, shootpos + aim
    t.mins, t.maxs = -col, col
    t.filter = {self, self:GetOwner()}
    for _, e in pairs(ents.FindAlongRay(t.start, t.endpos, t.mins * 5, t.maxs * 5)) do
        local w = ss.IsValidInkling(e)
        if w and ss.IsAlly(w, self) then
            t.filter = {self, self:GetOwner(), e, w}
        end
    end

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

local OrdinalNumbers = {"First", "Second", "Third"}
function SWEP:GetInitSpeed(number, spawncount, jumping)
    jumping = jumping and "Jumping" or ""
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local base = p["m" .. order .. "GroupBulletFirstInitSpeed" .. jumping .. "Base"]
    return base + spawncount * p["m" .. order .. "GroupBulletAfterInitSpeedOffset"]
end

local randvel = "SplatoonSWEPs: Spread velocity"
function SWEP:GetInitVelocity(number, spawncount, jumping)
    if jumping == nil then jumping = self:GetOwner():OnGround() end
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local base = self:GetInitSpeed(number, spawncount, jumping)
    local x = p["m" .. order .. "GroupBulletInitSpeedRandomX"]
    local z = p["m" .. order .. "GroupBulletInitSpeedRandomZ"]
    local y = base * p["m" .. order .. "GroupBulletInitVecYRate"]
    x = util.SharedRandom(randvel, -x, x, number)
    z = base + util.SharedRandom(randvel, -z, z, number * 2)
    return z, x, y -- Forward, Right, Up
end

function SWEP:GetPaintParameters(number, spawncount)
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    if spawncount == 0 then
        return p["m" .. order .. "GroupBulletFirstPaintFarD"],
               p["m" .. order .. "GroupBulletFirstPaintFarR"],
               p["m" .. order .. "GroupBulletFirstPaintFarRate"],
               p["m" .. order .. "GroupBulletFirstPaintNearD"],
               p["m" .. order .. "GroupBulletFirstPaintNearR"],
               p["m" .. order .. "GroupBulletFirstPaintNearRate"]
    else
        return p["m" .. order .. "GroupBulletSecondAfterPaintFarD"],
               p["m" .. order .. "GroupBulletSecondAfterPaintFarR"],
               p["m" .. order .. "GroupBulletSecondAfterPaintFarRate"],
               p["m" .. order .. "GroupBulletSecondAfterPaintNearD"],
               p["m" .. order .. "GroupBulletSecondAfterPaintNearR"],
               p["m" .. order .. "GroupBulletSecondAfterPaintNearRate"]
    end
end

function SWEP:GetCollisionRadii(number, spawncount)
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local forent = p["m" .. order .. "GroupBulletFirstCollisionRadiusForPlayer"]
    local forworld = p["m" .. order .. "GroupBulletFirstCollisionRadiusForField"]
    local forent_offset = p["m" .. order .. "GroupBulletAfterCollisionRadiusForPlayerOffset"]
    local forworld_offset = p["m" .. order .. "GroupBulletAfterCollisionRadiusForFieldOffset"]
    return forent + spawncount * forent_offset, forworld + spawncount * forworld_offset
end

function SWEP:GetDamageParameters(number, spawncount)
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local maxdist = p.mBulletDamageMaxDist
    local mindist = p.mBulletDamageMinDist
    local max = p["m" .. order .. "GroupBulletFirstDamageMaxValue"]
    local min = p["m" .. order .. "GroupBulletFirstDamageMinValue"]
    local mul = 1 + spawncount * p["m" .. order .. "GroupBulletAfterDamageRateOffset"]
    local mulmax = mul * max
    local mulmin = mul * min
    if max < 1 then mulmax = math.min(mulmax, 0.99) end
    if min < 1 then mulmin = math.min(mulmin, 0.99) end
    return mulmax, maxdist, mulmin, mindist
end

function SWEP:GetDrawRadius(number, spawncount)
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local base = p["m" .. order .. "GroupBulletFirstDrawRadius"]
    local offset = p["m" .. order .. "GroupBulletAfterDrawRadiusOffset"]
    return base + spawncount * offset
end

function SWEP:SharedInit()
    local p = self.Parameters
    table.Merge(self.Projectile, {
        AirResist = p.mFreeStateAirResist,
        Gravity = p.mFreeStateGravity,
    })
end

function SWEP:SharedHolster()
    self:SetIsBusy(false)
    self:SetSpawnRemaining1(0)
    self:SetSpawnRemaining2(0)
    self:SetSpawnRemaining3(0)
    self:SetNextInkSpawnTime1(0)
    self:SetNextInkSpawnTime2(0)
    self:SetNextInkSpawnTime3(0)
end

SWEP.GetEffectSplashInit = ss.GetEffectFloat
SWEP.SetEffectSplashInit = ss.SetEffectFloat
SWEP.GetEffectSpawnCount = ss.GetEffectUInt
SWEP.SetEffectSpawnCount = ss.SetEffectUInt
function SWEP:CollectEffectData(effect, data)
    local number = bit.rshift(bit.band(ss.GetEffectFlags(data), 0x30), 4)
    local order = OrdinalNumbers[number]
    local spawncount = self.GetEffectSpawnCount(data)
    local colent, colworld = self:GetCollisionRadii(number, spawncount)
    local splashnum        = self.Parameters["m" .. order .. "GroupSplashMaxNum"]
    local splashlength     = self.Parameters["m" .. order .. "GroupSplashBetween"]
    local splashcolradius  = self.Parameters["m" .. order .. "GroupSplashColRadius"]
    local splashdrawradius = self.Parameters["m" .. order .. "GroupSplashDrawRadius"]
    table.Merge(effect.Ink.Data, effect.IsDrop and {
        ColRadiusEntity  = splashcolradius,
        ColRadiusWorld   = splashcolradius,
        DrawRadius       = splashdrawradius,
        StraightFrame    = 0,
        SplashNum        = 0,
        SplashLength     = 0,
        SplashInitRate   = 0,
        AirResist        = self.Parameters.AirResist,
        Gravity          = self.Parameters.Gravity,
    } or {
        ColRadiusEntity  = colent,
        ColRadiusWorld   = colworld,
        DrawRadius       = self:GetDrawRadius(number, spawncount),
        StraightFrame    = self.Parameters.mBulletStraightFrame,
        SplashNum        = splashnum,
        SplashLength     = splashlength,
        SplashInitRate   = self.GetEffectSplashInit(data),
        AirResist        = self.Parameters.AirResist,
        Gravity          = self.Parameters.Gravity,
    })
end

local randinit = "SpaltoonSWEPs: Slosher splash init rate"
local randspread = "SplatoonSWEPs: Slosher random spread"
function SWEP:CreateInk(number, spawncount) -- Group #, spawncount-th bullet(0, 1, 2, ...)
    if not self:IsFirstTimePredicted() then return end
    local e = EffectData()
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local dir = self:GetAimVector()
    local pos = self:GetShootPos()
    local iscenter          = p["m" .. order .. "GroupCenterLine"]
    local isside            = p["m" .. order .. "GroupSideLine"]
    local splashcolradius   = p["m" .. order .. "GroupSplashColRadius"]
    local splashinitmin     = p["m" .. order .. "GroupSplashFirstDropRandomRateMin"]
    local splashinitmax     = p["m" .. order .. "GroupSplashFirstDropRandomRateMax"]
    local splashlength      = p["m" .. order .. "GroupSplashBetween"]
    local splashnum         = p["m" .. order .. "GroupSplashMaxNum"]
    local splashpaintradius = p["m" .. order .. "GroupSplashPaintRadius"]
    local splashratio       = p["m" .. order .. "GroupSplashDepthScaleRateByWidth"]
    local spread            = p.mShotRandomDegreeExceptBulletForGuide
    local spreadbias        = p.mShotRandomBiasExceptBulletForGuide
    local splashinit        = util.SharedRandom(randinit, splashinitmin, splashinitmax)
    local vforward, vright, vup = self:GetInitVelocity(number, spawncount)
    local dmax, dmaxdist, dmin, dmindist = self:GetDamageParameters(number, spawncount)
    local pfardist, pfarradius, pfarrate, pneardist, pnearradius, pnearrate = self:GetPaintParameters(number, spawncount)
    local colent, colworld = self:GetCollisionRadii(number, spawncount)
    local function Make(ang, i)
        local initvelocity = ang:Forward() * vforward + ang:Right() * vright + ang:Up() * vup
        local yaw = initvelocity:Angle().yaw
        if initvelocity.x == 0 and initvelocity.y == 0 then yaw = ang.yaw end
        table.Merge(self.Projectile, {
            InitVel = initvelocity,
            Type = ss.GetDropType(i),
            Yaw = yaw,
        })

        ss.SetEffectInitDir(e, self.Projectile.InitVel:GetNormalized())
        ss.SetEffectInitSpeed(e, self.Projectile.InitVel:Length())
        ss.UtilEffectPredicted(self:GetOwner(), "SplatoonSWEPsShooterInk", e, true, self.IgnorePrediction)
        ss.AddInk(p, self.Projectile)
    end

    table.Merge(self.Projectile, {
        Color = self:GetNWInt "inkcolor",
        InitPos = pos,
        ColRadiusEntity = colent,
        ColRadiusWorld = colworld,
        DamageMax = dmax,
        DamageMaxDistance = dmaxdist,
        DamageMin = dmin,
        DamageMinDistance = dmindist,
        IsCritical = number == p.mSpiralSplashGroup,
        PaintRatioFarDistance = pfardist,
        PaintFarDistance = pfardist,
        PaintFarRadius = pfarradius,
        PaintFarRatio = pfarrate,
        PaintRatioNearDistance = pneardist,
        PaintNearDistance = pneardist,
        PaintNearRadius = pnearradius,
        PaintNearRatio = pnearrate,
        SplashColRadius = splashcolradius,
        SplashInitRate = splashinit,
        SplashLength = splashlength,
        SplashNum = splashnum,
        SplashPaintRadius = splashpaintradius,
        SplashRatio = splashratio,
        StraightFrame = p.mBulletStraightFrame,
        WallPaintFirstLength = p.mHitWallSplashFirstLength,
        WallPaintLength = p.mHitWallSplashBetweenLength,
        WallPaintRadius = p.mHitWallSplashBetweenLength, -- WORKAROUND!!
        WallPaintUseSplashNum = true,
    })

    if number == p.mScatterSplashGroup and spawncount + 1 == p.mScatterSplashBulletNumInGroup then
        self.Projectile.ScatterSplashTime = CurTime() + p.mScatterSplashMinSpanFrame
        self.Projectile.ScatterSplashCount = 0
    else
        self.Projectile.ScatterSplashTime = nil
        self.Projectile.ScatterSplashCount = nil
    end

    local flags = bit.lshift(number, 4)
    ss.SetEffectEntity(e, self)
    ss.SetEffectFlags(e, self, ss.INK_EFFECT_TYPE.SLOSHER, flags)
    self.SetEffectSplashInit(e, splashinit)
    self.SetEffectSpawnCount(e, spawncount)

    local linenum = p.mLineNum - 1
    local centerline = math.floor(p.mLineNum / 2)
    for i = 0, linenum do
        local ang = dir:Angle()
        if linenum > 0 then
            ang:RotateAroundAxis(ang:Up(), (i / linenum - 0.5) * p.mLineDegree)
        end

        local sgn = math.Round(util.SharedRandom(randspread, 0, 1, number + spawncount + i)) * 2 - 1
        local sgnbias = spreadbias > util.SharedRandom(randspread, 0, 1, number + spawncount + i + 1)
        local frac = util.SharedRandom(randspread, sgnbias and spreadbias or 0, sgnbias and 1 or spreadbias, number + spawncount + i + 1 + 2)
        ang:RotateAroundAxis(ang:Up(), sgn * frac * spread)
        if i == centerline and iscenter then Make(ang, i) end
        if i ~= centerline and isside then Make(ang, i) end
    end
end

function SWEP:SharedPrimaryAttack(able, auto)
    if self:GetIsBusy() then return end
    local p = self.Parameters
    local spawntimebase = CurTime() + p.mSwingLiftFrame
    self:SetIsBusy(true)
    self:SetWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetCooldown(spawntimebase + p.mPostDelayFrm_Main)
    self:SetSpawnTimeBase(spawntimebase)
    self:SetNextPrimaryFire(CurTime() + p.mSwingRepeatFrame)
    self:SetNextInkSpawnTime1(spawntimebase)
    self:SetNextInkSpawnTime2(spawntimebase + p.mSecondGroupBulletFirstFrameOffset)
    self:SetNextInkSpawnTime3(spawntimebase + p.mThirdGroupBulletFirstFrameOffset)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
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

    for number, order in ipairs(OrdinalNumbers) do
        local spawnmax = p["m" .. order .. "GroupBulletNum"]
        local spawnremaining = self["GetSpawnRemaining" .. number](self)
        local spawntime = self["GetNextInkSpawnTime" .. number](self)
        local SetRemaining = self["SetSpawnRemaining" .. number]
        local SetTime = self["SetNextInkSpawnTime" .. number]
        local frameoffset = p["m" .. order .. "GroupBulletAfterFrameOffset"]
        while spawnremaining > 0 and CurTime() > spawntime do
            self:CreateInk(number, spawnmax - spawnremaining)
            spawnremaining = spawnremaining - 1
            spawntime = spawntime + frameoffset
            SetRemaining(self, spawnremaining)
            SetTime(self, spawntime)
        end
    end

    if not self:GetIsBusy() then return end
    if CurTime() < self:GetSpawnTimeBase() then return end
    self.Primary.Automatic = self:GetNWBool "automatic"
    self.Projectile.ID = CurTime() + self:EntIndex()
    self:SetWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:ResetSequence "fire2" -- This is needed in multiplayer to predict muzzle effects.
    self:SetIsBusy(false)
    self:SetReloadDelay(p.mInkRecoverStop)
    if self:GetInk() < p.mInkConsume then
        if not self:IsFirstTimePredicted() then return end
        ss.EmitSoundPredicted(self:GetOwner(), self, "SplatoonSWEPs.EmptySwing")
        if ss.mp and SERVER then return end
        ss.EmitSound(ply, ss.TankEmpty)
        return
    end

    ss.EmitSoundPredicted(self:GetOwner(), self, self.ShootSound)
    self:SetInk(math.max(self:GetInk() - p.mInkConsume, 0))
    self:SetSpawnRemaining1(p.mFirstGroupBulletNum)
    self:SetSpawnRemaining2(p.mSecondGroupBulletNum)
    self:SetSpawnRemaining3(p.mThirdGroupBulletNum)
end

function SWEP:CustomDataTables()
    self:AddNetworkVar("Bool", "ADS")
    self:AddNetworkVar("Bool", "IsBusy")
    self:AddNetworkVar("Bool", "PreviousHasInk")
    self:AddNetworkVar("Float", "NextInkSpawnTime1")
    self:AddNetworkVar("Float", "NextInkSpawnTime2")
    self:AddNetworkVar("Float", "NextInkSpawnTime3")
    self:AddNetworkVar("Float", "SpawnTimeBase")
    self:AddNetworkVar("Int", "SpawnRemaining1")
    self:AddNetworkVar("Int", "SpawnRemaining2")
    self:AddNetworkVar("Int", "SpawnRemaining3")
end

function SWEP:CustomActivity()
    return "crossbow"
end
