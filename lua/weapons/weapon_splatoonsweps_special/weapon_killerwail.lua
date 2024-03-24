
AddCSLuaFile()

---@class SWEP.KillerWail : SWEP.Special
---@field Crosshair CSEnt
local SWEP = SWEP

local ss = SplatoonSWEPs
if not (ss and SWEP) then return end

table.Merge(SWEP, ss.killerwail.Merge)
function SWEP:CustomActivity()
    return self:Clip1() > 0 and "duel" or "passive"
end

function SWEP:CustomMoveSpeed()
    if self:Clip1() <= 0 then return end
    return ss.InklingBaseSpeed * 0.1
end

function SWEP:SharedInitSpecial()
    self:AddSchedule(0, function()
        local loaded = self:Clip1() > 0
        self:SetSpecialActivated(loaded)
        if CLIENT and self:IsTPS() then return end
        if loaded then
            self:SetWeaponAnim(ss.ViewModel.Standing)
        else
            self:SetWeaponAnim(ss.ViewModel.Squid)
        end
    end)

    if CLIENT then return end
    local lastknownpos ---@type Vector
    self:AddSchedule(2, function()
        local Owner = self:GetOwner()
        if not (IsValid(Owner) and Owner:IsNPC()) then return end ---@cast Owner NPC
        local Enemy = Owner:GetEnemy()
        if not IsValid(Enemy) then return end
        if Enemy:GetClass() == "npc_bullseye" then return end
        if CurTime() - Owner:GetEnemyLastTimeSeen() > 16 and lastknownpos
        and lastknownpos:DistToSqr(Owner:GetEnemyLastKnownPos(Enemy)) < 100 then return end
        lastknownpos = Owner:GetEnemyLastKnownPos(Enemy)
        local tr = util.QuickTrace(Owner:WorldSpaceCenter(), lastknownpos - Owner:WorldSpaceCenter(), Owner)
        Owner:IgnoreEnemyUntil(Enemy, CurTime() + 2)
        local bullseye = ents.Create "npc_bullseye"
        bullseye:SetPos(LerpVector(0.5, tr.StartPos, tr.HitPos))
        bullseye:Spawn()
        bullseye:SetHealth(0)
        bullseye:SetMaxHealth(0)
        bullseye:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        SafeRemoveEntityDelayed(bullseye, 4)
        Owner:AddEntityRelationship(bullseye, D_HT, 1)
        Owner:SetEnemy(bullseye, true)
        Owner:UpdateEnemyMemory(bullseye, bullseye:GetPos())
    end)
end

function SWEP:SharedPrimaryAttack()
    if self:Clip1() <= 0 then return end

    self:TakePrimaryAmmo(1)
    local activator = self:GetNWEntity "Activator" ---@cast activator SplatoonWeaponBase
    if IsValid(activator) then activator:OnSpecialEnd() end

    if CLIENT then return end
    local Owner = self:GetOwner()
    if not IsValid(Owner) then return end ---@cast Owner Player
    local dir = ss.ProtectedCall(Owner.GetAimVector, Owner) or Owner:GetForward()
    local ent = ents.Create "ent_splatoonsweps_killerwail" --[[@as ENT.KillerWail]]
    if Owner:IsNPC() then ---@cast Owner NPC
        local enemy = Owner:GetEnemy()
        if IsValid(enemy) then
            dir = enemy:WorldSpaceCenter() - Owner:WorldSpaceCenter()
            dir:Normalize()
        end
    end
    ent:SetOwner(IsValid(activator) and activator or self)
    ent:SetPos(Owner:WorldSpaceCenter() + dir * 30)
    ent:SetAngles(dir:Angle())
    ent:Spawn()
    ss.ApplyKnockback(Owner, -Owner:GetForward() * ss.InklingBaseSpeed)
end

if SERVER then
    function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
        local Owner = self:GetOwner()
        if self:Clip1() > 0 then
            self:PrimaryAttackEntryPoint()
        elseif IsValid(Owner) and Owner:IsNPC() then ---@cast Owner NPC
            Owner:SetCondition(4) -- COND.NO_PRIMARY_AMMO
        end
    end
else
    ---@param self SWEP.KillerWail
    ---@param att AngPos
    local function Draw(self, att)
        local ent = self.Crosshair
        if not IsValid(ent) then return end
        local m = Matrix()
        m:Scale(ss.vector_one * ss.killerwail.Parameters.Radius * 2 / math.sqrt(math.pi))
        ent:SetNoDraw(true)
        ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ent:SetBodygroup(1, 0)
        ent:EnableMatrix("RenderMultiply", m)
        ent:SetSkin(3)
        ent:SetPos(att.Pos)
        ent:SetAngles(LocalPlayer():GetAimVector():Angle())
        ent:SetupBones()
        local c = ss.GetColor(ss.CrosshairColors[self:GetNWInt "inkcolor"]):ToVector()
        render.SetColorModulation(c:Unpack())
        ent:DrawModel()
        render.SetColorModulation(1, 1, 1)
    end

    local drawhud = GetConVar "cl_drawhud"
    function SWEP:PreDrawWorldModel()
        if self:Clip1() <= 0 then return true end
        if self:GetOwner() ~= LocalPlayer() then return end
        if not ss.GetOption "drawcrosshair" then return end
        if not drawhud:GetBool() then return end
        Draw(self, self:GetAttachment(self:LookupAttachment "muzzle"))
    end

    function SWEP:PreViewModelDrawn(vm)
        ---@cast vm Entity.Colorable
        function vm.GetInkColorProxy()
            return ss.ProtectedCall(self.GetInkColorProxy, self) or ss.vector_one
        end
        if self:Clip1() <= 0 then return end
        if self:GetOwner() ~= LocalPlayer() then return end
        if not ss.GetOption "drawcrosshair" then return end
        if not drawhud:GetBool() then return end
        Draw(self, vm:GetAttachment(vm:LookupAttachment "muzzle"))
    end

    local mdl = Model "models/splatoonsweps/effects/killerwail_effect.mdl"
    function SWEP:ClientInit()
        self.Crosshair = ClientsideModel(mdl, RENDERGROUP_TRANSLUCENT)
    end

    function SWEP:ClientOnRemove()
        if IsValid(self.Crosshair) then self.Crosshair:Remove() end
    end
end
