
local ss = SplatoonSWEPs
if not ss then return end

local TrailLagTime = 20 * ss.FrameToSec
local ApparentMergeTime = 10 * ss.FrameToSec
local invisiblemat = ss.Materials.Effects.Invisible
local mat = ss.Materials.Effects.Ink
local mdl = Model "models/props_junk/PopCan01a.mdl"
local rollerink1 = Material "splatoonsweps/effects/rollerink1"
local rollerink2 = Material "splatoonsweps/effects/rollerink2"
local inksplash = Material "splatoonsweps/effects/muzzlesplash"
local inkring = Material "splatoonsweps/effects/inkring"
local RenderFuncs = {
    weapon_splatoonsweps_blaster_base = "RenderBlaster",
    weapon_splatoonsweps_roller = "RenderSplash",
    weapon_splatoonsweps_slosher_base = "RenderSlosher",
    weapon_splatoonsweps_sloshingmachine = "RenderSloshingMachine",
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

function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(invisiblemat:GetName())
    local Weapon = ss.GetEffectEntity(e)
    if not IsValid(Weapon) then return end
    if not IsValid(Weapon:GetOwner()) then return end
    local ApparentPos, ApparentAng = Weapon:GetMuzzlePosition()
    if not (ApparentPos and ApparentAng) then return end
    local p = Weapon.Parameters
    local f = ss.GetEffectFlags(e)
    local AirResist = Weapon.Projectile.AirResist
    local ColorID = ss.GetEffectColor(e)
    local ColorValue = ss.GetColor(ColorID)
    local ColRadius = ss.GetEffectColRadius(e)
    local Gravity = Weapon.Projectile.Gravity
    local InitPos = ss.GetEffectInitPos(e)
    local InitVel = ss.GetEffectInitVel(e)
    local InitDir = InitVel:GetNormalized()
    local InitSpeed = InitVel:Length()
    local IsDrop = bit.band(f, 1) > 0
    -- local IsBlasterSphereSplashDrop = bit.band(f, 2) > 0
    -- local IsRollerSubSplash = bit.band(f, 4) > 0
    local IsBombSplash = bit.band(f, 8) > 0
    local IsLP = bit.band(f, 128) > 0 -- IsCarriedByLocalPlayer
    local IsBlaster = Weapon.IsBlaster
    local IsCharger = Weapon.IsCharger
    local IsRoller = Weapon.IsRoller
    local IsSlosher = Weapon.IsSlosher
    local Ping = IsLP and Weapon:Ping() or 0
    local Splash = ss.GetEffectSplash(e)
    local SplashInitRateVector = ss.GetEffectSplashInitRate(e)
    local SplashColRadius = Splash.pitch
    local SplashDrawRadius = Splash.yaw
    local SplashInitRate = SplashInitRateVector.x
    local SplashLength = Splash.roll
    local SplashNum = ss.GetEffectSplashNum(e)
    local StraightFrame = ss.GetEffectStraightFrame(e)
    local DrawRadius = ss.GetEffectDrawRadius(e)
    local RenderFunc = RenderFuncs[Weapon.ClassName] or RenderFuncs[Weapon.Base] or "RenderGeneral"
    local material = math.random() > 0.5 and inksplash or inkring
    if IsSlosher or IsRoller then
        material = math.random() > 0.5 and rollerink1 or rollerink2
        self.Frame = 0
    end

    if DrawRadius == 0 then return end
    if IsBombSplash then
        IsDrop = true
        AirResist = Splash.pitch / 180
        Gravity = Splash.yaw / 180 * ss.InkDropGravity
    end

    if IsDrop then
        ApparentPos = InitPos
        RenderFunc = "RenderGeneral"
    end

    if IsSlosher then
        DrawRadius = DrawRadius / 3
        self.SpiralTime = CurTime() - 5 * ss.FrameToSec - Ping
        self.SpiralCount = 0
    end

    self.Ink = ss.MakeInkQueueStructure()
    self.Ink.Data = table.Merge(ss.MakeProjectileStructure(), {
        AirResist = AirResist,
        Color = ColorID,
        ColRadiusEntity = ColRadius,
        ColRadiusWorld = ColRadius,
        DoDamage = not IsDrop,
        Gravity = Gravity,
        InitPos = InitPos,
        InitVel = InitVel,
        InitDir = InitDir,
        InitSpeed = InitSpeed,
        SplashColRadius = SplashColRadius,
        SplashDrawRadius = SplashDrawRadius,
        SplashInitRate = SplashInitRate,
        SplashLength = SplashLength,
        SplashNum = SplashNum,
        StraightFrame = StraightFrame,
        Weapon = Weapon,
    })
    self.Ink.InitTime = CurTime() - Ping
    self.Ink.IsCarriedByLocalPlayer = IsLP
    self.Ink.Parameters = p
    self.Ink.Owner = IsValid(Weapon) and Weapon:GetOwner() or nil
    self.Ink.Trace.maxs:Mul(ColRadius)
    self.Ink.Trace.mins:Mul(ColRadius)
    self.Ink.Trace.endpos:Set(self.Ink.Data.InitPos)

    self.Color = ColorValue
    self.ColorVector = ColorValue:ToVector()
    self.DrawRadius = math.max(6, DrawRadius)
    self.IsBlaster = not IsDrop and IsBlaster
    self.IsBombSplash = IsBombSplash
    self.IsCharger = IsCharger
    self.IsDrop = IsDrop
    self.IsRoller = IsRoller
    self.IsSlosher = IsSlosher
    self.Render = self[RenderFunc]

    self.ApparentInitPos = ApparentPos
    self.TrailPos = ApparentPos
    self.TrailInitPos = ApparentPos
    self:SetPos(ApparentPos)

    if not (IsRoller or IsSlosher) then return end
    local viewang = -LocalPlayer():GetViewEntity():GetAngles():Forward()
    self.Material = material
    self.Normal = (viewang + VectorRand() / 4):GetNormalized()
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
    self:DrawModel()
    ss.DoDropSplashes(self.Ink, true)
    CreateSpiralEffects(self)

    if self.IsBlaster then
        local p = self.Ink.Parameters
        return t < p.mExplosionFrame or not p.mExplosionSleep
    end

    if self.IsRoller and not self.IsBombSplash then return true end

    local tt = math.max(t - ss.ShooterTrailDelay, 0)
    if self.IsDrop or tt > 0 then
        local tmax = self.Ink.Data.StraightFrame
        local d = self.Ink.Data
        local f = math.Clamp((tt - tmax) / TrailLagTime, 0, 0.8)
        local p = ss.GetBulletPos(d.InitVel, d.StraightFrame, d.AirResist, d.Gravity, tt + f * ss.ShooterTrailDelay)
        self.TrailPos = LerpVector(f, self.TrailInitPos, initpos) + p
        if self.IsDrop and (self.IsCharger or self.IsSlosher) then
            self.TrailPos:Add(d.InitDir * d.SplashLength / 4)
        end

        return true
    end

    self.TrailPos = Weapon:GetMuzzlePosition() -- Stick the tail to the muzzle
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

local cable = Material "splatoonsweps/crosshair/line"
local cabletip = Material "splatoonsweps/crosshair/dot"
function EFFECT:RenderGeneral()
    local sizetip = self.DrawRadius * 0.75
    local AppPos = self:GetPos()
    local TailPos = self.TrailPos
    render.SetMaterial(cabletip)
    render.DrawSprite(TailPos, sizetip, sizetip, self.Color)
    render.DrawSprite(AppPos, sizetip, sizetip, self.Color)
    render.SetMaterial(cable)
    render.DrawBeam(AppPos, TailPos, self.DrawRadius, 0.3, 0.7, self.Color)
end

-- A render function for roller, slosher, etc.
function EFFECT:RenderSplash()
    self.Frame = math.min(math.floor(self.Ink.Trace.LifeTime * 30), 15)
    self.Material:SetInt("$frame", self.Frame)
    local radius = self.DrawRadius * 5
    render.SetMaterial(self.Material)
    render.DrawQuadEasy(self:GetPos(), self.Normal, radius, radius, self:GetRenderColor())
end

function EFFECT:RenderBlaster() -- Blaster bullet
    local color = self:GetRenderColor()
    render.SetMaterial(mat)
    mat:SetVector("$color", self.ColorVector)
    render.DrawSphere(self:GetPos(), self.DrawRadius, 8, 8, color)
    if LocalPlayer():FlashlightIsOn() or #ents.FindByClass "*projectedtexture*" > 0 then
        render.PushFlashlightMode(true) -- Ink lit by player's flashlight or a projected texture
        render.DrawSphere(self:GetPos(), self.DrawRadius, 8, 8, color)
        render.PopFlashlightMode()
    end
end

function EFFECT:RenderSlosher()
    self:RenderGeneral()
    self:RenderSplash()
end

function EFFECT:RenderSloshingMachine()
    if self.DrawRadius == 0 then return end
    local ang = (self:GetPos() - self.TrailPos):Angle()
    ang:RotateAroundAxis(ang:Up(), 45)
    ang:RotateAroundAxis(ang:Right(), 45)
    mat:SetVector("$color", self.ColorVector)
    render.SetMaterial(mat)
    render.DrawBox(self:GetPos(), ang, ss.vector_one * -12, ss.vector_one * 12, self.Color)
    self:RenderGeneral()
end
