
local ss = SplatoonSWEPs
if not ss then return end

-- Make splashes for the explosion and spread them around.
local function MakeExplosionSplashes(data, weapon)
    if not weapon then return end

    local rand = "SplatoonSWEPs: Explosion splash"
    local colradius = data.SplashPaintRadius / 4
    local paintradius = data.SplashPaintRadius
    local pitchmin = data.SplashInitPitchLow
    local pitchmax = data.SplashInitPitchHigh
    local speedmin = data.SplashInitVelocityLow
    local speedmax = data.SplashInitVelocityHigh
    local gpr = data.GroundPaintRadius
    local gravity = data.SplashGravity
    local distfar = gpr * 1.5
    local distnear = gpr
    local ratiofar = 3
    local rationear = 1.5
    local radiusfar = paintradius
    local radiusnear = paintradius
    local drawradius = 10

    for i = 1, data.SplashNum do
        local dropdata = ss.MakeProjectileStructure()
        table.Merge(dropdata, {
            AirResist = data.SplashAirResist,
            Color = data.InkColor,
            ColRadiusEntity = colradius,
            ColRadiusWorld = colradius,
            DoDamage = false,
            Gravity = gravity,
            PaintFarDistance = distfar,
            PaintFarRadius = radiusfar,
            PaintFarRatio = ratiofar,
            PaintNearDistance = distnear,
            PaintNearRadius = radiusnear,
            PaintNearRatio = rationear,
            PaintRatioFarDistance = distfar,
            PaintRatioNearDistance = distnear,
            StraightFrame = ss.FrameToSec,
            Type = ss.GetShooterInkType(i),
            Weapon = weapon,
        })

        local ang = Angle(data.SplashInitAng)
        local pitch = util.SharedRandom(rand, pitchmin, pitchmax, CurTime() + i)
        local yaw = util.SharedRandom(rand, -180, 180, CurTime() * 2 + i)
        local speed = util.SharedRandom(rand, speedmin, speedmax, CurTime() * 3 + i)
        local offsetdir = ang:Up()
        ang:RotateAroundAxis(ang:Up(), yaw)
        ang:RotateAroundAxis(ang:Right(), pitch)
        dropdata.InitPos = data.Origin + offsetdir * data.SplashHeightOffset
        dropdata.InitVel = ang:Forward() * speed
        dropdata.Yaw = ang.yaw
        ss.AddInk({}, dropdata)
        ss.CreateDropEffect(dropdata, drawradius)
    end
end

function ss.MakeExplosionStructure()
    return {
        BombEntity = NULL,
        ClassName = "",
        DamageRadius = 0,
        DoDamage = false,
        DoGroundPaint = false,
        EffectFlags = 0,
        EffectName = "SplatoonSWEPsExplosion",
        EffectRadius = 0,
        GroundPaintRadius = 0,
        GroundPaintType = 13,
        GetDamage = function(dist) return 0 end,
        GetTracePaintRadius = function(dist) return 0 end,
        HurtOwner = false,
        IgnorePrediction = nil,
        IsPredicted = nil,
        InkColor = 1,
        Origin = Vector(),
        Owner = NULL,
        ProjectileID = 0,
        ShouldPerformEffect = false,
        SplashNum = 0,
        SplashHeightOffset = 0,
        SplashPaintRadius = 0,
        SplashInitAng = Angle(),
        SplashInitPitchLow = 0,
        SplashInitPitchHigh = 0,
        SplashInitVelocityLow = 0,
        SplashInitVelocityHigh = 0,
        TraceLength = 0,
        TraceYaw = 0,
    }
end

