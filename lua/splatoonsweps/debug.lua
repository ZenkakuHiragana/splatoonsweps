
-- do return end -- Uncomment this to disable debugging

AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

ss.Debug = {}
require "greatzenkakuman/debug"
local d = greatzenkakuman.debug
local sd = ss.Debug

function d.DLoop() end
if CLIENT then hook.Remove("CreateMove", "Test") end
local ShowInkChecked     = false -- Draws ink boundary.
local ShowInkDrawn       = false -- When ink hits, show ink surface painted by it.
local ShowBlasterRadius  = false -- Shows where blaster explosion will be.
local ChargeQuarter      = false -- Press Shift to fire any charger at 25% charge.
local DrawInkUVMap       = false -- Press Shift to draw ink UV map.
local DrawInkUVBounds    = false -- Also draws UV boundary.
local ShowInkSurface     = false -- Press E for serverside, Shift for clientside, draws ink surface nearby player #1.
local ShowInkStateMesh   = false -- Shows the mesh to determine ink color of surface.
local ShowInkChecked_ServerTime = CurTime()
function sd.ShowInkChecked(r, s)
    if not ShowInkChecked then return end
    local debugv = {Vector(-r.ratio, -1), Vector(r.ratio, -1), Vector(r.ratio, 1), Vector(-r.ratio, 1)}
    for _, v in ipairs(debugv) do v:Rotate(Angle(0, -r.angle)) v:Mul(r.radius) v:Add(r.pos) end
    if CLIENT then d.DTick() end
    if SERVER then
        if CurTime() < ShowInkChecked_ServerTime then return end
        ShowInkChecked_ServerTime = CurTime() + 1
        d.DShort()
    end

    local c = ss.GetColor(r.color)
    d.DColor()
    d.DPoly {
        ss.To3D(debugv[1], s.Origin, s.Angles),
        ss.To3D(debugv[2], s.Origin, s.Angles),
        ss.To3D(debugv[3], s.Origin, s.Angles),
        ss.To3D(debugv[4], s.Origin, s.Angles),
    }
    d.DColor(c.r, c.g, c.b)
    for b in pairs(r.bounds) do
        local b1, b2, b3, b4 = unpack(b)
        local v1 = ss.To3D(Vector(b1, b2), s.Origin, s.Angles)
        local v2 = ss.To3D(Vector(b1, b4), s.Origin, s.Angles)
        local v3 = ss.To3D(Vector(b3, b4), s.Origin, s.Angles)
        local v4 = ss.To3D(Vector(b3, b2), s.Origin, s.Angles)
        d.DText(v1, string.format("(%d, %d)", b1, b2))
        d.DText(v3, string.format("(%d, %d)", b3, b4))
        d.DPoly {v1, v2, v3, v4}
    end
end

function sd.ShowInkDrawn(s, c, b, surf, q)
    if not ShowInkDrawn then return end
    d.DShort()
    d.DColor()
    d.DBox(s * ss.PixelsToUV * 500, b * ss.PixelsToUV * 500)
    d.DPoint(c * ss.PixelsToUV * 500)
    d.DPoly(surf.Vertices3D)
end

local gridsize = 12 -- [Hammer Units]
local ShowInkStatePos = Vector()
local ShowInkStateID = 0
local ShowInkStateSurf = {}
function sd.ShowInkStateMesh(pos, id, surf)
    if not ShowInkStateMesh then return end
    ShowInkStatePos = pos
    ShowInkStateID = id
    ShowInkStateSurf = surf
    if SERVER ~= player.GetByID(1):KeyDown(IN_ATTACK2) then return end
    local ink = surf.InkColorGrid
    local colorid = ink[pos.x] and ink[pos.x][pos.y]
    local c = ss.GetColor(colorid) or color_white
    local p = ss.To3D(pos * gridsize, surf.Origin, surf.Angles)
    d.DTick()
    d.DColor(c.r, c.g, c.b, colorid and 64 or 16)
    d.DABox(p, vector_origin, Vector(0, gridsize - 1, gridsize - 1), surf.Angles)
end

if ShowBlasterRadius then
    function d.DLoop() -- Show blaster explosion radius
        local ply = player.GetByID(1)
        if not IsValid(ply) then return end
        local w = ss.IsValidInkling(ply)
        if not w then return end
        if not w.IsBlaster then return end
        local firePos, fireDirection = w:GetFirePosition()
        local ink = {
            DamageClose = w.Parameters.mDamageNear,
            DamageMiddle = w.Parameters.mDamageMiddle,
            DamageFar = w.Parameters.mDamageFar,
            ColRadiusClose = w.Parameters.mCollisionRadiusNear,
            ColRadiusMiddle = w.Parameters.mCollisionRadiusMiddle,
            ColRadiusFar = w.Parameters.mCollisionRadiusFar,
            endpos = firePos + fireDirection * w:GetRange(),
        }
        d.DTick()
        d.DColor()
        d.DPoint(ink.endpos, false)
        d.DColor(0, 255, 0, 16)
        d.DSphere(ink.endpos, ink.ColRadiusFar, false)
        d.DColor()
        for _, e in ipairs(ents.FindInSphere(ink.endpos, ink.ColRadiusFar)) do
            if not IsValid(e) or e:Health() <= 0 or e == ply then continue end
            local dmg = ink.DamageClose
            local dist = Vector()
            local maxs, mins = e:OBBMaxs(), e:OBBMins()
            local origin = e:LocalToWorld(e:OBBCenter())
            d.DABox(e:GetPos(), mins, maxs, e:GetAngles())
            local size = (maxs - mins) / 2
            for i, dir in pairs {x = e:GetForward(), y = e:GetRight(), z = e:GetUp()} do
                local segment = dir:Dot(ink.endpos - origin)
                local sign = segment == 0 and 0 or segment > 0 and 1 or -1
                segment = math.abs(segment)
                if segment <= size[i] then continue end
                dist = dist + sign * (size[i] - segment) * dir
            end
            d.DVector(ink.endpos, dist)

            dist = dist:Length()
            if dist > ink.ColRadiusMiddle then
                d.DColor(0, 255, 0)
                d.DSphere(ink.endpos, ink.ColRadiusMiddle, false)
                dmg = math.Remap(dist, ink.ColRadiusMiddle, ink.ColRadiusFar, ink.DamageMiddle, ink.DamageFar)
            elseif dist > ink.ColRadiusClose then
                d.DColor(255, 255, 0, 16)
                d.DSphere(ink.endpos, ink.ColRadiusMiddle, false)
                d.DColor(255, 255, 0)
                d.DSphere(ink.endpos, ink.ColRadiusClose, false)
                dmg = math.Remap(dist, ink.ColRadiusClose, ink.ColRadiusMiddle, ink.DamageClose, ink.DamageMiddle)
            end

            d.DSText(.01, .01, dmg)
        end
    end
