
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/splatoonsweps/effects/killerwail_effect.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.KillerWail
---@class EFFECT.KillerWail : EFFECT
---@field AnimFrame integer
---@field DesiredRadius number
---@field Entity ENT.KillerWail
---@field HasSpawnedEffect boolean
---@field InitTime number
---@field Scale number

local mat = Material "splatoonsweps/weapons/specials/killerwail/killerwail_notification.vmt"
local mat2 = Material "splatoonsweps/weapons/specials/killerwail/killerwail_transition_additive.vmt"
local tex = mat:GetTexture "$basetexture"
local AnimFrameRate = 15
local BloatDuration = 20 * ss.FrameToSec -- Shockwave model scale change
local ShrinkDuration = 20 * ss.FrameToSec -- Shockwave model scale change
local FadeinDuration = 12 * ss.FrameToSec -- Notification fade-in
local FadeoutDuration = 10 * ss.FrameToSec -- Notification fade-out
function EFFECT:Init(e)
    self.Entity = e:GetEntity() --[[@as ENT.KillerWail]]
    if not IsValid(self.Entity) then return end
    self.Scale = 1
    self.AnimFrame = 0
    self.HasSpawnedEffect = false
    self.InitTime = CurTime()
    self.DesiredRadius = ss.killerwail.Parameters.Radius * 2 / math.sqrt(math.pi)
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetModel(mdl)
    self:SetBodygroup(1, 0)
    local bound = ss.GetMinimapAreaBounds(e:GetOrigin())
    if bound then self:SetRenderBoundsWS(bound.mins, bound.maxs) end
    local f = e:GetFlags()
    if f == 0 then -- Initial notification
        if not IsValid(self.Entity) then return end
        self:SetSkin(2)
        self.Scale = self.DesiredRadius
    elseif f == 1 then -- Main shockwave
        self:SetSkin(1)
    end
end

function EFFECT:Think()
    local ent = self.Entity
    local t = CurTime() - self.InitTime
    local param = ss.killerwail.Parameters
    local radius = self.DesiredRadius
    local alpha = 255
    if self:GetSkin() == 2 then -- Initial notification
        if t < param.NotificationDuration then
            alpha = Lerp(t / FadeinDuration, 0, 255)
            if t > FadeinDuration then
                t = t - FadeinDuration
                self.AnimFrame = math.Clamp(math.floor(t * AnimFrameRate), 0, tex:GetNumAnimationFrames() - 1)
            end
        else
            t = t - param.NotificationDuration
            alpha = Lerp(t / FadeoutDuration, 255, 0)
            if t > FadeoutDuration then return false end
            if IsValid(ent) and not self.HasSpawnedEffect then
                local e = EffectData()
                e:SetEntity(ent)
                e:SetFlags(1)
                e:SetOrigin(self:GetPos())
                util.Effect("SplatoonSWEPsKillerWail", e)
                self.HasSpawnedEffect = true
            end
        end
    else -- Main shockwave
        if t < BloatDuration then -- Initial bloating
            self.Scale = Lerp(t / BloatDuration, 1, radius)
        elseif t < param.AttackDuration then
            local scale = TimedCos(ss.SecToFrame / 5, radius - 2, radius + 2, 0)
            self:SetSkin(0)
            self:SetBodygroup(1, 1)
            self.Scale = scale
        else
            t = t - param.AttackDuration
            if t > ShrinkDuration then return false end
            alpha = Lerp(t / ShrinkDuration, 255, 0)
            self.Scale = Lerp(t / ShrinkDuration, radius, 1)
        end
    end

    local color = self:GetColor()
    if IsValid(ent) then color = ent:GetInkColorProxy():ToColor() end
    self:SetColor(ColorAlpha(color, alpha))
    return true
end

function EFFECT:Render()
    if self:GetSkin() == 2 then
        mat:SetInt("$frame", self.AnimFrame)
    elseif self:GetSkin() == 1 then
        local frac = self.Scale / self.DesiredRadius
        mat2:SetVector("$color", LerpVector(frac, ss.vector_one, self:GetColor():ToVector()))
    end
    if IsValid(self.Entity) then
        local att = self.Entity:GetAttachment(self.Entity:LookupAttachment "muzzle")
        self:SetPos(att.Pos)
        self:SetAngles(att.Ang)
    end

    local m = Matrix()
    m:Scale(Vector(self.DesiredRadius, self.Scale, self.Scale))
    self:EnableMatrix("RenderMultiply", m)
    self:DrawModel()
end
