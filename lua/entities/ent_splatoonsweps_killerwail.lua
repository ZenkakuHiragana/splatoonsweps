
local ENT = ENT
local ss = SplatoonSWEPs
if not ss then return end

---@cast ENT ENT.KillerWail
---@class ENT.KillerWail : ENT
---@field InitTime         number
---@field InkColor         Vector
---@field NextEmitEffect   number
---@field NextEmitMuzzle   number
---@field NextEmitSplash   number
---@field SoundPlayed      boolean
---@field AdjustPosition   fun(self)
---@field GetInkColorProxy fun(self): Vector

AddCSLuaFile()
ENT.Type = "anim"
ENT.SoundPlayed = false
ENT.InkColor = ss.vector_one

if CLIENT and not killicon.Exists "ent_splatoonsweps_killerwail" then
    local icon = "entities/weapon_splatoonsweps_killerwail.vmt"
    killicon.Add("ent_splatoonsweps_killerwail", icon, color_white)
end

---@return Vector
function ENT:GetInkColorProxy()
    local w = self:GetOwner() ---@cast w SplatoonWeaponBase
    if IsValid(w) then
        self:SetNWInt("inkcolor", w:GetNWInt "inkcolor")
        self.InkColor = w:GetInkColorProxy()
    end
    return self.InkColor
end

local mdl = Model "models/splatoonsweps/specials/killerwail/w_right.mdl"
function ENT:Initialize()
    local w = self:GetOwner() ---@cast w SplatoonWeaponBase
    if not IsValid(w) then
        SafeRemoveEntity(self)
        return
    end

    self:SetModel(mdl)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:EmitSound "SplatoonSWEPs.KillerWailPrefire"
    self.InitTime = CurTime()
    self.NextEmitEffect = CurTime()
    self.NextEmitMuzzle = CurTime()
    self.NextEmitSplash = CurTime()

    if CLIENT then
        local att = self:LookupAttachment "muzzle"
        local p = CreateParticleSystem(self, ss.Particles.BubblerEnd, PATTACH_POINT_FOLLOW, att)
        p:SetControlPoint(1, LerpVector(0.5, self:GetInkColorProxy(), ss.vector_one))
        p:SetControlPoint(2, ss.vector_one * 10)
    end
end

function ENT:OnRemove()
    if SERVER then return end
    local att = self:LookupAttachment "muzzle"
    local muzzle = self:GetAttachment(att).Pos
    local p = CreateParticleSystemNoEntity(ss.Particles.BubblerEnd, muzzle, self:GetAngles())
    p:SetControlPoint(1, LerpVector(0.5, self:GetInkColorProxy(), ss.vector_one))
    p:SetControlPoint(2, ss.vector_one * 20)
end

function ENT:Think()
    local weapon = self:GetOwner() ---@cast weapon SplatoonWeaponBase
    local elapsed = CurTime() - self.InitTime
    local att = self:LookupAttachment "muzzle"
    local muzzle = self:GetAttachment(att).Pos
    local dir = self:GetForward()
    local param = ss.killerwail.Parameters
    if SERVER then
        if elapsed > 4 then SafeRemoveEntity(self) end
        if elapsed > 1 then
            if not self.SoundPlayed then
                self.SoundPlayed = true
                self:EmitSound "SplatoonSWEPs.KillerWail"
            end

            local dmg = DamageInfo()
            dmg:SetDamage(param.DamagePerFrame)
            dmg:SetAttacker(IsValid(weapon) and (IsValid(weapon:GetOwner()) and weapon:GetOwner() or weapon) or game.GetWorld())
            dmg:SetInflictor(self)
            dmg:SetDamageForce(dir)
            dmg:SetDamageType(bit.bor(DMG_AIRBOAT, DMG_REMOVENORAGDOLL))
            dmg:ScaleDamage(ss.ToHammerHealth)
            local size = ss.vector_one * param.Radius
            for _, victim in ipairs(ents.FindAlongRay(
                muzzle + dir * 50, muzzle + dir * 65536, -size, size)) do
                if not IsValid(victim) then continue end
                if victim:Health() <= 0 then continue end
                if victim:GetMaxHealth() <= 0 then continue end
                local w = ss.IsValidInkling(victim)
                if w and ss.IsAlly(weapon, w) then continue end
                dmg:SetDamagePosition(victim:WorldSpaceCenter())
                dmg:SetReportedPosition(muzzle)
                victim:TakeDamageInfo(dmg)
            end
        end
    else
        self:SetNextClientThink(CurTime())
        if CurTime() > self.NextEmitEffect then
            self.NextEmitEffect = CurTime() + (elapsed < 1 and 3 or 1) * ss.FrameToSec
            local color = elapsed < 1 and 0.6 or 0
            local frac = math.random()
            for i = 1, 128 do
                local p = CreateParticleSystemNoEntity(ss.Particles.BlasterTrail,
                    muzzle + dir * (i + frac) * param.Radius / 2, self:GetAngles())
                p:SetControlPoint(1, LerpVector(color, self:GetInkColorProxy(), vector_origin))
                p:SetControlPoint(2, vector_up * param.Radius * Lerp(i / 3, 0.25, 1))
            end
        end

        if CurTime() > self.NextEmitMuzzle then
            self.NextEmitMuzzle = CurTime() + 0.2
            local e = EffectData()
            e:SetEntity(self)
            e:SetOrigin(muzzle)
            e:SetNormal(self:GetForward())
            e:SetRadius(40)
            e:SetFlags(5)
            util.Effect("AR2Explosion", e)
            e:SetNormal(-self:GetForward())
            util.Effect("AR2Explosion", e)
        end

        if CurTime() > self.NextEmitSplash then
            self.NextEmitSplash = CurTime() + 4 * ss.FrameToSec
            for i = 1, 4 do
                local e = EffectData()
                local a = self:GetAttachment(self:LookupAttachment("nozzle" .. i))
                e:SetAngles(a.Ang)
                e:SetAttachment(6)
                e:SetColor(self:GetNWInt "inkcolor")
                e:SetEntity(NULL)
                e:SetFlags(16)
                e:SetOrigin(a.Pos)
                e:SetRadius(15)
                e:SetScale(.4)
                util.Effect("SplatoonSWEPsMuzzleSplash", e)
            end
        end
    end
    self:NextThink(CurTime() + ss.FrameToSec)
    return true
end
