
local ss = SplatoonSWEPs
if not ss then return end
local mat = Material "splatoonsweps/effects/explosion_ink"
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local numframes = 32
function EFFECT:Init(e)
    local f = e:GetFlags()
    local hitwall = bit.band(f, 1) > 0
    local predicted = bit.band(f, 128) > 0
    local maxscale = e:GetRadius() / 120
    local minscale = maxscale / 2
    local color = ss.GetColor(e:GetColor())
    local ping = predicted and LocalPlayer():Ping() / 1000 or 0
    self:SetModel(mdl)
    self:SetMaterial "splatoonsweps/effects/explosion_ink"
    self:SetPos(e:GetOrigin())
    self:SetAngles(AngleRand())
    self:SetColor(color)
    self:SetModelScale(minscale)
    self.Frame = 0
    self.InitTime = CurTime() - ping
    self.MaxScale = maxscale
    self.MinScale = minscale
    local p = CreateParticleSystem(game.GetWorld(), ss.Particles.BlasterExplosion, PATTACH_WORLDORIGIN, 0, self:GetPos())
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, color:ToVector())
    p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * e:GetRadius())
    sound.Play(hitwall and "SplatoonSWEPs.BlasterHitWall" or "SplatoonSWEPs.BlasterExplosion", e:GetOrigin())
end

function EFFECT:Think()
    local t = CurTime() - self.InitTime
    local f = math.floor(t * ss.SecToFrame * 3)
    local frac = math.EaseInOut(f / (numframes - 1), 0.3, 0.3)
    self.Frame = math.Clamp(f, 0, numframes - 1)
    self:SetModelScale(Lerp(frac, self.MinScale, self.MaxScale))
    return f < numframes
end

function EFFECT:Render()
    mat:SetInt("$frame", self.Frame)
    self:DrawModel()
end
