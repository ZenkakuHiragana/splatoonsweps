
-- This lua manages whole ink in map.

local ss = SplatoonSWEPs
if not ss then return end
local MIN_BOUND = 20 -- Ink minimum bounding box scale
local POINT_BOUND = ss.vector_one * .1
local reference_polys = {}
local reference_vert = Vector(1)
local circle_polys = 360 / 12
for _ = 1, circle_polys do
    reference_polys[#reference_polys + 1] = Vector(reference_vert)
    reference_vert:Rotate(Angle(0, circle_polys))
end

-- Internal function to record a new ink to the map.
local gridsize = ss.InkGridSize
local gridarea = gridsize * gridsize
local griddivision = 1 / gridsize
local To2D, floor, rad, sin, cos = ss.To2D, math.floor, math.rad, math.sin, math.cos
function ss.AddInkRectangle(color, inktype, localang, pos, radius, ratio, s)
    local pos2d = To2D(pos, s.Origin, s.Angles) * griddivision
    local x0, y0 = pos2d.x, pos2d.y
    local ink = s.InkColorGrid
    local t = ss.InkShotMaterials[inktype]
    local w, h = t.width, t.height
    local surfsize = s.Bound * griddivision
    local sw, sh = floor(surfsize.x), floor(surfsize.y)
    local dy = radius * griddivision
    local dx = ratio * dy
    local y_const = dy * 2 / h
    local x_const = ratio * dy * 2 / w
    local ang = rad(-localang)
    local sind, cosd = sin(ang), cos(ang)
    local pointcount = {}
    local area = 0
    local paint_threshold = math.floor(gridarea / (dx * dy)) + 1
    for x = 0, w - 1, 0.5 do
        local tx = t[floor(x)]
        if not tx then continue end
        for y = 0, h - 1, 0.5 do
            if not tx[floor(y)] then continue end
            local p = x * x_const - dx
            local q = y * y_const - dy
            local i = floor(p * cosd - q * sind + x0)
            local k = floor(p * sind + q * cosd + y0)
            if 0 <= i and i <= sw and 0 <= k and k <= sh then
                pointcount[i] = pointcount[i] or {}
                pointcount[i][k] = (pointcount[i][k] or 0) + 1
                if pointcount[i][k] > paint_threshold then
                    ink[i] = ink[i] or {}
                    if ink[i][k] ~= color then area = area + 1 end
                    ink[i][k] = color
                end
            end
        end
    end

    return area
end

-- Draws ink.
-- Arguments:
--   Vector pos       | Center position.
--   Vector normal    | Normal of the surface to draw.
--   number radius    | Scale of ink in Hammer units.
--   number angle     | Ink rotation in degrees.
--   number inktype   | Shape of ink.
--   number ratio     | Aspect ratio.
--   Entity ply       | The shooter.
--   string classname | Weapon's class name.
local Order, OrderTick = 1, 0 -- The ink paint order at OrderTime[sec]
local AddInkRectangle = ss.AddInkRectangle
function ss.Paint(pos, normal, radius, color, angle, inktype, ratio, ply, classname)
    -- Parameter limit to reduce network traffic
    pos.x = math.Round(pos.x * 2) / 2
    pos.y = math.Round(pos.y * 2) / 2 -- -16384 to 16384, 0.5 step
    pos.z = math.Round(pos.z * 2) / 2
    radius = math.min(math.Round(radius), 255) -- 0 to 255, integer
    inktype = math.floor(inktype) -- 0 to MAX_INK_TYPE, integer
    angle = math.Round(math.NormalizeAngle(angle))

    local area = 0
    local ang = normal:Angle()
    local AABB = {mins = ss.vector_one * math.huge, maxs = -ss.vector_one * math.huge}
    local dot = -normal:Dot(ss.GetGravityDirection())
    ang.roll = math.abs(dot) > ss.MAX_COS_DIFF and angle * dot or ang.yaw
    for _, v in ipairs(reference_polys) do
        local vertex = ss.To3D(v * radius, pos, ang)
        AABB.mins = ss.MinVector(AABB.mins, vertex)
        AABB.maxs = ss.MaxVector(AABB.maxs, vertex)
    end

    AABB.mins:Add(-ss.vector_one * MIN_BOUND)
    AABB.maxs:Add(ss.vector_one * MIN_BOUND)
    ss.SuppressHostEventsMP(ply)
    for _, s in ss.SearchAABB(AABB, normal) do
        local _, localang = WorldToLocal(vector_origin, ang, vector_origin, s.Normal:Angle())
        localang = ang.yaw - localang.roll + s.DefaultAngles + (CLIENT and s.Moved and 90 or 0)
        localang = math.Round(math.NormalizeAngle(localang)) -- -180 to 179, integer
        area = area + AddInkRectangle(color, inktype, localang, pos, radius, ratio, s)

        Order = Order + 1
        if engine.TickCount() > OrderTick then
            OrderTick = engine.TickCount()
            Order = 1
        end

        if SERVER then
            net.Start "SplatoonSWEPs: Send an ink queue"
            net.WriteUInt(s.Index, ss.SURFACE_ID_BITS)
            net.WriteUInt(color, ss.COLOR_BITS)
            net.WriteUInt(inktype, ss.INK_TYPE_BITS)
            net.WriteUInt(radius, 8)
            net.WriteVector(Vector(ratio))
            net.WriteInt(localang, 9)
            net.WriteInt(pos.x * 2, 16)
            net.WriteInt(pos.y * 2, 16)
            net.WriteInt(pos.z * 2, 16)
            net.WriteUInt(Order, 8) -- 119 to 128 bits
            net.WriteFloat(OrderTick)
            net.Send(ss.PlayersReady)
        else
            ss.ReceiveInkQueue(s.Index, radius, localang, ratio, color, inktype, pos, Order - 256, OrderTick)
        end
    end

    ss.EndSuppressHostEventsMP(ply)
    if not ply:IsPlayer() or ply:IsBot() then return end

    ss.WeaponRecord[ply].Inked[classname] = (ss.WeaponRecord[ply].Inked[classname] or 0) - area * gridarea
    if ss.sp and SERVER then
        net.Start "SplatoonSWEPs: Send turf inked"
        net.WriteDouble(ss.WeaponRecord[ply].Inked[classname])
        net.WriteUInt(table.KeyFromValue(ss.WeaponClassNames, classname), ss.WEAPON_CLASSNAMES_BITS)
        net.Send(ply)
    end
end

-- Takes a TraceResult and returns ink color of its HitPos.
-- Argument:
--   TraceResult tr | A TraceResult structure to pick up a position.
-- Returning:
--   number         | The ink color of the specified position.
--   nil            | If there is no ink, this returns nil.
function ss.GetSurfaceColor(tr)
    if not tr.Hit then return end
    local pos = tr.HitPos
    local AABB = {mins = pos - POINT_BOUND, maxs = pos + POINT_BOUND}
    for _, s in ss.SearchAABB(AABB, tr.HitNormal) do
        local p2d = ss.To2D(pos, s.Origin, s.Angles)
        local ink = s.InkColorGrid
        local x, y = math.floor(p2d.x * griddivision), math.floor(p2d.y * griddivision)
        local colorid = ink[x] and ink[x][y]
        if ss.Debug then ss.Debug.ShowInkStateMesh(Vector(x, y), i, s) end
        if colorid then return colorid end
    end
end

-- Traces and picks up colors in an area on XY plane and returns the representative color of the area
-- Arguments:
--   Vector org       | the origin/center of the area.
--   Vector max       | Maximum size (only X and Y components are used).
--   Vector min       | Minimum size (only X and Y components are used).
--   number num       | Number of traces per axis.
--   number tracez    | Depth of the traces.
--   number tolerance | Should be from 0 to 1.
--     The returning color should be the one that covers more than this ratio of the area.
-- Returning:
--   number           | The ink color.
--   nil              | If there is no ink or it's too mixed, this returns nil.
function ss.GetSurfaceColorArea(org, mins, maxs, num, tracez, tolerance, filter)
    local ink_t = {filter = filter, mask = MASK_SHOT}
    local gcoloravailable = 0 -- number of points whose color is not -1
    local gcolorlist = {} -- Ground color list
    for dx = -num, num do
        for dy = -num, num do
            ink_t.start = org + Vector(maxs.x * dx, maxs.y * dy) / num
            ink_t.endpos = ink_t.start - vector_up * tracez
            local color = ss.GetSurfaceColor(util.TraceLine(ink_t)) or -1
            if color >= 0 then
                gcoloravailable = gcoloravailable + 1
                gcolorlist[color] = (gcolorlist[color] or 0) + 1
            end
        end
    end

    local gcolorkey = table.GetWinningKey(gcolorlist)
    return gcoloravailable / (num * 2 + 1) ^ 2 > tolerance and gcolorkey or -1
end