end

if CLIENT then
    if ChargeQuarter then
        local t = CurTime() -- Charge 25%
        hook.Add("CreateMove", "Test", function(c)
            if not c:KeyDown(IN_SPEED) then return end
            if CurTime() < t then return end
            local p = LocalPlayer()
            local w = ss.IsValidInkling(p)
            if not (w and w.GetChargeProgress) then return end
            local r = w:GetChargeProgress(true)
            if r < .25 then
                c:SetButtons(bit.bor(c:GetButtons(), IN_ATTACK))
            else
                t = CurTime() + 1
            end
        end)
    end

    if DrawInkUVMap then
        local c = 500
        function d.DLoop() -- Draw ink UV map
            -- setpos 0 250 500; setang 90 -90 0
            local ply = LocalPlayer()
            if not ply:KeyPressed(IN_SPEED) then return end
            d.DShort()
            d.DColor(255, 255, 255)
            d.DPoly {Vector(0, 0), Vector(0, c), Vector(c, c), Vector(c, 0)}
            d.DColor(255, 0, 0)
            d.DVector(Vector(c, 0), Vector(c, 0))
            d.DColor(0, 255, 0)
            d.DVector(Vector(0, c), Vector(0, c))
            for _, s in ipairs(ss.SurfaceArray) do
                local t = {}
                for i, v in ipairs(s.Vertices2D) do t[i] = v * c end

                d.DColor()
                d.DPoly(t)

                if DrawInkUVBounds then
                    d.DColor(255, 255, 255)
                    local bu, bv = -s.Boundary2D.x * ss.UnitsToUV, s.Boundary2D.y * ss.UnitsToUV
                    for i, ti in ipairs(t) do
                        d.DVector(ti, vector_up * c / 500)
                        d.DPoly {
                            t[i],
                            t[i] + Vector(bu, 0) * c,
                            t[i] + Vector(bu, bv) * c,
                            t[i] + Vector(0, bv) * c,
                        }
                    end
                end
            end
        end
    end
end

if ShowInkSurface then
    local key = SERVER and IN_USE or IN_SPEED
    function d.DLoop()
        local ply = player.GetByID(1)
        if not IsValid(ply) then return end
        if not ply:KeyPressed(key) then return end
        d.DShort()
        d.DColor()
        local p = ply:GetPos()
        local AABB = {mins = p - ss.vector_one, maxs = p + ss.vector_one}
        for _, s in ss.SearchAABB(AABB, vector_up) do
            local v = {}
            for i, w in ipairs(s.Vertices3D) do v[i] = w end
            d.DPoint(s.Origin)
            d.DPoly(v)
        end
    end
end

if ShowInkStateMesh then
    local key = SERVER and IN_USE or IN_SPEED
    function d.DLoop()
        local ply = SERVER and player.GetByID(1) or LocalPlayer()
        if not IsValid(ply) then return end
        if not ply:KeyPressed(key) then return end
        if not ShowInkStatePos then return end
        local pos = ShowInkStatePos
        local id = ShowInkStateID
        local surf = ShowInkStateSurf
        local ink = surf.InkColorGrid
        local colorid = ink[pos.x] and ink[pos.x][pos.y]
        local color = ss.GetColor(colorid) or color_white
        local sw, sh = surf.Boundary2D.x, surf.Boundary2D.y
        local gw, gh = math.floor(sw / gridsize), math.floor(sh / gridsize)
        d.DShort()
        d.DColor(color.r, color.g, color.b, colorid and 64 or 16)
        d.DPoint(surf.Origin)
        d.DText(surf.Origin, tostring(id))
        for x = 0, gw do
            for y = 0, gh do
                local p = Vector(x, y) * gridsize
                local org = ss.To3D(p, surf.Origin, surf.Angles)
                local cid = ink[x] and ink[x][y]
                local c = ss.GetColor(cid) or color_white
                d.DColor(c.r, c.g, c.b, cid and 64 or 16)
                d.DABox(org, vector_origin, Vector(0, gridsize - 1, gridsize - 1), surf.Angles)
            end
        end
    end
end