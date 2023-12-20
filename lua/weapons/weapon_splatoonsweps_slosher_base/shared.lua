
local ss = SplatoonSWEPs
if not ss then return end

local SWEP = SWEP
---@cast SWEP SWEP.Slosher
---@class SWEP.Slosher : SplatoonWeaponBase
---@field Parameters          Parameters.Slosher
---@field ShootSound          string
---@field CreateInk           fun(self, number: integer, spawncount: integer)
---@field GetCollisionRadii   fun(self, number: integer, spawncount: integer): number, number
---@field GetColRadius        fun(self): number
---@field GetCrosshairTrace   fun(self, t: table)
---@field GetDamageParameters fun(self, number: integer, spawncount: integer): number, number, number, number
---@field GetDrawRadius       fun(self, number: integer, spawncount: integer): number
---@field GetFirePosition     fun(self, ping: boolean?): Vector, Vector, integer
---@field GetInitSpeed        fun(self, number: integer, spawncount: integer, jumping: boolean?): number
---@field GetInitVelocity     fun(self, number: integer, spawncount: integer, jumping: boolean?): number, number, number
---@field GetPaintParameters  fun(self, number: integer, spawncount: integer): number, number, number, number, number, number
---@field GetRange            fun(self): number

SWEP.Base = "weapon_splatoonsweps_inklingbase"
SWEP.IsSlosher = true

function SWEP:GetRange() return self.Range end
function SWEP:GetColRadius() return self.Parameters.mFirstGroupBulletFirstCollisionRadiusForField end

local OrdinalNumbers = {"First", "Second", "Third"}
function SWEP:GetInitSpeed(number, spawncount, jumping)
    jumping = jumping and "Jumping" or ""
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local base = p["m" .. order .. "GroupBulletFirstInitSpeed" .. jumping .. "Base"] ---@type number
    local offset = p["m" .. order .. "GroupBulletAfterInitSpeedOffset"] ---@type number
    return base + spawncount * offset
end

local randvel = "SplatoonSWEPs: Spread velocity"
function SWEP:GetInitVelocity(number, spawncount, jumping)
    if jumping == nil then jumping = self:GetOwner():OnGround() end
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local base = self:GetInitSpeed(number, spawncount, jumping)
    local x = p["m" .. order .. "GroupBulletInitSpeedRandomX"] ---@type number
    local z = p["m" .. order .. "GroupBulletInitSpeedRandomZ"] ---@type number
    local y = base * p["m" .. order .. "GroupBulletInitVecYRate"] ---@type number
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
    local forent = p["m" .. order .. "GroupBulletFirstCollisionRadiusForPlayer"] ---@type number
    local forworld = p["m" .. order .. "GroupBulletFirstCollisionRadiusForField"] ---@type number
    local forent_offset = p["m" .. order .. "GroupBulletAfterCollisionRadiusForPlayerOffset"] ---@type number
    local forworld_offset = p["m" .. order .. "GroupBulletAfterCollisionRadiusForFieldOffset"] ---@type number
    return forent + spawncount * forent_offset, forworld + spawncount * forworld_offset
end

function SWEP:GetDamageParameters(number, spawncount)
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local maxdist = p.mBulletDamageMaxDist
    local mindist = p.mBulletDamageMinDist
    local max = p["m" .. order .. "GroupBulletFirstDamageMaxValue"] ---@type number
    local min = p["m" .. order .. "GroupBulletFirstDamageMinValue"] ---@type number
    local mul = 1 + spawncount * p["m" .. order .. "GroupBulletAfterDamageRateOffset"] ---@type number
    local mulmax = mul * max
    local mulmin = mul * min
    if max < 1 then mulmax = math.min(mulmax, 0.99) end
    if min < 1 then mulmin = math.min(mulmin, 0.99) end
    return mulmax, maxdist, mulmin, mindist
end

function SWEP:GetDrawRadius(number, spawncount)
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local base = p["m" .. order .. "GroupBulletFirstDrawRadius"] ---@type number
    local offset = p["m" .. order .. "GroupBulletAfterDrawRadiusOffset"] ---@type number
    return base + spawncount * offset
end

function SWEP:SharedInit()
    local shooter = weapons.Get "weapon_splatoonsweps_shooter"
    self.GetFirePosition = shooter.GetFirePosition
    self.GetCrosshairTrace = shooter.GetCrosshairTrace

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

