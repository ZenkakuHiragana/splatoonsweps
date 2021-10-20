
-- Shared library

local ss = SplatoonSWEPs
if not ss then return end

-- Each surface should have these fields.
function ss.CreateSurfaceStructure()
	return CLIENT and {} or {
		Angles = {},
		Areas = {},
		Bounds = {},
		DefaultAngles = {},
		Indices = {},
		InkCircles = {},
		Maxs = {},
		Mins = {},
		Normals = {},
		Origins = {},
		Vertices = {},
	}
end

-- Finds AABB-tree nodes/leaves which includes the given AABB.
-- Use as an iterator function:
--   for nodes in SplatoonSWEPs:SearchAABB(AABB) do ... end
-- Arguments:
--   table AABB | {mins = Vector(), maxs = Vector()}
-- Returning:
--   table      | A sequential table.
function ss.SearchAABB(AABB, normal)
	local function recursive(a)
		local t = {}
		if a.SurfIndices then
			for _, i in ipairs(a.SurfIndices) do
				local a = ss.SurfaceArray[i]
				local max_diff = a.Displacement and ss.MAX_COS_DIFF_DISP or ss.MAX_COS_DIFF
				if a.Normal:Dot(normal) > max_diff then
					if ss.CollisionAABB(a.AABB.mins, a.AABB.maxs, AABB.mins, AABB.maxs) then
						t[#t + 1] = a
					end
				end
			end
		else
			local l = ss.AABBTree[a.Children[1]]
			local r = ss.AABBTree[a.Children[2]]
			if l and ss.CollisionAABB(l.AABB.mins, l.AABB.maxs, AABB.mins, AABB.maxs) then
				table.Add(t, recursive(l))
			end

			if r and ss.CollisionAABB(r.AABB.mins, r.AABB.maxs, AABB.mins, AABB.maxs) then
				table.Add(t, recursive(r))
			end
		end

		return t
	end

	return ipairs(recursive(ss.AABBTree[1]))
end

-- The function names of EffectData() don't make sense, renaming.
do local e = EffectData()
	ss.GetEffectSplash = e.GetAngles -- Angle(SplashColRadius, SplashDrawRadius, SplashLength)
	ss.SetEffectSplash = e.SetAngles
	ss.GetEffectColor = e.GetColor
	ss.SetEffectColor = e.SetColor
	ss.GetEffectColRadius = e.GetRadius
	ss.SetEffectColRadius = e.SetRadius
	ss.GetEffectDrawRadius = e.GetMagnitude
	ss.SetEffectDrawRadius = e.SetMagnitude
	ss.GetEffectEntity = e.GetEntity
	ss.SetEffectEntity = e.SetEntity
	ss.GetEffectInitPos = e.GetOrigin
	ss.SetEffectInitPos = e.SetOrigin
	ss.GetEffectInitVel = e.GetStart
	ss.SetEffectInitVel = e.SetStart
	ss.GetEffectSplashInitRate = e.GetNormal
	ss.SetEffectSplashInitRate = e.SetNormal
	ss.GetEffectSplashNum = e.GetSurfaceProp
	ss.SetEffectSplashNum = e.SetSurfaceProp
	ss.GetEffectStraightFrame = e.GetScale
	ss.SetEffectStraightFrame = e.SetScale
	ss.GetEffectFlags = e.GetFlags
	function ss.SetEffectFlags(eff, weapon, flags)
		if isnumber(weapon) and not flags then
			flags, weapon = weapon
		end

		flags = flags or 0
		if IsValid(weapon) then
			local IsLP = CLIENT and weapon:IsCarriedByLocalPlayer()
			flags = flags + (IsLP and 128 or 0)
		end

		eff:SetFlags(flags)
	end

	-- Dispatch an effect properly in a weapon predicted hook.
	-- Arguments:
	--   Player ply        | The owner of the weapon
	--   vararg            | Arguments of util.Effect()
	function ss.UtilEffectPredicted(ply, ...)
		ss.SuppressHostEventsMP(ply)
		util.Effect(...)
		ss.EndSuppressHostEventsMP(ply)
	end
end

include "util.lua"
include "debug.lua"
include "explosion.lua"
include "fixings.lua"
include "text.lua"
include "convars.lua"
include "inkballistic.lua"
include "inkpainting.lua"
include "movement.lua"
include "sounds/common.lua"
include "weapons.lua"
include "weaponregistration.lua"

local path = "splatoonsweps/sub/%s"
for i, filename in ipairs(file.Find("splatoonsweps/sub/*.lua", "LUA")) do
	include(path:format(filename))
end

local CrouchMask = bit.bnot(IN_DUCK)
local WALLCLIMB_KEYS = bit.bor(IN_JUMP, IN_FORWARD, IN_BACK)
function ss.PredictedThinkMoveHook(w, ply, mv)
	ss.ProtectedCall(w.Move, w, ply, mv)

	local crouching = ply:Crouching()
	if w:CheckCanStandup() and w:GetKey() ~= 0 and w:GetKey() ~= IN_DUCK
	or CurTime() > w:GetEnemyInkTouchTime() + ss.EnemyInkCrouchEndurance and ply:KeyDown(IN_DUCK)
	or CurTime() < w:GetCooldown() then
		mv:SetButtons(bit.band(mv:GetButtons(), CrouchMask))
		crouching = false
	end

	local maxspeed = math.min(mv:GetMaxSpeed(), w.InklingSpeed * 1.1)
	if ply:OnGround() then -- Max speed clip
		maxspeed = ss.ProtectedCall(w.CustomMoveSpeed, w) or w.InklingSpeed
		maxspeed = maxspeed * Either(crouching, ss.SquidSpeedOutofInk, 1)
		maxspeed = w:GetInInk() and w.SquidSpeed or maxspeed
		maxspeed = w:GetOnEnemyInk() and w.OnEnemyInkSpeed or maxspeed
		maxspeed = maxspeed * (w:GetThrowing() and ss.InklingSpeedMulSubWeapon or 1)
		maxspeed = maxspeed * (w:GetIsDisrupted() and ss.DisruptedSpeed or 1)
		ply:SetWalkSpeed(maxspeed)
		if w:GetNWBool "allowsprint" and not (crouching or w:GetInInk() or w:GetOnEnemyInk()) then
			maxspeed = Lerp(0.5, maxspeed, w.SquidSpeed) -- Sprint speed
		end
		
		mv:SetMaxSpeed(maxspeed)
		ply:SetRunSpeed(maxspeed)
	end

	if ss.PlayerShouldResetCamera[ply] then
		local a = ply:GetAimVector():Angle()
		a.p = math.NormalizeAngle(a.p) / 2
		ply:SetEyeAngles(a)
		ss.PlayerShouldResetCamera[ply] = math.abs(a.p) > 1
	end

	local jumppower = w.JumpPower
	jumppower = jumppower * (w:GetOnEnemyInk() and ss.JumpPowerMulOnEnemyInk or 1)
	jumppower = jumppower * (w:GetIsDisrupted() and ss.JumpPowerMulDisrupted or 1)
	ply:SetJumpPower(jumppower)
	if CLIENT then w:UpdateInkState() end -- Ink state prediction

	for v, i in pairs {
		[mv:GetVelocity()] = true, -- Current velocity
		[ss.MoveEmulation.m_vecVelocity[ply] or false] = false,
	} do
		if v then
			local speed, vz = v:Length2D(), v.z -- Horizontal speed, Z component
			if w:GetInWallInk() and mv:KeyDown(WALLCLIMB_KEYS) then -- Wall climbing
				local sp = ply:GetShootPos()
				local t = {
					start = sp, endpos = sp + ply:GetForward() * 32768,
					mask = ss.SquidSolidMask,
					collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
					filter = ply,
				}
				local fw = util.TraceLine(t)
				t.endpos = sp - ply:GetForward() * 32768
				local bk = util.TraceLine(t)
				if fw.Fraction < bk.Fraction == mv:KeyDown(IN_FORWARD) then
					vz = math.max(math.abs(vz) * -.75,
					vz + math.min(12 + (mv:KeyPressed(IN_JUMP) and maxspeed / 4 or 0), maxspeed))
					if ply:OnGround() then
						t.endpos = sp + ply:GetRight() * 32768
						local r = util.TraceLine(t)
						t.endpos = sp - ply:GetRight() * 32768
						local l = util.TraceLine(t)
						if math.min(fw.Fraction, bk.Fraction) < math.min(r.Fraction, l.Fraction) then
							mv:AddKey(IN_JUMP)
						end
					end
				end

				t.start = mv:GetOrigin()
				t.endpos = t.start + vector_up * ss.WALLCLIMB_STEP_CHECK_LENGTH
				t.mins, t.maxs = ply:GetCollisionBounds()
				local tr = util.TraceHull(t)
				if tr.HitWorld then
					t.start = t.endpos + w:GetWallNormal() * ss.MAX_WALLCLIMB_STEP
					tr = util.TraceHull(t)
					if not tr.StartSolid and math.abs(tr.HitNormal.z) < ss.MAX_COS_DIFF then
						mv:SetOrigin(tr.HitPos)
					end
				end
			end

			if not (crouching and ply:OnGround()) and speed > maxspeed then -- Limits horizontal speed
				v:Mul(maxspeed / speed)
				speed = math.min(speed, maxspeed)
			end

			v.z = w.OnOutofInk and not w:GetInWallInk()
			and math.min(vz, ply:GetJumpPower() * .7) or vz
			if i then mv:SetVelocity(v) end
		end
	end

	-- Send viewmodel animation.
	if crouching then
		w.LoopSounds.SwimSound.SoundPatch:ChangeVolume(math.Clamp(mv:GetVelocity():Length() / w.SquidSpeed * (w:GetInInk() and 1 or 0), 0, 1))
		if not w:GetOldCrouching() then
			w:SetWeaponAnim(ss.ViewModel.Squid)
			if w:GetNWInt "playermodel" ~= ss.PLAYER.NOCHANGE then
				ply:RemoveAllDecals()
			end

			if IsFirstTimePredicted() then
				ss.EmitSoundPredicted(ply, w, "SplatoonSWEPs_Player.ToSquid")
			end
		end
	elseif w:GetOldCrouching() then
		w.LoopSounds.SwimSound.SoundPatch:ChangeVolume(0)
		w:SetWeaponAnim(w:GetThrowing() and ss.ViewModel.Throwing or ss.ViewModel.Standing)
		if IsFirstTimePredicted() then
			ss.EmitSoundPredicted(ply, w, "SplatoonSWEPs_Player.ToHuman")
		end
	end

	w.OnOutofInk = w:GetInWallInk()
	w:SetOldCrouching(crouching or infence)
end

-- Short for Entity:NetworkVar().
-- A new function Entity:AddNetworkVar() is created to the given entity.
-- Argument:
--   Entity ent	| The entity to add to.
function ss.AddNetworkVar(ent)
	if ent.NetworkSlot then return end
	function ent:InitNetworkSlots()
		self.NetworkSlot = {
			String = -1, Bool = -1, Float = -1, Int = -1,
			Vector = -1, Angle = -1, Entity = -1,
		}
	end
	ent:InitNetworkSlots()

	-- Returns how many network slots the entity uses.
	-- Argument:
	--   string typeof	| The type to inspect.
	-- Returning:
	--   number			| The number of slots the entity uses.
	function ent:GetLastSlot(typeof) return self.NetworkSlot[typeof] end

	-- Adds a new network variable to the entity.
	-- Arguments:
	--   string typeof	| The variable type.  Same as Entity:NetworkVar().
	--   string name	| The variable name.
	-- Returning:
	--   number			| A new assigned slot.
	function ent:AddNetworkVar(typeof, name)
		assert(self.NetworkSlot[typeof] < 31, "SplatoonSWEPs: Tried to use too many network variables!")
		self.NetworkSlot[typeof] = self.NetworkSlot[typeof] + 1
		self:NetworkVar(typeof, self.NetworkSlot[typeof], name)
		return self.NetworkSlot[typeof]
	end
end

-- Lets the given entity use CurTime() based timer library.
-- Call it in the header, and put SplatoonSWEPs:ProcessSchedules() in ENT:Think().
-- Argument:
--   Entity ent	| The entity to be able to use timer library.
function ss.AddTimerFramework(ent)
	if ent.FunctionQueue then return end

	ss.AddNetworkVar(ent) -- Required to use Entity:AddNetworkSchedule()
	ent.FunctionQueue = {}

	-- Sets how many this schedule has done.
	-- Argument:
	--   number done | The new counter.
	local ScheduleFunc = {}
	local ScheduleMeta = {__index = ScheduleFunc}
	function ScheduleFunc:SetDone(done)
		if isstring(self.done) then
			self.weapon["Set" .. self.done](self.weapon, done)
		else
			self.done = done
		end
	end

	-- Returns the current counter value.
	function ScheduleFunc:GetDone()
		return isstring(self.done) and self.weapon["Get" .. self.done](self.weapon) or self.done
	end

	-- Resets the interval of the schedule.
	-- Argument:
	--   number newdelay	| The new interval.
	function ScheduleFunc:SetDelay(newdelay)
		if isstring(self.delay) then
			self.weapon["Set" .. self.delay](self.weapon, newdelay)
		else
			self.delay = newdelay
		end

		if isstring(self.prevtime) then
			self.weapon["Set" .. self.prevtime](self.weapon, CurTime())
		else
			self.prevtime = CurTime()
		end

		if isstring(self.time) then
			self.weapon["Set" .. self.time](self.weapon, CurTime() + newdelay)
		else
			self.time = CurTime() + newdelay
		end
	end

	-- Returns the current interval of the schedule.
	function ScheduleFunc:GetDelay()
		return isstring(self.delay) and self.weapon["Get" .. self.delay](self.weapon) or self.delay
	end

	-- Sets a time for SinceLastCalled()
	-- Argument:
	--   number newtime	| Relative to CurTime()
	function ScheduleFunc:SetLastCalled(newtime)
		if isstring(self.prevtime) then
			self.weapon["Set" .. self.prevtime](self.weapon, CurTime() - newtime)
		else
			self.prevtime = CurTime() - newtime
		end
	end

	-- Returns the time since the schedule has been last called.
	function ScheduleFunc:SinceLastCalled()
		if isstring(self.prevtime) then
			return CurTime() - self.weapon["Get" .. self.prevtime](self.weapon)
		else
			return CurTime() - self.prevtime
		end
	end

	-- Adds an syncronized schedule.
	-- Arguments:
	--   number delay	| How long the function should be ran in seconds.
	--   				| Use 0 to have the function run every time ENT:Think() called.
	--   function func	| The function to run after the specified delay.
	-- Returning:
	--   table			| The created schedule object.
	function ent:AddNetworkSchedule(delay, func)
		local schedule = setmetatable({
			func = func,
			weapon = self,
		}, ScheduleMeta)
		schedule.delay = "TimerDelay" .. tostring(self:GetLastSlot "Float")
		self:AddNetworkVar("Float", schedule.delay)
		self["Set" .. schedule.delay](self, delay)
		schedule.prevtime = "TimerPrevious" .. tostring(self:GetLastSlot "Float")
		self:AddNetworkVar("Float", schedule.prevtime)
		self["Set" .. schedule.prevtime](self, CurTime())
		schedule.time = "Timer" .. tostring(self:GetLastSlot "Float")
		self:AddNetworkVar("Float", schedule.time)
		self["Set" .. schedule.time](self, CurTime())
		schedule.done = "Done" .. tostring(self:GetLastSlot "Int")
		self:AddNetworkVar("Int", schedule.done)
		self["Set" .. schedule.done](self, 0)
		self.FunctionQueue[#self.FunctionQueue + 1] = schedule
		return schedule
	end

	-- Adds an schedule.
	-- Arguments:
	--   number delay	| How long the function should be ran in seconds.
	--   				| Use 0 to have the function run every time ENT:Think() called.
	--   number numcall	| The number of times to repeat.  Set to nil or 0 for infinite schedule.
	--   function func	| The function to run.  Returning true in it to have the schedule stop.
	-- Returning:
	--   table			| The created schedule object.
	function ent:AddSchedule(delay, numcall, func)
		local schedule = setmetatable({
			delay = delay,
			done = 0,
			func = func or numcall,
			numcall = func and numcall or 0,
			time = CurTime() + delay,
			prevtime = CurTime(),
			weapon = self,
		}, ScheduleMeta)
		self.FunctionQueue[#self.FunctionQueue + 1] = schedule
		return schedule
	end

	-- Makes the registered functions run.  Put it in ENT:Think() for desired use.
	function ent:ProcessSchedules()
		for i, s in pairs(self.FunctionQueue) do
			if isstring(s.time) then
				local get = self["Get" .. s.time]
				if not (isfunction(s.func) and isfunction(get) and isnumber(get(self))) then
					self.FunctionQueue[i] = nil
				elseif CurTime() > get(self) then
					local remove = s.func(self, s)
					self["Set" .. s.prevtime](self, CurTime())
					self["Set" .. s.time](self, CurTime() + self["Get" .. s.delay](self))
					self["Set" .. s.done](self, self["Get" .. s.done](self) + 1)
					if remove then self["Set" .. s.done](self, 2^16 - 1) end
				end
			elseif CurTime() > s.time then
				local remove = not isfunction(s.func) or s.func(self, s)
				s.prevtime = CurTime()
				s.time = CurTime() + s.delay
				if s.numcall > 0 then
					s.done = s.done + 1
					remove = remove or s.done >= s.numcall
				end

				if remove then self.FunctionQueue[i] = nil end
			end
		end
	end
end

-- ss.GetMaxHealth() - Get inkling's desired maximum health
-- ss.GetMaxInkAmount() - Get the maximum amount of an ink tank.
local gain = ss.GetOption "gain"
function ss.GetMaxHealth() return gain "maxhealth" end
function ss.GetMaxInkAmount() return gain "inkamount" end

function ss.GetBotOption(pt)
	return (pt.cl or pt.sv):GetDefault()
end

-- Play footstep sound of ink.
function ss.PlayerFootstep(w, ply, pos, foot, soundName, volume, filter)
	if SERVER and ss.mp then return end
	if ply:Crouching() and w:GetNWBool "becomesquid" and w:GetGroundColor() < 0
	or not ply:Crouching() and w:GetGroundColor() >= 0 then
		ply:EmitSound "SplatoonSWEPs_Player.InkFootstep"
		return true
	end

	if not ply:Crouching() then return end
	return soundName:find "chainlink" and true or nil
end

function ss.UpdateAnimation(w, ply, velocity, maxseqspeed)
	ss.ProtectedCall(w.UpdateAnimation, w, ply, velocity, maxseqspeed)

	if not w:GetThrowing() then return end

	ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, 1)

	local f = (CurTime() - w:GetThrowAnimTime()) / ss.SubWeaponThrowTime
	if CLIENT and w:IsCarriedByLocalPlayer() then
		f = f + LocalPlayer():Ping() / 1000 / ss.SubWeaponThrowTime
	end

	if 0 <= f and f <= 1 then
		ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,
		ply:SelectWeightedSequence(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE),
		f * .55, true)
	end
end

function ss.KeyPress(self, ply, key)
	if ss.KeyMaskFind[key] then
		self:SetKey(key)
		table.RemoveByValue(self.KeyPressedOrder, key)
		self.KeyPressedOrder[#self.KeyPressedOrder + 1] = key
	end
	
	ss.ProtectedCall(self.KeyPress, self, ply, key)
	if CLIENT and key == IN_SPEED then ss.OpenMiniMap() end

	local squid = self:GetNWEntity "Squid"
	if key == IN_JUMP and ply:OnGround() and IsValid(squid)
	and squid:LookupSequence "jump_start" >= 0 then
		squid:SetSequence "jump_start"
	end
end

function ss.KeyRelease(self, ply, key)
	table.RemoveByValue(self.KeyPressedOrder, key)
	if #self.KeyPressedOrder > 0 then
		ss.KeyPress(self, ply, self.KeyPressedOrder[#self.KeyPressedOrder])
	else
		self:SetKey(0)
	end

	ss.ProtectedCall(self.KeyRelease, self, ply, key)
	if not ss.KeyMaskFind[key] then return end
	if CurTime() < self:GetNextSecondaryFire() then return end
	if not (self:GetThrowing() and key == IN_ATTACK2) then return end
	self:AddSchedule(ss.SubWeaponThrowTime, 1, function() self:SetThrowing(false) end)
	if self:Crouching() then return end

	local time = CurTime() + ss.SubWeaponThrowTime
	self:SetCooldown(time)
	self:SetNextPrimaryFire(time)
	self:SetNextSecondaryFire(time)

	local able = self:GetInk() > 0 and self:CheckCanStandup() and self:CanSecondaryAttack()
	if not able then return end
	self:SetThrowAnimTime(CurTime())
	self:SetWeaponAnim(ss.ViewModel.Throw)
	ss.ProtectedCall(self.SharedSecondaryAttack, self, able)
	ss.ProtectedCall(Either(SERVER, self.ServerSecondaryAttack, self.ClientSecondaryAttack), self, able)
end

function ss.OnPlayerHitGround(self, ply, inWater, onFloater, speed)
	if not self:GetInInk() then return end
	if not self:IsFirstTimePredicted() then return end
	local e = EffectData()
	local f = (speed - 100) / 600
	local t = util.QuickTrace(ply:GetPos(), -vector_up * 16384, {self, ply})
	e:SetAngles(t.HitNormal:Angle())
	e:SetAttachment(10)
	e:SetColor(self:GetNWInt "inkcolor")
	e:SetEntity(self)
	e:SetFlags((f > .5 and (64 + 32 + 16) or (32 + 16))
	+ (CLIENT and self:IsCarriedByLocalPlayer() and 128 or 0))
	e:SetOrigin(t.HitPos)
	e:SetRadius(Lerp(f, 25, 50))
	e:SetScale(.5)
	util.Effect("SplatoonSWEPsMuzzleSplash", e, true)
end

hook.Add("PlayerFootstep", "SplatoonSWEPs: Ink footstep", ss.hook "PlayerFootstep")
hook.Add("UpdateAnimation", "SplatoonSWEPs: Adjust TPS animation speed", ss.hook "UpdateAnimation")
hook.Add("KeyPress", "SplatoonSWEPs: Check a valid key", ss.hook "KeyPress")
hook.Add("KeyRelease", "SplatoonSWEPs: Throw sub weapon", ss.hook "KeyRelease")
hook.Add("OnPlayerHitGround", "SplatoonSWEPs: Play diving sound", ss.hook "OnPlayerHitGround")

cvars.AddChangeCallback("gmod_language", function(convar, old, new)
	CompileFile "splatoonsweps/text.lua" ()
end, "SplatoonSWEPs: OnLanguageChanged")

if ss.GetOption "enabled" then
	cleanup.Register(ss.CleanupTypeInk)
end

local nest = nil
for hookname in pairs {CalcMainActivity = true, TranslateActivity = true} do
	hook.Add(hookname, "SplatoonSWEPs: Crouch anim in fence", ss.hook(function(w, ply, ...)
		if nest then nest = nil return end
		if not ply:Crouching() then return end
		if not w:GetInFence() then return end
		nest, ply.m_bWasNoclipping = true
		ply:SetMoveType(MOVETYPE_WALK)
		local res1, res2 = gamemode.Call(hookname, ply, ...)
		ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
		ply:SetMoveType(MOVETYPE_NOCLIP)
		return res1, res2
	end))
end

concommand.Add("-splatoonsweps_reset_camera", function(ply) end, nil, ss.Text.CVars.ResetCamera)
concommand.Add("+splatoonsweps_reset_camera", function(ply)
	ss.PlayerShouldResetCamera[ply] = true
end, nil, ss.Text.CVars.ResetCamera)
