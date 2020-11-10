
local ss = SplatoonSWEPs
if not ss then return end

local MAX_INK_SIM_AT_ONCE = 60 -- Calculating ink trajectory at once
local function DoScatterSplash(ink)
	local data, p = ink.Data, ink.Parameters
	if CurTime() < data.ScatterSplashTime then return end
	if data.ScatterSplashCount >= p.mScatterSplashMaxNum then return end
	local t = ink.Trace.LifeTime
	local tmin = p.mScatterSplashMinSpanBulletCounter
	local tmax = p.mScatterSplashMaxSpanBulletCounter
	local tfrac = math.TimeFraction(tmin, tmax, t)
	local delaymin = p.mScatterSplashMinSpanFrame
	local delaymax = p.mScatterSplashMaxSpanFrame
	local delay = Lerp(tfrac, delaymin, delaymax)
	local dropdata = ss.MakeProjectileStructure()
	data.ScatterSplashTime = CurTime() + delay
	data.ScatterSplashCount = data.ScatterSplashCount + 1
	table.Merge(dropdata, {
		AirResist = 1e-8,
		Color = data.Color,
		ColRadiusEntity = p.mScatterSplashColRadius,
		ColRadiusWorld = p.mScatterSplashColRadius,
		DoDamage = false,
		Gravity = ss.InkDropGravity,
		InitPos = ink.Trace.endpos,
		PaintFarRadius = p.mScatterSplashPaintRadius,
		PaintFarRatio = 1,
		PaintNearRadius = p.mScatterSplashPaintRadius,
		PaintNearRatio = 1,
		StraightFrame = ss.FrameToSec,
		Type = ss.GetDropType(),
		Weapon = data.Weapon,
		Yaw = data.Yaw,
	})

	local rand = "SplatoonSWEPs: Scatter offset"
	local ang = data.InitDir:Angle()
	local offsetdir = ang:Right()
	local offsetmin = p.mScatterSplashInitPosMinOffset
	local offsetmax = p.mScatterSplashInitPosMaxOffset
	local offsetsign = math.Round(util.SharedRandom(rand, 0, 1, CurTime())) * 2 - 1
	local offsetamount = util.SharedRandom(rand, offsetmin, offsetmax, CurTime() * 2)
	local offsetvec = offsetdir * offsetsign * offsetamount
	
	local initspeed = p.mScatterSplashInitSpeed
	local initang = Angle(ang)
	local rotmax = util.SharedRandom(rand, 0, 1, CurTime() * 3) > 0.5
		and -p.mScatterSplashUpDegree or p.mScatterSplashDownDegree
	local bias = p.mScatterSplashDegreeBias
	local selectbias = bias > util.SharedRandom(rand, 0, 1, CurTime() * 4)
	local frac = util.SharedRandom(rand,
		selectbias and bias or 0, selectbias and 1 or bias, CurTime() * 5)
	
	initang:RotateAroundAxis(initang:Forward(), frac * rotmax * offsetsign)
	dropdata.InitPos = dropdata.InitPos + offsetvec
	dropdata.InitVel = initang:Right() * offsetsign * initspeed
	ss.AddInk(p, dropdata)
	
	local e = EffectData()
	ss.SetEffectColor(e, dropdata.Color)
	ss.SetEffectColRadius(e, dropdata.ColRadiusWorld)
	ss.SetEffectDrawRadius(e, p.mScatterSplashColRadius)
	ss.SetEffectEntity(e, dropdata.Weapon)
	ss.SetEffectFlags(e, dropdata.Weapon, 8)
	ss.SetEffectInitPos(e, dropdata.InitPos)
	ss.SetEffectInitVel(e, dropdata.InitVel)
	ss.SetEffectSplash(e, Angle(dropdata.AirResist * 180, dropdata.Gravity / ss.InkDropGravity * 180))
	ss.SetEffectSplashInitRate(e, Vector(0))
	ss.SetEffectSplashNum(e, 0)
	ss.SetEffectStraightFrame(e, dropdata.StraightFrame)
	ss.UtilEffectPredicted(ink.Trace.filter, "SplatoonSWEPsShooterInk", e)
