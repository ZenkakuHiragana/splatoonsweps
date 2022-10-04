
local ss = SplatoonSWEPs
if not ss then return end

local TRACE_SIZE = 15
local mat = Material "splatoonsweps/crosshair/landing_point"
local mdl = Model "models/hunter/misc/sphere075x075.mdl"
local function CheckVars(self)
    if not IsValid(self.Weapon) then return end
    if not IsValid(self.Weapon:GetOwner()) then return end
    if self.Weapon:GetOwner():GetActiveWeapon() ~= self.Weapon then return end
    return true
end

local function RefreshPos(self, pos)
    local ang = self.Normal:Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    pos = pos or GetViewEntity():GetPos()
    self:SetAngles(ang)
    self:SetPos(pos)
    self:SetRenderOrigin(pos)
end

function EFFECT:Init(e)
    self.Weapon = e:GetEntity()
    if not IsValid(self.Weapon) then return end
    self.Positions = {}
    self.Normal = Vector()
    self:SetRenderBounds(ss.vector_one * -16384, ss.vector_one * 16384)
    self:SetPos(GetViewEntity():GetPos())
    self:SetColor(ss.GetColor(self:GetNWInt "inkcolor"))
    self:SetModel(mdl)
    self:SetMaterial(mat:GetName())
    self:SetModelScale(e:GetScale())
end

function EFFECT:Render()
    if not CheckVars(self) then return end
    if self.Weapon:GetInk() < ss.ProtectedCall(self.Weapon.GetSubWeaponInkConsume, self.Weapon) then return end
    local color = ss.GetColor(self.Weapon:GetNWInt "inkcolor")
    local initapparentpos = self.Weapon:GetHandPos()
    local initposdiff = initapparentpos - self.Weapon:GetShootPos()

    render.SetColorMaterial()
    render.StartBeam(#self.Positions)
    for i, p in ipairs(self.Positions) do
        p = p + LerpVector(i / #self.Positions, initposdiff, Vector())
        render.AddBeam(p, 1, (i - 1) / #self.Positions, color)
    end
    render.EndBeam()

    RefreshPos(self, self.Positions[#self.Positions])
    render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255)
    render.ModelMaterialOverride(mat)
    render.SuppressEngineLighting(true)
    self:SetupBones()
    self:DrawModel()
    render.ModelMaterialOverride()
    render.SuppressEngineLighting(false)
end

function EFFECT:Think()
    if not CheckVars(self) then return false end
    local initpos = self.Weapon:GetShootPos()
    local g_dir = ss.GetGravityDirection()
    local velocity = self.Weapon:GetSubWeaponInitVelocity()
    local dt = ss.FrameToSec
    local tr = {
        start = initpos,
        endpos = initpos,
        mask = MASK_SOLID,
        collisiongroup = COLLISION_GROUP_PROJECTILE,
        filter = ss.MakeAllyFilter(self.Weapon),
        maxs = ss.vector_one * TRACE_SIZE,
        mins = -ss.vector_one * TRACE_SIZE,
    }

    self.Positions = {initpos}
    local count = 0
    local p = ss.splatbomb.Parameters
    repeat
        tr.start = tr.endpos
        tr.endpos = tr.endpos + velocity * dt
        local t = count * dt
        local trace = util.TraceHull(tr)
        velocity:Add(velocity * (p.Fly_VelKd - 1))
        if t > p.Fly_AirFrm then
            velocity:Add(g_dir * p.Fly_Gravity * dt)
        end

        count = count + 1
        self.Positions[#self.Positions + 1] = trace.HitPos
        self.Normal = trace.HitNormal
    until count > 1 and trace.Hit

    self.Positions[#self.Positions + 1] = self.Positions[#self.Positions]
    + velocity * dt - self.Normal * TRACE_SIZE

    RefreshPos(self)
    return self.Weapon:GetThrowing() and self.Weapon:GetKey() == IN_ATTACK2
end
