
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
    local name = ss.Particles.RollerRolling
    if e:GetFlags() > 0 then
        a = ent:LookupAttachment "tip"
        name = ss.Particles.BrushRunning
    end

    local p = CreateParticleSystem(ent, name, PATTACH_POINT_FOLLOW, a, dp)
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, w:GetInkColorProxy())
    p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * e:GetRadius())
end