end

local function Simulate(ink)
	if IsFirstTimePredicted() then ss.DoDropSplashes(ink) end
	ink.CurrentSpeed = ink.Trace.start:Distance(ink.Trace.endpos) / FrameTime()
	ss.AdvanceBullet(ink)

	if not IsFirstTimePredicted() then return end
	if ink.Data.ScatterSplashCount then DoScatterSplash(ink) end
	if not ink.Data.Weapon.IsBlaster then return end
	if not ink.Data.DoDamage then return end

	local tr, p = ink.Trace, ink.Parameters
	if tr.LifeTime <= p.mExplosionFrame then return end
	if ink.Exploded then return end
	ink.BlasterRemoval = p.mExplosionSleep
	ink.Exploded = true
	tr.collisiongroup = COLLISION_GROUP_DEBRIS
	ss.MakeBlasterExplosion(ink)
end

local function HitSmoke(ink, t) -- FIXME: Don't emit it twice
	local data, weapon = ink.Data, ink.Data.Weapon
	if weapon.IsBamboozler then return end
	if not t.HitWorld or CurTime() - ink.InitTime > data.StraightFrame then return end
	local e = EffectData()
	e:SetAttachment(0)
	e:SetColor(data.Color)
	e:SetEntity(game.GetWorld())
	e:SetFlags(PATTACH_ABSORIGIN)
	e:SetOrigin(t.HitPos + t.HitNormal * 10)
	e:SetScale(6)
	e:SetStart(data.InitPos)
	util.Effect("SplatoonSWEPsMuzzleMist", e, true, weapon.IgnorePrediction)
end

