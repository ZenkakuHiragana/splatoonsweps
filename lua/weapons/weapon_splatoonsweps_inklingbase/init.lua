
local ss = SplatoonSWEPs
if not ss then return end
AddCSLuaFile "shared.lua"
AddCSLuaFile "baseinfo.lua"
AddCSLuaFile "ai_translations.lua"
AddCSLuaFile "cl_draw.lua"
include "shared.lua"
include "baseinfo.lua"
include "ai_translations.lua"

local function InvalidPlayer(Owner)
    return not IsValid(Owner) or Owner:IsPlayer() and
    not Owner:IsBot() and not table.HasValue(ss.PlayersReady, Owner)
end

function SWEP:ChangePlayermodel(data)
    if not self:GetOwner():IsPlayer() then return end
    self:GetOwner():SetModel(data.Model)
    self:GetOwner():SetSkin(data.Skin)
    local numgroups = self:GetOwner():GetNumBodyGroups()
    if isnumber(numgroups) then
        for k = 0, numgroups - 1 do
            local v = data.BodyGroups[k + 1]
            v = istable(v) and isnumber(v.num) and v.num or 0
            self:GetOwner():SetBodygroup(k, v)
        end
    end

    ss.SetSubMaterial_Workaround(self:GetOwner())
    self:GetOwner():SetPlayerColor(data.PlayerColor)
    if self:GetNWInt "playermodel" <= ss.PLAYER.BOY then
        ss.ProtectedCall(self:GetOwner().SplatColors, self:GetOwner())
    end

    local hands = self:GetOwner():GetHands()
    if not IsValid(hands) then return end
    local mdl = player_manager.TranslateToPlayerModelName(data.Model)
    local info = player_manager.TranslatePlayerHands(mdl)
    if not info then return end
    hands:SetModel(info.model)
    hands:SetSkin(info.skin)
    hands:SetBodyGroups(info.body)
end

local UseRagdoll = {
    weapon_splatoonsweps_roller = true,
    weapon_splatoonsweps_splatling = true,
}
function SWEP:CreateRagdoll()
    if not UseRagdoll[self.Base] then return end
    local ragdoll = self.Ragdoll
    if IsValid(ragdoll) then ragdoll:Remove() end
    ragdoll = ents.Create "prop_ragdoll"
    ragdoll:SetModel(self.WorldModel)
    ragdoll:SetPos(self:GetPos())
    ragdoll:SetAngles(self:GetAngles())
    ragdoll:SetMaterial(ss.Materials.Effects.Invisible:GetName(), true)
    ragdoll:DeleteOnRemove(self)
    ragdoll:Spawn()
    ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    function ragdoll.OnEntityCopyTableFinish(_, data)
        table.Empty(data)
        table.Merge(data, duplicator.CopyEntTable(self))
    end

    self:PhysicsDestroy()
    self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetParent(ragdoll)
    self:AddEffects(EF_BONEMERGE)
    self:DeleteOnRemove(ragdoll)
    self.Ragdoll = ragdoll
    local n = "SplatoonSWEPs: RagdollCollisionCheck" .. self:EntIndex()
    timer.Create(n, 0, 0, function()
        if not (IsValid(self) and IsValid(ragdoll)) then timer.Remove(n) return end
        local nearest, ply = self:BoundingRadius() ^ 2, NULL
        for _, p in ipairs(ss.PlayersReady) do
            local d = p:GetPos():DistToSqr(ragdoll:GetPos())
            if d < nearest then nearest, ply = d, p end
        end

        if not IsValid(ply) then return end
        self:RemoveRagdoll()
        timer.Remove(n)
    end)
end

function SWEP:RemoveRagdoll()
    if not UseRagdoll[self.Base] then return end
    local ragdoll = self.Ragdoll
    if not IsValid(ragdoll) then return end
    self:DrawShadow(true)
    self:DontDeleteOnRemove(ragdoll)
    self:RemoveEffects(EF_BONEMERGE)
    self:SetParent(NULL)
    ragdoll:DontDeleteOnRemove(self)
    ragdoll:Remove()
end

