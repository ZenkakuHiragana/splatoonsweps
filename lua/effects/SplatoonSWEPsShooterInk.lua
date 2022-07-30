
-- Seems to be unreadable, huh?

local ss = SplatoonSWEPs
if not ss then return end

local TrailLagTime = 4 * ss.FrameToSec
local ApparentMergeTime = 4 * ss.FrameToSec
local mat = ss.Materials.Effects.Ink
local mdl = Model "models/splatoonsweps/effects/ink.mdl"
local ball = Model "models/hunter/misc/sphere025x025.mdl"
local rollerink1 = Material "splatoonsweps/effects/rollerink1"
local rollerink2 = Material "splatoonsweps/effects/rollerink2"
local RenderFuncs = {
    weapon_splatoonsweps_blaster_base        = "RenderBlaster",
    weapon_splatoonsweps_roller              = "RenderSplash",
    weapon_splatoonsweps_slosher_base        = "RenderSlosher",
    weapon_splatoonsweps_sloshingmachine     = "RenderSloshingMachine",
    weapon_splatoonsweps_sloshingmachine_neo = "RenderSloshingMachine",
}
local function CreateSpiralEffects(self)
    if self.IsDrop then return end
    if self.DrawRadius == 0 then return end
    local p = self.Ink.Parameters
    local spiralgroup = p.mSpiralSplashGroup
    if not spiralgroup or spiralgroup == 0 then return end
    local delaymin = p.mSpiralSplashMinSpanFrame
    local delaymax = p.mSpiralSplashMaxSpanFrame
    local timemin = p.mSpiralSplashMinSpanBulletCounter
    local timemax = p.mSpiralSplashMaxSpanBulletCounter
    local timefrac = math.TimeFraction(timemin, timemax, CurTime() - self.Ink.InitTime)
    local delay = Lerp(timefrac, delaymin, delaymax)
    if CurTime() - self.SpiralTime < delay then return end
    local e = EffectData()
    local offset = self.SpiralCount * 360 / p.mSpiralSplashRoundSplitNum
    local num = p.mSpiralSplashSameTimeBulletNum
    e:SetAngles((self:GetPos() - self.TrailPos):Angle())
    e:SetColor(self.Ink.Data.Color)
    e:SetOrigin(self:GetPos())
    e:SetRadius(p.mSpiralSplashLifeFrame)
    e:SetEntity(self)
    for i = 0, num - 1 do
        local step = i * 360 / num
        e:SetScale(step + offset)
        util.Effect("SplatoonSWEPsSloshingSpiral", e)
    end

    self.SpiralTime = CurTime()
    self.SpiralCount = self.SpiralCount + 1
end