local function HitPaint(ink, t)
	local data, tr, weapon = ink.Data, ink.Trace, ink.Data.Weapon
	local g_dir = ss.GetGravityDirection()
	local hitfloor = -t.HitNormal:Dot(g_dir) > ss.MAX_COS_DIFF
	local lmin = data.PaintNearDistance
	local lmin_ratio = data.PaintRatioNearDistance
	local lmax = data.PaintFarDistance
	local lmax_ratio = data.PaintRatioFarDistance
	local rmin = data.PaintNearRadius
	local rmax = data.PaintFarRadius
	local ratio_min = data.PaintNearRatio
	local ratio_max = data.PaintFarRatio
	local length = math.Clamp(tr.LengthSum, lmin, lmax)
	local length2d = math.Clamp((t.HitPos - data.InitPos):Length2D(), lmin_ratio, lmax_ratio)
	local radius = math.Remap(length, lmin, lmax, rmin, rmax)
	local ratio = math.Remap(length2d, lmin_ratio, lmax_ratio, ratio_min, ratio_max)
	if length == lmin and lmin == lmax then radius = rmax end -- Avoid NaN
	if length2d == lmin_ratio and lmin_ratio == lmax_ratio then ratio = ratio_max end
	if length2d == lmin_ratio then data.Type = ss.GetDropType() end
	if data.DoDamage then
		if weapon.IsCharger then
			-- HitSmoke(ink, t) -- TODO: Add smoke if the surface is not paintable
			local radiusmul = ink.Parameters.mPaintRateLastSplash
			if not hitfloor then radius = radius * Lerp(data.Charge, radiusmul, 1) end
			if tr.LengthSum < data.Range then
				local cos = math.Clamp(-data.InitDir.z, ss.MAX_COS_DIFF, 1)
				ratio = math.Remap(cos, ss.MAX_COS_DIFF, 1, ratio, 1)
			elseif hitfloor then
				radius = radius * radiusmul
			end
		elseif weapon.IsBlaster then
			data.DoDamage = false
			data.Type = ss.GetDropType()
			if not ink.Exploded then
				ink.BlasterHitWall = true
				tr.endpos:Set(t.HitPos)
				ss.MakeBlasterExplosion(ink)
			end
		end
	end

	if not hitfloor then
		ratio = 1
		data.Type = ss.GetDropType()
	end

	if (ss.sp or CLIENT and IsFirstTimePredicted()) and t.Hit and data.DoDamage then
		sound.Play("SplatoonSWEPs_Ink.HitWorld", t.HitPos)
	end
	
	ss.Paint(t.HitPos, t.HitNormal, radius * ratio, data.Color,
	data.Yaw, data.Type, 1 / ratio, tr.filter, weapon.ClassName)
	
	if not data.DoDamage then return end
	if hitfloor then return end
	
	local n = data.WallPaintMaxNum
	if data.WallPaintUseSplashNum then n = data.SplashNum - data.SplashCount end
	if not t.FractionPaintWall then t.FractionPaintWall = 0 end
	for i = 1, n do
		local pos = t.HitPos + g_dir * data.WallPaintFirstLength
		if i > 1 then pos:Add(g_dir * (i - 1) * data.WallPaintLength) end
		local tn = util.TraceLine {
			collisiongroup = COLLISION_GROUP_INTERACTIVE_DEBRIS,
			endpos = pos - t.HitNormal,
			filter = tr.filter,
			mask = ss.SquidSolidMask,
			start = data.InitPos,
		}

		if math.abs(tn.HitNormal:Dot(g_dir)) < ss.MAX_COS_DIFF
		and t.FractionPaintWall < tn.Fraction
		and not tn.StartSolid and tn.HitWorld then
			ss.PaintSchedule[{
				pos = tn.HitPos,
				normal = tn.HitNormal,
				radius = data.WallPaintRadius,
				color = data.Color,
				angle = data.Yaw,
				inktype = ss.GetDropType(),
				ratio = 1,
				Time = CurTime() + i * data.WallPaintRadius / ink.CurrentSpeed,
				filter = tr.filter,
				ClassName = data.Weapon.ClassName,
			}] = true
		end
	end
end

local function HitEntity(ink, t)
	local data, tr, weapon = ink.Data, ink.Trace, ink.Data.Weapon
	local time = math.max(CurTime() - ink.InitTime, 0)
	local d, e, o = DamageInfo(), t.Entity, tr.filter
	if weapon.IsCharger and time > data.StraightFrame + ss.FrameToSec then return end
	if ss.LastHitID[e] == data.ID then return end
	ss.LastHitID[e] = data.ID -- Avoid multiple damages at once
	
	local decay_start = data.DamageMaxDistance
	local decay_end = data.DamageMinDistance
	local damage_max = data.DamageMax
	local damage_min = data.DamageMin
	local damage = damage_max
	if not weapon.IsCharger then
		local value = tr.LengthSum
		if weapon.IsShooter then
			value = math.max(CurTime() - ink.InitTime, 0)
		elseif weapon.IsSlosher then
			value = tr.endpos.z - data.InitPos.z
		end

		local frac = math.Remap(value, decay_start, decay_end, 0, 1)
		damage = Lerp(frac, damage_max, damage_min)
	end

	if ink.IsCarriedByLocalPlayer then
		local te = util.TraceLine {start = t.HitPos, endpos = e:WorldSpaceCenter()}
		ss.CreateHitEffect(data.Color, data.IsCritical and 1 or 0, te.HitPos, te.HitNormal)
		if ss.mp and CLIENT then return end
	end

	d:SetDamage(damage)
	d:SetDamageForce(-t.HitNormal)
	d:SetDamagePosition(t.HitPos)
	d:SetDamageType(DMG_GENERIC)
	d:SetMaxDamage(damage_max)
	d:SetReportedPosition(t.HitPos)
	d:SetAttacker(IsValid(o) and o or game.GetWorld())
	d:SetInflictor(IsValid(weapon) and weapon or game.GetWorld())
	d:ScaleDamage(ss.ToHammerHealth)
	ss.ProtectedCall(e.TakeDamageInfo, e, d)