local randinit = "SpaltoonSWEPs: Slosher splash init rate"
local randspread = "SplatoonSWEPs: Slosher random spread"
function SWEP:CreateInk(number, spawncount) -- Group #, spawncount-th bullet(0, 1, 2, ...)
    if not self:IsFirstTimePredicted() then return end
    local e = EffectData()
    local order = OrdinalNumbers[number]
    local p = self.Parameters
    local pos = self:GetShootPos()
    local iscenter = p["m" .. order .. "GroupCenterLine"] ---@type boolean
    local isside = p["m" .. order .. "GroupSideLine"] ---@type boolean
    local splashcolradius = p["m" .. order .. "GroupSplashColRadius"] ---@type number
    local splashdrawradius = p["m" .. order .. "GroupSplashDrawRadius"] ---@type number
    local splashinitmin = p["m" .. order .. "GroupSplashFirstDropRandomRateMin"] ---@type number
    local splashinitmax = p["m" .. order .. "GroupSplashFirstDropRandomRateMax"] ---@type number
    local splashlength = p["m" .. order .. "GroupSplashBetween"] ---@type number
    local splashnum = p["m" .. order .. "GroupSplashMaxNum"] ---@type number
    local splashpaintradius = p["m" .. order .. "GroupSplashPaintRadius"] ---@type number
    local splashratio = p["m" .. order .. "GroupSplashDepthScaleRateByWidth"] ---@type number
    local spread = p.mShotRandomDegreeExceptBulletForGuide
    local spreadbias = p.mShotRandomBiasExceptBulletForGuide
    local vforward, vright, vup = self:GetInitVelocity(number, spawncount)
    local dmax, dmaxdist, dmin, dmindist = self:GetDamageParameters(number, spawncount)
    local pfardist, pfarradius, pfarrate, pneardist, pnearradius, pnearrate = self:GetPaintParameters(number, spawncount)
    local colent, colworld = self:GetCollisionRadii(number, spawncount)
    ---@param ang Angle
    ---@param i integer
    local function Make(ang, i)
        local initvelocity = ang:Forward() * vforward + ang:Right() * vright + ang:Up() * vup
        local yaw = initvelocity:Angle().yaw
        if initvelocity.x == 0 and initvelocity.y == 0 then yaw = ang.yaw end
        table.Merge(self.Projectile, {
            InitVel = initvelocity,
            Type = ss.GetSlosherInkType(i),
            Yaw = yaw,
        })

        ss.SetEffectInitVel(e, self.Projectile.InitVel)
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
        SplashInitRate = util.SharedRandom(randinit, splashinitmin, splashinitmax),
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

    local proj = self.Projectile
    ss.SetEffectColor(e, proj.Color)
    ss.SetEffectColRadius(e, proj.ColRadiusWorld)
    ss.SetEffectDrawRadius(e, self:GetDrawRadius(number, spawncount))
    ss.SetEffectEntity(e, self)
    ss.SetEffectFlags(e, self)
    ss.SetEffectInitPos(e, proj.InitPos)
    ss.SetEffectSplash(e, Angle(proj.SplashColRadius, splashdrawradius, proj.SplashLength / ss.ToHammerUnits))
    ss.SetEffectSplashInitRate(e, Vector(proj.SplashInitRate))
    ss.SetEffectSplashNum(e, proj.SplashNum)
    ss.SetEffectStraightFrame(e, proj.StraightFrame)

    local linenum = p.mLineNum - 1
    local centerline = math.floor(p.mLineNum / 2)
    for i = 0, linenum do
        local dir = self:GetAimVector()
        local ang = dir:Angle()
        if math.NormalizeAngle(ang.pitch) < -72 then
            ang.pitch = -72
            dir = ang:Forward() ---@type Vector
        end

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
    if ply:IsPlayer() then ---@cast ply Player
        if self:GetNWBool "toggleads" then
            if ply:KeyPressed(IN_USE) then
                self:SetADS(not self:GetADS())
            end
        else
            self:SetADS(ply:KeyDown(IN_USE))
        end
    end

    for number, order in ipairs(OrdinalNumbers) do
        local spawnmax       = p["m" .. order .. "GroupBulletNum"]              ---@type number
        local spawnremaining = self["GetSpawnRemaining"   .. number](self)      ---@type number
        local spawntime      = self["GetNextInkSpawnTime" .. number](self)      ---@type number
        local SetRemaining   = self["SetSpawnRemaining"   .. number]            ---@type fun(self, value: number)
        local SetTime        = self["SetNextInkSpawnTime" .. number]            ---@type fun(self, value: number)
        local frameoffset    = p["m" .. order .. "GroupBulletAfterFrameOffset"] ---@type number
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
    ---@class SWEP.Slosher
    ---@field GetADS               fun(self): boolean
    ---@field GetIsBusy            fun(self): boolean
    ---@field GetPreviousHasInk    fun(self): boolean
    ---@field GetNextInkSpawnTime1 fun(self): number
    ---@field GetNextInkSpawnTime2 fun(self): number
    ---@field GetNextInkSpawnTime3 fun(self): number
    ---@field GetSpawnTimeBase     fun(self): number
    ---@field GetSpawnRemaining1   fun(self): integer
    ---@field GetSpawnRemaining2   fun(self): integer
    ---@field GetSpawnRemaining3   fun(self): integer
    ---@field SetADS               fun(self, value: boolean)
    ---@field SetIsBusy            fun(self, value: boolean)
    ---@field SetPreviousHasInk    fun(self, value: boolean)
    ---@field SetNextInkSpawnTime1 fun(self, value: number)
    ---@field SetNextInkSpawnTime2 fun(self, value: number)
    ---@field SetNextInkSpawnTime3 fun(self, value: number)
    ---@field SetSpawnTimeBase     fun(self, value: number)
    ---@field SetSpawnRemaining1   fun(self, value: integer)
    ---@field SetSpawnRemaining2   fun(self, value: integer)
    ---@field SetSpawnRemaining3   fun(self, value: integer)

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
