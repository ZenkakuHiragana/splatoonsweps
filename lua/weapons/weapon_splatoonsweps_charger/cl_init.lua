
local ss = SplatoonSWEPs
if not ss then return end
include "shared.lua"

local SWEP = SWEP
---@cast SWEP SWEP.Charger
---@class SWEP.Charger
---@field Crosshair table
---@field DrawCrosshairFlash fun(self, t: table)
---@field RenderScreenspaceEffects fun(self)

local crosshairalpha = 64
SWEP.Crosshair = {
    color_circle = ColorAlpha(color_black, crosshairalpha),
    color_nohit = ColorAlpha(color_white, crosshairalpha),
    color_hit = ColorAlpha(color_white, 192),
    Dot = 5, HitLine = 20, HitWidth = 2, -- in pixel
    Inner = 26, Middle = 34, Outer = 38, -- in pixel
    HitLineSize = 114,
}

function SWEP:ClientInit()
    self.CrosshairFlashTime = CurTime()
    self.MinChargeDeg = self.Parameters.mMinChargeFrame / self.Parameters.mMaxChargeFrame * 360
    self.IronSightsPos[6] = self.ScopePos
    self.IronSightsAng[6] = self.ScopeAng
    self.IronSightsFlip[6] = false
    self:GetBase().ClientInit(self)

    if not self.Scoped then return end
    self.RTScope = GetRenderTarget(ss.RenderTarget.Name.RTScope, 512, 512)
    self:AddSchedule(0, function(_, sched)
        if not (self.Scoped and IsValid(self:GetOwner())) then return end
        self:GetOwner():SetNoDraw(
            self:IsMine() and
            self:GetScopedProgress() == 1 and
            not self:GetNWBool "usertscope")
    end)
end

function SWEP:Holster(weapon)
    self:GetBase().Holster(self, weapon)
    if not self.RTScope then return true end
    local vm = self:GetViewModel()
    if not IsValid(vm) then return true end
    ss.SetSubMaterial_Workaround(vm, self.RTScopeNum - 1)
    return true
end

function SWEP:DisplayAmmo()
    if self:GetCharge() == math.huge then return 0 end
    return math.max(self:GetChargeProgress(true) * 100, 0)
end

function SWEP:GetScopedSize()
    return 1 + (self:GetNWBool "usertscope" and self:IsTPS() and 0 or self:GetScopedProgress(true))
end

function SWEP:DrawFourLines(t) end
function SWEP:DrawOuterCircle(t)
    local scoped = self:GetScopedSize()
    local prog = self:GetChargeProgress(true)
    local x, y = t.HitPosScreen.x, t.HitPosScreen.y
    if prog == 0 then
        local elapsed = math.max(CurTime() - self:GetCharge() + self:Ping(), 0)
        local minchargetime = self.Parameters.mMaxChargeFrame * ss.GetTimeScale(self:GetOwner())
        prog = math.Clamp(elapsed / minchargetime, 0, 1) * 360
    else
        prog = prog * (360 - self.MinChargeDeg) + self.MinChargeDeg
    end

    ss.DrawCrosshair.ChargerProgress(x, y, scoped, prog)
    if not t.Trace.Hit then return end
    ss.DrawCrosshair.ChargerColoredCircle(x, y, scoped, t.CrosshairColor)
end

function SWEP:DrawInnerCircle(t)
    local mul = self:GetScopedSize()
    if mul == 2 then return end
    ss.DrawCrosshair.ChargerBaseCircle(t.EndPosScreen.x, t.EndPosScreen.y, mul)
end

function SWEP:DrawCenterDot(t) -- Center circle
    local mul = self:GetScopedSize()
    if mul < 2 then
        ss.DrawCrosshair.ChargerCenterDot(
        t.EndPosScreen.x, t.EndPosScreen.y, mul)
    end

    if not t.Trace.Hit then return end
    ss.DrawCrosshair.ChargerCenterDot(
    t.HitPosScreen.x, t.HitPosScreen.y,
    mul, t.CrosshairDarkColor, t.CrosshairColor)
end

function SWEP:DrawCrosshairFlash(t)
    if not self.FullChargeFlag then return end
    local frac = math.TimeFraction(self.CrosshairFlashTime,
    self.CrosshairFlashTime + self.FlashDuration, CurTime())
    if frac > 1 then return end
    ss.DrawCrosshair.ChargerFlash(t.HitPosScreen.x, t.HitPosScreen.y,
    self:GetScopedSize(), self:GetInkColor(), frac)
end

function SWEP:DrawHitCross(t) -- Hit cross pattern, foreground
    if not t.HitEntity then return end
    local mul = self:GetScopedSize()
    local frac = 1 - (t.Distance / self:GetRange()) / 2
    ss.DrawCrosshair.ChargerFourLines(
    t.HitPosScreen.x, t.HitPosScreen.y,
    frac, mul, t.CrosshairDarkColor, t.CrosshairBrightColor)
end