end

local function ProcessInkQueue(ply)
	local Benchmark = SysTime()
	while true do
		repeat coroutine.yield() until IsFirstTimePredicted()
		Benchmark = SysTime()
		for inittime, inkgroup in SortedPairs(ss.InkQueue) do
			local k = 1
			for i = 1, #inkgroup do
				local ink = inkgroup[i]
				local removal = not ink
				if ink then
					local data, tr, weapon = ink.Data, ink.Trace, ink.Data.Weapon
					if not removal then
						removal = not IsValid(tr.filter)
						or not IsValid(data.Weapon)
						or not IsValid(data.Weapon.Owner)
						or data.Weapon.Owner:GetActiveWeapon() ~= data.Weapon
					end

					if not removal and (not tr.filter:IsPlayer() or tr.filter == ply) then
						Simulate(ink)
						if tr.start:DistToSqr(tr.endpos) > 0 then
							tr.maxs = ss.vector_one * data.ColRadiusWorld
							tr.mins = -tr.maxs
							tr.mask = ss.SquidSolidMaskBrushOnly
							local trworld = util.TraceHull(tr)
							tr.maxs = ss.vector_one * data.ColRadiusEntity
							tr.mins = -tr.maxs
							tr.mask = ss.SquidSolidMask
							local trent = util.TraceHull(tr)
							if ink.BlasterRemoval or not (trworld.Hit or ss.IsInWorld(trworld.HitPos)) then
								removal = true
							elseif data.DoDamage and IsValid(trent.Entity) and trent.Entity:Health() > 0 then
								local w = ss.IsValidInkling(trent.Entity) -- If ink hits someone
								if not (w and ss.IsAlly(w, data.Color)) then HitEntity(ink, trent) end
								removal = true
							elseif trworld.Hit then
								if trworld.StartSolid and tr.LifeTime < ss.FrameToSec then trworld = util.TraceLine(tr) end
								if trworld.Hit and not (trworld.StartSolid and tr.LifeTime < ss.FrameToSec) then
									tr.endpos = trworld.HitPos - trworld.HitNormal * data.ColRadiusWorld * 2
									HitPaint(ink, util.TraceLine(tr))
									removal = true
								end
							end
						end

						if SysTime() - Benchmark > ss.FrameToSec then
							coroutine.yield()
							Benchmark = SysTime()
						end
					end
				end
				
				if removal then
					inkgroup[i] = nil
				else -- Move i's kept value to k's position, if it's not already there.
					if i ~= k then inkgroup[k], inkgroup[i] = ink end
					k = k + 1 -- Increment position of where we'll place the next kept value.
				end

				if #inkgroup == 0 then ss.InkQueue[inittime] = nil end
			end
		end

		for ink in pairs(ss.PaintSchedule) do
			if CurTime() > ink.Time then
				ss.Paint(ink.pos, ink.normal, ink.radius, ink.color,
				ink.angle, ink.inktype, ink.ratio, ink.filter, ink.ClassName)
				ss.PaintSchedule[ink] = nil

				if SysTime() - Benchmark > ss.FrameToSec then
					coroutine.yield()
					Benchmark = SysTime()
				end
			end
		end
	end
end

function ss.CreateHitEffect(color, flags, pos, normal)
	if ss.mp and (SERVER or not IsFirstTimePredicted()) then return end
	local e = EffectData()
	e:SetColor(color)
	e:SetFlags(flags)
	e:SetOrigin(pos)
	util.Effect("SplatoonSWEPsOnHit", e)
	e:SetAngles(normal:Angle())
	e:SetAttachment(6)
	e:SetEntity(NULL)
	e:SetFlags(129)
	e:SetOrigin(pos)
	e:SetRadius(50)
	e:SetScale(.4)
	util.Effect("SplatoonSWEPsMuzzleSplash", e)
