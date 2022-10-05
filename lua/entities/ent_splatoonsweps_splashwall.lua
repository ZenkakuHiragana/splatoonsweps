
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_throwable"

local ss = SplatoonSWEPs
if not ss then return end
ENT.AutomaticFrameAdvance = true
ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.Model = Model "models/splatoonsweps/subs/splashwall/splashwall.mdl"
ENT.SubWeaponName = "splashwall"
ENT.IsFirstTimeContact = true

function ENT:Initialize()
    local p = ss[self.SubWeaponName].Parameters
    self.Parameters = p
    self.StraightFrame = p.Fly_AirFrm
    self.AirResist = p.Fly_VelKd - 1
    self.AngleAirResist = p.Fly_RotKd - 1
    self.GravityHold = p.Fly_Gravity
    self.Gravity = p.Fly_Gravity
    self.HitNormal = vector_up
    self.DragCoeffChangeTime = CurTime() + self.StraightFrame
    self.BaseClass.Initialize(self)
    self.RunningSound = CreateSound(self, ss.SplashWallRunning)
    self:SetSequence "folded"
    self:SetUnfolded(false)
    self:MakeCollisionMesh()
    self:AddEFlags(EFL_DONTBLOCKLOS)
    if SERVER then
        self:SetMaxHealth(p.mMaxHp * ss.ToHammerHealth)
        self:SetHealth(self:GetMaxHealth())
    else
        self.ParticleEffects = {}
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Unfolded")
    self:NetworkVar("Vector", 0, "InkColorProxy")
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

function ENT:TracePaint()
    local t = util.QuickTrace(self:GetPos(), -vector_up * 10, self)
    if not t.Hit then return end
    ss.Paint(t.HitPos, t.HitNormal, self.TracePaintRadius, self:GetNWInt "inkcolor",
    self:GetAngles().yaw + 90, math.random(10, 12), 0.5, self:GetOwner(), self.WeaponClassName)
end

function ENT:MakeCollisionMesh()
    local mins, maxs = self:GetCollisionBounds()
    self.CollisionMesh = {
        Vector(mins.x, mins.y, mins.z),
        Vector(mins.x, mins.y, maxs.z),
        Vector(mins.x, maxs.y, mins.z),
        Vector(mins.x, maxs.y, maxs.z),
        Vector(maxs.x, mins.y, mins.z),
        Vector(maxs.x, mins.y, maxs.z),
        Vector(maxs.x, maxs.y, mins.z),
        Vector(maxs.x, maxs.y, maxs.z),
    }
end

if CLIENT then
    ENT.PhysObjChanged = false
    ENT.NextEmissionTime = CurTime()
    ENT.EmissionInterval = 0.2
    function ENT:Think()
        self:SetNextClientThink(CurTime())
        if not self:GetUnfolded() then return true end
        if #self.ParticleEffects > 0 then return end
        if CurTime() < self.NextEmissionTime then return true end
        self.NextEmissionTime = CurTime() + self.EmissionInterval

        if not self.PhysObjChanged then
            self.PhysObjChanged = true
            self:PhysicsInitConvex(self.CollisionMesh)
            self:EnableCustomCollisions(true)
        end

        local scale = 8
        local color = ss.GetColor(self:GetNWInt "inkcolor"):ToVector()
        for i, att in ipairs(self:GetAttachments()) do
            local p = CreateParticleSystem(self, ss.Particles.SplashWall, PATTACH_POINT_FOLLOW, att.id, self:GetPos())
            p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, color)
            p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * scale)
            self.ParticleEffects[i] = p
        end

        return true
    end

    return
end

ENT.NextPaintTime = CurTime()
function ENT:Paint()
    if not self:GetUnfolded() then return end
    if CurTime() < self.NextPaintTime then return end
    self.NextPaintTime = CurTime() + self.Parameters.mPaintRepeatFrame

    local ratio = 0.6
    local radius = self.Parameters.mPaintWidth / 2
    local inkcolor = self:GetNWInt "inkcolor"
    local atts = self:GetAttachments()
    local dz = self:OBBMaxs().z
    local paintPos = {}
    for _, att in ipairs(atts) do
        -- get rid of leftmost/rightmost nozzle
        if not (att.name:find "7" or att.name:find "6") then
            local a = self:GetAttachment(att.id)
            local t = util.QuickTrace(a.Pos, a.Ang:Forward() * dz, self)
            if ss.GetSurfaceColor(t) ~= inkcolor then
                table.insert(paintPos, t)
            end
        end
    end

    for _, t in ipairs(paintPos) do
        ss.Paint(t.HitPos, t.HitNormal, radius / ratio, inkcolor, self:GetAngles().yaw + 90,
        ss.GetDropType(), ratio, self:GetOwner(), self.WeaponClassName)
    end