function ss.MakeExplosion(data)
    local origin = data.Origin
    local owner = data.Owner
    local inkcolor = data.InkColor
    local weapon = ss.IsValidInkling(owner)
    if data.DoDamage then -- Find entities within explosion and deal damage
        local d = DamageInfo()
        local damagedealt = false
        local hurtowner = data.HurtOwner
        local projectileID = data.ProjectileID
        local attacker = IsValid(owner) and owner or game.GetWorld()
        local inflictor = IsValid(data.BombEntity) and data.BombEntity
                       or IsValid(weapon) and weapon or game.GetWorld()
        local ShouldPerformEffect = data.ShouldPerformEffect
        local GetDamage = data.GetDamage
        for _, e in ipairs(ents.FindInSphere(origin, data.DamageRadius)) do
            local target_weapon = ss.IsValidInkling(e)
            local shouldhit = IsValid(e) and e:Health() > 0 and ss.LastHitID[e] ~= projectileID
            local isally = ss.IsAlly(target_weapon, inkcolor) or ss.IsAlly(e, inkcolor)
            if not shouldhit then continue end
            if isally and not (hurtowner and e == owner) then continue end
            local dist = Vector()
            local maxs, mins = e:OBBMaxs(), e:OBBMins()
            local center = e:LocalToWorld(e:OBBCenter())
            local size = (maxs - mins) / 2
            for i, dir in pairs {
                x = e:GetForward(), y = e:GetRight(), z = e:GetUp()
            } do
                local segment = dir:Dot(origin - center)
                local sign = segment == 0 and 0 or segment > 0 and 1 or -1
                segment = math.abs(segment)
                if segment > size[i] then
                    dist = dist + sign * (size[i] - segment) * dir
                end
            end

            local t = util.TraceLine {
                start = origin,
                endpos = origin + dist,
                filter = {data.BombEntity, not hurtowner and owner or nil},
                mask = MASK_SHOT,
                collisiongroup = COLLISION_GROUP_NONE,
            }
            if not t.Hit or t.Entity == e then
                if ShouldPerformEffect then
                    ss.CreateHitEffect(inkcolor, damagedealt and 6 or 2, origin + dist, -dist, owner)
                    if CLIENT and e ~= owner then
                        damagedealt = true
                        break
                    end
                end

                ss.LastHitID[e] = projectileID -- Avoid multiple damages at once
                damagedealt = damagedealt or ss.sp or e == owner
                local dmg = GetDamage(dist:Length(), e)
                local dt = bit.bor(DMG_BLAST, DMG_AIRBOAT, DMG_REMOVENORAGDOLL)
                if not e:IsPlayer() then dt = bit.bor(dt, DMG_DISSOLVE) end

                d:SetDamage(dmg)
                d:SetDamageForce((e:WorldSpaceCenter() - origin):GetNormalized() * dmg)
                d:SetDamagePosition(e:WorldSpaceCenter())
                d:SetDamageType(dt)
                d:SetMaxDamage(dmg)
                d:SetReportedPosition(origin)
                d:SetAttacker(attacker)
                d:SetInflictor(inflictor)
                d:ScaleDamage(ss.ToHammerHealth)
                ss.ProtectedCall(e.TakeDamageInfo, e, d)
            end
        end
    end

    if ss.mp and not IsFirstTimePredicted() then return end

    -- Explosion effect
    local IgnorePrediction = data.IgnorePrediction
    local effectflags = data.EffectFlags
    local effectname = data.EffectName
    local e = EffectData()
    e:SetOrigin(origin)
    e:SetColor(inkcolor)
    e:SetFlags(effectflags)
    e:SetRadius(data.EffectRadius)
    if data.IsPredicted then
        ss.UtilEffectPredicted(owner, effectname, e, true, IgnorePrediction)
    else
        util.Effect(effectname, e, true, true)
    end

    -- Trace around and paint
    local GetTracePaintRadius = data.GetTracePaintRadius
    local classname = data.ClassName
    local a = data.SplashInitAng
    local a2, a3 = Angle(a), Angle(a)
    a2:RotateAroundAxis(a:Right(), 45)
    a2:RotateAroundAxis(a:Up(), 45)
    a3:RotateAroundAxis(a:Right(), 45)
    a3:RotateAroundAxis(a:Up(), -45)
    for i, d in ipairs {
        a:Forward(), -a:Forward(), a:Right(), -a:Right(), a:Up(),
        a2:Forward(), a2:Right(), -a2:Right(), a2:Up(),
        a3:Forward(), a3:Right(), -a3:Right(), a3:Up(),
    } do
        local t = util.TraceLine {
            collisiongroup = COLLISION_GROUP_DEBRIS,
            start = origin,
            endpos = origin + d * data.TraceLength,
            filter = owner,
            mask = ss.SquidSolidMaskBrushOnly,
        }

        if t.Hit and not t.StartSolid then
            local dist = (t.HitPos - t.StartPos):Length2D()
            ss.Paint(t.HitPos, t.HitNormal, GetTracePaintRadius(dist),
            inkcolor, data.TraceYaw, ss.GetDropType(i), 1, owner, classname)
        end
    end

    if data.DoGroundPaint then
        local t = util.TraceLine {
            collisiongroup = COLLISION_GROUP_DEBRIS,
            start = origin,
            endpos = origin + -a:Up() * data.GroundPaintRadius / 2,
            filter = owner,
            mask = ss.SquidSolidMaskBrushOnly,
        }

        if t.Hit and not t.StartSolid then
            ss.Paint(t.HitPos, t.HitNormal, data.GroundPaintRadius,
            inkcolor, data.TraceYaw, data.GroundPaintType, 1, owner, classname)
        end
    end

    MakeExplosionSplashes(data, weapon)
