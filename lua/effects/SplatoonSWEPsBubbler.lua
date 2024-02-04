
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/splatoonsweps/specials/bubbler.mdl"
local EFFECT = EFFECT
---@cast EFFECT EFFECT.Bubbler
---@class EFFECT.Bubbler : EFFECT
---@field InitTime         number
---@field Weapon           SplatoonWeaponBase
---@field GetInkColorProxy fun(self): Vector

function EFFECT:GetInkColorProxy()
    if not IsValid(self.Weapon) then return ss.vector_one end
    return self.Weapon:GetInkColorProxy()
end

function EFFECT:Init(e)
    self.InitTime = CurTime()
    self.Weapon = e:GetEntity() --[[@as SplatoonWeaponBase]]
    if not (IsValid(self.Weapon) and IsValid(self.Weapon:GetOwner())) then return end
    self:SetPos(self.Weapon:GetOwner():WorldSpaceCenter())
    self:SetModel(mdl)
end

function EFFECT:Think()
    local valid = IsValid(self.Weapon)
    and IsValid(self.Weapon:GetOwner())
    and ss.IsInvincible(self.Weapon:GetOwner())
    if not valid then
        self:EmitSound "SplatoonSWEPs.BubblerEnd"
        return false
    end

    local mins, maxs = self:GetModelRenderBounds()
    local ref = maxs.z - mins.z
    local Owner = self.Weapon:GetOwner()
    local dz = Owner:EyePos().z - Owner:GetPos().z
    local scale = dz / ref
    self:SetPos(Owner:WorldSpaceCenter())
    self:SetAngles(EyeAngles())
    self:SetModelScale(scale * 1.5)
    return true
end

function EFFECT:Render()
    local w = self.Weapon
    if not IsValid(w) then return end
    local Owner = w:GetOwner()
    if not IsValid(Owner) then return end
    if not (Owner:IsPlayer() or Owner:IsNPC()) then return end ---@cast Owner Player
    if Owner:GetActiveWeapon() ~= w then return end
    self:SetPos(Owner:WorldSpaceCenter())
    self:SetAngles(EyeAngles())
    self:SetupBones()
    self:DrawModel()
end