end

function ss.GetDropType(offset) -- math.floor(1 <= x < 4) -> 1, 2, 3
	return math.floor(util.SharedRandom("SplatoonSWEPs: Ink type", 1, 4, CurTime() + (offset or 0)))
end

function ss.GetShooterInkType(offset) -- math.floor(4 <= x < 10) -> 4, 5, 6, 7, 8
	return math.floor(util.SharedRandom("SplatoonSWEPs: Ink type", 4, 9, CurTime() * 2 + (offset or 0)))
end

function ss.CreateDrop(params, pos, color, weapon, colradius, paintradius, paintratio, yaw)
	local dropdata = ss.MakeProjectileStructure()
	table.Merge(dropdata, {
		Color = color,
		ColRadiusEntity = colradius,
		ColRadiusWorld = colradius,
		DoDamage = false,
		Gravity = ss.InkDropGravity,
		InitPos = pos,
		PaintFarRadius = paintradius,
		PaintFarRatio = paintratio or 1,
		PaintNearRadius = paintradius,
		PaintNearRatio = paintratio or 1,
		Range = 0,
		Type = ss.GetDropType(),
		Weapon = weapon,
		Yaw = yaw or 0,
	})

	ss.AddInk(params, dropdata)
end

function ss.DoDropSplashes(ink, iseffect)
	local data, tr, p = ink.Data, ink.Trace, ink.Parameters
	if not data.DoDamage then return end
	if data.SplashCount >= data.SplashNum then return end
	local IsBamboozler = data.Weapon.IsBamboozler
	local IsBlaster = data.Weapon.IsBlaster
	local IsCharger = data.Weapon.IsCharger
	local DropDir = data.InitDir
	local Length = tr.endpos:Distance(data.InitPos)
	local NextLength = (data.SplashCount + data.SplashInitRate) * data.SplashLength
	if not IsCharger then
		Length = (tr.endpos - data.InitPos):Length2D()
		DropDir = Vector(data.InitDir.x, data.InitDir.y, 0):GetNormalized()
	end
	
	while Length >= NextLength and data.SplashCount < data.SplashNum do -- Creates ink drops
		local droppos = data.InitPos + DropDir * NextLength
		if not IsCharger then
			local frac = NextLength / Length
			if frac ~= frac then frac = 0 end -- In case of NaN
			droppos.z = Lerp(frac, data.InitPos.z, tr.endpos.z)
		end

		local hull = {
			collisiongroup = COLLISION_GROUP_INTERACTIVE_DEBRIS,
			start = data.InitPos,
			endpos = droppos,
			filter = tr.filter,
			mask = ss.SquidSolidMask,
			maxs = tr.maxs,
			mins = tr.mins,
		}
		local t = util.TraceHull(hull)
		if iseffect then
			local e = EffectData()
			if IsBlaster then
				e:SetColor(data.Color)
				e:SetNormal(data.InitDir)
				e:SetOrigin(t.HitPos)
				e:SetRadius(p.mCollisionRadiusNear / 2)
				ss.UtilEffectPredicted(tr.filter, "SplatoonSWEPsBlasterTrail", e)
			end
			
			ss.SetEffectColor(e, data.Color)
			ss.SetEffectColRadius(e, data.SplashColRadius)
			ss.SetEffectDrawRadius(e, data.SplashDrawRadius)
			ss.SetEffectEntity(e, data.Weapon)
			ss.SetEffectFlags(e, 1)
			ss.SetEffectInitPos(e, droppos + ss.GetGravityDirection() * data.SplashDrawRadius)
			ss.SetEffectInitVel(e, data.InitVel)
			ss.SetEffectSplash(e, Angle(0, 0, data.SplashLength))
			ss.SetEffectSplashInitRate(e, Vector(0))
			ss.SetEffectSplashNum(e, 0)
			ss.SetEffectStraightFrame(e, 0)
			ss.UtilEffectPredicted(tr.filter, "SplatoonSWEPsShooterInk", e)
		else
			hull.start = droppos
			hull.endpos = droppos + data.InitDir * data.SplashLength
			ss.CreateDrop(p, t.HitPos, data.Color, data.Weapon,
			data.SplashColRadius, data.SplashPaintRadius, data.SplashRatio, data.Yaw)
			if util.TraceHull(hull).Hit then break end
		end

		NextLength = NextLength + data.SplashLength
		data.SplashCount = data.SplashCount + 1
	end
