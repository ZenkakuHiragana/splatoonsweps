
local ss = SplatoonSWEPs
if not ss then return end

EFFECT.Alpha = 255
EFFECT.InitRatio = 32
EFFECT.Ratio = EFFECT.InitRatio
EFFECT.Rotated = false
EFFECT.Rotation = 45
local RotationInverseTime = 2 * ss.FrameToSec
local FadeStartTime = 4 * ss.FrameToSec
local LifeTime = 6 * ss.FrameToSec
local LifeTimeCritical = 18 * ss.FrameToSec
local mdl = Model "models/props_junk/PopCan01a.mdl"
local hitnormal = "SplatoonSWEPs.DealDamage"
local hitcritical = "SplatoonSWEPs.DealDamageCritical"
local critsglow = Material "sprites/animglow02"
local function AnimateCritical(self, t)
    if t > LifeTime then
        local f = math.EaseInOut(math.TimeFraction(LifeTime, LifeTimeCritical, t), 0, .75)
        self.Alpha = Lerp(f, 255, 0)
        self.Ratio = Lerp(f, 1, 64)
        self.Size = self.InitSize * Lerp(f, .2, .01)
    else
        local f = math.EaseInOut(t / LifeTime, .5, 0)
        self.Ratio = self.InitRatio
        self.Size = self.InitSize * Lerp(f, 1, .2)
    end
end

function EFFECT:Animate(t)
    if t > FadeStartTime then
        self.Ratio = math.Remap(t, FadeStartTime, LifeTime, self.InitRatio / 8, 1)
        self.Size = self.InitSize * math.Remap(t, FadeStartTime, LifeTime, 2, 4)
        self.Alpha = math.Remap(t, FadeStartTime, LifeTime, 255, 0)
    elseif t > RotationInverseTime then
        if not self.Rotated then
            self.Rotated = true
            self.Rotation = self.Rotation - 90
        end

        self.Ratio = self.InitRatio * math.Remap(t, RotationInverseTime, FadeStartTime, .5, .125)
        self.Size = self.InitSize * math.Remap(t, RotationInverseTime, FadeStartTime, 1, 2)
    else
        self.Ratio = self.InitRatio
        self.Size = self.InitSize * math.Remap(t, 0, RotationInverseTime, 1, .5)
    end
end

function EFFECT:Init(e)
    local ping = ss.mp and bit.band(e:GetFlags(), 128) > 0 and LocalPlayer():Ping() / 1000 or 0
    local c = ss.GetColor(e:GetColor())
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self:SetPos(e:GetOrigin())
    self.Color = (c:ToVector() + ss.vector_one) / 2
    self.Color = self.Color:ToColor()
    self.Flags = e:GetFlags()
    self.InitSize = ScrH() / 40
    self.IsCritical = bit.band(self.Flags, 1) > 0
    self.LifeTime = LifeTime
    self.Material = ss.Materials.Effects.Hit
    self.Rotation = self.Rotation + math.Rand(-45, 45) + math.random(0, 1) * 90
    self.Size = self.InitSize
    self.Time = CurTime() - ping
    if bit.band(self.Flags, 2) > 0 then self.InitSize = self.InitSize * 2 end
    if bit.band(self.Flags, 4) == 0 then
        self:EmitSound(self.IsCritical and hitcritical or hitnormal)
    end

    if not self.IsCritical then return end
    self.Animate = AnimateCritical
    -- self.Color = c
    self.InitSize = self.InitSize * self.InitRatio / 2
    self.InitRatio = 1
    self.LifeTime = LifeTimeCritical
    self.Material = ss.Materials.Effects.HitCritical
    self.Rotation = 0
    local d = DynamicLight(self:EntIndex())
    if not d then return end
    d.pos = self:GetPos()
    d.r, d.g, d.b = self.Color.r, self.Color.g, self.Color.b
    d.brightness = 5
    d.decay = 1000 / LifeTimeCritical
    d.size = 256
    d.dietime = CurTime() + LifeTimeCritical
end

function EFFECT:Render()
    local toscr = self:GetPos():ToScreen()
    if not toscr.visible then return end
    local x, y, t = toscr.x, toscr.y, CurTime() - self.Time
    self:Animate(t)
    cam.Start2D()
    surface.SetDrawColor(ColorAlpha(self.Color, self.Alpha))
    surface.SetMaterial(self.Material)
    surface.DrawTexturedRectRotated(x, y, self.Size * self.Ratio, self.Size, self.Rotation)
    if self.IsCritical then
        surface.SetMaterial(critsglow)
        surface.DrawTexturedRectRotated(x, y, self.Size * self.Ratio, self.Size, self.Rotation)
    end
    cam.End2D()
end

function EFFECT:Think()
    return CurTime() - self.Time < self.LifeTime
end
