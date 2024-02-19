
local ss = SplatoonSWEPs
if not ss then return end
include "shared.lua"

local SWEP = SWEP
---@cast SWEP SWEP.Special
---@class SWEP.Special : SplatoonWeaponBase
---@field SwayTime               number
---@field IronSightsAng          Angle[]
---@field IronSightsPos          Vector[]
---@field IronSightsFlip         boolean[]
---@field ArmPos                 integer
---@field ArmBegin               number
---@field BasePos                Vector
---@field BaseAng                Angle
---@field OldPos                 Vector
---@field OldAng                 Angle
---@field OldArmPos              integer
---@field TransitFlip            boolean
---@field Bones                  { Neck: integer,  Roll: integer, Root: integer }
---@field VMBones                { Neck: integer,  Roll: integer, Root: integer }
---@field Mode                   integer
---@field RotateRollPos          Vector
---@field GetMuzzlePosition      fun(self): Vector, Angle

SWEP.SwayTime = 12 * ss.FrameToSec
SWEP.IronSightsAng = {
    Angle(), -- right
    Angle(), -- left
    Angle(0, 0, -60), -- top-right
    Angle(0, 0, -60), -- top-left
    Angle(), -- center
}
SWEP.IronSightsPos = {
    Vector(), -- right
    Vector(), -- left
    Vector(), -- top-right
    Vector(), -- top-left
    Vector(0, 6, -2), -- center
}
SWEP.IronSightsFlip = {
    false,
    true,
    false,
    true,
    false,
}

function SWEP:GetMuzzlePosition()
    local ent = self:IsTPS() and self or self:GetViewModel()
    local i = self.IsBrush and ent:LookupAttachment "tip" or ent:LookupAttachment "roll"
    local a = ent:GetAttachment(i)
    if not a then return self:WorldSpaceCenter(), self:GetAngles() end
    return a.Pos, a.Ang
end

local LeftHandAlt = {2, 1, 4, 3, 5, 6}
function SWEP:GetViewModelPosition(pos, ang)
    local vm = self:GetViewModel()
    if not IsValid(vm) then return pos, ang end

    local ping = IsFirstTimePredicted() and self:Ping() or 0
    local ct = CurTime() - ping
    if not self.OldPos then
        self.ArmPos, self.ArmBegin = 1, ct
        self.BasePos, self.BaseAng = Vector(), Angle()
        self.OldPos, self.OldAng = self.BasePos, self.BaseAng
        return pos, ang
    end

    local armpos = self.OldArmPos
    if self:IsFirstTimePredicted() then
        self.OldArmPos = 1
    end

    if self:GetNWBool "lefthand" then armpos = LeftHandAlt[armpos] or armpos end
    if not isangle(self.IronSightsAng[armpos]) then return pos, ang end
    if not isvector(self.IronSightsPos[armpos]) then return pos, ang end

    local DesiredFlip = self.IronSightsFlip[armpos]
    local relpos, relang = LocalToWorld(vector_origin, angle_zero, pos, ang)
    local SwayTime = self.SwayTime / ss.GetTimeScale(self:GetOwner())
    if self:IsFirstTimePredicted() and armpos ~= self.ArmPos then
        self.ArmPos, self.ArmBegin = armpos, ct
        self.BasePos, self.BaseAng = self.OldPos, self.OldAng
        self.TransitFlip = self.ViewModelFlip ~= DesiredFlip
    else
        armpos = self.ArmPos
    end

    local dt = ct - self.ArmBegin
    local f = math.Clamp(dt / SwayTime, 0, 1)
    if self.TransitFlip then
        f, armpos = f * 2, 5
        if self:IsFirstTimePredicted() and f >= 1 then
            f, self.ArmPos = 1, 5
            self.ViewModelFlip = DesiredFlip
            self.ViewModelFlip1 = DesiredFlip
            self.ViewModelFlip2 = DesiredFlip
        end
    end

    local newpos = LerpVector(f, self.BasePos, self.IronSightsPos[armpos])
    local newang = LerpAngle(f, self.BaseAng, self.IronSightsAng[armpos])
    if self:IsFirstTimePredicted() then
        self.OldPos, self.OldAng = newpos, newang
    end

    return LocalToWorld(self.OldPos, self.OldAng, relpos, relang)
end

function SWEP:CustomAmmoDisplay()
    return {
        Draw = true,
        PrimaryClip = self.Primary.ClipSize > 0 and self:Clip1() or nil,
        PrimaryAmmo = self.Primary.ClipSize > 0 and self:Ammo1() or nil,
        SecondaryAmmo = self.Secondary.ClipSize > 0 and self:Ammo2() or nil,
    }
end
