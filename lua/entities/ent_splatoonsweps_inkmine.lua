
local ENT = ENT
---@cast ENT ENT.Inkmine
---@class ENT.Inkmine : ENT
---@field BaseClass ENT
---@field AlertSoundPlayed boolean
---@field AnimFasterTime   number
---@field EmitDLight       boolean
---@field Explode          fun(self)
---@field ExplodeStartTime number
---@field ExplosionDelay   number
---@field ExplosionTime    number
---@field InitTime         number
---@field IsEnemyNearby    fun(self): boolean
---@field IsForgotten      boolean
---@field IsSplatoonBomb   boolean
---@field Model            string
---@field ShouldExplode    fun(self): boolean
---@field Weapon           SplatoonWeaponBase
---@field WeaponClassName  string

AddCSLuaFile()
ENT.Type = "anim"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
ENT.Model = Model "models/splatoonsweps/subs/inkmine/inkmine.mdl"
ENT.WeaponClassName = ""
ENT.AlertSoundPlayed = false
ENT.AnimFasterTime = 8
ENT.ExplodeStartTime = 10
ENT.ExplosionDelay = 1
ENT.ExplosionTime = ENT.ExplodeStartTime + ENT.ExplosionDelay
ENT.IsForgotten = false -- If true, it's successfully removed from the item count in the weapon.
ENT.IsSplatoonBomb = true

function ENT:Initialize()
    if IsValid(self:GetOwner()) then
        local w = ss.IsValidInkling(self:GetOwner())
        if w then self.WeaponClassName = w:GetClass() end
    end

    self:SetModel(self.Model)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetNWBool("EmitDLight", false)
    self.InitTime = CurTime()

    if CLIENT and self:GetOwner() == LocalPlayer() then
        self:EmitSound "SplatoonSWEPs.SubWeaponPut"
    end
end

if CLIENT then
    function ENT:Think()
        self:SetNextClientThink(CurTime())
        if not self:GetNWBool "EmitDLight" then return true end
        if self.EmitDLight then return true end
        self.EmitDLight = true
        self.InitTime = CurTime() - self.ExplodeStartTime
        local d = DynamicLight(self:EntIndex())
        if not d then return true end
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
        local w = ss.IsValidInkling(LocalPlayer())
        if not w then return end
        if self:GetOwner() ~= LocalPlayer() and not ss.IsAlly(self, w) then return end

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

function ENT:IsEnemyNearby()
    local r = ss.inkmine.Parameters.PlayerColRadius
    for _, p in ipairs(ents.FindInSphere(self:GetPos(), r)) do
        if not IsValid(p) then continue end
        if not (p:IsPlayer() or p:IsNPC()) then continue end
        if p == self:GetOwner() then continue end
        local w = ss.IsValidInkling(p)
        if not (w and ss.IsAlly(w, self)) then
            return true
        end
    end

    return false
end

function ENT:ShouldExplode()
    local elapsed = CurTime() - self.InitTime
    if elapsed > self.ExplodeStartTime then return true end
    if self:IsEnemyNearby() then return true end
    local maxs = ss.vector_one * 16
    local mins = -maxs
    local gcolor = ss.GetSurfaceColorArea(self:GetPos(), mins, maxs, 1, 0.5)
    if gcolor ~= self:GetNWInt "inkcolor" then return true end
    return false
end

function ENT:Explode()
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
        if IsValid(self.Weapon) and self.Weapon.NumInkmines and not self.IsForgotten then
            self.Weapon.NumInkmines = self.Weapon.NumInkmines - 1
            self.IsForgotten = true
        end
    end

    return true
end
