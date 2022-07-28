
local ss = SplatoonSWEPs
if not ss then return end
include "shared.lua"

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
    self.ArmPos, self.ArmBegin = nil, nil
    self.BasePos, self.BaseAng = nil, nil
    self.OldPos, self.OldAng = nil, nil
    self.OldArmPos = 1
    self.TransitFlip = false
    self.ModifyWeaponSize = SysTime() - 1
    self.ViewPunch = Angle()
    self.ViewPunchVel = Angle()
    if not (self.ADSAngOffset and self.ADSOffset) then return end
    self.IronSightsAng[6] = self.IronSightsAng[5] + self.ADSAngOffset
    self.IronSightsPos[6] = self.IronSightsPos[5] + self.ADSOffset
end

function SWEP:ClientThink()
    if self.IsOctoShot then
        self.Skin = self:GetNWBool "advanced"
        self.Skin = self.Skin and 1 or 0
    elseif self.IsHeroWeapon then
        self.Skin = self:GetNWInt "level"
        if not self.IsHeroShot then return end
        local t = self:GetNWEntity "Trail"
        local tv = self:GetNWEntity "TrailVM"
        local fps = self:IsMine() and not self:IsTPS()
        local hide = self:GetInInk() or (self:GetNWBool "becomesquid" and self:Crouching())
        if IsValid(t) then t:SetNoDraw(hide or fps) end
        if IsValid(tv) then tv:SetNoDraw(not fps) end
    end
end

function SWEP:GetMuzzlePosition()
    local ent = self:IsTPS() and self or self:GetViewModel()
    local a = ent:GetAttachment(ent:LookupAttachment "spout")
    if not a then return self:WorldSpaceCenter(), self:GetAngles() end
    return a.Pos, a.Ang
end

function SWEP:GetCrosshairTrace(t)
    local range = self.Range
    local tr = ss.SquidTrace
    tr.start, tr.endpos = t.pos, t.pos + t.dir * range
    tr.filter = ss.MakeAllyFilter(self)
    tr.maxs = ss.vector_one * self.Parameters.mFirstGroupBulletFirstCollisionRadiusForField
    tr.mins = -tr.maxs

    t.Trace = util.TraceHull(tr)
    t.EndPosScreen = (self:GetShootPos() + self:GetAimVector() * range):ToScreen()
    t.HitPosScreen = t.Trace.HitPos:ToScreen()
    t.HitEntity = IsValid(t.Trace.Entity) and t.Trace.Entity:Health() > 0
    t.Distance = t.Trace.HitPos:Distance(t.pos)
    if t.HitEntity then
        local w = ss.IsValidInkling(t.Trace.Entity)
        if w and ss.IsAlly(w, self) then
            t.HitEntity = false
        end
    end
end

function SWEP:DrawFourLines(t)
    local bgcolor = t.IsSplatoon2 and t.Trace.Hit and ss.CrosshairBaseColor or color_white
    local forecolor = t.HitEntity and ss.GetColor(self:GetNWInt "inkcolor")
    local dir = self:GetAimVector() * t.Distance
    local org = self:GetShootPos()
    local right = EyeAngles():Right()
    local range = self:GetRange()
    local adjust = not t.IsSplatoon2 and t.HitEntity
    local dx, dy = 0, 0
    if not t.IsSplatoon2 then
        dx = t.HitPosScreen.x - t.EndPosScreen.x
        dy = t.HitPosScreen.y - t.EndPosScreen.y
    end

    ss.DrawCrosshair.FourLinesAround(
    org, right, dir, range, 1, 1, dx, dy, adjust, bgcolor, forecolor)
end

function SWEP:DrawCenterCircleNoHit(t)
    if not t.IsSplatoon2 and t.Trace.Hit then return end
    ss.DrawCrosshair.CircleNoHit(t.EndPosScreen.x, t.EndPosScreen.y)
end

function SWEP:DrawHitCrossBG(t) -- Hit cross pattern, background
    if not t.HitEntity then return end
    local mul = ss.ProtectedCall(self.GetScopedSize, self) or 1
    local frac = 1 - (t.Distance / self:GetRange()) / 2
    ss.DrawCrosshair.LinesHitBG(t.HitPosScreen.x, t.HitPosScreen.y, frac, mul)
end

function SWEP:DrawHitCross(t) -- Hit cross pattern, foreground
    if not t.HitEntity then return end
    local c = ss.GetColor(self:GetNWInt "inkcolor")
    local frac = 1 - (t.Distance / self:GetRange()) / 2
    ss.DrawCrosshair.LinesHit(t.HitPosScreen.x, t.HitPosScreen.y, c, frac, 1)
end

function SWEP:DrawOuterCircleBG(t)
    if not (t.Trace.Hit and t.HitEntity) then return end
    ss.DrawCrosshair.OuterCircleBG(t.HitPosScreen.x, t.HitPosScreen.y)
end

function SWEP:DrawOuterCircle(t)
    if not t.Trace.Hit then return end
    ss.DrawCrosshair.OuterCircle(t.HitPosScreen.x, t.HitPosScreen.y, t.CrosshairColor)
end

function SWEP:DrawInnerCircle(t)
    if not t.Trace.Hit then return end
    ss.DrawCrosshair.InnerCircle(t.HitPosScreen.x, t.HitPosScreen.y)
end

function SWEP:DrawCenterDot(t) -- Center circle
    ss.DrawCrosshair.CenterDot(t.HitPosScreen.x, t.HitPosScreen.y)
    if not (t.IsSplatoon2 and t.Trace.Hit) then return end
    ss.DrawCrosshair.CenterDot(t.EndPosScreen.x, t.EndPosScreen.y, ss.CrosshairBaseColor)
end

function SWEP:GetArmPos()
    if self:GetADS() then
        self.IronSightsFlip[6] = self.ViewModelFlip
        return 6
    end
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
        self.OldArmPos = ss.ProtectedCall(self.GetArmPos, self)
        if self:GetHolstering() or self:GetThrowing()
        or vm:GetSequenceActivityName(vm:GetSequence()) == "ACT_VM_DRAW" then
            self.OldArmPos = 1
        elseif not self.OldArmPos then
            if ss.GetOption "doomstyle" then
                self.OldArmPos = 5
            elseif ss.GetOption "moveviewmodel" and not self:Crouching() then
                if not self.Cursor then return pos, ang end
                self.OldArmPos = select(3, self:GetFirePosition())
            else
                self.OldArmPos = 1
            end
        end
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

function SWEP:SetupDrawCrosshair()
    local t = {Size = {}}
    t.CrosshairColor = ss.GetColor(ss.CrosshairColors[self:GetNWInt "inkcolor"])
    t.pos, t.dir = self:GetFirePosition(true)
    t.IsSplatoon2 = ss.GetOption "newstylecrosshair"
    self:GetCrosshairTrace(t)
    return t
end

function SWEP:DrawCrosshair(x, y)
    local p = self.Parameters
    for linenum = 1, p.mLineNum do
        local t = self:SetupDrawCrosshair(linenum)
        if t.CrosshairColor then
            self:DrawFourLines(t)
            self:DrawCenterCircleNoHit(t)
            self:DrawHitCrossBG(t)
            self:DrawOuterCircleBG(t)
            self:DrawOuterCircle(t)
            self:DrawHitCross(t)
            self:DrawInnerCircle(t)
            self:DrawCenterDot(t)
        end
    end

    return true
end
