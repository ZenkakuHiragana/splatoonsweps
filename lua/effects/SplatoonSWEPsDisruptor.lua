
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
function EFFECT:Init(e)
    self:SetModel(mdl)
    local color = ss.GetColor(e:GetColor())
    local p = CreateParticleSystem(game.GetWorld(), ss.Particles.Disruptor, PATTACH_WORLDORIGIN, 0, e:GetOrigin())
    p:AddControlPoint(1, game.GetWorld(), PATTACH_WORLDORIGIN, nil, color:ToVector() * 0.75)
    p:AddControlPoint(2, game.GetWorld(), PATTACH_WORLDORIGIN, nil, vector_up *  e:GetRadius())
end

function EFFECT:Render()
end
