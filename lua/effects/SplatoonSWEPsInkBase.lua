
local ss = SplatoonSWEPs
if not ss then return end

EFFECT.ApparentMergeTime = 4 * ss.FrameToSec
EFFECT.TrailLagTime      = 4 * ss.FrameToSec

EFFECT.InkMaterialName   = ss.Materials.Effects.Ink:GetName()
EFFECT.Model             = Model "models/splatoonsweps/effects/ink.mdl"

EFFECT.HandleTrail = true
EFFECT.MinDrawRadius = 6

EFFECT.MaxTranslucentDistSqr = 30 ^ 2
EFFECT.TrailLengthScaleConstant = 6

function EFFECT:Init(e)
    self.Weapon = ss.GetEffectEntity(e)
    if not IsValid(self.Weapon) then return end
    if not IsValid(self.Weapon:GetOwner()) then return end

    local MuzzlePos, MuzzleAng = self.Weapon:GetMuzzlePosition()
    if not (MuzzlePos and MuzzleAng) then return end

    local f = ss.GetEffectFlags(e)
    local IsLocalPlayer = bit.band(f, 128) > 0
    local ping = IsLocalPlayer and self.Weapon:Ping() or 0
    self.Apparent = {
        CurrentAng = MuzzleAng,
        CurrentPos = MuzzlePos,
        InitPos    = MuzzlePos,
    }
    self.ColorID     = self.Weapon:GetNWInt "inkcolor"
    self.ColorValue  = ss.GetColor(self.ColorID)
    self.ColorVector = self.ColorValue:ToVector()
    self.DrawRadius  = math.max(self.MinDrawRadius, ss.GetEffectDrawRadius(e))
    self.IsDrop      = bit.band(f, 64) > 0
    self.Ink         = ss.MakeInkQueueStructure()
    self.Ink.Data    = table.Merge(ss.MakeProjectileStructure(), {
        Color      = self.ColorID,
        DoDamage   = not self.IsDrop,
        Owner      = self.Weapon:GetOwner(),
        InitPos    = ss.GetEffectInitPos(e),
        InitDir    = ss.GetEffectInitDir(e),
        InitSpeed  = ss.GetEffectInitSpeed(e),
        InitTime   = CurTime() - ping,
        Parameters = self.Weapon.Parameters,
    })
    self.Weapon:CollectEffectData(self, e)
    self.Ink.Trace.maxs:Mul(self.Ink.Data.ColRadiusWorld)
    self.Ink.Trace.mins:Mul(self.Ink.Data.ColRadiusWorld)
    self.Ink.Trace.endpos = self.Ink.Data.InitPos
    self.Is = {
        Blaster = self.Weapon.IsBlaster,
        Charger = self.Weapon.IsCharger,
        Drop    = bit.band(f, 1) > 0,
        Roller  = self.Weapon.IsRoller,
        Slosher = self.Weapon.IsSlosher,
    }
    self.Trail = {
        CurrentPos = MuzzlePos,
        InitPos    = MuzzlePos,
        InitVel    = MuzzleAng:Forward() * self.Ink.Data.InitSpeed,
    }

    self:SetModel(self.Model)
    self:SetMaterial(self.InkMaterialName)
    self:SetColor(self.ColorValue)
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

function EFFECT:Think()
    if not IsValid(self.Weapon) then return false end
    if not IsValid(self.Weapon:GetOwner()) then return false end
    if not ss.IsInWorld(self.Ink.Trace.endpos) then return false end
    ss.AdvanceBullet(self.Ink)
    ss.DoDropSplashes(self.Ink, true)

    -- Check collision against local player
    self.Ink.Trace.filter = ss.MakeAllyFilter(self.Weapon)
    local tr = util.TraceHull(self.Ink.Trace)
    local lp = self.Weapon:IsCarriedByLocalPlayer()
    local start = self.Ink.Trace.start
    local endpos = self.Ink.Trace.endpos
    local trlp = not lp and ss.TraceLocalPlayer(start, endpos - start)
    local t = self.Ink.Trace.LifeTime
    if tr.HitWorld and t > ss.FrameToSec then self:HitEffect(tr) end
    if (tr.Hit or trlp) and not (tr.StartSolid and t < ss.FrameToSec) then return false end

    -- Set current apparent position and angle
    local offset = endpos - self.Ink.Data.InitPos
    local frac = math.min(t / self.ApparentMergeTime, 1)
    self:SetPos(LerpVector(frac, self.Apparent.InitPos + offset, endpos))
    self:SetAngles((self.Trail.CurrentPos - self:GetPos()):Angle())

    if not self.HandleTrail then return true end
    local tt = math.max(t - ss.ShooterTrailDelay, 0)
    if self.Is.Drop or tt > 0 then
        local tmax = self.Ink.Data.StraightFrame
        local d = self.Ink.Data
        local f = math.Clamp((tt - tmax) / self.TrailLagTime, 0, 0.75)
        local v = LerpVector(f, self.Trail.InitVel, d.InitVel)
        local p = ss.GetBulletPos(v, d.StraightFrame, d.AirResist, d.Gravity, tt + f * ss.ShooterTrailDelay)
        self.Trail.CurrentPos = LerpVector(f, self.Trail.InitPos, d.InitPos) + p
        if self.IsDrop and (self.Is.Charger or self.Is.Slosher) then
            self.Trail.CurrentPos:Add(d.InitDir * d.SplashLength / 4)
        end
    else
        self.Trail.CurrentPos = self.Weapon:GetMuzzlePosition() -- Stick the tail to the muzzle
        self.Trail.InitPos = self.Trail.CurrentPos
        self.Trail.InitVel = self.Weapon:GetAimVector() * self.Ink.Data.InitSpeed
    end

    return true
end

function EFFECT:GetRenderColor()
    local frac = EyePos():DistToSqr(self:GetPos()) / self.MaxTranslucentDistSqr
    return ColorAlpha(self.Color, Lerp(frac, 0, 255))
end

function EFFECT:Render()
    local m = Matrix()
    local trailLength = self:GetPos():Distance(self.Trail.CurrentPos)
    debugoverlay.Line(self.Ink.Trace.start, self.Ink.Trace.endpos, 0.1, Color(0, 255, 0), true)
    m:Scale(Vector(trailLength / self.TrailLengthScaleConstant, 1, 1))
    self:EnableMatrix("RenderMultiply", m)
    self:DrawModel()
end