function SWEP:GetNPCBurstSettings()
    local min, max, delay = ss.ProtectedCall(self.NPCBurstSettings, self)
    return min or 3, max or 8, delay or self.NPCDelay
end

function SWEP:GetNPCRestTimes()
    local min, max = ss.ProtectedCall(self.NPCRestTime, self)
    return min or self.NPCDelay, max or self.NPCDelay * 3
end

function SWEP:CanBePickedUpByNPCs()
    return true
end

function SWEP:Initialize()
    self:SetHolstering(true)
    self:SetInInk(false)
    self:SetOnEnemyInk(false)
    self:SetInk(ss.GetMaxInkAmount())
    self:SetInkColorProxy(ss.vector_one)
    self:SharedInitBase()
    self.NextEnemyInkDamage = CurTime()
    timer.Simple(0, function()
        if not IsValid(self) then return end
        if IsValid(self:GetOwner()) then return end
        self:CreateRagdoll()
    end)

    ss.ProtectedCall(self.ServerInit, self)
end

function SWEP:BackupInfo()
    self.BackupInklingMaxHealth = ss.GetMaxHealth()
    self.BackupHumanMaxHealth = self:GetOwner():GetMaxHealth()
    self:SetNWInt("BackupInklingMaxHealth", self.BackupInklingMaxHealth)
    self:SetNWInt("BackupHumanMaxHealth", self.BackupHumanMaxHealth)
    if not self:GetOwner():IsPlayer() then return end
    self.BackupPlayerInfo = {
        Color = self:GetOwner():GetColor(),
        Flags = self:GetOwner():GetFlags(),
        JumpPower = self:GetOwner():GetJumpPower(),
        Material = self:GetOwner():GetMaterial(),
        RenderMode = self:GetRenderMode(),
        Speed = {
            Crouched = self:GetOwner():GetCrouchedWalkSpeed(),
            Duck = self:GetOwner():GetDuckSpeed(),
            Max = self:GetOwner():GetMaxSpeed(),
            Run = self:GetOwner():GetRunSpeed(),
            Walk = self:GetOwner():GetWalkSpeed(),
            UnDuck = self:GetOwner():GetUnDuckSpeed(),
        },
        SubMaterial = {},
        Playermodel = {
            Model = self:GetOwner():GetModel(),
            Skin = self:GetOwner():GetSkin(),
            BodyGroups = self:GetOwner():GetBodyGroups(),
            SetOffsets = table.HasValue(SplatoonTable or {}, self:GetOwner():GetModel()),
            PlayerColor = self:GetOwner():GetPlayerColor(),
        },
        ViewOffsetDucked = self:GetOwner():GetViewOffsetDucked()
    }
    self.BackupPlayerInfo.HullMins, self.BackupPlayerInfo.HullMaxs = self:GetOwner():GetHullDuck()
    for _, v in pairs(self.BackupPlayerInfo.Playermodel.BodyGroups) do
        v.num = self:GetOwner():GetBodygroup(v.id)
    end

    for i = 0, 31 do
        local submat = self:GetOwner():GetSubMaterial(i)
        if submat == "" then submat = nil end
        self.BackupPlayerInfo.SubMaterial[i] = submat
    end
end

