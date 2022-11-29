
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/props_junk/PopCan01a.mdl"
function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self:SetNoDraw(true)
    local w = e:GetEntity()
    if not IsValid(w) then return end
    local ent = w:IsTPS() and w or w:GetViewModel()
    local a = ent:LookupAttachment "roll"
    local c = w:GetInkColorProxy() + ss.vector_one
    local f = e:GetFlags()
    local name = ss.Particles.RollerSplash
    if bit.band(f, 1) > 0 then
        a = ent:LookupAttachment "tip"
        name = ss.Particles.BrushSplash
    elseif bit.band(f, 2) > 0 then
        a = ent:LookupAttachment "spout"
        name = ss.Particles.RollerSplash
    end

    local p = CreateParticleSystem(ent, name, PATTACH_POINT_FOLLOW, a, vector_origin)
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, c / 2)
end
