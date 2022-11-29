
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/props_junk/PopCan01a.mdl"
local drawviewmodel = GetConVar "r_drawviewmodel"
function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetMaterial(ss.Materials.Effects.Invisible:GetName())
    self:SetNoDraw(true)
    local w = e:GetEntity()
    if not IsValid(w) then return end
    local t = w:IsTPS()
    if not (t or drawviewmodel:GetBool()) then return end
    local ent = t and w or w:GetViewModel()
    local s = t and 30 or 15
    local c = w:GetInkColorProxy() + ss.vector_one
    local a = ent:LookupAttachment "muzzle"
    local p = CreateParticleSystem(ent, ss.Particles.SplatlingMuzzleFlash, PATTACH_POINT_FOLLOW, a, vector_origin)
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, c / 2)
    p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up * s)
end