-- Flags:
-- +128 Lag compensation for local player
-- +8   Use custom gravity and air resist (GetEffectSplash.pitch and yaw)
-- +2   Explosion drop (unused)
-- +1   Normal drop
function EFFECT:Init(e)
    self:SetModel(mdl)
    local Weapon = ss.GetEffectEntity(e)
    if not IsValid(Weapon) then return end
    if not IsValid(Weapon:GetOwner()) then return end
    local ApparentPos, ApparentAng = Weapon:GetMuzzlePosition()
    local DrawRadius = ss.GetEffectDrawRadius(e)
    if not (ApparentPos and ApparentAng) or DrawRadius == 0 then return end
    local f                = ss.GetEffectFlags(e)
    local ColorID          = ss.GetEffectColor(e)
    local ColorValue       = ss.GetColor(ColorID)
    local ColRadius        = ss.GetEffectColRadius(e)
    local InitPos          = ss.GetEffectInitPos(e)
    local InitVel          = ss.GetEffectInitVel(e)
    local InitDir          = InitVel:GetNormalized()
    local InitSpeed        = InitVel:Length()
    local IsDrop           = bit.band(f, 1) > 0
    local IsLP             = bit.band(f, 128) > 0 -- IsCarriedByLocalPlayer
    local IsBlaster        = Weapon.IsBlaster
    local IsCharger        = Weapon.IsCharger
    local IsRoller         = Weapon.IsRoller
    local IsSlosher        = Weapon.IsSlosher
    local Ping             = IsLP and Weapon:Ping() or 0
    local SplashInfo       = ss.GetEffectSplash(e)
    local SplashInitRate   = ss.GetEffectSplashInitRate(e).x
    local SplashColRadius  = SplashInfo.pitch
    local SplashDrawRadius = SplashInfo.yaw
    local SplashLength     = SplashInfo.roll
    local SplashNum        = ss.GetEffectSplashNum(e)
    local StraightFrame    = ss.GetEffectStraightFrame(e)
    local RenderFunc       = RenderFuncs[Weapon.ClassName] or RenderFuncs[Weapon.Base] or "RenderGeneral"
    local UseCustomGravity = bit.band(f, 8) > 0
    local AirResist        = Weapon.Projectile.AirResist
    local Gravity          = Weapon.Projectile.Gravity
    local TrailInitPos     = ApparentPos
    if UseCustomGravity then
        IsDrop    = true
        AirResist = SplashInfo.pitch / 180
        Gravity   = SplashInfo.yaw / 180 * ss.InkDropGravity
    end

    if IsDrop then
        RenderFunc  = "RenderGeneral"
        if IsCharger then
            ApparentPos = InitPos
            TrailInitPos = -InitDir * SplashLength
            InitVel = Vector()
        else
            ApparentPos = InitPos
            TrailInitPos = InitPos
        end
    end

    if IsSlosher then
        DrawRadius = DrawRadius / 3
        self.SpiralTime = CurTime() - 5 * ss.FrameToSec - Ping
        self.SpiralCount = 0
    end

    self.Ink = ss.MakeInkQueueStructure()
    self.Ink.Data = table.Merge(ss.MakeProjectileStructure(), {
        AirResist        = AirResist,
        Color            = ColorID,
        ColRadiusEntity  = ColRadius,
        ColRadiusWorld   = ColRadius,
        DoDamage         = not IsDrop,
        Gravity          = Gravity,
        InitPos          = InitPos,
        InitVel          = InitVel,
        InitDir          = InitDir,
        InitSpeed        = InitSpeed,
        SplashColRadius  = SplashColRadius,
        SplashDrawRadius = SplashDrawRadius,
        SplashInitRate   = SplashInitRate,
        SplashLength     = SplashLength,
        SplashNum        = SplashNum,
        StraightFrame    = StraightFrame,
        Weapon           = Weapon,
    })
    self.Ink.InitTime   = CurTime() - Ping
    self.Ink.IsCarriedByLocalPlayer = IsLP
    self.Ink.Owner      = IsValid(Weapon) and Weapon:GetOwner() or nil
    self.Ink.Parameters = Weapon.Parameters
    self.Ink.Trace.maxs:Mul(ColRadius)
    self.Ink.Trace.mins:Mul(ColRadius)
    self.Ink.Trace.endpos:Set(self.Ink.Data.InitPos)

    self.Color       = ColorValue
    self.ColorVector = ColorValue:ToVector()
    self.DrawRadius  = math.max(6, DrawRadius)
    self.IsBlaster   = not IsDrop and IsBlaster
    self.IsCharger   = IsCharger
    self.IsDrop      = IsDrop
    self.IsRoller    = IsRoller
    self.IsSlosher   = IsSlosher
    self.Render      = self[RenderFunc]
    self.UseCustomGravity = UseCustomGravity

    self.ApparentInitPos = ApparentPos
    self.TrailPos        = TrailInitPos
    self.TrailInitPos    = TrailInitPos
    self.TrailInitVel    = ApparentAng:Forward() * InitSpeed
    self:SetPos(ApparentPos)
    self:SetAngles(InitDir:Angle())
    self:SetColor(self.Color)

    if self.IsBlaster then
        self:SetModel(ball)
        self:SetMaterial(mat:GetName())
        self:SetModelScale(self.DrawRadius / 6)
    end

    if IsCharger and IsDrop then
        self.TrailPos = ApparentPos - TrailInitPos
    end

    if IsRoller or IsSlosher then
        local viewang  = -LocalPlayer():GetViewEntity():GetAngles():Forward()
        local material = math.random() > 0.5 and rollerink1 or rollerink2
        self.Material = material
        self.Normal   = (viewang + VectorRand() / 4):GetNormalized()
        self.Frame    = 0
        if not IsDrop then
            self:SetModelScale(0.1)
        end
    end
end

function EFFECT:HitEffect(tr) -- World hit effect here
    local e = EffectData()
    e:SetAngles(tr.HitNormal:Angle())
    e:SetAttachment(6)
    e:SetColor(self.Ink.Data.Color)
    e:SetEntity(NULL)
    e:SetFlags(16)
    e:SetOrigin(tr.HitPos - tr.HitNormal * self.DrawRadius)
    e:SetRadius(self.DrawRadius * 5)
    e:SetScale(.4)
    util.Effect("SplatoonSWEPsMuzzleSplash", e)
end

