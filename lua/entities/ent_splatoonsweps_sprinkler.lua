
local ENT = ENT
---@cast ENT ENT.Sprinkler
---@class ENT.Sprinkler : ENT.SplatBomb
---@field BaseClass ENT.SplatBomb
---@field DestroyOnLand     Entity
---@field GetMuzzlePosition fun(self): Vector, Angle
---@field NextSpoutTime     number
---@field Parameters        SubParameters.Sprinkler
---@field RunningSound      CSoundPatch
---@field Spout             fun(self)
---@field Weapon            Weapon

AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_splatbomb"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
ENT.AutomaticFrameAdvance = true
ENT.HitSound = "SplatoonSWEPs.SubWeaponPut"
ENT.Model = Model "models/splatoonsweps/subs/sprinkler/sprinkler.mdl"
ENT.RunningSound = nil
ENT.SubWeaponName = "sprinkler"
ENT.NextSpoutTime = CurTime()

if CLIENT then
    function ENT:FireAnimationEvent(pos, ang, event, options)
        return ss.FireAnimationEvent(self, pos, ang, event, options)
    end

    function ENT:GetMuzzlePosition()
        local a = self:GetAttachment(self:LookupAttachment "muzzle_1")
        return a.Pos, a.Ang
    end

    return
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self:SetMaxHealth(100)
    self:SetHealth(self:GetMaxHealth())
end

function ENT:OnRemove()
    local p = self:GetPos()
    local n = self.HitNormal
    local e = EffectData()
    e:SetOrigin(p)
    e:SetNormal(n)
    e:SetScale(3)
    e:SetMagnitude(2)
    e:SetRadius(5)
    util.Effect("Sparks", e)
    self:EmitSound "SplatoonSWEPs.SubWeaponDestroy"
    if self.RunningSound then self.RunningSound:Stop() end
end

function ENT:OnTakeDamage(d)
    local health = self:Health()
    self:SetHealth(math.max(0, health - d:GetDamage()))
    if self:Health() > 0 then return d:GetDamage() end
    SafeRemoveEntity(self)
    return health
end

function ENT:Spout()
    if not IsValid(self.Weapon) then return end
    local ink = ss.MakeProjectileStructure()
    local p = self.Parameters
    table.Merge(ink, {
        AirResist = p.Spout_AirResist,
        Color = self:GetNWInt "inkcolor",
        ColRadiusEntity = p.Spout_SplashCollisionR_First,
        ColRadiusWorld = p.Spout_SplashCollisionR_First,
        DoDamage = true,
        DamageMax = p.Spout_SplashDamage,
        DamageMin = p.Spout_SplashDamage,
        Gravity = p.Spout_Gravity,
        ID = CurTime() + self:EntIndex(),
        PaintFarDistance = p.Spout_SplashPaintR_MinHeight,
        PaintFarRadius = p.Spout_SplashPaintR_First * p.Spout_SplashPaintR_MinRate,
        PaintFarRatio = p.Spout_FarRatio,
        PaintNearDistance = p.Spout_SplashPaintR_MaxHeight,
        PaintNearRadius = p.Spout_SplashPaintR_First,
        PaintNearRatio = p.Spout_NearRatio,
        PaintRatioFarDistance = p.Spout_FarRatioD,
        PaintRatioNearDistance = p.Spout_NearRatioD,
        StraightFrame = p.Spout_StraightFrame,
        Type = ss.GetShooterInkType(),
        Weapon = self.Weapon,
    })

    local DegBias = p.Spout_SplashDegBias
    local DegRand = p.Spout_RandomDeg
    local PitchH = p.Spout_SplashPitH
    local PitchL = p.Spout_SplashPitL
    local VelH = p.Spout_SplashVelH_First
    local VelL = p.Spout_SplashVelL_First
    for i = 1, 2 do
        local an = string.format("muzzle_%d", i)
        local ai = self:LookupAttachment(an)
        local a = self:GetAttachment(ai)
        local _, localang = WorldToLocal(Vector(), a.Ang, Vector(), self:GetAngles())
        localang.pitch = -math.Rand(PitchL, PitchH)
        localang.yaw = localang.yaw + ss.GetBiasedRandom(DegBias) * DegRand
        local _, ang = LocalToWorld(Vector(), localang, Vector(), self:GetAngles())
        local dir = ang:Forward()
        ss.AddInk({}, table.Merge(ink, {
            InitPos = a.Pos,
            InitVel = dir * math.Rand(VelL, VelH),
            Yaw     = ang.yaw,
        }))

        local e = EffectData()
        ss.SetEffectColor(e, ink.Color)
        ss.SetEffectColRadius(e, ink.ColRadiusWorld)
        ss.SetEffectDrawRadius(e, p.Spout_SplashDrawR_First)
        ss.SetEffectEntity(e, ink.Weapon)
        ss.SetEffectFlags(e, ink.Weapon, 8 + 4 + 1)
        ss.SetEffectInitPos(e, ink.InitPos)
        ss.SetEffectInitVel(e, ink.InitVel)
        ss.SetEffectSplash(e, Angle(ink.AirResist * 180, ink.Gravity / ss.InkDropGravity * 180))
        ss.SetEffectSplashInitRate(e, Vector(0))
        ss.SetEffectSplashNum(e, 0)
        ss.SetEffectStraightFrame(e, ink.StraightFrame)
        util.Effect("SplatoonSWEPsShooterInk", e)
    end
