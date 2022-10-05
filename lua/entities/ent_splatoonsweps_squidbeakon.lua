
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_throwable"

local ss = SplatoonSWEPs
if not ss then return end
ENT.AutomaticFrameAdvance = true
ENT.Model = Model "models/splatoonsweps/subs/squidbeakon/squidbeakon.mdl"
ENT.SubWeaponName = "squidbeakon"
ENT.WeaponClassName = ""
ENT.IsSplatoonBomb = true
ENT.IsSquidBeakon = true

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "InkColorProxy")
    self:NetworkVar("Float", 0, "LightEmitTime")

    -- 1, 2, 3, 4 -> emitting (1), resting, emitting (2), interval
    self:NetworkVar("Int", 0, "LightEmitState")
end

function ENT:Initialize()
    if IsValid(self:GetOwner()) then
        local w = ss.IsValidInkling(self:GetOwner())
        if w then self.WeaponClassName = w:GetClass() end
    end

    local p = ss[self.SubWeaponName].Parameters
    self.Parameters = p
    self.LightEmitTimeTable = { p.LightEmitTime, p.LightEmitRestTime, p.LightEmitTime, p.LightEmitInterval }
    self.StraightFrame = p.Fly_AirFrm or 0
    self.AirResist = (p.Fly_VelKd or 1) - 1
    self.AngleAirResist = (p.Fly_RotKd or 1) - 1
    self.Gravity = p.Fly_Gravity or 0

    local base = self.BaseClass
    while base.ClassName ~= "ent_splatoonsweps_throwable" do base = base.BaseClass end
    base.Initialize(self)
    self:ResetSequence "deploy"
    self:SetSkin(1)
    self:SetLightEmitState(1)
    self:SetLightEmitTime(CurTime() + p.LightEmitInitialDelay)

    self.MinimapEffectTime = CurTime() + p.LightEmitInitialDelay
    self.MinimapEffectDuration = 0
    for _, t in ipairs(self.LightEmitTimeTable) do
        self.MinimapEffectDuration = self.MinimapEffectDuration + t
    end
    self.MinimapEffectInterval = self.MinimapEffectDuration * 2
    timer.Simple(p.DeploySoundDelay, function()
        if not IsValid(self) then return end
        self:EmitSound "SplatoonSWEPs.BeakonDeploy"
    end)

    if SERVER then
        self:SetMaxHealth(100)
        self:SetHealth(self:GetMaxHealth())
        self:SetNWFloat("DeployFinishedTime", -1)
    else
        if self:GetOwner() ~= LocalPlayer() then return end
        self:EmitSound "SplatoonSWEPs.SubWeaponPut"
    end
end

function ENT:UpdateLightEmission()
    local t0 = self:GetLightEmitTime()
    local t = CurTime() - t0
    if t <= 0 then self:SetSkin(1) return end

    local state = self:GetLightEmitState()
    self:SetSkin((state == 1 or state == 3) and 0 or 1)

    if t < self.LightEmitTimeTable[state] then return end
    self:SetLightEmitTime(CurTime())
    self:SetLightEmitState(state + 1)
    if state > 3 then
        self:SetLightEmitState(1)
    elseif SERVER and state == 1 then
        self:EmitSound "SplatoonSWEPs.BeakonIdle"
    end
end

function ENT:UpdateMinimapEffect()
    local t = CurTime() - self.MinimapEffectTime
    if t > self.MinimapEffectInterval then
        self.MinimapEffectTime = CurTime()
    end
end

if CLIENT then
    function ENT:Think()
        self:SetNextClientThink(CurTime())
        self:UpdateLightEmission()
        self:UpdateMinimapEffect()

        local td = self:GetNWFloat "DeployFinishedTime"
        if td <= 0 then return true end

        local dt = CurTime() - td
        if dt <= 0 then return true end

        local bone = self:LookupBone "neck"
        local pitch = dt * self.Parameters.RotationSpeed
        self:ManipulateBoneAngles(bone, Angle(pitch, 0, 0))

        return true
    end

    function ENT:Draw()
        self:DrawModel()
    end

    return
end

function ENT:OnRemove()
    local p = self:GetPos()
    local n = self.HitNormal or vector_up
    local e = EffectData()
    e:SetOrigin(p)
    e:SetNormal(n)
    e:SetScale(3)
    e:SetMagnitude(2)
    e:SetRadius(5)
    util.Effect("Sparks", e)
    self:EmitSound "SplatoonSWEPs.SubWeaponDestroy"

    if IsValid(self.Weapon) and self.Weapon.NumBeakons then
        self.Weapon.NumBeakons = self.Weapon.NumBeakons - 1
    end
end

function ENT:OnTakeDamage(d)
    local health = self:Health()
    self:SetHealth(math.max(0, health - d:GetDamage()))
    if self:Health() > 0 then return d:GetDamage() end
    SafeRemoveEntity(self)
    return health
end

ENT.NextRadioPlayTime = CurTime()
function ENT:UpdateRadio()
    if self:GetNWFloat "DeployFinishedTime" < 0 then return end
    if CurTime() < self.NextRadioPlayTime then return end
    self.NextRadioPlayTime = CurTime() + self.Parameters.RadioPlayInterval
    self:EmitSound "SplatoonSWEPs.BeakonRadio"
end

function ENT:Think()
    self:NextThink(CurTime())
    self:UpdateLightEmission()
    self:UpdateRadio()

    if IsValid(self.Weapon) and IsValid(self.Weapon:GetOwner()) and self.Weapon:GetOwner():Health() > 0 then
        self:SetNWInt("inkcolor", self.Weapon:GetNWInt "inkcolor")
        local color = ss.GetColor(self:GetNWInt "inkcolor")
        if color then self:SetInkColorProxy(color:ToVector()) end
    end

    if self:GetSequence() ~= self:LookupSequence "idle" and self:IsSequenceFinished() then
        self:ResetSequence "idle"
        self:SetNWFloat("DeployFinishedTime", CurTime() + self.Parameters.RotationDelay)
    end

    return true
end

function ENT:PhysicsCollide(data, collider)
    if self:IsStuck() then return end
    self.BaseClass.PhysicsCollide(self, data, collider)
    collider:EnableMotion(not data.HitEntity:IsWorld())

    self.HitNormal = -data.HitNormal
    self.ContactEntity = data.HitEntity
    self.ContactPhysObj = data.HitObject
    self.ContactStartTime = self.ContactStartTime or CurTime()
    self:Weld()
end
