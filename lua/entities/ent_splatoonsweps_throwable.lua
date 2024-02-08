
local ENT = ENT
---@cast ENT ENT.Throwable
---@class ENT.Throwable : ENT
---@field AirResist           number
---@field AngleAirResist      number
---@field BaseClass           ENT
---@field CollisionGroup      integer
---@field ContactEntity       Entity
---@field ContactPhysObj      PhysObj
---@field DragCoeffChangeTime number
---@field FindBoneFromPhysObj fun(self, ent: Entity, physobj: PhysObj): integer
---@field GetInkColorProxy    fun(self): Vector
---@field Gravity             number
---@field GravityDirection    Vector
---@field IsSplatoonBomb      boolean
---@field IsStuck             fun(self): boolean
---@field Model               string
---@field Owner               Entity
---@field SetInkColorProxy    fun(self, Vector)
---@field StraightFrame       number
---@field SubWeaponName       string
---@field UseSubWeaponFilter  boolean
---@field WeaponClassName     string
---@field Weld                fun(self)

AddCSLuaFile()
ENT.Type = "anim"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
ENT.CollisionGroup = COLLISION_GROUP_PASSABLE_DOOR
ENT.Model = Model "models/splatoonsweps/subs/splatbomb/splatbomb.mdl"
ENT.UseSubWeaponFilter = true
ENT.WeaponClassName = ""

---Determine Splash Wall to be solid against given entity
---@param e1 ENT.Throwable
---@param e2 ENT.Throwable
---@return boolean?
local function SplashWallFilter(e1, e2)
    if e2.SubWeaponName == "splashwall" then
        e1, e2 = e2, e1 ---@type ENT.Throwable, ENT.Throwable
    end
    local w = ss.IsValidInkling(e2)
    if w and ss.IsAlly(e1, w) then return false end
    if not isstring(e2.SubWeaponName) then return end
    return not ss.IsAlly(e1, e2)
end

hook.Add("ShouldCollide", "SplatoonSWEPs: Sub weapon filter",
---@param e1 ENT.Throwable
---@param e2 ENT.Throwable
---@return boolean?
function(e1, e2)
    if e1.SubWeaponName == "splashwall" or e2.SubWeaponName == "splashwall" then
        return SplashWallFilter(e1, e2)
    end

    if e2.UseSubWeaponFilter then
        e1, e2 = e2, e1 ---@type ENT.Throwable, ENT.Throwable
    end
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
            p:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
        end
    end

    ss.SetEntityFilter(self, nil, true)
    self:SetNWVarProxy("inkcolor", function(ent, name, old, new)
        if old == new then return end
        ss.SetEntityFilter(ent, old, false)
        ss.SetEntityFilter(ent, new, true)
    end)
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
    if not IsValid(p) then return end
    if self:IsStuck() then return end

    local fix = FrameTime() * ss.SecToFrame
    -- Linear drag for X/Y axis
    p:AddVelocity(p:GetVelocity() * self.AirResist * fix)

    -- Angular drag
    local a = p:GetAngleVelocity()
    p:AddAngleVelocity(a * self.AngleAirResist * fix)

    if CurTime() < self.DragCoeffChangeTime then return end

    -- Gravity
    local g_dir = self.GravityDirection or ss.GetGravityDirection()
    p:AddVelocity(g_dir * self.Gravity * FrameTime() * fix)
end