end

function ENT:OnTakeDamage(d)
    local health = self:Health()
    self:SetHealth(math.max(0, self:Health() - d:GetDamage()))
    if health > 0 and self:Health() == 0 then
        self.DestroyWaitStartTime = CurTime()
    end

    return d:GetDamage()
end

function ENT:Think()
    self:NextThink(CurTime())
    local p = self:GetPhysicsObject()
    if not IsValid(p) then return true end
    if not self.ContactStartTime then return end

    local i = self:GetFlexIDByName "InkAmount"
    if self.DestroyWaitStartTime then
        self:SetFlexWeight(i, 1)
        local t = CurTime() - self.DestroyWaitStartTime
        if t > self.Parameters.mDestroyWaitFrame then self:Remove() end
    else
        local t = CurTime() - self.ContactStartTime
        local duration = self.Parameters.mNoDamageRunningDurationFrame
        local healthToTime = (1 - self:Health() / self:GetMaxHealth()) * duration
        local inkAmount = math.min(1, (t + healthToTime) / duration)
        if inkAmount == 1 then self.DestroyWaitStartTime = CurTime() end
        if t > duration then self:Remove() end
        self:SetFlexWeight(i, inkAmount)
    end

    if self:GetSequenceName(self:GetSequence()) == "unfolding" and self:GetCycle() == 1 then
        self:ResetSequence "idle"
        self:SetUnfolded(true)
        self:PhysicsInitConvex(self.CollisionMesh)
        self:EnableCustomCollisions(true)
        self:Weld()
        local ph = self:GetPhysicsObject()
        if IsValid(ph) then
            ph:EnableMotion(not self.ContactEntity:IsWorld())
            ph:EnableGravity(true)
        end
    end

    self:Paint()
    return true
end

function ENT:PhysicsCollide(data, collider)
    if self:IsStuck() then
        if data.HitEntity.SubWeaponName then
            if data.HitEntity.SubWeaponName == "splashwall" then
                if not data.HitEntity:IsStuck() then
                    SafeRemoveEntity(data.HitEntity)
                end
            else
                SafeRemoveEntity(data.HitEntity)
                if isfunction(data.HitEntity.Detonate) then
                    data.HitEntity:Detonate()
                end
            end
        elseif not data.HitEntity:IsWorld() then
            local d = DamageInfo()
            local dt = bit.bor(DMG_AIRBOAT, DMG_REMOVENORAGDOLL)
            if not data.HitEntity:IsPlayer() then dt = bit.bor(dt, DMG_DISSOLVE) end
            d:SetDamage(self.Parameters.mDamage)
            d:SetDamageForce(-data.HitNormal)
            d:SetDamagePosition(data.HitPos)
            d:SetDamageType(dt)
            d:SetReportedPosition(data.HitPos)
            d:SetAttacker(self:GetOwner())
            d:SetInflictor(self)
            d:ScaleDamage(ss.ToHammerHealth)
            data.HitEntity:TakeDamageInfo(d)
            if data.HitEntity:GetClass() == "npc_grenade_frag" then
                data.HitEntity:Fire("SetTimer", 0)
            end
        end

        return
    end

    if -data.HitNormal.z < 0.7 then
        local v = Vector(data.OurOldVelocity)
        local dot = v:Dot(data.HitNormal)
        v = v - data.HitNormal * dot * 2
        collider:SetAngleVelocityInstantaneous(vector_origin)
        collider:SetVelocityInstantaneous(v)
        return
    end

    collider:EnableMotion(not data.HitEntity:IsWorld())
    collider:EnableGravity(true)
    collider:SetPos(data.HitPos)
    collider:SetAngles(Angle(0, collider:GetAngles().yaw, 0))

    self.HitNormal = -data.HitNormal
    self.ContactEntity = data.HitEntity
    self.ContactPhysObj = data.HitObject
    self.ContactStartTime = self.ContactStartTime or CurTime()
    self:Weld()

    if self.IsFirstTimeContact then
        self.IsFirstTimeContact = false
        self:EmitSound "SplatoonSWEPs.SplashWallDeploy"
        self:ResetSequence "unfolding"
        timer.Simple(self.Parameters.mPreparationDurationFrame, function()
            if not IsValid(self) then return end
            self.RunningSound:Play()
        end)
    end
end
