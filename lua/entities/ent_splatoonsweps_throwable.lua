
AddCSLuaFile()
ENT.Type = "anim"

local ss = SplatoonSWEPs
if not ss then return end
ENT.CollisionGroup = COLLISION_GROUP_PASSABLE_DOOR
ENT.Model = Model "models/splatoonsweps/subs/splatbomb/splatbomb.mdl"
ENT.UseSubWeaponFilter = true
ENT.WeaponClassName = ""

local function SplashWallFilter(e1, e2)
    if e2.SubWeaponName == "splashwall" then e1, e2 = e2, e1 end
    local w = ss.IsValidInkling(e2)
    if w and ss.IsAlly(e1, w) then return false end
    if not isstring(e2.SubWeaponName) then return end
    return not ss.IsAlly(e1, e2)
end

hook.Add("ShouldCollide", "SplatoonSWEPs: Sub weapon filter", function(e1, e2)
    if e1.SubWeaponName == "splashwall" or e2.SubWeaponName == "splashwall" then
        return SplashWallFilter(e1, e2)
    end

    if e2.UseSubWeaponFilter then e1, e2 = e2, e1 end
    if e2.UseSubWeaponFilter then return false end
    if not e1.UseSubWeaponFilter then return end
    if not IsValid(e1.Owner) then return end
    local w1 = ss.IsValidInkling(e1.Owner)
    local w2 = ss.IsValidInkling(e2)
    if not (w1 and w2) then return end
    if ss.IsAlly(w1, w2) then return false end
end)

function ENT:Initialize()
    if IsValid(self:GetOwner()) then
        local w = ss.IsValidInkling(self:GetOwner())
        if w then self.WeaponClassName = w:GetClass() end
    end

    self:SetModel(self.Model)
    self:SetCollisionGroup(self.CollisionGroup)
    self:SetCustomCollisionCheck(true)
    self.DragCoeffChangeTime = CurTime() + self.StraightFrame
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:PhysWake()
        local p = self:GetPhysicsObject()
        if IsValid(p) then
            p:EnableDrag(false)
            p:EnableGravity(false)
        end
    end

    ss.RegisterEntity(self)
end

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "InkColorProxy")
end

function ENT:IsStuck()
    return IsValid(self.ContactEntity)
    or isentity(self.ContactEntity) and self.ContactEntity:IsWorld()
end

function ENT:FindBoneFromPhysObj(ent, physobj)
    for i = 0, ent:GetPhysicsObjectCount() - 1 do
        if ent:GetPhysicsObjectNum(i) == physobj then return i end
    end

    return 0
end

if CLIENT then return end

function ENT:Weld()
    timer.Simple(0, function()
        if not IsValid(self) then return end
        if self.ContactEntity ~= game.GetWorld()
        and not IsValid(self.ContactEntity) then return end
        if not IsValid(self.ContactPhysObj) then return end
        local phys = self:FindBoneFromPhysObj(self.ContactEntity, self.ContactPhysObj)
        constraint.Weld(self, self.ContactEntity, 0, phys, 0, false, false)
    end)
end

function ENT:PhysicsUpdate(p)
    if self:IsStuck() then return end

    local fix = FrameTime() * ss.SecToFrame
    -- Linear drag for X/Y axis
    p:AddVelocity(p:GetVelocity() * self.AirResist * fix)

    -- Angular drag
    local a = p:GetAngleVelocity()
    p:AddAngleVelocity(a * self.AngleAirResist * fix)

    if CurTime() < self.DragCoeffChangeTime then return end

    -- Gravity
    local g_dir = ss.GetGravityDirection()
    p:AddVelocity(g_dir * self.Gravity * FrameTime() * fix)
end
