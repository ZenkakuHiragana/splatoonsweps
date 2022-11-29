
local ss = SplatoonSWEPs
if not ss then return end
include "shared.lua"

local Pitch = Angle(1, 0, 0)
local LerpSpeed = 360 -- degs/sec
local drawhud = GetConVar "cl_drawhud"
local function AdjustRollerAngles(self, tracelength, vm)
    local traceheight = 32
    local tracedown = 128
    local tracewidth = self.Parameters.mCoreColWidthHalf * 2
    local target = vm or self
    local bone = vm and self.VMBones.Root or self.Bones.Root
    local oldang = target:GetManipulateBoneAngles(bone)
    local ownerang = Angle(0, self:GetAimVector():Angle().yaw, 0)
    local up = vector_up * traceheight
    local down = -vector_up * tracedown
    local forward = ownerang:Forward() * tracelength
    local right = ownerang:Right() * tracewidth / 2
    local trleft = util.TraceLine {
        start = self:GetPos() + up,
        endpos = self:GetPos() + up + forward + right,
        filter = {self:GetOwner(), self},
    }
    local trright = util.TraceLine {
        start = self:GetPos() + up,
        endpos = self:GetPos() + up + forward - right,
        filter = {self:GetOwner(), self},
    }
    trleft = util.TraceLine {
        start = trleft.HitPos,
        endpos = trleft.HitPos + down,
        filter = {self:GetOwner(), self},
    }
    trright = util.TraceLine {
        start = trright.HitPos,
        endpos = trright.HitPos + down,
        filter = {self:GetOwner(), self},
    }
    target:ManipulateBoneAngles(bone, angle_zero)
    target:SetupBones()

    local hitpos = (trleft.HitPos + trright.HitPos) / 2
    local bonemat = target:GetBoneMatrix(bone)
    if not bonemat then return end
    local bonepos = bonemat:GetTranslation()
    local dzp = bonepos.z - hitpos.z
    local dp = math.deg(math.asin(dzp / hitpos:Distance(bonepos)))
    local dzr = trleft.HitPos.z - trright.HitPos.z
    local dr = math.deg(math.atan2(dzr, tracewidth))
    local ang = Angle(dp - 90, ownerang.yaw)
    local step = LerpSpeed * RealFrameTime()
    ang:RotateAroundAxis(ang:Up(), dr)
    ang = select(2, WorldToLocal(vector_origin, ang, vector_origin, bonemat:GetAngles()))
    ang.p = math.Approach(oldang.p, ang.p, step)
    ang.y = math.Approach(oldang.y, ang.y, step)
    ang.r = math.Approach(oldang.r, ang.r, step)
    target:ManipulateBoneAngles(bone, ang)
end

local function RotateRoll(self, vm)
    if self.IsBrush then return end
    if not self:GetOwner():OnGround() then return end
    local target = vm or self
    local bone = vm and self.VMBones.Roll or self.Bones.Roll
    local oldpos = self.RotateRollPos or self:GetOwner():GetPos()
    local oldang = target:GetManipulateBoneAngles(bone)
    local forward = Angle(0, self:GetAimVector():Angle().yaw, 0):Forward()
    local diameter = self.Primary.Diameter or 15
    local diff = self:GetOwner():GetPos() - oldpos
    local amount = forward:Dot(diff)
    local p = oldang.p + math.deg(amount / diameter)
    target:ManipulateBoneAngles(bone, math.NormalizeAngle(p) * Pitch)
    self.RotateRollPos = self:GetOwner():GetPos()
end

local function DrawVCrosshair(self, isfirstperson)
    if self:GetOwner() ~= LocalPlayer() then return end
    if self:GetThrowing() then return end
    if CurTime() > self.NextCrosshairSpawnTime then
        ss.tablepush(self.Crosshair, CurTime())
        self.NextCrosshairSpawnTime = CurTime() + (self.CrosshairSpawnDelay or delay)
    end

    if self.Mode ~= self.MODE.READY and self:GetMode() == self.MODE.READY then
        self.NextCrosshairDrawTime = CurTime() + self.CrosshairDrawDelay
    end

    local dodraw = drawhud:GetBool() and ss.GetOption "drawcrosshair"
    and CurTime() > self.NextCrosshairDrawTime and self:GetMode() == self.MODE.READY
    ss.DrawVCrosshair(self, dodraw, isfirstperson)
    self.Mode = self:GetMode()
end

SWEP.CrosshairDrawDelay = 8 * ss.FrameToSec
SWEP.CrosshairSpawnDelay = 20 * ss.FrameToSec
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

function SWEP:ClientInit()
    self.Crosshair = {}
    self.NextCrosshairDrawTime = CurTime()
    self.NextCrosshairSpawnTime = CurTime()
end

function SWEP:ClientHolster() table.Empty(self.Crosshair) end
function SWEP:PreViewModelDrawn(vm, weapon, ply)
    DrawVCrosshair(self, true)
    self.VMBones = {
        Neck = vm:LookupBone "neck_1",
        Roll = vm:LookupBone "roll_root_1" or self:LookupBone "roll_1",
        Root = vm:LookupBone "root_1",
    }
    function vm.GetInkColorProxy()
        return ss.ProtectedCall(self.GetInkColorProxy, self) or ss.vector_one
    end

    if self:GetMode() ~= self.MODE.PAINT then
        vm:ManipulateBoneAngles(self.VMBones.Root, angle_zero)
        return
    end

    local ping = self:IsMine() and self:Ping() or 0
    if CurTime() + ping < self:GetSwingStartTime() + self.SwingAnimTime then return end
    AdjustRollerAngles(self, 40, vm)
    RotateRoll(self, vm)
end

function SWEP:PreDrawWorldModel(vm, weapon, ply)
    self.Bones = {
        Neck = self:LookupBone "neck_1",
        Roll = self:LookupBone "roll_root_1" or self:LookupBone "roll_1",
        Root = self:LookupBone "root_1",
    }

    local mode = self:GetMode()
    local ct = CurTime() + (self:IsMine() and self:Ping() or 0)
    local neck, start = 0, self:GetMousePressedTime()
    if mode ~= self.MODE.PAINT then
        if not self.IsBrush then
            local duration, n1, n2 -- Animate the neck
            if mode == self.MODE.READY then
                duration = self.CollapseRollTime
                n1, n2 = 0, -90
            elseif mode == self.MODE.ATTACK then
                duration = self.PreSwingTime
                n1, n2 = -90, 0
            end

            local f = math.TimeFraction(start, start + duration, ct)
            neck = Lerp(math.EaseInOut(math.Clamp(f, 0, 1), .25, .25), n1, n2)
        end

        self:ManipulateBoneAngles(self.Bones.Root, angle_zero)
    elseif ct > self:GetSwingStartTime() + self.SwingAnimTime then
        AdjustRollerAngles(self, 75) -- Adjust the angle
        RotateRoll(self)
    end

    if self.IsBrush then return end
    self:ManipulateBoneAngles(self.Bones.Neck, Angle(0, 0, neck))
end

function SWEP:PreDrawWorldModelTranslucent()
    DrawVCrosshair(self)
end

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