function SWEP:RestoreInfo()
    self:GetOwner():SetMaxHealth(self.BackupHumanMaxHealth)
    self:GetOwner():SetHealth(self:GetOwner():Health() * self.BackupHumanMaxHealth / self.BackupInklingMaxHealth)

    if not self:GetOwner():IsPlayer() then return end
    self:GetOwner():SetDSP(1)
    if istable(self.BackupPlayerInfo) then -- Restores owner's information.
        self:ChangePlayermodel(self.BackupPlayerInfo.Playermodel)
        self:GetOwner():SetColor(self.BackupPlayerInfo.Color)
        -- self:GetOwner():RemoveFlags(self:GetOwner():GetFlags()) -- Restores no target flag and something.
        -- self:GetOwner():AddFlags(self.BackupPlayerInfo.Flags)
        self:GetOwner():SetJumpPower(self.BackupPlayerInfo.JumpPower)
        self:GetOwner():SetRenderMode(self.BackupPlayerInfo.RenderMode)
        self:GetOwner():SetCrouchedWalkSpeed(self.BackupPlayerInfo.Speed.Crouched)
        self:GetOwner():SetDuckSpeed(self.BackupPlayerInfo.Speed.Duck)
        self:GetOwner():SetMaxSpeed(self.BackupPlayerInfo.Speed.Max)
        self:GetOwner():SetRunSpeed(self.BackupPlayerInfo.Speed.Run)
        self:GetOwner():SetWalkSpeed(self.BackupPlayerInfo.Speed.Walk)
        self:GetOwner():SetUnDuckSpeed(self.BackupPlayerInfo.Speed.UnDuck)
        self:GetOwner():SetHullDuck(self.BackupPlayerInfo.HullMins, self.BackupPlayerInfo.HullMaxs)
        self:GetOwner():SetViewOffsetDucked(self.BackupPlayerInfo.ViewOffsetDucked)
        self:GetOwner():SetMaterial(self.BackupPlayerInfo.Material)
        for i = 0, 31 do
            ss.SetSubMaterial_Workaround(self:GetOwner(), i, self.BackupPlayerInfo.SubMaterial[i])
        end
    end
end

function SWEP:Equip(newowner)
    self:SetOwner(newowner)
    if InvalidPlayer(self:GetOwner()) then return end
    self:RemoveRagdoll()
    self:PlayLoopSound()
    self.SafeOwner = self:GetOwner()

    if IsValid(self:GetOwner()) and not self:GetOwner():IsPlayer() then
        self:SetSaveValue("m_fMinRange1", 0)
        self:SetSaveValue("m_fMinRange2", 0)
        self:SetSaveValue("m_fMaxRange1", self.Range)
        self:SetSaveValue("m_fMaxRange2", self.Range)
        print(self.Range)
        self:Deploy()
        local think = "SplatoonSWEPs: NPC Think function" .. self:EntIndex()
        timer.Create(think, 0, 0, function()
            if not (IsValid(self) and IsValid(self:GetOwner()) and not self:GetOwner():IsPlayer()) then
                return timer.Remove(think)
            end

            self:Think()
        end)

        local move = "SplatoonSWEPs: NPC Move function" .. self:EntIndex()
        timer.Create(move, 0, 0, function()
            if not (IsValid(self) and IsValid(self:GetOwner()) and not self:GetOwner():IsPlayer()) then
                return timer.Remove(move)
            end

            ss.ProtectedCall(self.Move, self, self:GetOwner())
        end)

        return
    end

    self:BackupInfo()
end

function SWEP:Deploy()
    if not IsValid(self:GetOwner()) then return true end
    if InvalidPlayer(self:GetOwner()) then
        ss.SendError("LocalPlayerNotReadyToSplat", self:GetOwner())
        self:Remove()
        return
    end

    self:GetOptions()
    self:SetInkColorProxy(self:GetInkColor():ToVector())
    self:SetInInk(false)
    self:SetOnEnemyInk(false)
    self:BackupInfo()
    self.SafeOwner = self:GetOwner()
    self:GetOwner():SetMaxHealth(self:GetNWInt "BackupInklingMaxHealth") -- NPCs also have inkling's standard health.
    if self:GetOwner():IsPlayer() then
        local PMPath = ss.Playermodel[self:GetNWInt "playermodel"]
        if PMPath then
            if file.Exists(PMPath, "GAME") then
                self.PMTable = {
                    Model = PMPath,
                    Skin = 0,
                    BodyGroups = {},
                    SetOffsets = true,
                    PlayerColor = self:GetInkColorProxy(),
                }
                self:ChangePlayermodel(self.PMTable)
            else
                ss.SendError("WeaponPlayermodelNotFound", self:GetOwner())
            end
        else
            self:GetOwner():SetPlayerColor(self:GetInkColorProxy())
        end

        ss.ProtectedCall(self:GetOwner().SplatColors, self:GetOwner())
    end

    ss.ProtectedCall(self.ServerDeploy, self)
    return self:SharedDeployBase()
end

function SWEP:OnRemove()
    self:RemoveRagdoll()
    self:StopLoopSound()
    self:EndRecording()
    ss.ProtectedCall(self.ServerOnRemove, self)
    if self:GetHolstering() then return end
    self:Holster()