end

function ENT:Think()
    if not IsValid(self.Weapon)
    or not IsValid(self:GetOwner())
    or self:GetOwner():Health() == 0 then
        SafeRemoveEntity(self)
    end

    self:NextThink(CurTime())
    if not self.ContactStartTime then return true end
    if CurTime() < self.NextSpoutTime then return true end
    self.NextSpoutTime = CurTime() + self.Parameters.Spout_Span_First
    if IsValid(self.Weapon) then
        self:SetNWInt("inkcolor", self.Weapon:GetNWInt "inkcolor")
        local color = ss.GetColor(self:GetNWInt "inkcolor")
        if color then self:SetInkColorProxy(color:ToVector()) end
    end

    self:Spout()
    return true
end

function ENT:PhysicsCollide(data, collider)
    if self:IsStuck() then return end
    self.BaseClass.PhysicsCollide(self, data, collider)
    local n = -data.HitNormal
    local ang = n:Angle()
    local v = collider:GetVelocity()
    local v2d = v - n * n:Dot(v)
    local vn = v2d:GetNormalized()
    local dot = vn:Dot(ang:Right())
    local sign = vn:Dot(ang:Up()) > 0 and -1 or 1
    local deg = math.deg(math.acos(dot)) * sign
    ang:RotateAroundAxis(ang:Forward(), deg)
    ang:RotateAroundAxis(ang:Right(), -90)
    collider:EnableMotion(not data.HitEntity:IsWorld())
    collider:EnableGravity(true)
    collider:SetPos(data.HitPos)
    collider:SetAngles(ang)

    timer.Simple(0.125, function()
        if not IsValid(self) then return end
        self:ResetSequenceInfo()
        if self.RunningSound then return end
        self.RunningSound = CreateSound(self, ss.SprinklerRunning)
        self.RunningSound:Play()
    end)

    self.HitNormal = -data.HitNormal
    self.ContactEntity = data.HitEntity
    self.ContactPhysObj = data.HitObject
    self.ContactStartTime = self.ContactStartTime or CurTime()
    self:Weld()
    self:SetSequence "sprinkle"
    self:SetNWFloat("t0", CurTime())
    self:SetNWBool("hit", true)

    local inkcolor = self:GetNWInt "inkcolor"
    ss.Paint(data.HitPos, self.HitNormal, self.Parameters.InitInkRadius,
    inkcolor, 0, ss.GetDropType(), 1, self:GetOwner(), self.WeaponClassName)

    if IsValid(self.DestroyOnLand) then
        SafeRemoveEntity(self.DestroyOnLand)
    end
end