end

-- Make an ink bullet for shooter.
-- Arguments:
--   table parameters	| Table contains weapon parameters
--   table data			| Table contains ink bullet data
function ss.AddInk(parameters, data)
	local w = data.Weapon
	if not IsValid(w) then return {} end
	local ply = w.Owner
	local t = ss.MakeInkQueueStructure()
	t.Data = table.Copy(data)
	t.IsCarriedByLocalPlayer = Either(SERVER, ply:IsPlayer(), ss.ProtectedCall(w.IsCarriedByLocalPlayer, w))
	t.Parameters = parameters
	t.Trace.filter = ply
	t.Trace.endpos:Set(data.InitPos)
	t.Data.InitDir = t.Data.InitVel:GetNormalized()
	t.Data.InitSpeed = t.Data.InitVel:Length()
	t.CurrentSpeed = t.Data.InitSpeed

	local t0 = t.InitTime
	local dest = ss.InkQueue[t0] or {}
	ss.InkQueue[t0], dest[#dest + 1] = dest, t
	return t
end

local processes = {}
hook.Add("Move", "SplatoonSWEPs: Simulate ink", function(ply, mv)
	local p = processes[ply]
	if not p or coroutine.status(p) == "dead" then
		processes[ply] = coroutine.create(ProcessInkQueue)
		p = processes[ply]
		table.Empty(ss.InkQueue)
	end

	ply:LagCompensation(true)
	local ok, msg = coroutine.resume(p, ply)
	ply:LagCompensation(false)

	if ok then return end
	ErrorNoHalt(msg)
end)

-- Physics simulation for ink trajectory.
-- The first some frames(1/60 sec.) ink flies without gravity.
-- After that, ink decelerates horizontally and is affected by gravity.
-- Arguments:
--   Vector InitVel       | Initial velocity in Hammer units/s
--   number StraightFrame | Time to go straight in seconds
--   number AirResist     | Air resistance after it goes straight (0-1)
--   number Gravity       | Gravity acceleration in Hammer units/s^2
--   number t             | Time in seconds
function ss.GetBulletPos(InitVel, StraightFrame, AirResist, Gravity, t)
	local tf = math.max(t - StraightFrame, 0) -- Time for being "free state"
	local tg = tf^2 / 2 -- Time for applying gravity
	local g = ss.GetGravityDirection() * Gravity -- Gravity accelerator
	local tlim = math.min(t, StraightFrame) -- Time limited to go straight
	local f = tf * ss.SecToFrame -- Frames for air resistance
	local ratio = 1 - AirResist
	local resist = (ratio^f - 1) / math.log(ratio) * ss.FrameToSec
	if resist ~= resist then resist = 0 end

	-- Additional pos = integral[ts -> t] InitVel * AirResist^u du (ts < t)
	return InitVel * (tlim + resist) + g * tg
end

function ss.AdvanceBullet(ink)
	local data, tr = ink.Data, ink.Trace
	local t = math.max(CurTime() - ink.InitTime, 0)
	tr.start:Set(tr.endpos)
	tr.endpos:Set(data.InitPos + ss.GetBulletPos(
		data.InitVel, data.StraightFrame, data.AirResist, data.Gravity, t))
	tr.LengthSum = tr.LengthSum + tr.start:Distance(tr.endpos)
	tr.LifeTime = t
end
