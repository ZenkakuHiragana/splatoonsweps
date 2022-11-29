
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/props_junk/PopCan01a.mdl"
local drawviewmodel = GetConVar "r_drawviewmodel"
local EmissionDuration = .125
local EmissionDelay = 1 / 125
local LifeSpan = .2
local Swirl = Material "particle/particle_crescent"
local dr = math.rad(30)
local drdt = math.rad(-2700)
local dzDefault = -3
local function Think(self)
    if not IsValid(self.Enttiy) then return end
    local a = self.Entity:GetAttachment(self.Attachment)
    self:SetPos(a.Pos + a.Ang:Forward() * self.Offset + a.Ang:Up() * dzDefault)
    self:SetNextThink(CurTime())
end

function EFFECT:Think()
    if not (self.TPS or drawviewmodel:GetBool()) then return false end
    local v = IsValid(self.Weapon)
    v = v and self.TPS == self.Weapon:IsTPS()
    v = v and self.Weapon:GetCharge() < math.huge
    if not self.Emitter:IsValid() then return false end
    if not v then self.Emitter:Finish() return false end
    local i = self.Attachment
    local ent = self.Entity
    local t = CurTime() - self.Time
    local a = ent:GetAttachment(i)
    local dx = self.TPS and -30 or -15
    local dz = self.TPS and dzDefault or dzDefault / 2
    local dt = EmissionDelay * (self.TPS and 1 or 2)
    self.Emitter:SetPos(a.Pos)
    while t < EmissionDuration and self.Count < math.floor(t / dt) do
        local dx2 = math.Remap(self.Count * dt, EmissionDuration, 0, dx, 0)
        local p = self.Emitter:Add(Swirl, a.Pos + a.Ang:Forward() * dx2 + a.Ang:Up() * dz)
        local r = math.Remap(t, 0, EmissionDuration, 1, 2 - self.Flags)
        p.Attachment, p.Entity, p.Offset = i, ent, dx2
        p:SetColor(self.r, self.g, self.b)
        p:SetDieTime(LifeSpan)
        p:SetRoll(math.Rand(-dr, dr))
        p:SetRollDelta(drdt)
        p:SetStartAlpha(255)
        p:SetEndAlpha(0)
        p:SetStartSize(r * 9)
        p:SetEndSize(r * self.Radius + math.Rand(-3, 3) * self.Flags)
        p:SetThinkFunction(Think)
        p:SetNextThink(CurTime())
        self.Count = self.Count + 1
    end

    if t < EmissionDuration or self.Emitter:GetNumActiveParticles() > 0 then return true end
    self.Emitter:Finish()
    return false
end

function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self:SetNoDraw(true)
    local w = e:GetEntity()
    if not IsValid(w) then return end
    local t = w:IsTPS()
    if not (t or drawviewmodel:GetBool()) then return end
    local ent = t and w or w:GetViewModel()
    local a = ent:LookupAttachment "muzzle"
    local c = ((w:GetInkColorProxy() + ss.vector_one) / 2):ToColor()
    local f = e:GetFlags() -- 0 or 1
    local s = e:GetScale() / (t and 1 or (3 - f))
    local p = ent:GetAttachment(a).Pos
    self.r, self.g, self.b = c.r, c.g, c.b
    self.Attachment = a
    self.Count = 0
    self.Emitter = ParticleEmitter(p, false)
    self.Entity = ent
    self.Flags = f
    self.Radius = s
    self.Time = CurTime()
    self.TPS = t
    self.Weapon = w
end
