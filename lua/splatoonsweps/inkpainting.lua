
-- This lua manages whole ink in map.

local ss = SplatoonSWEPs
if not ss then return end
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
    local sw, sh = s.GridSize.x, s.GridSize.y
    local dy = radius * griddivision
    local dx = ratio * dy
    local y_const = dy * 2 / h
    local x_const = ratio * dy * 2 / w
    local ang = rad(-localang)
    local sind, cosd = sin(ang), cos(ang)
    local pointcount = {}
    local area = 0
    local paint_threshold = floor(gridarea / (dx * dy)) + 1
    for x = 0, w - 1, 0.5 do
        local tx = t[floor(x)]
        if not tx then continue end
        for y = 0, h - 1, 0.5 do
            if not tx[floor(y)] then continue end
            local p = x * x_const - dx
            local q = y * y_const - dy
            local i = floor(p * cosd - q * sind + x0)
            local j = floor(p * sind + q * cosd + y0)
            local k = i * 32768 + j
            if 0 <= i and i <= sw and 0 <= j and j <= sh then
                pointcount[k] = (pointcount[k] or 0) + 1
                if pointcount[k] > paint_threshold then
                    if ink[k] ~= color then area = area + 1 end
                    ink[k] = color
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
    pos.x = math.Round(pos.x / 2) * 2
    pos.y = math.Round(pos.y / 2) * 2 -- -16384 to 16384, 2 step
    pos.z = math.Round(pos.z / 2) * 2
    radius = math.min(math.Round(radius), 255) -- 0 to 255, integer
    inktype = math.floor(inktype) -- 0 to MAX_INK_TYPE, integer
    angle = math.Round(math.NormalizeAngle(angle) / 4) * 4

    local area = 0
    local ang = normal:Angle()
    local mins, maxs = ss.vector_one * math.huge, -ss.vector_one * math.huge
    for _, v in ipairs(reference_polys) do
        local vertex = ss.To3D(v * radius, pos, ang)
        mins = ss.MinVector(mins, vertex)
        maxs = ss.MaxVector(maxs, vertex)
    end

    ss.SuppressHostEventsMP(ply)
    for s in ss.CollectSurfaces(mins, maxs, normal) do
        area = area + AddInkRectangle(color, inktype, s.Angles.roll + s.Angles.yaw - angle, pos, radius, ratio, s)

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
            net.WriteFloat(ratio)
            net.WriteInt(angle / 4, 7)
            net.WriteInt(pos.x / 2, 15)
            net.WriteInt(pos.y / 2, 15)
            net.WriteInt(pos.z / 2, 15)
            net.WriteUInt(Order, 9) -- 119 to 128 bits
            net.WriteUInt(bit.band(OrderTick, 0x1F), 5)
            net.Send(ss.PlayersReady)
        else
            ss.ReceiveInkQueue(s.Index, radius, angle, ratio, color, inktype, pos, Order, bit.band(OrderTick, 0x1F))
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
local CollectSurfaces = ss.CollectSurfaces
function ss.GetSurfaceColor(pos, normal)
    for s in CollectSurfaces(pos, pos, normal) do
        local p2d = To2D(pos, s.Origin, s.Angles)
        local ink = s.InkColorGrid
        local x, y = floor(p2d.x * griddivision), floor(p2d.y * griddivision)
        local colorid = ink[x * 32768 + y]
        -- if ss.Debug then ss.Debug.ShowInkStateMesh(Vector(x, y), i, s) end
        if colorid then return colorid end
    end
end

-- Returns if given position is paintable against given normal.
-- Arguments:
--   Vector pos
--   Vector normal
-- Returning:
--   boolean
function ss.IsPaintable(pos, normal)
    for s in CollectSurfaces(pos, pos, normal) do
        if s.InkColorGrid then return true end
    end
end

-- Traces and picks up colors in an area on XY plane and returns the representative color of the area
-- Arguments:
--   Vector org       | the origin/center of the area.
--   Vector max       | Maximum size (only X and Y components are used).
--   Vector min       | Minimum size (only X and Y components are used).
--   number num       | Number of traces per axis.
--   number tolerance | Should be from 0 to 1.
--     The returning color should be the one that covers more than this ratio of the area.
-- Returning:
--   number           | The ink color.
--   nil              | If there is no ink or it's too mixed, this returns nil.
local GetSurfaceColor = ss.GetSurfaceColor
local GetWinningKey = table.GetWinningKey
local Vector = Vector
function ss.GetSurfaceColorArea(org, mins, maxs, num, tolerance)
    local gcoloravailable = 0 -- number of points whose color is not -1
    local gcolorlist = {} -- Ground color list
    for dx = -num, num do
        for dy = -num, num do
            local pos = org + Vector(maxs.x * dx, maxs.y * dy) / num
            local color = GetSurfaceColor(pos, vector_up) or -1
            if color >= 0 then
                gcoloravailable = gcoloravailable + 1
                gcolorlist[color] = (gcolorlist[color] or 0) + 1
            end
        end
    end

    local gcolorkey = GetWinningKey(gcolorlist)
    return gcoloravailable / (num * 2 + 1) ^ 2 > tolerance and gcolorkey or -1
end
