
local ss = SplatoonSWEPs
if not ss then return end

local MinRadius = 3
local Division = 16
local DegStep = 90 / Division
local drawviewmodel = GetConVar "r_drawviewmodel"
local mdl = Model "models/props_junk/PopCan01a.mdl"
local inkringtranslucent = Material "splatoonsweps/effects/inkring"
local inkring = Material "splatoonsweps/effects/inkring_alphatest"
local function AdvanceVertex(self, pos, norm, u, v, a)
    mesh.Color(self.Color.r, self.Color.g, self.Color.b, a)
    mesh.Normal(norm)
    mesh.Position(pos)
    mesh.TexCoord(0, u, v)
    mesh.AdvanceVertex()
end

function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self.Weapon = e:GetEntity()
    if not IsValid(self.Weapon) then return end
    local f = e:GetFlags()
    local lag = bit.band(f, 128) > 0
    local ping = lag and self.Weapon:Ping() or 0
    self.Color = ss.GetColor(e:GetColor())
    self.deg = e:GetScale()
    self.rad = e:GetRadius()
    self.LifeTime = e:GetAttachment() * ss.FrameToSec
    self.IsRollerSwing = bit.band(f, 2) > 0
    self.IsBrushSwing = bit.band(f, 4) > 0
    self.UseRefract = bit.band(f, 1) > 0
    self.curl = self.UseRefract and 3 or 2
    self.tmax = self.rad / 3
    self.tmin = self.rad / 6
    self.radmin = MinRadius
    self.InitTime = CurTime() - ping
    local pos, ang = self.Weapon:GetMuzzlePosition()
    if IsValid(self.Weapon:GetOwner()) then
        local forward = self.Weapon:GetOwner():GetForward()
        local right = self.Weapon:GetOwner():GetRight()
        local up = self.Weapon:GetOwner():GetUp()
        local yaw = self.Weapon:GetOwner():GetAngles().yaw
        if self.Weapon:GetOwner():IsPlayer() then
            yaw = self.Weapon:GetOwner():GetAimVector():Angle().yaw
        end

        if self.IsRollerSwing then
            pos:Add(forward * 60)
            pos:Add(right * e:GetScale())
            pos:Add(up * -20)
            self.initang = Angle(0, yaw + 90, -157.5)
            self.endang = Angle(0, yaw + 90, -67.5)
            self.deg = 0
            self.tmax = self.rad
            self.tmin = self.rad
            self.radmin = self.rad
        elseif self.IsBrushSwing then
            pos = self.Weapon:GetShootPos() + forward * 20 - up * 5
            self.deg = 0
            self.endang = Angle(100, yaw + 90, -120)
            self.initang = Angle(100, yaw + 90, 30)
            self.tmax = self.Weapon.Parameters.mCorePaintWidthHalf
            self.tmin = self.Weapon.Parameters.mCorePaintWidthHalf
            self.radmin = self.rad
            if e:GetScale() < 0 then
                self.initang, self.endang = self.endang, self.initang
            end

            if self.Weapon:IsTPS() then
                self.tmax = self.tmax * 2
                self.tmin = self.tmin * 2
            end
        end
    end

    self:SetPos(pos)
    self:SetAngles(ang)
end

function EFFECT:Render()
    if not IsValid(self.Weapon) then return end
    if not istable(self.Color) then return end
    if not isnumber(self.Color.r) then return end
    if not isnumber(self.Color.g) then return end
    if not isnumber(self.Color.b) then return end
    if not isnumber(self.deg) then return end
    if not isnumber(self.rad) then return end
    if not isnumber(self.InitTime) then return end
    if not isnumber(self.LifeTime) then return end
    if not isnumber(self.tmax) then return end
    if not isnumber(self.tmin) then return end
    if not (self.Weapon:IsTPS() or drawviewmodel:GetBool()) then return end
    local pos, ang = self.Weapon:GetMuzzlePosition()
    if not isvector(pos) then return end
    if not isangle(ang) then return end
    local g = physenv.GetGravity()
    local norm = ang:Forward()
    local mul = self.Weapon:IsTPS() and 1 or .5
    local LifeTime = math.max(0, CurTime() - self.InitTime)
    local f = math.Clamp(LifeTime / self.LifeTime, 0, 1)
    local t = Lerp(f, self.tmax, self.tmin)
    local r = Lerp(f, self.radmin, self.rad) * mul
    local alpha = 255
    local mat = inkring

    if self.IsRollerSwing or self.IsBrushSwing then
        pos = self:GetPos()
        ang = LerpAngle(math.EaseInOut(f, 0, 0.5), self.initang, self.endang)
        norm = ang:Forward()
        mat = inkringtranslucent
        alpha = Lerp(math.EaseInOut(f, 0, 1), 255, 0)
    else
        pos:Add(norm * self.tmax * f + g / 2 * LifeTime^2)
        self:SetPos(pos)
        if self.UseRefract then
            mat = ss.GetWaterMaterial()
            render.UpdateRefractTexture()
        else
            inkring:SetFloat("$alphatestreference", Lerp(f, 0.1, 0.9))
            inkring:Recompute()
        end
    end

    render.SetMaterial(mat)
    for x = 0, 2 do
        mesh.Begin(MATERIAL_TRIANGLE_STRIP, Division * 2)
        for i = 0, Division do
            local v = i / Division
            local a = Angle(ang) a:RotateAroundAxis(norm, self.deg + DegStep * i)
            local dir = a:Right() a:RotateAroundAxis(norm, DegStep)
            local nextdir = a:Right() a:RotateAroundAxis(norm, -DegStep * 2)
            local prevdir = a:Right()
            local n = norm:Cross((prevdir - nextdir):GetNormalized())
            local dp1 = norm * (.5 - x / 3) * t
            local dp2 = norm * (.5 - (x + 1) / 3) * t
            local p1 = dir * (r - (x == 0 and t / self.curl or 0)) + dp1
            local p2 = dir * (r - (x == 2 and t / self.curl or 0)) + dp2
            AdvanceVertex(self, pos + p1, n, x / 3, v, alpha)
            AdvanceVertex(self, pos + p2, n, (x + 1) / 3, v, alpha)
        end
        mesh.End()
    end
end

-- Called when the effect should think, return false to kill the effect.
function EFFECT:Think()
    return IsValid(self.Weapon)
    and istable(self.Color)
    and isnumber(self.Color.r)
    and isnumber(self.Color.g)
    and isnumber(self.Color.b)
    and isnumber(self.deg)
    and isnumber(self.rad)
    and isnumber(self.InitTime)
    and isnumber(self.LifeTime)
    and isnumber(self.tmax)
    and isnumber(self.tmin)
    and CurTime() < self.InitTime + self.LifeTime
    and (self.Weapon:IsTPS() or drawviewmodel:GetBool())
    and IsValid(self.Weapon:GetOwner())
    and self.Weapon:GetOwner():GetActiveWeapon() == self.Weapon
end
