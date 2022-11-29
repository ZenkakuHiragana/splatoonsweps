
-- When: in singleplayer, the owner is player, and third person view,
-- Particle effect doesn't attach to the muzzle.

local ss = SplatoonSWEPs
if not ss then return end

local mdl = Model "models/props_junk/PopCan01a.mdl"
local drawviewmodel = GetConVar "r_drawviewmodel"
local function ThinkFPS(self)
    if not self.Flash:IsValid() then return false end
    local v = IsValid(self.Weapon)
    local t = v and self.Weapon:IsTPS()
    v = v and self.FlashOnTPS == t
    if v then return true end
    self.Flash:StopEmissionAndDestroyImmediately()
    return false
end

local function ThinkTPS(self)
    if not self.Emitter:IsValid() then return false end
    local v = IsValid(self.Weapon)
    local t = v and self.Weapon:IsTPS()
    v = v and self.FlashOnTPS == t
    v = v and self.Emitter:GetNumActiveParticles() > 0
    if v then return true end
    self.Emitter:Finish()
    return false
end

function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self:SetNoDraw(true)
    self.Weapon = e:GetEntity()
    if not IsValid(self.Weapon) then return end
    self.FlashOnTPS = self.Weapon:IsTPS()
    if not (self.FlashOnTPS or drawviewmodel:GetBool()) then return end
    local ent = self.FlashOnTPS and self.Weapon or self.Weapon:GetViewModel()
    local c = (self.Weapon:GetInkColorProxy() + ss.vector_one) / 2
    local a = ent:LookupAttachment "muzzle"
    local pos = ent:GetAttachment(a).Pos
    if e:GetFlags() == 1 then
        local scale = 15 * (self.Weapon:GetFireAt() + 1)
        local function SetPos(p)
            if not IsValid(ent) then return end
            local att = ent:GetAttachment(a)
            if att then
                p:SetPos(att.Pos)
                p:SetNextThink(CurTime())
            end
        end

        if ss.sp and self.Weapon:GetOwner():IsPlayer() then
            c:Mul(255)
            self.Emitter = ParticleEmitter(pos)
            self.Flash = self.Emitter:Add("splatoonsweps/effects/blaster_explosion_impact", pos)
            self.Flash:SetColor(c.x, c.y, c.z)
            self.Flash:SetDieTime(.2)
            self.Flash:SetStartAlpha(255)
            self.Flash:SetEndAlpha(0)
            self.Flash:SetStartSize(scale * 1.5)
            self.Flash:SetEndSize(0)
            self.Flash:SetRoll(math.Rand(0, 2 * math.pi))
            self.Flash:SetNextThink(CurTime())
            self.Flash:SetThinkFunction(SetPos)
        else
            self.Flash = CreateParticleSystem(ent, ss.Particles.ChargerMuzzleFlash, PATTACH_POINT_FOLLOW, ent:LookupAttachment "muzzle")
            self.Flash:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, c)
            self.Flash:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * scale)
            self.Think = ThinkFPS
        end

        return
    end

    if ss.sp and self.Weapon:GetOwner():IsPlayer() then
        local function SetPos(p)
            local att = ent:GetAttachment(a)
            if att then
                p:SetPos(att.Pos + att.Ang:Forward() * 2)
                p:SetNextThink(CurTime())
            end
        end

        c:Mul(255)
        self.Emitter = ParticleEmitter(pos)
        self.Flash = self.Emitter:Add("splatoonsweps/effects/flash", pos)
        self.Flash:SetColor(c.x, c.y, c.z)
        self.Flash:SetDieTime(.375)
        self.Flash:SetStartAlpha(255)
        self.Flash:SetEndAlpha(0)
        self.Flash:SetStartSize(11.25)
        self.Flash:SetEndSize(15)
        self.Flash:SetRollDelta(2 * math.pi)
        self.Flash:SetNextThink(CurTime())
        self.Flash:SetThinkFunction(SetPos)
        self.Ring = self.Emitter:Add("particle/particle_ring_sharp_additive", pos)
        self.Ring:SetColor(c.x, c.y, c.z)
        self.Ring:SetDieTime(.28125)
        self.Ring:SetStartAlpha(255)
        self.Ring:SetEndAlpha(0)
        self.Ring:SetStartSize(1.875)
        self.Ring:SetEndSize(10)
        self.Ring:SetNextThink(CurTime())
        self.Ring:SetThinkFunction(SetPos)
        self.Think = ThinkTPS
    else
        self.Flash = CreateParticleSystem(ent, ss.Particles.ChargerFlash, PATTACH_POINT_FOLLOW, ent:LookupAttachment "muzzle")
        self.Flash:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, c)
        self.Think = ThinkFPS
    end
end
