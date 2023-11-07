
local ENT = ENT
---@cast ENT ENT.SplatBomb
---@class ENT.SplatBomb : ENT.Throwable
---@field BaseClass ENT.Throwable
---@field BurstTotalFrame        number
---@field CollisionSeSilentFrame number
---@field ContactStartTime       number
---@field ContactTotalTime       number
---@field Detonate               fun(self)
---@field ExplosionOffset        number
---@field GetContactTime         fun(self): number
---@field HitNormal              Vector
---@field HitSound               string
---@field NextPlayHitSE          number
---@field Parameters             SubParameters.SplatBomb
---@field WarnSound              CSoundPatch
---@field WarnSoundPlayed        boolean

AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_throwable"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
ENT.ContactTotalTime = 0
ENT.ExplosionOffset = 0
ENT.HitSound = "SplatoonSWEPs.SplatbombHitWorld"
ENT.IsSplatoonBomb = true
ENT.Model = Model "models/splatoonsweps/subs/splatbomb/splatbomb.mdl"
ENT.NextPlayHitSE = 0
ENT.SubWeaponName = "splatbomb"
ENT.WarnSoundPlayed = false

function ENT:OnRemove()
    if not self.WarnSound then return end
    self.WarnSound:Stop()
end

function ENT:Initialize()
    local p = ss[self.SubWeaponName].Parameters ---@type SubParameters.SplatBomb
    self.Parameters = p
    self.StraightFrame = p.Fly_AirFrm or 0
    self.AirResist = (p.Fly_VelKd or 1) - 1
    self.AngleAirResist = (p.Fly_RotKd or 1) - 1
    self.Gravity = p.Fly_Gravity or 0
    self.BurstTotalFrame = (p.Burst_WaitFrm or 0) + (p.Burst_WarnFrm or 0)
    self.HitNormal = vector_up
    self.CollisionSeSilentFrame = p.CollisionSeSilentFrame or math.huge
    local base = self.BaseClass ---@type ENT|ENT.Throwable
    while base.ClassName ~= "ent_splatoonsweps_throwable" do base = base.BaseClass end
    base.Initialize(self)
    if CLIENT then return end
    self.WarnSound = CreateSound(self, ss.BombAlert)
end

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "InkColorProxy")
end

if CLIENT then return end
function ENT:GetContactTime()
    local t = self.ContactTotalTime
    if not self.ContactStartTime then return t end
    return t + CurTime() - self.ContactStartTime
end

function ENT:Detonate()
    ss.MakeBombExplosion(self:GetPos() + self.HitNormal * self.ExplosionOffset,
    self.HitNormal, self, self:GetNWInt "inkcolor", self.SubWeaponName)
    self:StopSound "SplatoonSWEPs.BombAlert"
    self:StopSound "SplatoonSWEPs.SubWeaponThrown"
    SafeRemoveEntity(self)
end

function ENT:Think()
    self:NextThink(CurTime())
    local p = self:GetPhysicsObject()
    if not IsValid(p) then return true end

    local t = self:GetContactTime()
    if t > self.Parameters.Burst_WaitFrm then -- Brighten and inflate it
        local f = math.Clamp(math.TimeFraction(self.Parameters.Burst_WaitFrm, self.BurstTotalFrame, t), 0, 1)
        local freq = 6 -- Hz
        local pulse = math.sin(2 * math.pi * t * freq)
        self:SetFlexWeight(0, f)
        self:SetSkin(pulse > 0 and 1 or 0)
    end

    if self:GetClass() ~= "ent_splatoonsweps_splatbomb" or p:GetStress() > 0 then
        if self:GetContactTime() > self.BurstTotalFrame then
            self:Detonate()
        end

        if t > self.Parameters.Burst_WaitFrm - self.Parameters.Burst_WarnFrm then
            self.WarnSound:PlayEx(1, 100)
        end
    else
        self.ContactStartTime = nil
        self.ContactTotalTime = t
        self.WarnSound:PlayEx(0, 100)
    end

    return true
end

function ENT:PhysicsCollide(data, collider)
    if data.OurOldVelocity:LengthSqr() > 1000 and CurTime() > self.NextPlayHitSE then
        self:EmitSound(self.HitSound)
        self.NextPlayHitSE = CurTime() + self.CollisionSeSilentFrame
    end

    if self.ContactStartTime then return end
    if data.HitNormal:Dot(ss.GetGravityDirection()) < ss.MAX_COS_DIFF then return end
    self.HitNormal = -data.HitNormal
    self.ContactStartTime = CurTime()
end