end

function ss.MakeBombExplosion(org, normal, ent, color, subweapon)
    local sub = ss[subweapon]
    if not sub then return end
    local params = sub.Parameters
    if not params then return end
    local ang = normal:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)
    sound.Play(sub.BurstSound, org)
    ss.MakeExplosion(table.Merge(ss.MakeExplosionStructure(), {
        BombEntity = ent,
        ClassName = ent.WeaponClassName,
        DamageRadius = params.Burst_Radius_Far,
        DoDamage = true,
        DoGroundPaint = true,
        EffectName = "SplatoonSWEPsExplosion",
        EffectRadius = params.Burst_Radius_Far,
        GetDamage = sub.GetDamage,
        GetTracePaintRadius = function(dist) return params.CrossPaintRadius end,
        GroundPaintRadius = params.Burst_PaintR,
        HurtOwner = ss.GetOption "hurtowner",
        InkColor = color,
        Origin = org,
        Owner = IsValid(ent.Owner) and ent.Owner or ent,
        ProjectileID = CurTime(),
        ShouldPerformEffect = params.PerformHitEffect,
        SplashAirResist = 1 - params.Fly_VelKd,
        SplashGravity = params.Fly_Gravity,
        SplashNum = params.Burst_SplashNum,
        SplashHeightOffset = params.Burst_SplashOfstY,
        SplashPaintRadius = params.Burst_SplashPaintR,
        SplashInitAng = ang,
        SplashInitPitchLow = params.Burst_SplashPitL,
        SplashInitPitchHigh = params.Burst_SplashPitH,
        SplashInitVelocityLow = params.Burst_SplashVelL,
        SplashInitVelocityHigh = params.Burst_SplashVelH,
        TraceLength = params.CrossPaintRayLength,
    }))
end

function ss.MakeDeathExplosion(org, attacker, color)
    sound.Play("SplatoonSWEPs_Player.DeathExplosion", org)
    ss.MakeExplosion(table.Merge(ss.MakeExplosionStructure(), {
        ClassName = ss.IsValidInkling(attacker).ClassName,
        DoGroundPaint = true,
        EffectName = "SplatoonSWEPsExplosion",
        EffectRadius = 300,
        GetTracePaintRadius = function(dist) return 50 end,
        GroundPaintRadius = 150,
        GroundPaintType = 14,
        HurtOwner = false,
        InkColor = color,
        Origin = org,
        Owner = attacker,
        ProjectileID = CurTime(),
        TraceLength = 150,
    }))
end