-- Called when the effect should think, return false to kill the effect.
function EFFECT:Think()
    if not self.Ink then return false end
    if not self.Ink.Data then return false end
    local Weapon = self.Ink.Data.Weapon
    if not IsValid(Weapon) then return false end
    if not IsValid(Weapon:GetOwner()) then return false end
    if not ss.IsInWorld(self.Ink.Trace.endpos) then return false end
    ss.AdvanceBullet(self.Ink)

    -- Check collision agains local player
    self.Ink.Trace.filter = ss.MakeAllyFilter(Weapon)
    local tr = util.TraceHull(self.Ink.Trace)
    local trlp = Weapon:GetOwner() ~= LocalPlayer()
    local start, endpos = self.Ink.Trace.start, self.Ink.Trace.endpos
    local t = self.Ink.Trace.LifeTime
    if trlp then trlp = ss.TraceLocalPlayer(start, endpos - start) end
    if tr.HitWorld and self.Ink.Trace.LifeTime > ss.FrameToSec then self:HitEffect(tr) end
    if (tr.Hit or trlp) and not (tr.StartSolid and t < ss.FrameToSec) then return false end

    local initpos = self.Ink.Data.InitPos
    local offset = endpos - initpos
    self:SetPos(LerpVector(math.min(t / ApparentMergeTime, 1), self.ApparentInitPos + offset, endpos))
    self:SetAngles((self.TrailPos - self:GetPos()):Angle())
    ss.DoDropSplashes(self.Ink, true)
    CreateSpiralEffects(self)

    if self.IsBlaster then
        local p = self.Ink.Parameters
        return t < p.mExplosionFrame or not p.mExplosionSleep
    end

    if self.IsRoller and not self.UseCustomGravity then
        return true
    end

    if self.IsCharger and self.IsDrop then
        self.TrailPos = self:GetPos() - self.TrailInitPos
        return true
    end

    local tt = math.max(t - ss.ShooterTrailDelay, 0)
    if self.IsDrop or tt > 0 then
        local tmax = self.Ink.Data.StraightFrame
        local d = self.Ink.Data
        local f = math.Clamp((tt - tmax) / TrailLagTime, 0, 0.75)
        local v = LerpVector(f, self.TrailInitVel, d.InitVel)
        local p = ss.GetBulletPos(v, d.StraightFrame, d.AirResist, d.Gravity, tt + f * ss.ShooterTrailDelay)
        self.TrailPos = LerpVector(f, self.TrailInitPos, initpos) + p
        if self.IsDrop and (self.IsCharger or self.IsSlosher) then
            self.TrailPos:Add(d.InitDir * d.SplashLength / 4)
        end

        return true
    end

    self.TrailPos = Weapon:GetMuzzlePosition() -- Stick the tail to the muzzle
    self.TrailInitVel = Weapon:GetAimVector() * self.Ink.Data.InitSpeed
    self.TrailInitPos = self.TrailPos
    return true
end

local MaxTranslucentDistSqr = 120
MaxTranslucentDistSqr = 1 / MaxTranslucentDistSqr^2
function EFFECT:GetRenderColor()
    local frac = EyePos():DistToSqr(self:GetPos()) * MaxTranslucentDistSqr
    local alpha = Lerp(frac, 0, 255)
    return ColorAlpha(self.Color, alpha)
end

function EFFECT:RenderGeneral()
    local m = Matrix()
    local trailLength = self:GetPos():Distance(self.TrailPos)
    m:Scale(Vector(trailLength / 6, 1, 1))
    self:EnableMatrix("RenderMultiply", m)
    self:DrawModel()
end

-- A render function for roller, slosher, etc.
function EFFECT:RenderSplash()
    local radius = self.DrawRadius * 5
    local alpha = self:GetRenderColor().a
    self.Frame = math.min(math.floor(self.Ink.Trace.LifeTime * 30), 15)
    self.Material:SetInt("$frame", self.Frame)
    self.Material:SetVector("$color", self.ColorVector)
    self.Material:SetFloat("$alpha", alpha / 255)
    self:DrawModel()
    render.SetMaterial(self.Material)
    render.DrawQuadEasy(self:GetPos(), self.Normal, radius, radius, self.Color)
end

function EFFECT:RenderBlaster() -- Blaster bullet
    self:DrawModel()
end

function EFFECT:RenderSlosher()
    self:RenderGeneral()
    self:RenderSplash()
end

function EFFECT:RenderSloshingMachine()
    if self.DrawRadius == 0 then return end
    self:SetModelScale(2)
    self:RenderGeneral()
end
