
local ss = SplatoonSWEPs
if not ss then return end
include "shared.lua"
include "baseinfo.lua"
include "cl_draw.lua"
include "ai_translations.lua"

---@class SplatoonWeaponBase
---@field HullDuckMaxs             Vector
---@field HullDuckMins             Vector
---@field ViewOffsetDucked         Vector
local SWEP = SWEP

SWEP.WElements = {
    bubbler = {
        type  = "Model",
        model = ss.BubblerModel,
        bone  = "ValveBiped.Bip01_Spine4",
    },
    inktank = {
        type      = "Model",
        model     = ss.InkTankModel,
        bone      = "ValveBiped.Bip01_Spine4",
        pos       = Vector(-22, -3, 0),
        angle     = Angle(0, 75, 90),
        inktank   = true,
    },
    subweaponusable = {
        type     = "Sprite",
        sprite   = "sprites/orangeflare1",
        bone     = "ValveBiped.Bip01_Spine4",
        pos      = Vector(3, -10, 0),
        size     = { x = 12, y = 12 },
        nocull   = true,
        additive = true,
    },
}

---Pops up error notification on the player's screen
---@param msg string
function SWEP:PopupError(msg)
    msg = ss.Text.Error[msg] --[[@as string]]
    if not msg then return end
    notification.AddLegacy(msg, NOTIFY_ERROR, 10)
end

function SWEP:Initialize()
    -- Create a new table for every weapon instance
    self.WElements = ss.deepcopy(self.WElements)
    self:CreateModels(self.WElements) -- create worldmodels

    -- Our initialize code
    self.SpriteCurrentSize = 0
    self.SpriteSizeChangeSpeed = 0
    self.EnoughSubWeapon = true
    self.PreviousInk = true
    self.Cursor = { x = ScrW() / 2, y = ScrH() / 2 }
    self:MakeSquidModel()
    self:SharedInitBase()
    ss.ProtectedCall(self.ClientInit, self)
    self:Deploy()
end

function SWEP:Deploy()
    local Owner = self:GetOwner()
    if not IsValid(Owner) then return true end
    if Owner:IsPlayer() then ---@cast Owner Player
        self.HullDuckMins, self.HullDuckMaxs = Owner:GetHullDuck()
        self.ViewOffsetDucked = Owner:GetViewOffsetDucked()
        self:ResetBonePositions(self:GetViewModel())
    end

    self:GetOptions()
    ss.ProtectedCall(self.ClientDeploy, self)
    return self:SharedDeployBase()
end

function SWEP:Holster()
    if self:GetInFence() then return false end

    local Owner = self:GetOwner()
    if not IsValid(Owner) then return true end
    if Owner:IsPlayer() then ---@cast Owner Player
        local vm = self:GetViewModel()
        if IsValid(vm) then self:ResetBonePositions(vm) end
        if self:GetNWBool "becomesquid" and self.HullDuckMins then
            Owner:SetHullDuck(self.HullDuckMins, self.HullDuckMaxs)
            Owner:SetViewOffsetDucked(self.ViewOffsetDucked)
        end
    end

    Owner:SetHealth(Owner:Health() * self:GetNWInt "BackupHumanMaxHealth" / self:GetNWInt "BackupInklingMaxHealth")
    ss.ProtectedCall(self.ClientHolster, self)
    return self:SharedHolsterBase()
end

-- It's important to remove CSEnt with CSEnt:Remove() when it's no longer needed.
function SWEP:OnRemove()
    local vm = self:GetViewModel()
    if IsValid(vm) then self:ResetBonePositions(vm) end
    for _, v in pairs(self.WElements) do
        if IsValid(v.modelEnt) then v.modelEnt:Remove() end
    end

    self:StopLoopSound()
    self:EndRecording()
    ss.ProtectedCall(self.ClientOnRemove, self)
    ss.ProtectedCall(self.SharedOnRemove, self)
    ss.UnregisterEntity(self:GetOwner(), self:GetNWInt("inkcolor", -1))
end

function SWEP:Think()
    if not IsValid(self:GetOwner()) or self:GetHolstering() then return end
    if self:IsFirstTimePredicted() then
        local enough = self:GetInk() > (ss.ProtectedCall(self.GetSubWeaponInkConsume, self) or 0)
        if not self.EnoughSubWeapon and enough and self:IsCarriedByLocalPlayer() then
            surface.PlaySound(ss.BombAvailable)
        end
        self.EnoughSubWeapon = enough
    end

    self:ProcessSchedules()
    self:SharedThinkBase()
    ss.ProtectedCall(self.ClientThink, self)
end

---Returns if the owner is seeing third person view
---@return boolean # True if the camera is third person view
function SWEP:IsTPS()
    local Owner = self:GetOwner() --[[@as Player]]
    return not self:IsCarriedByLocalPlayer() or Owner:ShouldDrawLocalPlayer()
end

---Translates given world position to view model position
---@param pos Vector The world position
---@return Vector # Translated view model position
function SWEP:TranslateToViewmodelPos(pos)
    if self:IsTPS() then return pos end
    local dir = pos - EyePos() dir:Normalize()
    local aim = EyeAngles():Forward()
    dir = aim + (dir - aim) * self:GetFOV() / self.ViewModelFOV
    return EyePos() + dir * pos:Distance(EyePos())
end

---Translates given view model position to world position
---@param pos Vector The view model position
---@return Vector # Translated world position
function SWEP:TranslateToWorldmodelPos(pos)
    if self:IsTPS() then return pos end
    local dir = pos - EyePos() dir:Normalize()
    local aim = EyeAngles():Forward()
    dir = aim + (dir - aim) * self.ViewModelFOV / self:GetFOV()
    return EyePos() + dir * pos:Distance(EyePos())
end
