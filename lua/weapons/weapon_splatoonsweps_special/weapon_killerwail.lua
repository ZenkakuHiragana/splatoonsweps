
AddCSLuaFile()
local SWEP = SWEP ---@cast SWEP SWEP.Special
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
    function SWEP:PreDrawWorldModel()
        return self:Clip1() <= 0
    end
end
