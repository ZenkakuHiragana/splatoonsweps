
local ss = SplatoonSWEPs
if not ss then return end

include "SplatoonSWEPsInkBase.lua"

local BaseInit = EFFECT.Init
function EFFECT:Init(e)
    print(e:GetAngles())
    BaseInit(self, e)
end