local MatScope = Material "gmod/scope"
local MatRefScope = Material "gmod/scope-refract"
local MatRefDefault = MatRefScope:GetFloat "$refractamount" or 0 -- Null in DXLevel 80
function SWEP:RenderScreenspaceEffects()
    if not self.Scoped or self:GetNWBool "usertscope" then return end
    local prog = self:GetScopedProgress(true)
    if prog == 0 then return end
    local padding = surface.DrawTexturedRectUV
    local u, v = .115, 1
    local t = self:SetupDrawCrosshair()
    local x, y = t.HitPosScreen.x, t.HitPosScreen.y
    local sx, sy = math.ceil(ScrH() * 4 / 3), ScrH()
    local ex, ey = math.ceil(x + sx / 2), math.ceil(y + sy / 2) -- End position of x, y
    x, y = math.floor(x - sx / 2), math.floor(y - sy / 2)

    MatRefScope:SetFloat("$refractamount", prog * prog * MatRefDefault)
    render.UpdateRefractTexture()
    for _, material in ipairs {MatRefScope, MatScope} do
        surface.SetDrawColor(ColorAlpha(color_black, prog * 255))
        surface.SetMaterial(material)
        surface.DrawTexturedRect(x, y - 1, sx, sy + 1)
        if x  > 0      then padding(-1,     -1,     x + 1,           ScrH()      + 1, 0, 0, u, v) end
        if y  > 0      then padding(x,      -1,     sx,              y           + 1, 0, 0, u, v) end
        if ex < ScrW() then padding(ex - 1, -1,     ScrW() - ex + 1, ScrH()      + 1, 0, 0, u, v) end
        if ey < ScrH() then padding(x,      ey - 1, ScrW(),          ScrH() - ey + 1, 0, 0, u, v) end
    end

    MatRefScope:SetFloat("$refractamount", MatRefDefault)
end

function SWEP:CustomDrawCrosshair(x, y)
    if self:GetCharge() == math.huge then return end
    local t = self:SetupDrawCrosshair()
    local p = self.Parameters
    local dist = self.Scoped and p.mFullChargeDistanceScoped or p.mFullChargeDistance
    if not t.CrosshairColor then return end
    t.EndPosScreen = (self:GetShootPos() + self:GetAimVector() * dist):ToScreen()
    t.CrosshairDarkColor = ColorAlpha(t.CrosshairColor, 192)
    t.CrosshairDarkColor.r = t.CrosshairDarkColor.r / 2
    t.CrosshairDarkColor.g = t.CrosshairDarkColor.g / 2
    t.CrosshairDarkColor.b = t.CrosshairDarkColor.b / 2
    t.CrosshairBrightColor = ColorAlpha(ss.GetColor(self:GetNWInt "inkcolor"), 255)
    t.CrosshairBrightColor.r = (t.CrosshairBrightColor.r + 255) / 2
    t.CrosshairBrightColor.g = (t.CrosshairBrightColor.g + 255) / 2
    t.CrosshairBrightColor.b = (t.CrosshairBrightColor.b + 255) / 2
    self:DrawCenterDot(t)
    self:DrawInnerCircle(t)
    self:DrawOuterCircle(t)
    self:DrawHitCross(t)
    self:DrawCrosshairFlash(t)
    return true
end

function SWEP:TranslateFOV(fov)
    if not self.Scoped or self:GetNWBool "usertscope" then return fov end
    return Lerp(self:GetScopedProgress(true), fov, self.Parameters.mSniperCameraFovy)
end

function SWEP:PreViewModelDrawn(vm, weapon, ply)
    ss.ProtectedCall(self:GetBase().PreViewModelDrawn, self, vm, weapon, ply)
    if not self.Scoped or self:GetNWBool "usertscope" then return end
    render.SetBlend((1 - self:GetScopedProgress(true)) ^ 2)
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
    ss.ProtectedCall(self:GetBase().PostDrawViewModel, self, vm, weapon, ply)
    if not self.Scoped then return end
    render.SetBlend(1)

    -- Entity:GetAttachment() for viewmodel returns incorrect value in singleplayer.
    if ss.mp then return end
    self.RTAttachment = self.RTAttachment or vm:LookupAttachment "scope_end"
    if self.RTAttachment then
        self.ScopeOrigin = vm:GetAttachment(self.RTAttachment).Pos
    end
end

function SWEP:PreDrawWorldModel()
    if not self.Scoped or self:GetNWBool "usertscope" then return end
    return self:GetScopedProgress(true) == 1
end

function SWEP:GetArmPos()
    local p = self.Parameters
    local startmove = p.mSniperCameraMoveStartChargeRate
    local endmove = p.mSniperCameraMoveEndChargeRate
    local swaytime = (endmove - startmove) * p.mMaxChargeFrame / 2
    local prog = self:GetChargeProgress(true)
    if not self:GetADS() then return end
    if not self.Scoped then
        self.SwayTime = 12 * ss.FrameToSec
    elseif prog < startmove then
        self.SwayTime = self.TransitFlip and 12 * ss.FrameToSec or swaytime
    end

    return 6
end

function SWEP:CustomCalcView(ply, pos, ang, fov)
    if not self.Scoped then return end
    if self:GetNWBool "usertscope" then return end
    if not (self:IsTPS() and self:IsMine()) then return end
    local p, a = self:GetFirePosition()
    local frac = self:GetScopedProgress(true)
    pos:Set(LerpVector(frac, pos, p))
    ang:Set(LerpAngle(frac, ang, a:Angle()))
    self:SetNoDraw(frac == 1)
end
