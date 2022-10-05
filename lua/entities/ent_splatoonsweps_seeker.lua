
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_throwable"

local ss = SplatoonSWEPs
if not ss then return end
ENT.Model = Model "models/splatoonsweps/subs/seekers/seeker.mdl"
ENT.SubWeaponName = "seeker"
ENT.AlertSoundPlayed = false
ENT.AlertSoundTime = 4
ENT.DesiredSpeed = 6.65 * ss.ToHammerUnitsPerSec
ENT.ExplodeTime = 5
ENT.ExplosionOffset = 16
ENT.IsSplatoonBomb = true
ENT.NextTracePaintTime = 0
ENT.SeekStartTime = 0.5
ENT.TracePaintInterval = 2 * ss.FrameToSec
ENT.TracePaintRadius = 10 * ss.ToHammerUnits

function ENT:Initialize()
    local p = ss[self.SubWeaponName].Parameters
    self.Parameters = p
    self.StraightFrame = p.Fly_AirFrm
    self.AirResist = p.Fly_VelKd - 1
    self.AngleAirResist = p.Fly_RotKd - 1
    self.GravityHold = p.Fly_Gravity
    self.Gravity = p.Fly_Gravity
    self.HitNormal = vector_up
    self.CollisionSeSilentFrame = p.CollisionSeSilentFrame or math.huge
    self.DragCoeffChangeTime = CurTime() + self.StraightFrame
    self.BaseClass.Initialize(self)
    self.InitMoveDirection = self:GetAngles():Forward()
    self.MoveDirection = self.InitMoveDirection
    self.SeekerFarSound = CreateSound(self, ss.SeekerFar)
    self.SeekerNearSound = CreateSound(self, ss.SeekerNear)
    self.SeekSoundDistanceThreshold = p.SeThreshold
    if CLIENT then return end
    self.InitTime = CurTime()
    self:EmitSound "SplatoonSWEPs.SeekerThrown"
    self:EmitSound "SplatoonSWEPs.SeekerRunning"
end

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "InkColorProxy")
end

if CLIENT then
    function ENT:Draw()
        local t = 2 * math.pi * CurTime()
        self:DrawModel()
        self:ManipulateBoneAngles(self:LookupBone "screw_1", Angle(CurTime() * 720))
        self:ManipulateBoneAngles(self:LookupBone "pole_1", Angle(math.cos(3 * t) * 10, math.sin(3 * t) * 6))
    end

    return
end

function ENT:OnRemove()
    self:StopSound "SplatoonSWEPs.SeekerAlert"
    self:StopSound "SplatoonSWEPs.SeekerFar"
    self:StopSound "SplatoonSWEPs.SeekerNearar"
    self:StopSound "SplatoonSWEPs.SeekerRunning"
    self.SeekerFarSound:Stop()
    self.SeekerNearSound:Stop()
end

function ENT:TracePaint()
    local t = util.QuickTrace(self:GetPos(), -vector_up * 10, self)
    if not t.Hit then return end
    ss.Paint(t.HitPos, t.HitNormal, self.TracePaintRadius, self:GetNWInt "inkcolor",
    self:GetAngles().yaw + 90, math.random(10, 12), 0.5, self:GetOwner(), self.WeaponClassName)
end

function ENT:Explode()
    ss.MakeBombExplosion(self:GetPos() + self.HitNormal * self.ExplosionOffset,
    self.HitNormal, self, self:GetNWInt "inkcolor", self.SubWeaponName)
    SafeRemoveEntity(self)
end

function ENT:Think()
    self:NextThink(CurTime())
    local p = self:GetPhysicsObject()
    if not IsValid(p) then return true end
    if CurTime() > self.NextTracePaintTime then
        self.NextTracePaintTime = CurTime() + self.TracePaintInterval
        self:TracePaint()
    end

    local t = CurTime() - self.InitTime
    if t > self.AlertSoundTime and not self.AlertSoundPlayed then
        self:EmitSound "SplatoonSWEPs.SeekerAlert"
        self.AlertSoundPlayed = true
    end

    if t > self.ExplodeTime then self:Explode() end
    if IsValid(self.Target) then
        if t > self.SeekStartTime then
            local dir = self.Target:GetPos() - self:GetPos() dir:Normalize()
            local rdot = dir:Dot(self:GetRight())
            local fdot = dir:Dot(self:GetForward())
            local deg = math.abs(90 - math.deg(math.acos(rdot)))
            if fdot > 0 and deg < 5 then
                self.InitMoveDirection = dir
                self.MoveDirection = dir
            else
                local sign = rdot > 0 and -1 or 1
                local ang = self.MoveDirection:Angle()
                ang:RotateAroundAxis(self:GetUp(), sign * math.min(1, deg))
                self.InitMoveDirection = ang:Forward()
                self.MoveDirection = ang:Forward()
            end
        end

        local distance = self.Target:GetPos():Distance(self:GetPos())
        if distance < 30 then self:Explode() end
        if distance > self.SeekSoundDistanceThreshold then
            self.SeekerFarSound:Play()
            self.SeekerNearSound:Stop()
        else
            self.SeekerFarSound:Stop()
            self.SeekerNearSound:Play()
        end
    else
        self.MoveDirection = self:GetForward()
        self.SeekerFarSound:Stop()
        self.SeekerNearSound:Stop()
    end

    return true
end

function ENT:PhysicsUpdate(p)
    self.BaseClass.PhysicsUpdate(self, p)
    p:AddVelocity(self.MoveDirection * self.DesiredSpeed * FrameTime())
    local axis = self.MoveDirection:Cross(self:GetForward())
    local dot = self.MoveDirection:Dot(self:GetForward())
    p:AddAngleVelocity(axis * (dot - 1) * 180)
    if p:GetStress() == 0 then
        self.GravityDirection = nil
        self.Gravity = self.GravityHold
    else
        self.GravityDirection = -self:GetUp()
        self.Gravity = ss.eps
    end
end

local MAX_DIFF = math.cos(math.rad(75))
function ENT:PhysicsCollide(data, collider)
    local normal = data.HitNormal
    if -normal.z > ss.MAX_COS_DIFF then
        local right = self.InitMoveDirection:Cross(normal)
        self.MoveDirection = normal:Cross(right)
        return
    end

    local mc = collider:LocalToWorld(collider:GetMassCenter())
    if math.abs(self:GetUp():Dot((data.HitPos - mc):GetNormalized())) > MAX_DIFF then return end
    self:Explode()
end
