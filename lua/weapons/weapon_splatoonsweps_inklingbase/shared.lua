
include "sh_anim.lua"

local ss = SplatoonSWEPs
if not ss then return end

SWEP.RestrictedFieldsToCopy = {
    FunctionQueue = true,
    NetworkSlot = true,
    Projectile = true,
    HealSchedule = true,
    ReloadSchedule = true,
}
SWEP.LoopSounds = {
    SwimSound = {SoundName = ss.SwimSound},
    EnemyInkSound = {SoundName = ss.EnemyInkSound},
}
ss.AddTimerFramework(SWEP)
function SWEP:PlayLoopSound()
    for _, s in pairs(self.LoopSounds) do
        if not s.SoundPatch then
            s.SoundPatch = CreateSound(self, s.SoundName)
        end

        s.SoundPatch:PlayEx(0, 100)
    end
end

function SWEP:StopLoopSound()
    for _, s in pairs(self.LoopSounds) do
        if not s.SoundPatch then
            s.SoundPatch = CreateSound(self, s.SoundName)
        end

        s.SoundPatch:Stop()
    end
end

function SWEP:StartRecording()
    local o = self:GetOwner()
    if not (o:IsPlayer() and ss.WeaponRecord[o]) then return end
    self:SetNWEntity("Owner", o)
    ss.WeaponRecord[o].Recent[self.ClassName] = -os.time()
end

function SWEP:EndRecording()
    local o = IsValid(self:GetOwner()) and self:GetOwner() or self:GetNWEntity "Owner"
    local r = ss.WeaponRecord[o]
    local c = self.ClassName
    local t = os.time()
    if not (o:IsPlayer() and r) then return end
    r.Duration[c] = (r.Duration[o] or 0) - (t + (r.Recent[c] or -t))
end

function SWEP:IsMine()
    return SERVER or self:IsCarriedByLocalPlayer()
end

function SWEP:IsFirstTimePredicted()
    return SERVER or ss.sp or IsFirstTimePredicted() or not self:IsCarriedByLocalPlayer()
end

function SWEP:GetBase(BaseClassName)
    BaseClassName = BaseClassName or "weapon_splatoonsweps_inklingbase"
    local base = self.BaseClass
    while base and base.Base ~= BaseClassName do
        base = base.BaseClass
    end

    return base
end

-- Speed on humanoid form = base speed * ability factor
function SWEP:GetInklingSpeed()
    return ss.InklingBaseSpeed
end

-- Speed on squid form = base speed * ability factor
function SWEP:GetSquidSpeed()
    return ss.SquidBaseSpeed
end

function SWEP:GetInkColor()
    return ss.GetColor(self:GetNWInt "inkcolor")
end

-- Returns the owner ping in seconds.
-- Returns 0 if the owner is invalid or an NPC.
function SWEP:Ping()
    return IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():Ping() / 1000 or 0
end

function SWEP:Crouching()
    return IsValid(self:GetOwner()) and Either(self:GetOwner():IsPlayer(),
    ss.ProtectedCall(self:GetOwner().Crouching, self:GetOwner()), self:GetOwner():IsFlagSet(FL_DUCKING))
end

function SWEP:GetFOV()
    return self:GetOwner():GetFOV()
end

local function RetrieveOption(self, name, pt)
    if pt.options and (pt.options.serverside or pt.options.clientside) then return end
    if #pt.location > 1 then
        if pt.location[2] ~= self.Base then return end
        if #pt.location > 2 and pt.location[3] ~= self.ClassName then return end
    end

    local value = greatzenkakuman.cvartree.GetValue(pt, self:GetOwner())
    if isbool(value) and self:GetNWBool(name) ~= value then
        self:SetNWBool(name, value)
    end

    if isnumber(value) and self:GetNWInt(name) ~= value then
        if name == "inkcolor" then
            if self:GetOwner():IsNPC() then return end
            if self:GetOwner():IsPlayer() and self:GetOwner():IsBot() then return end
        end

        self:SetNWInt(name, value)
    end
end

function SWEP:GetOptions()
    if ss.mp and CLIENT and not IsFirstTimePredicted() then return end
    if not self:IsMine() then return end
    for name, pt in greatzenkakuman.cvartree.IteratePreferences "splatoonsweps" do
        RetrieveOption(self, name, pt)
    end

    if self:GetOwner():IsPlayer() and not self:GetOwner():IsBot() then return end
    local inkcolor
    if self:GetOwner():IsPlayer() and self:GetOwner():IsBot() then
        inkcolor = ss.GetBotInkColor(self)
    else
        inkcolor = ss.GetNPCInkColor(self:GetOwner())
    end

    if self:GetNWInt "inkcolor" == inkcolor then return end
    self:SetNWInt("inkcolor", inkcolor)
