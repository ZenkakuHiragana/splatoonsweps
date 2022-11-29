
local ss = SplatoonSWEPs
if not ss then return end
AddCSLuaFile "shared.lua"
include "shared.lua"

function SWEP:NPCBurstSettings()
    if self.Parameters.mTripleShotSpan > 0 then
        return 1, 1, self.NPCDelay
    end
end

function SWEP:NPCRestTimes()
    local span = self.Parameters.mTripleShotSpan
    if span > 0 then return span, span end
end

local TrailParams = {true, 3, 1, .5, .125, "sprites/physbeama"}
function SWEP:ServerDeploy()
    if not (self.IsHeroShot and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then return end
    local a = self:LookupAttachment "trail"
    local c = self.HeroColor[self:GetNWInt "level" + 1]
    local vm = self:GetViewModel()
    self:SetNWEntity("Trail", util.SpriteTrail(self, a, c, unpack(TrailParams)))
    self:DeleteOnRemove(self:GetNWEntity "Trail")

    if not IsValid(vm) then return end
    a = vm:LookupAttachment "trail"
    self:SetNWEntity("TrailVM", util.SpriteTrail(vm, a, c, unpack(TrailParams)))
    self:DeleteOnRemove(self:GetNWEntity "TrailVM")
end

function SWEP:ServerHolster()
    if not self.IsHeroShot then return end
    SafeRemoveEntity(self:GetNWEntity "Trail")
    SafeRemoveEntity(self:GetNWEntity "TrailVM")
end

function SWEP:ServerThink()
    local c = self.HeroColor[self:GetNWInt "level" + 1]
    for _, t in ipairs {self:GetNWEntity "Trail", self:GetNWEntity "TrailVM"} do
        if IsValid(t) then t:Fire("Color", tostring(c)) end
    end
end

function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
    self:PrimaryAttack()
    if self.IsBlaster then return end
    self:AddSchedule(self.Parameters.mRepeatFrame, 2, function(_, schedule)
        self:PrimaryAttack()
    end)
end
