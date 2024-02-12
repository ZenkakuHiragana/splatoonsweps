
local ss = SplatoonSWEPs
if not ss then return end
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Bubbler
---@class EFFECT.Bubbler : EFFECT

function EFFECT:Init(e)
    self:SetModel(ss.BubblerModel)
    local w = e:GetEntity() --[[@as SplatoonWeaponBase]]
    if not IsValid(w) then return end
    local Owner = w:GetOwner()
    if not IsValid(Owner) then return end
    if not IsValid(w.WElements.bubbler.modelEnt) then w:RecreateModel(w.WElements.bubbler) end
    if not IsValid(w.WElements.bubbler.modelEnt) then return end
    local disappearing = e:GetFlags() > 0
    local mdl = w.WElements.bubbler.modelEnt --[[@as CSEnt.Bubbler]]
    local eye = Owner:EyePos()
    local pos = Owner:GetPos()
    local dz = eye.z - pos.z
    local color = ss.GetColor(e:GetColor()):ToVector()
    local name = disappearing and ss.Particles.BubblerEnding or ss.Particles.BubblerStart
    local p = CreateParticleSystem(mdl, name, PATTACH_ABSORIGIN_FOLLOW)
    if disappearing then
        timer.Simple(1.1, function()
            if not IsValid(mdl) then return end
            mdl:SetColor4Part(255, 255, 255, 0)
        end)
    else
        mdl:SetColor4Part(255, 255, 255, 255)
    end
    p:SetControlPoint(1, LerpVector(1 / 3, color, ss.vector_one))
    p:SetControlPoint(2, ss.vector_one * dz)
    w.BubblerEffect = p
    mdl.InitTime = CurTime()
    mdl.IsDisappearing = disappearing
end

function EFFECT:Render()
end