end

function SWEP:ApplySkinAndBodygroups()
    self:SetSkin(self.Skin or 0)
    for k, v in pairs(self.Bodygroup or {}) do
        self:SetBodygroup(k, v)
    end

    if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then return end
    for i = 0, 2 do
        local vm = self:GetOwner():GetViewModel(i)
        if IsValid(vm) then
            vm:SetSkin(self.Skin or 0)
            for k, v in pairs(self.Bodygroup or {}) do
                vm:SetBodygroup(k, v)
            end
        end
    end
end

local InkTraceLength = 30
local InkTraceDepth = 20
function SWEP:UpdateInkState() -- Set if player is in ink
    local ang = Angle(0, self:GetOwner():GetAngles().yaw)
    local c = self:GetNWInt "inkcolor"
    local org = self:GetOwner():GetPos()
    local fw, right = ang:Forward() * InkTraceLength, ang:Right() * InkTraceLength
    local gtrace = util.QuickTrace(org, -vector_up * InkTraceDepth, self:GetOwner())
    local gcolor = gtrace.Hit and ss.GetSurfaceColor(gtrace.HitPos, gtrace.HitNormal) or -1
    local onink = gcolor >= 0
    local onourink = gcolor == c
    local onenemyink = onink and not onourink

    local center = self:GetOwner():WorldSpaceCenter()
    local normal, onwallink = Vector(), false
    for _, p in ipairs { fw + right, fw - right, -fw + right, -fw - right } do
        local tr = util.QuickTrace(center, p, self:GetOwner())
        if not tr.Hit or tr.HitNormal.z > ss.MAX_COS_DIFF then continue end
        if ss.GetSurfaceColor(tr.HitPos, tr.HitNormal) == c then
            normal = tr.HitNormal
            onwallink = true
            break
        end
    end

    local inwallink = self:Crouching() and onwallink
    local inink = self:GetSuperJumpState() < 0 and self:Crouching() and (onink and onourink or self:GetInWallInk())
    if onenemyink and not self:GetOnEnemyInk() then
        self.LoopSounds.EnemyInkSound.SoundPatch:ChangeVolume(1, .5)
    end
    if not onenemyink and self:GetOnEnemyInk() then
        self.LoopSounds.EnemyInkSound.SoundPatch:ChangeVolume(0, .5)
    end
    if inink and not self:GetInInk() then self:GetOwner():SetDSP(14) end
    if not inink and self:GetInInk() then self:GetOwner():SetDSP(1) end
    if self:GetOwner():IsPlayer() and not (self:GetOnEnemyInk() and self:GetOwner():KeyDown(IN_DUCK)) then
        self:SetEnemyInkTouchTime(CurTime())
    end

    self:SetGroundColor(gcolor)
    self:SetInWallInk(inwallink)
    self:SetInInk(inink)
    self:SetOnEnemyInk(onenemyink)
    self:SetWallNormal(normal)

    self:GetOptions()
    if not self:GetInkColor() then return end
    self:SetInkColorProxy(self:GetInkColor():ToVector())
end

function SWEP:GetHandPos()
    if not self:GetOwner():IsPlayer() then return self:GetShootPos() end

    local e = (SERVER or self:IsTPS()) and self:GetOwner() or self:GetViewModel()
    local boneid = e:LookupBone "ValveBiped.Bip01_R_Hand"
    or e:LookupBone "ValveBiped.Weapon_bone" or 0
    return e:GetBoneMatrix(boneid):GetTranslation()
end

