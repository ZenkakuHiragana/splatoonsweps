
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
	if not self.Owner:IsPlayer() then return end
	self.Owner:SetModel(data.Model)
	self.Owner:SetSkin(data.Skin)
	local numgroups = self.Owner:GetNumBodyGroups()
	if isnumber(numgroups) then
		for k = 0, numgroups - 1 do
			local v = data.BodyGroups[k + 1]
			v = istable(v) and isnumber(v.num) and v.num or 0
			self.Owner:SetBodygroup(k, v)
		end
	end

	ss.SetSubMaterial_Workaround(self.Owner)
	self.Owner:SetPlayerColor(data.PlayerColor)
	if self:GetNWInt "playermodel" <= ss.PLAYER.BOY then
		ss.ProtectedCall(self.Owner.SplatColors, self.Owner)
	end

	local hands = self.Owner:GetHands()
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
		local nearest, ply = self:BoundingRadius()^2, NULL
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

function SWEP:GetNPCRestTime()
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
		if IsValid(self.Owner) then return end
		self:CreateRagdoll()
	end)

	ss.ProtectedCall(self.ServerInit, self)
end

function SWEP:BackupInfo()
	self.BackupInklingMaxHealth = ss.GetMaxHealth()
	self.BackupHumanMaxHealth = self.Owner:GetMaxHealth()
	self:SetNWInt("BackupInklingMaxHealth", self.BackupInklingMaxHealth)
	self:SetNWInt("BackupHumanMaxHealth", self.BackupHumanMaxHealth)
	if not self.Owner:IsPlayer() then return end
	self.BackupPlayerInfo = {
		Color = self.Owner:GetColor(),
		Flags = self.Owner:GetFlags(),
		JumpPower = self.Owner:GetJumpPower(),
		Material = self.Owner:GetMaterial(),
		RenderMode = self:GetRenderMode(),
		Speed = {
			Crouched = self.Owner:GetCrouchedWalkSpeed(),
			Duck = self.Owner:GetDuckSpeed(),
			Max = self.Owner:GetMaxSpeed(),
			Run = self.Owner:GetRunSpeed(),
			Walk = self.Owner:GetWalkSpeed(),
			UnDuck = self.Owner:GetUnDuckSpeed(),
		},
		SubMaterial = {},
		Playermodel = {
			Model = self.Owner:GetModel(),
			Skin = self.Owner:GetSkin(),
			BodyGroups = self.Owner:GetBodyGroups(),
			SetOffsets = table.HasValue(SplatoonTable or {}, self.Owner:GetModel()),
			PlayerColor = self.Owner:GetPlayerColor(),
		},
		ViewOffsetDucked = self.Owner:GetViewOffsetDucked()
	}
	self.BackupPlayerInfo.HullMins, self.BackupPlayerInfo.HullMaxs = self.Owner:GetHullDuck()
	for k, v in pairs(self.BackupPlayerInfo.Playermodel.BodyGroups) do
		v.num = self.Owner:GetBodygroup(v.id)
	end

	for i = 0, 31 do
		local submat = self.Owner:GetSubMaterial(i)
		if submat == "" then submat = nil end
		self.BackupPlayerInfo.SubMaterial[i] = submat
	end
end

function SWEP:RestoreInfo()
	self.Owner:SetMaxHealth(self.BackupHumanMaxHealth)
	self.Owner:SetHealth(self.Owner:Health() * self.BackupHumanMaxHealth / self.BackupInklingMaxHealth)

	if not self.Owner:IsPlayer() then return end
	self.Owner:SetDSP(1)
	if istable(self.BackupPlayerInfo) then -- Restores owner's information.
		self:ChangePlayermodel(self.BackupPlayerInfo.Playermodel)
		self.Owner:SetColor(self.BackupPlayerInfo.Color)
	--	self.Owner:RemoveFlags(self.Owner:GetFlags()) -- Restores no target flag and something.
	--	self.Owner:AddFlags(self.BackupPlayerInfo.Flags)
		self.Owner:SetJumpPower(self.BackupPlayerInfo.JumpPower)
		self.Owner:SetRenderMode(self.BackupPlayerInfo.RenderMode)
		self.Owner:SetCrouchedWalkSpeed(self.BackupPlayerInfo.Speed.Crouched)
		self.Owner:SetDuckSpeed(self.BackupPlayerInfo.Speed.Duck)
		self.Owner:SetMaxSpeed(self.BackupPlayerInfo.Speed.Max)
		self.Owner:SetRunSpeed(self.BackupPlayerInfo.Speed.Run)
		self.Owner:SetWalkSpeed(self.BackupPlayerInfo.Speed.Walk)
		self.Owner:SetUnDuckSpeed(self.BackupPlayerInfo.Speed.UnDuck)
		self.Owner:SetHullDuck(self.BackupPlayerInfo.HullMins, self.BackupPlayerInfo.HullMaxs)
		self.Owner:SetViewOffsetDucked(self.BackupPlayerInfo.ViewOffsetDucked)
		self.Owner:SetMaterial(self.BackupPlayerInfo.Material)
		for i = 0, 31 do
			ss.SetSubMaterial_Workaround(self.Owner, i, self.BackupPlayerInfo.SubMaterial[i])
		end
	end