function ss.MakeBlasterExplosion(ink)
    local data, p = ink.Data, ink.Parameters
    local dmul = ink.BlasterHitWall and p.mShotCollisionHitDamageRate or 1
    local dnear = p.mDamageNear * dmul
    local dmid = p.mDamageMiddle * dmul
    local dfar = p.mDamageFar * dmul
    local rmul = ink.BlasterHitWall and p.mShotCollisionRadiusRate or 1
    local rnear = p.mCollisionRadiusNear * rmul
    local rmid = p.mCollisionRadiusMiddle * rmul
    local rfar = p.mCollisionRadiusFar * rmul
    local IsLP = CLIENT and LocalPlayer() == ink.Owner
    local ex = table.Merge(ss.MakeExplosionStructure(), {
        ClassName = data.Weapon.ClassName,
        DamageRadius = rfar,
        DoDamage = true,
        EffectFlags = (IsLP and 128 or 0) + (ink.BlasterHitWall and 1 or 0),
        EffectName = "SplatoonSWEPsBlasterExplosion",
        EffectRadius = p.mCollisionRadiusFar * rmul,
        GetDamage = function(dist)
            if dist > rmid then
                return math.Remap(dist, rmid, rfar, dmid, dfar)
            elseif dist > rnear then
                return math.Remap(dist, rnear, rmid, dnear, dmid)
            end

            return dnear
        end,
        GetTracePaintRadius = function(dist)
            local frac = dist / p.mBoundPaintMinDistanceXZ
            return Lerp(frac, p.mBoundPaintMaxRadius, p.mBoundPaintMinRadius)
        end,
        HurtOwner = ss.GetOption "hurtowner",
        IgnorePrediction = data.Weapon.IgnorePrediction,
        ShouldPerformEffect = ink.IsCarriedByLocalPlayer,
        IsPredicted = true,
        InkColor = data.Color,
        Origin = ink.Trace.endpos,
        Owner = ink.Owner,
        ProjectileID = data.ID,
        SplashInitAng = data.InitDir:Angle(),
        TraceLength = p.mMoveLength,
        TraceYaw = data.Yaw,
    })

    if ink.BlasterHitWall then
        ex.SplashInitAng:RotateAroundAxis(ex.SplashInitAng:Right(), -90)
    end

    ss.MakeExplosion(ex)
    if not p.mSphereSplashDropOn then return end

    -- Create a blaster's drop
    local dropdata = ss.MakeProjectileStructure()
    table.Merge(dropdata, {
        Color = data.Color,
        ColRadiusEntity = p.mSphereSplashDropCollisionRadius,
        ColRadiusWorld = p.mSphereSplashDropCollisionRadius,
        DoDamage = false,
        Gravity = ss.ToHammerUnitsPerSec2,
        InitPos = ink.Trace.endpos + vector_up * p.mSphereSplashDropCollisionRadius * 2,
        InitVel = vector_up * p.mSphereSplashDropInitSpeed,
        PaintFarDistance = p.mPaintFarDistance,
        PaintFarRadius = p.mSphereSplashDropPaintRadius,
        PaintNearDistance = p.mPaintNearDistance,
        PaintNearRadius = p.mSphereSplashDropPaintRadius,
        Weapon = data.Weapon,
        Yaw = data.Yaw,
    })

    local e = EffectData()
    ss.SetEffectColor(e, dropdata.Color)
    ss.SetEffectColRadius(e, dropdata.ColRadiusWorld)
    ss.SetEffectDrawRadius(e, p.mSphereSplashDropDrawRadius)
    ss.SetEffectEntity(e, dropdata.Weapon)
    ss.SetEffectFlags(e, dropdata.Weapon, 3)
    ss.SetEffectInitPos(e, dropdata.InitPos)
    ss.SetEffectInitVel(e, dropdata.InitVel)
    ss.SetEffectSplash(e, Angle(0, 0, 0))
    ss.SetEffectSplashInitRate(e, Vector(0))
    ss.SetEffectSplashNum(e, 0)
    ss.SetEffectStraightFrame(e, 0)
    ss.UtilEffectPredicted(ink.Owner, "SplatoonSWEPsShooterInk", e, true, data.Weapon.IgnorePrediction)
    ss.AddInk(p, dropdata)
end
