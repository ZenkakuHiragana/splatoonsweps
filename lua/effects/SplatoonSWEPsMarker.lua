
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/splatoonsweps/effects/marker_ring.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Marker
---@class EFFECT.Marker : EFFECT
---@field Particle CNewParticleEffect
---@field NextEffectDispatchTime number
---@field Color integer
---@field InitTime number
---@field Radius number
---@field Target Entity
---@field UpdatePos fun(self)
---@field DispatchEffect fun(self)
---@field ShouldDraw fun(self): boolean

function EFFECT:ShouldDraw()
    if not IsValid(self.Target) then return false end
    local lp = LocalPlayer()
    local w = ss.IsValidInkling(lp)
    local isally = w and w:GetNWInt("inkcolor", -1) == self.Color or false
    if self.Target == lp and not ss.GetOption "hurtowner" then
        return not isally
    else
        return isally
    end
end

function EFFECT:DispatchEffect()
    if not self:ShouldDraw() then return end
    local yaw = EyeAngles().yaw + 90 + math.random(0, 3) * 30
    local angle = Angle(0, yaw, 0)
    local scale = self.Radius / 32
    local name = ss.Particles.MarkerLeft

    local mod = ""
    local index = math.random(1, 2)
    if scale < 0.75 then mod = "half_" end
    if scale > 1.55 then mod = "big_" end
    local p = CreateParticleSystemNoEntity(name:format(mod, index), self:GetPos(), angle)
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
    self.NextEffectDispatchTime = CurTime() + math.Rand(1 - 0.2, 1 + 0.2)
    self.Target = ent
    self.Radius = (ent:OBBMaxs():Length2D() + ent:OBBMins():Length2D()) / 2
    self.Color = e:GetColor()
    self.InitTime = CurTime()
    self:SetColor(ss.GetColor(self.Color))
    self:SetModel(mdl)
    self:SetModelScale(self.Radius)
    self:UpdatePos()
end

function EFFECT:Think()
    self:UpdatePos()
    if CurTime() - self.InitTime < 0.5 then return true end
    if self:ShouldDraw() and CurTime() > self.NextEffectDispatchTime then
        local p = CreateParticleSystemNoEntity(ss.Particles.MarkerSquare, self:GetPos())
        p:SetControlPoint(1, self:GetColor():ToVector())
        p:SetControlPoint(2, ss.vector_one * self.Radius / 205)
        self.NextEffectDispatchTime = CurTime() + math.Rand(1 - 0.2, 1 + 0.2)
    end

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