end

function SWEP:Equip(newowner)
	self.Owner = newowner
	if InvalidPlayer(self.Owner) then return end
	self:RemoveRagdoll()
	self:PlayLoopSound()
	self.SafeOwner = self.Owner

	if IsValid(self.Owner) and not self.Owner:IsPlayer() then
		self:SetSaveValue("m_fMinRange1", 0)
		self:SetSaveValue("m_fMinRange2", 0)
		self:SetSaveValue("m_fMaxRange1", self.Range)
		self:SetSaveValue("m_fMaxRange2", self.Range)
		self:Deploy()
		local think = "SplatoonSWEPs: NPC Think function" .. self:EntIndex()
		timer.Create(think, 0, 0, function()
			if not (IsValid(self) and IsValid(self.Owner) and not self.Owner:IsPlayer()) then
				return timer.Remove(think)
			end

			self:Think()
		end)

		local move = "SplatoonSWEPs: NPC Move function" .. self:EntIndex()
		timer.Create(move, 0, 0, function()
			if not (IsValid(self) and IsValid(self.Owner) and not self.Owner:IsPlayer()) then
				return timer.Remove(move)
			end

			ss.ProtectedCall(self.Move, self, self.Owner)
		end)

		return
	end

	self:BackupInfo()
end

function SWEP:Deploy()
	self.Owner = self:GetOwner()
	if not IsValid(self.Owner) then return true end
	if InvalidPlayer(self.Owner) then
		ss.SendError("LocalPlayerNotReadyToSplat", self.Owner)
		self:Remove()
		return
	end

	self:GetOptions()
	self:SetInkColorProxy(self:GetInkColor():ToVector())
	self:SetInInk(false)
	self:SetOnEnemyInk(false)
	self:BackupInfo()
	self.SafeOwner = self.Owner
	self.Owner:SetMaxHealth(self:GetNWInt "BackupInklingMaxHealth") -- NPCs also have inkling's standard health.
	if self.Owner:IsPlayer() then
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
				ss.SendError("WeaponPlayermodelNotFound", self.Owner)
			end
		else
			self.Owner:SetPlayerColor(self:GetInkColorProxy())
		end

		ss.ProtectedCall(self.Owner.SplatColors, self.Owner)
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
	self.Owner = self.SafeOwner
	self.PMTable = nil
	self:RestoreInfo()
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
	if not IsValid(self.Owner) then return true end
	if InvalidPlayer(self.Owner) then return true end
	self.PMTable = nil
	self:RestoreInfo()
	ss.ProtectedCall(self.ServerHolster, self)
	return self:SharedHolsterBase()
end

function SWEP:Think()
	if not IsValid(self.Owner) or self:GetHolstering() then return end
	self:ProcessSchedules()
	self:UpdateInkState()
	self:SharedThinkBase()
	ss.ProtectedCall(self.ServerThink, self)
	if ss.GetOption "candrown" and self.Owner:WaterLevel() > 1 then
		local d = DamageInfo()
		d:SetAttacker(game.GetWorld())
		d:SetDamage(self.Owner:GetMaxHealth() * 10000)
		d:SetDamageForce(vector_origin)
		d:SetDamagePosition(self.Owner:GetPos())
		d:SetDamageType(DMG_DROWN)
		d:SetInflictor(game.GetWorld())
		d:SetMaxDamage(d:GetDamage())
		d:SetReportedPosition(self.Owner:GetPos())
		self.Owner:TakeDamageInfo(d)
	end

	if not self.Owner:IsPlayer() then
		self:SetAimVector(ss.ProtectedCall(self.Owner.GetAimVector, self.Owner) or self.Owner:GetForward())
		self:SetShootPos(ss.ProtectedCall(self.Owner.GetShootPos, self.Owner) or self.Owner:WorldSpaceCenter())
		if self.Owner:IsNPC() then
			local target = self.Owner:GetTarget()
			if not IsValid(target) then target = self.Owner:GetEnemy() end
			if IsValid(target) then self:SetNPCTarget(target) end
		end

		return
	end
	
	if self:GetOnEnemyInk() and CurTime() > self.NextEnemyInkDamage then
		local delay = 200 / ss.GetMaxHealth() * ss.FrameToSec
		self.NextEnemyInkDamage = CurTime() + delay
		self.HealSchedule:SetDelay(ss.HealDelay)
		if self.Owner:Health() > self.Owner:GetMaxHealth() / 2 then
			local d = DamageInfo()
			d:SetAttacker(game.GetWorld())
			d:SetDamage(1)
			d:SetInflictor(self)
			self.Owner:TakeDamageInfo(d) -- Enemy ink damage
		end
	end

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
		end

		if self.PMTable and self.PMTable.Model ~= self.Owner:GetModel() then
			self:ChangePlayermodel(self.PMTable)
		end
	else
		local mdl = self.BackupPlayerInfo.Playermodel
		if mdl.Model ~= self.Owner:GetModel() then
			self:ChangePlayermodel(mdl)
		end
	end

	if self.Owner:GetPlayerColor() ~= self:GetInkColorProxy() then
		self.Owner:SetPlayerColor(self:GetInkColorProxy())
	end
end