function SWEP:GetViewModel(index)
    if not (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then return end
    return self:GetOwner():GetViewModel(index)
end

function SWEP:SetWeaponAnim(act, index)
    if not index then self:SendWeaponAnim(act) end
    if index == 0 then self:SendWeaponAnim(act) return end
    if not self:IsFirstTimePredicted() then return end
    if not (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then return end
    for i = 1, 2 do
        if not (index and i ~= index) then
            -- Entity:GetSequenceCount() returns nil on an invalid viewmodel
            local vm = self:GetOwner():GetViewModel(i)
            if IsValid(vm) and (vm:GetSequenceCount() or 0) > 0 then
                local seq = vm:SelectWeightedSequence(act)
                if seq > -1 then
                    vm:SendViewModelMatchingSequence(seq)
                    vm:SetPlaybackRate(rate or 1)
                end
            end
        end
    end
end

function SWEP:ConsumeInk(amount)
    if not isnumber(amount) then return end
    if self:GetIsDisrupted() then amount = amount * 2 end
    self:SetInk(math.max(self:GetInk() - amount, 0))
end

function SWEP:SharedInitBase()
    self:SetCooldown(CurTime())
    self:ApplySkinAndBodygroups()
    self.KeyPressedOrder = {} -- Pressed keys are added here, most recent key will go last

    local translate = {}
    for _, t in ipairs {
        "ar2",
        "crossbow",
        "grenade",
        "melee",
        "melee2",
        "passive",
        "revolver",
        "rpg",
        "shotgun",
        "smg",
    } do
        self:SetWeaponHoldType(t)
        translate[t] = self.ActivityTranslate
    end

    if ss.sp then self.Buttons, self.OldButtons = 0, 0 end
    if ss[self.Sub] then table.Merge(self, ss[self.Sub].Merge) end

    self.Translate = translate
    self.Projectile = ss.MakeProjectileStructure()
    self.Projectile.Weapon = self
    ss.ProtectedCall(self.SharedInit, self)
end

-- Predicted hooks
function SWEP:SharedDeployBase()
    self:PlayLoopSound()
    self:SetHolstering(false)
    self:SetThrowing(false)
    self:SetCooldown(CurTime())
    self:StartRecording()
    self:SetKey(0)
    self:SetSuperJumpState(-1)
    self:MakeSquidModel()
    self.KeyPressedOrder = {}
    self.InklingSpeed = self:GetInklingSpeed()
    self.SquidSpeed = self:GetSquidSpeed()
    self.OnEnemyInkSpeed = ss.OnEnemyInkSpeed
    self.JumpPower = ss.InklingJumpPower
    self.IgnorePrediction = SERVER and ss.mp and not self:GetOwner():IsPlayer() or nil
    self:GetOwner():SetHealth(self:GetOwner():Health() * self:GetNWInt "BackupInklingMaxHealth" / self:GetNWInt "BackupHumanMaxHealth")
    if self:GetOwner():IsPlayer() then
        self:GetOwner():SetJumpPower(self.JumpPower)
        self:GetOwner():SetCrouchedWalkSpeed(.5)
        for _, k in ipairs(ss.KeyMask) do
            if self:GetOwner():KeyDown(k) then
                ss.KeyPress(self, self,Owner, k)
            end
        end
    end

    ss.ProtectedCall(self.SharedDeploy, self)
    return true
end

function SWEP:SharedHolsterBase()
    self:SetHolstering(true)
    ss.ProtectedCall(self.SharedHolster, self)
    self:StopLoopSound()
    self:EndRecording()
    return true
end

function SWEP:DisplayAmmo()
    return ss.GetMaxInkAmount()
end

function SWEP:SharedThinkBase()
    local vm = self:GetViewModel()
    if IsValid(vm) and vm:IsSequenceFinished()
    and vm:GetSequenceActivity(vm:GetSequence()) == ACT_VM_DRAW then
        self:SetWeaponAnim(ACT_VM_IDLE)
    end

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:SetClip1(math.Round(self:GetInk()))
        self:GetOwner():SetAmmo(self:DisplayAmmo(), self:GetPrimaryAmmoType())
    end

    local ShouldNoDraw = Either(self:GetNWBool "becomesquid", self:Crouching(), self:GetInInk())
    self:GetOwner():DrawShadow(not ShouldNoDraw)
    self:DrawShadow(not ShouldNoDraw)
    self:ApplySkinAndBodygroups()
    ss.ProtectedCall(self.SharedThink, self)
end

-- Begin to use special weapon.
function SWEP:Reload()
    if self:GetHolstering() then return end
end

function SWEP:CheckCanStandup()
    if not IsValid(self:GetOwner()) then return end
    if not self:GetOwner():IsPlayer() then return true end
    if self:GetSuperJumpState() == 0 then return false end
    if self:GetSuperJumpState() == 1 then return false end
    if self:GetSuperJumpState() == 2 then return false end
    local plmins, plmaxs = self:GetOwner():GetHull()
    return not (self:Crouching() and util.TraceHull {
        start = self:GetOwner():GetPos(),
        endpos = self:GetOwner():GetPos(),
        mins = plmins, maxs = plmaxs,
        filter = {self, self:GetOwner()},
        mask = MASK_PLAYERSOLID,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    } .Hit)
end

function SWEP:SetReloadDelay(delay)
    local reloadtime = delay / ss.GetTimeScale(self:GetOwner())
    if self.ReloadSchedule:SinceLastCalled() < -reloadtime then return end
    self.ReloadSchedule:SetDelay(reloadtime) -- Stop reloading ink
    self.ReloadSchedule:SetLastCalled(-reloadtime)
end

function SWEP:PrimaryAttack(auto) -- Shoot ink.  bool auto | is a scheduled shot
    if self:GetHolstering() then return end
    if self:GetThrowing() then return end
    if CurTime() < self:GetNextPrimaryFire() then return end
    if not self:CheckCanStandup() then return end
    if auto and ss.sp and CLIENT then return end
    if not auto and CurTime() < self:GetCooldown() then return end
    if not auto and self:GetOwner():IsPlayer() and self:GetKey() ~= IN_ATTACK then return end
    local able = self:GetInk() > 0 and self:CheckCanStandup()
    ss.SuppressHostEventsMP(self:GetOwner())
    ss.ProtectedCall(self.SharedPrimaryAttack, self, able, auto)
    ss.ProtectedCall(Either(SERVER, self.ServerPrimaryAttack, self.ClientPrimaryAttack), self, able, auto)
    ss.EndSuppressHostEventsMP(self:GetOwner())
end

function SWEP:SecondaryAttack() -- Use sub weapon
    if self:GetHolstering() then return end
    if self:GetKey() ~= IN_ATTACK2 then self:SetThrowing(false) return end
    if self:GetThrowing() then return end
    if self:GetSuperJumpState() >= 0 then return end
    if CurTime() < self:GetCooldown() then return end
    if not self:CheckCanStandup() then return end
    if self:GetOwner():IsPlayer() then
        self:SetThrowing(true)
        self:SetWeaponAnim(ss.ViewModel.Throwing)

        if self.IsSubWeaponThrowable then
            local filter = self.IgnorePrediction
            if SERVER and ss.mp and self:GetOwner():IsPlayer() then
                filter = RecipientFilter()
                filter:AddPlayer(self:GetOwner())
            end

            local e = EffectData()
            e:SetEntity(self)
            e:SetScale(1.5)
            ss.UtilEffectPredicted(self:GetOwner(), "SplatoonSWEPsLandingPoint", e, true, filter)
        end

        if not self:IsFirstTimePredicted() then return end
        if self.HoldType ~= "grenade" then
            self:GetOwner():AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
        end
    else
        local able = self:GetInk() > 0 and self:CheckCanStandup() and self:CanSecondaryAttack()
        ss.ProtectedCall(self.SharedSecondaryAttack, self, able)
        ss.ProtectedCall(self.ServerSecondaryAttack, self, able)
    end
end
-- End of predicted hooks

-- Set up by NetworkVarNotify.  Called when SetThrowing() is executed.
function SWEP:ChangeThrowing(name, old, new)
    if old == new then return end
    if self:GetHolstering() then return end
    local start, stop = not old and new, old and not new

    -- Changes the world model on serverside and local player
    self.WorldModel = self.ModelPath .. (start and "w_left.mdl" or "w_right.mdl")
    if stop then self:SetWeaponAnim(ss.ViewModel.Standing) end
    if CLIENT then return end
    net.Start "SplatoonSWEPs: Change throwing"
    net.WriteEntity(self)
    net.WriteBool(start)
    net.Send(ss.PlayersReady) -- Properly changes it on other clients
end

function SWEP:OnRestore()
    self:PlayLoopSound()
    self.NextEnemyInkDamage = CurTime()
    if ss[self.Sub] then table.Merge(self, ss[self.Sub].Merge) end
end

function SWEP:SetupDataTables()
    local gain = ss.GetOption "gain"
    self:InitNetworkSlots()
    self:AddNetworkVar("Bool", "InInk") -- If owner is in ink.
    self:AddNetworkVar("Bool", "InFence") -- If owner is in fence.
    self:AddNetworkVar("Bool", "InWallInk") -- If owner is on wall.
    self:AddNetworkVar("Bool", "IsDisrupted") -- If owner is getting Disruptor mist.
    self:AddNetworkVar("Bool", "OldCrouching") -- If owner was crouching a tick ago.
    self:AddNetworkVar("Bool", "OnEnemyInk") -- If owner is on enemy ink.
    self:AddNetworkVar("Bool", "Holstering") -- The weapon is being holstered.
    self:AddNetworkVar("Bool", "Throwing") -- Is about to use sub weapon.
    self:AddNetworkVar("Entity", "NPCTarget") -- Target entity for NPC.
    self:AddNetworkVar("Entity", "SuperJumpEntity") -- Target entity to perform super jump onto.
    self:AddNetworkVar("Float", "Cooldown") -- Cannot crouch, fire, or use sub weapon.
    self:AddNetworkVar("Float", "EnemyInkTouchTime") -- Delay timer to force to stand up.
    self:AddNetworkVar("Float", "DisruptorEndTime") -- The time when Disruptor is worn off
    self:AddNetworkVar("Float", "Ink") -- Ink remainig. 0 to ss.GetMaxInkAmount()
    self:AddNetworkVar("Float", "OldSpeed") -- Old Z-velocity of the player.
    self:AddNetworkVar("Float", "SuperJumpStartTime")
    self:AddNetworkVar("Float", "ThrowAnimTime") -- Time to adjust throw anim. speed.
    self:AddNetworkVar("Int", "GroundColor") -- Surface ink color.
    self:AddNetworkVar("Int", "Key") -- A valid key input.
    self:AddNetworkVar("Int", "SuperJumpState") -- Super jump animation progress (< 0 for normal state)
    self:AddNetworkVar("Vector", "InkColorProxy") -- For material proxy.
    self:AddNetworkVar("Vector", "AimVector") -- NPC:GetAimVector() doesn't exist in clientside.
    self:AddNetworkVar("Vector", "ShootPos") -- NPC:GetShootPos() doesn't, either.
    self:AddNetworkVar("Vector", "SuperJumpFrom") -- The location where player starts super jump.
    self:AddNetworkVar("Vector", "SuperJumpTo") -- Destination of super jump in case of having invalid target entity.
    self:AddNetworkVar("Vector", "WallNormal") -- The normal vector of a wall when climbing.
    local getaimvector = self.GetAimVector
    local getshootpos = self.GetShootPos
    function self:GetAimVector()
        if not IsValid(self:GetOwner()) then return self:GetForward() end
        if self:GetOwner():IsPlayer() then return self:GetOwner():GetAimVector() end
        return getaimvector(self)
    end

    function self:GetShootPos()
        if not IsValid(self:GetOwner()) then return self:GetPos() end
        if self:GetOwner():IsPlayer() then return self:GetOwner():GetShootPos() end
        return getshootpos(self)
    end

    self.HealSchedule = self:AddNetworkSchedule(0, function(_, schedule)
        local healink = self:GetNWBool "canhealink" and self:GetInInk() -- Gradually heals the owner
        local timescale = ss.GetTimeScale(self:GetOwner())
        local delay = 10 / timescale
        if healink then
            delay = delay / 8 / gain "healspeedink"
        else
            delay = delay / gain "healspeedstand"
        end

        if schedule:GetDelay() ~= delay then schedule:SetDelay(delay) end
        if not self:GetOnEnemyInk() and (self:GetNWBool "canhealstand" or healink) then
            local health = math.Clamp(self:GetOwner():Health() + 1, 0, self:GetOwner():GetMaxHealth())
            if self:GetOwner():Health() ~= health then self:GetOwner():SetHealth(health) end
        end
    end)

    self.ReloadSchedule = self:AddNetworkSchedule(0, function(_, schedule)
        local reloadamount = math.max(0, schedule:SinceLastCalled()) -- Recharging ink
        local reloadink = self:GetNWBool "canreloadink" and self:GetInInk()
        local timescale = ss.GetTimeScale(self:GetOwner())
        local mul = ss.GetMaxInkAmount() * timescale
        if reloadink then
            mul = mul / 3 * gain "reloadspeedink" / 100
        else
            mul = mul / 10 * gain "reloadspeedstand" / 100
        end

        if self:GetIsDisrupted() then mul = mul * 0.75 end
        if self:GetNWBool "canreloadstand" or reloadink then
            local ink = math.Clamp(self:GetInk() + reloadamount * mul, 0, ss.GetMaxInkAmount())
            if self:GetInk() ~= ink then self:SetInk(ink) end
        end

        if schedule:GetDelay() == 0 then return end
        schedule:SetDelay(0)
    end)

    ss.ProtectedCall(self.CustomDataTables, self)
    self:NetworkVarNotify("Throwing", self.ChangeThrowing)
    if pac then
        self:NetworkVarNotify("InInk", function(_, name, old, new)
            if tobool(old) == tobool(new) then return end
            pac.TogglePartDrawing(self:GetOwner(),
            not (new or self:GetOldCrouching() and self:GetNWBool "becomesquid"))
        end)
        self:NetworkVarNotify("OldCrouching", function(_, name, old, new)
            if tobool(old) == tobool(new) then return end
            if new and not self:GetNWBool "becomesquid" then return end
            pac.TogglePartDrawing(self:GetOwner(), not tobool(new))
        end)
    end
end
