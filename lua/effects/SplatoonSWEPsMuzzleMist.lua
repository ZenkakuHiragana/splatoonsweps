
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/props_junk/PopCan01a.mdl"
local drawviewmodel = GetConVar "r_drawviewmodel"
function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self:SetNoDraw(true)
    local w = e:GetEntity()
    if w ~= game.GetWorld() and (not IsValid(w) or w:ViewModelIndex() and not drawviewmodel:GetBool()) then return end
    local p = CreateParticleSystem(w, ss.Particles.MuzzleMist, e:GetFlags(), e:GetAttachment(), e:GetOrigin())
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, ss.GetColor(e:GetColor()):ToVector())
    p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * e:GetScale())
    p:AddControlPoint(3, game.GetWorld(), PATTACH_WORLDORIGIN, nil, e:GetStart())
end
