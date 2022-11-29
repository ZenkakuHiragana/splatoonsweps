
local ss = SplatoonSWEPs
if not ss then return end

local mdl = Model "models/splatoonsweps/effects/sloshing_spiral.mdl"
function EFFECT:Init(e)
    local ang = e:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), e:GetScale())
    self.Duration = e:GetRadius()
    self.DecayTime = CurTime() + self.Duration
    self.InitTime = CurTime()
    self.InitPos = e:GetOrigin()
    self.InitAngle = ang
    self:SetModel(mdl)
    self:SetColor(ss.GetColor(e:GetColor()))
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetPos(self.InitPos)
    self:SetAngles(ang)
end

function EFFECT:Think()
    local t = CurTime() - self.InitTime
    local ang = Angle(self.InitAngle)
    ang:RotateAroundAxis(ang:Forward(), 120 * t / self.Duration)
    self:SetPos(self.InitPos + self:GetForward() * 20 * t / self.Duration)
    self:SetAngles(ang)
    self:SetColor(ColorAlpha(self:GetColor(), 255 * (self.Duration - t) / self.Duration))
    return CurTime() < self.DecayTime
end

function EFFECT:Render()
    self:DrawModel()
end
