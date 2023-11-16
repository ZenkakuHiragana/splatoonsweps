
-- When: in singleplayer, the owner is player, and third person view,
-- Particle effect doesn't attach to the muzzle.

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/props_junk/PopCan01a.mdl"
local drawviewmodel = GetConVar "r_drawviewmodel"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.MuzzleFlash
---@class EFFECT.MuzzleFlash : EFFECT
---@field Weapon      SWEP.Shooter|SWEP.Charger
---@field FlashOnTPS  boolean
---@field Emitter     CLuaEmitter
---@field Particle    CLuaParticle
---@field NewParticle CNewParticleEffect
---@field Ring        CLuaParticle

---Think function for first person muzzle flash
---@param self EFFECT.MuzzleFlash
---@return boolean
local function ThinkFPS(self)
    if not self.NewParticle:IsValid() then return false end
    local v = IsValid(self.Weapon)
    local t = v and self.Weapon:IsTPS()
    v = v and self.FlashOnTPS == t
    if v then return true end
    self.NewParticle:StopEmissionAndDestroyImmediately()
    return false
end

---Think function for third person muzzle flash
---@param self EFFECT.MuzzleFlash
---@return boolean
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
    self.Weapon = e:GetEntity() --[[@as SWEP.Shooter|SWEP.Charger]]
    if not IsValid(self.Weapon) then return end
    self.FlashOnTPS = self.Weapon:IsTPS()
    if not (self.FlashOnTPS or drawviewmodel:GetBool()) then return end
    local ent = self.FlashOnTPS and self.Weapon or self.Weapon:GetViewModel()
    local c = (self.Weapon:GetInkColorProxy() + ss.vector_one) / 2
    local a = ent:LookupAttachment "muzzle"
    local pos = ent:GetAttachment(a).Pos
    if e:GetFlags() == 1 then
        local scale = 15 * (self.Weapon:GetFireAt() + 1)
        ---@param p CLuaParticle
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
            self.Particle = self.Emitter:Add("splatoonsweps/effects/blaster_explosion_impact", pos)
            self.Particle:SetColor(c.x, c.y, c.z)
            self.Particle:SetDieTime(.2)
            self.Particle:SetStartAlpha(255)
            self.Particle:SetEndAlpha(0)
            self.Particle:SetStartSize(scale * 1.5)
            self.Particle:SetEndSize(0)
            self.Particle:SetRoll(math.Rand(0, 2 * math.pi))
            self.Particle:SetNextThink(CurTime())
            self.Particle:SetThinkFunction(SetPos)
        else
            self.NewParticle = CreateParticleSystem(ent, ss.Particles.ChargerMuzzleFlash, PATTACH_POINT_FOLLOW, ent:LookupAttachment "muzzle")
            self.NewParticle:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, c)
            self.NewParticle:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * scale)
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
        self.Particle = self.Emitter:Add("splatoonsweps/effects/flash", pos)
        self.Particle:SetColor(c.x, c.y, c.z)
        self.Particle:SetDieTime(.375)
        self.Particle:SetStartAlpha(255)
        self.Particle:SetEndAlpha(0)
        self.Particle:SetStartSize(11.25)
        self.Particle:SetEndSize(15)
        self.Particle:SetRollDelta(2 * math.pi)
        self.Particle:SetNextThink(CurTime())
        self.Particle:SetThinkFunction(SetPos)
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
        self.NewParticle = CreateParticleSystem(ent, ss.Particles.ChargerFlash, PATTACH_POINT_FOLLOW, ent:LookupAttachment "muzzle")
        self.NewParticle:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, c)
        self.Think = ThinkFPS
    end
end
