
local ss = SplatoonSWEPs
if not ss then return end
AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model "models/splatoonsweps/subs/inkmine/inkmine.mdl"
ENT.WeaponClassName = ""
ENT.AnimFasterTime = 8
ENT.ExplodeStartTime = 10
ENT.ExplosionDelay = 1
ENT.ExplosionTime = ENT.ExplodeStartTime + ENT.ExplosionDelay
ENT.AlertSoundPlayed = false
function ENT:Initialize()
    if IsValid(self.Owner) then
        local w = ss.IsValidInkling(self.Owner)
        if w then self.WeaponClassName = w:GetClass() end
    end

    self:SetModel(self.Model)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetNWBool("EmitDLight", false)
    self.InitTime = CurTime()
end

if CLIENT then
    function ENT:Think()
        self:SetNextClientThink(CurTime())
        if not self:GetNWBool "EmitDLight" then return true end
        if self.EmitDLight then return true end
        self.EmitDLight = true
        self.InitTime = CurTime() - self.ExplodeStartTime
        local d = DynamicLight(self:EntIndex())
        if not d then return end
        local c = ss.GetColor(self:GetNWInt "inkcolor")
        d.pos = self:GetPos() + self:GetUp() * 10
        d.r, d.g, d.b = c.r, c.g, c.b
        d.brightness = 4
        d.decay = 800
        d.size = 768
        d.dietime = CurTime() + self.ExplosionDelay
        return true
    end

    local LightEffectMaterial = Material "sprites/physg_glow1"
    function ENT:Draw()
        self:DrawModel()
        local t = CurTime() - self.InitTime - self.ExplodeStartTime
        if t < 0 then return end
        local f = math.TimeFraction(0, self.ExplosionDelay, t)
        f = math.EaseInOut(math.Clamp(f, 0, 1), 0.9, 0.1)
        local size = Lerp(f, 600, 60)
        local org = self:GetPos() - self:GetUp() * 8
        local color = ColorAlpha(ss.GetColor(self:GetNWInt "inkcolor"), 255)
        color.r = color.r * 0.75 + 255 * 0.25
        color.g = color.g * 0.75 + 255 * 0.25
        color.b = color.b * 0.75 + 255 * 0.25
        render.SetMaterial(LightEffectMaterial)
        render.DrawSprite(org, size, size, color)
    end

    return
end

function ENT:ShouldExplode()
    local elapsed = CurTime() - self.InitTime
    if elapsed > self.ExplodeStartTime then return true end
    local mins, maxs = self:GetCollisionBounds()
    local gcolor = ss.GetSurfaceColorArea(self:GetPos(), mins, maxs, 1, 15, 0.5)
    if gcolor ~= self:GetNWInt "inkcolor" then return true end
    return false
end

function ENT:Explode()
    if IsValid(self.Weapon) and self.Weapon.NumInkmines then
        self.Weapon.NumInkmines = self.Weapon.NumInkmines - 1
    end
    
    ss.MakeBombExplosion(self:GetPos() + self:GetUp() * 10,
    self:GetUp(), self, self:GetNWInt "inkcolor", "inkmine")
end

function ENT:Think()
    self:NextThink(CurTime())
    local elapsed = CurTime() - self.InitTime
    if elapsed > self.AnimFasterTime then self:SetSkin(1) end
    if elapsed > self.ExplosionTime then
        self:Explode()
        self:Remove()
    end

    if not self.AlertSoundPlayed and self:ShouldExplode() then
        self:SetNWBool("EmitDLight", true)
        self:EmitSound "SplatoonSWEPs.InkmineAlert"
        self.AlertSoundPlayed = true
        self.InitTime = CurTime() - self.ExplodeStartTime
    end

    return true
end
