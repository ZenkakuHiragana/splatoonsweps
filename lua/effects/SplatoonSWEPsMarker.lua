
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/splatoonsweps/effects/marker_ring.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Marker
---@class EFFECT.Marker : EFFECT
---@field Particle CNewParticleEffect
---@field Color integer
---@field Radius number
---@field Target Entity
---@field UpdatePos fun(self)
---@field DispatchEffect fun(self)
---@field ShouldDraw fun(self): boolean

function EFFECT:ShouldDraw()
    if not IsValid(self.Target) then return false end
    local lp = LocalPlayer()
    local w = ss.IsValidInkling(lp)
    local isally = w and ss.IsAlly(w, self.Color) or false
    if self.Target == lp then
        return not isally
    else
        return isally
    end
end

function EFFECT:DispatchEffect()
    if not self:ShouldDraw() then return end
    local angle = Angle(0, EyeAngles().yaw + 90, 0)
    local scale = self.Radius / 32
    local name = "splatoonsweps_marker_off_"
    local index = math.random(1, 1)
    if scale < 0.75 then name = name .. "half_" end
    if scale > 1.55 then name = name .. "big_" end
    local p = CreateParticleSystemNoEntity(name .. index, self:GetPos(), angle)
    p:SetControlPoint(1, self:GetColor():ToVector())
    p:SetControlPoint(2, ss.vector_one * scale)
    p:SetControlPoint(3, Vector())
    p:SetControlPointOrientation(3, angle:Forward(), angle:Right(), angle:Up())
end

function EFFECT:UpdatePos()
    if not IsValid(self.Target) then return end
    local lp = LocalPlayer()
    if self.Target ~= lp or lp:ShouldDrawLocalPlayer() then
        self:SetPos(ss.GetMarkerPosition(self.Target))
    else
        self:SetPos(lp:GetPos() + lp:GetViewOffsetDucked() / 2)
    end
end

function EFFECT:Init(e)
    local ent = e:GetEntity()
    if not IsValid(ent) then return end
    self.Target = ent
    self.Radius = (ent:OBBMaxs():Length2D() + ent:OBBMins():Length2D()) / 2
    self.Color = e:GetColor()
    self:SetColor(ss.GetColor(self.Color))
    self:SetModel(mdl)
    self:SetModelScale(self.Radius)
    self:UpdatePos()
end

function EFFECT:Think()
    self:UpdatePos()
    if not IsValid(self.Target)
    or self.Target:Health() <= 0
    or not ss.MarkedEntities[self.Target]
    or not ss.MarkedEntities[self.Target][self.Color] then
        self:DispatchEffect()
        if self.Target == LocalPlayer() and LocalPlayer():Alive() then
            self.Target:EmitSound "SplatoonSWEPs.PointSensorLeft"
        end
        return false
    end
    return true
end

function EFFECT:Render()
    if not self:ShouldDraw() then return end
    self:UpdatePos()
    self:SetAngles(Angle(180, -CurTime() * 360, 0))
    self:SetupBones()

    local lp = LocalPlayer()
    local w = ss.IsValidInkling(lp)
    if w and self.Target == lp and lp:ShouldDrawLocalPlayer() then
        render.SetBlend(w:GetCameraFade())
        self:DrawModel()
        render.SetBlend(1)
    else
        self:DrawModel()
    end
end
