
local ss = SplatoonSWEPs
if not ss then return end
local mat = Material "splatoonsweps/effects/explosion_ink"
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local numframes = 32
function EFFECT:Init(e)
    local maxscale = e:GetRadius() / 100
    local minscale = maxscale / 2
    local color = ss.GetColor(e:GetColor())
    self:SetModel(mdl)
    self:SetMaterial "splatoonsweps/effects/explosion_ink"
    self:SetPos(e:GetOrigin())
    self:SetAngles(AngleRand())
    self:SetColor(color)
    self:SetModelScale(minscale)
    self.Color = e:GetColor()
    self.Frame = 0
    self.InitTime = CurTime()
    self.IsSubExplosion = e:GetFlags() > 0
    self.MaxScale = maxscale
    self.MinScale = minscale
    self.Radius = e:GetRadius()
    if self.IsSubExplosion then return end
    local p = CreateParticleSystem(game.GetWorld(), ss.Particles.BombExplosion, PATTACH_WORLDORIGIN, 0, self:GetPos())
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, color:ToVector())
    p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * self.Radius)
end

function EFFECT:Think()
    local animspeed = self.IsSubExplosion and 5 or 10
    local t = CurTime() - self.InitTime
    local f = math.floor(t * ss.SecToFrame * animspeed)
    local linearfrac = f / (numframes - 1)
    local frac = math.EaseInOut(linearfrac, 0.3, 0.3)
    self.Frame = math.Clamp(f, 0, numframes - 1)
    self:SetModelScale(Lerp(frac, self.MinScale, self.MaxScale))
    if not (self.IsSubExplosion or self.SubExplosionEmitted) and linearfrac > 1 then
        local e = EffectData()
        e:SetColor(self.Color)
        e:SetFlags(1)
        e:SetOrigin(self:GetPos())
        e:SetRadius(self.Radius)
        util.Effect("SplatoonSWEPsExplosion", e)
        self.SubExplosionEmitted = true
    end

    return f < numframes
end

function EFFECT:Render()
    mat:SetInt("$frame", self.Frame)
    self:DrawModel()
end