end

function SWEP:OnDrop()
    self:SetOwner(self.SafeOwner)
    self.PMTable = nil
    if self:GetOwner():GetActiveWeapon() == self then
        self:RestoreInfo()
    end

    ss.ProtectedCall(self.ServerHolster, self)
    self:SharedHolsterBase()
    self:CreateRagdoll()
end

function SWEP:OnEntityCopyTableFinish(data)
    table.Empty(data.DT)
    for key, value in pairs(data) do
        if self.RestrictedFieldsToCopy[key] then data[key] = nil end
        if TypeID(value) == TYPE_SOUND then data[key] = nil end
        if TypeID(value) == TYPE_ENTITY then data[key] = nil end
    end
end

function SWEP:Holster()
    if self:GetInFence() then return false end
    if self:GetSuperJumpState() >= 0 then return false end
    if not IsValid(self:GetOwner()) then return true end
    if InvalidPlayer(self:GetOwner()) then return true end
    self.PMTable = nil
    self:RestoreInfo()
    ss.ProtectedCall(self.ServerHolster, self)
    return self:SharedHolsterBase()
end

function SWEP:Think()
    if not IsValid(self:GetOwner()) or self:GetHolstering() then return end
    self:ProcessSchedules()
    self:UpdateInkState()
    self:SharedThinkBase()
    ss.ProtectedCall(self.ServerThink, self)
    if ss.GetOption "candrown" and self:GetOwner():WaterLevel() > 1 then
        local d = DamageInfo()
        d:SetAttacker(game.GetWorld())
        d:SetDamage(self:GetOwner():GetMaxHealth() * 10000)
        d:SetDamageForce(vector_origin)
        d:SetDamagePosition(self:GetOwner():GetPos())
        d:SetDamageType(DMG_DROWN)
        d:SetInflictor(game.GetWorld())
        d:SetMaxDamage(d:GetDamage())
        d:SetReportedPosition(self:GetOwner():GetPos())
        self:GetOwner():TakeDamageInfo(d)
    end

    if not self:GetOwner():IsPlayer() then
        self:SetAimVector(ss.ProtectedCall(self:GetOwner().GetAimVector, self:GetOwner()) or self:GetOwner():GetForward())
        self:SetShootPos(ss.ProtectedCall(self:GetOwner().GetShootPos, self:GetOwner()) or self:GetOwner():WorldSpaceCenter())
        if self:GetOwner():IsNPC() then
            local target = self:GetOwner():GetTarget()
            if not IsValid(target) then target = self:GetOwner():GetEnemy() end
            if IsValid(target) then self:SetNPCTarget(target) end
        end

        return
    end

    if self:GetOnEnemyInk() and CurTime() > self.NextEnemyInkDamage then
        local delay = 200 / ss.GetMaxHealth() * ss.FrameToSec
        self.NextEnemyInkDamage = CurTime() + delay
        self.HealSchedule:SetDelay(ss.HealDelay)
        if self:GetOwner():Health() > self:GetOwner():GetMaxHealth() / 2 then
            local d = DamageInfo()
            d:SetAttacker(game.GetWorld())
            d:SetDamage(1)
            d:SetInflictor(self)
            self:GetOwner():TakeDamageInfo(d) -- Enemy ink damage
        end
    end

    local PMPath = ss.Playermodel[self:GetNWInt "playermodel"]
    if PMPath then
        if (not self.PMTable or PMPath ~= self:GetOwner():GetModel()) and file.Exists(PMPath, "GAME") then
            self.PMTable = {
                Model = PMPath,
                Skin = 0,
                BodyGroups = {},
                SetOffsets = true,
                PlayerColor = self:GetInkColorProxy(),
            }
            self:ChangePlayermodel(self.PMTable)
        end
    else
        local mdl = self.BackupPlayerInfo.Playermodel
        if mdl.Model ~= self:GetOwner():GetModel() then
            self:ChangePlayermodel(mdl)
        end
    end

    if self:GetOwner():GetPlayerColor() ~= self:GetInkColorProxy() then
        self:GetOwner():SetPlayerColor(self:GetInkColorProxy())
    end
end
