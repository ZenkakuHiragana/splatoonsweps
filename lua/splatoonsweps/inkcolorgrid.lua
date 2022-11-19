
-- Handles ink color info on the map and determines color at a point on a surface

local ss = SplatoonSWEPs
if not ss then return end
local reference_polys = {}
local reference_vert = Vector(1)
local circle_polys = 360 / 12
for _ = 1, circle_polys do
    reference_polys[#reference_polys + 1] = Vector(reference_vert)
    reference_vert:Rotate(Angle(0, circle_polys))
end

-- Constant value localization
local SERVER = SERVER
local huge = math.huge
local vector_one = ss.vector_one
local vector_mins, vector_maxs = vector_one * huge, -vector_one * huge

-- Global built-in function localization
local band = bit.band
local ipairs = ipairs
local TickCount = engine.TickCount
local Vector = Vector

-- Math function localization
local floor = math.floor
local min = math.min
local rad = math.rad
local sin, cos = math.sin, math.cos
local To2D, To3D = ss.To2D, ss.To3D
local MinVector, MaxVector = ss.MinVector, ss.MaxVector
local NormalizeAngle = math.NormalizeAngle
local Round = math.Round

-- net function localization
local net_Send = net.Send
local net_Start = net.Start
local net_WriteFloat = net.WriteFloat
local net_WriteInt = net.WriteInt
local net_WriteUInt = net.WriteUInt
local net_WriteNormal = net.WriteNormal

-- Internal function to record a new ink to the map.
local gridsize = ss.InkGridSize
local gridarea = gridsize * gridsize
local griddivision = 1 / gridsize
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

function ss.GetInkReferenceAABB(pos, normal, radius)
    local ang = normal:Angle()
    local mins, maxs = vector_mins, vector_maxs
    for _, v in ipairs(reference_polys) do
        local vertex = To3D(v * radius, pos, ang)
        mins = MinVector(mins, vertex)
        maxs = MaxVector(maxs, vertex)
    end
    return mins, maxs
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
local Order, Tick = 1, 0 -- The ink paint order to handle multiple query at the same tick
local AddInkRectangle = ss.AddInkRectangle
local CollectSurfaces = ss.CollectSurfaces
local GetInkReferenceAABB = ss.GetInkReferenceAABB
function ss.Paint(pos, normal, radius, color, angle, inktype, ratio, ply, classname)
    -- Parameter limit to reduce network traffic
    pos.x   = Round(pos.x / 2) * 2
    pos.y   = Round(pos.y / 2) * 2 -- -16384 to 16384, 2 step
    pos.z   = Round(pos.z / 2) * 2
    radius  = min(Round(radius), 255) -- 0 to 255, integer
    inktype = floor(inktype)          -- 0 to MAX_INK_TYPE, integer
    angle   = Round(NormalizeAngle(angle) / 4) * 4

    Order = Order + 1
    if TickCount() > Tick then
        Tick, Order = TickCount(), 0
    end

    if SERVER then
        net_Start "SplatoonSWEPs: Send an ink queue"
        net_WriteUInt(color, ss.COLOR_BITS)
        net_WriteUInt(inktype, ss.INK_TYPE_BITS)
        net_WriteUInt(radius, 8)
        net_WriteFloat(ratio)
        net_WriteNormal(normal)
        net_WriteInt(angle / 4, 7)
        net_WriteInt(pos.x / 2, 15)
        net_WriteInt(pos.y / 2, 15)
        net_WriteInt(pos.z / 2, 15)
        net_WriteUInt(Order, 9)
        net_WriteUInt(band(Tick, 0x1F), 5)
        net_Send(ss.PlayersReady) -- 142 to 166 bits
    else
        ss.ReceiveInkQueue(radius, angle, normal, ratio, color, inktype, pos, Order, band(Tick, 0x1F))
    end

    local area = 0
    local mins, maxs = GetInkReferenceAABB(pos, normal, radius)
    for s in CollectSurfaces(mins, maxs, normal) do
        local ang = s.Angles
        local localang = ang.roll + ang.yaw - angle
        area = area + AddInkRectangle(color, inktype, localang, pos, radius, ratio, s)
    end

    if not ply:IsPlayer() or ply:IsBot() then return end
    ss.WeaponRecord[ply].Inked[classname] = (ss.WeaponRecord[ply].Inked[classname] or 0) - area * gridarea
    if ss.sp and SERVER then
        net_Start "SplatoonSWEPs: Send turf inked"
        net_WriteFloat(ss.WeaponRecord[ply].Inked[classname])
        net_WriteUInt(table.KeyFromValue(ss.WeaponClassNames, classname), ss.WEAPON_CLASSNAMES_BITS)
        net_Send(ply)
    end
end

-- Returns ink color at given position against given normal.
-- Argument:
--   Vector pos
--   Vector normal
-- Returning:
--   number         | The ink color of the specified position.
--   nil            | If there is no ink, this returns nil.
function ss.GetSurfaceColor(pos, normal)
    for s in CollectSurfaces(pos, pos, normal) do
        local p2d = To2D(pos, s.Origin, s.Angles)
        local ink = s.InkColorGrid
        local x, y = floor(p2d.x * griddivision), floor(p2d.y * griddivision)
        local colorid = ink[x * 32768 + y]
        if ss.Debug then ss.Debug.ShowInkStateMesh(Vector(x, y), i, s) end
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
--   Vector mins      | Minimum size (only X and Y components are used).
--   Vector maxs      | Maximum size (only X and Y components are used).
--   number num       | Number of traces per axis.
--   number tolerance | Should be from 0 to 1.
--     The returning color should be the one that covers more than this ratio of the area.
-- Returning:
--   number           | The ink color.
--   nil              | If there is no ink or it's too mixed, this returns nil.
local GetSurfaceColor = ss.GetSurfaceColor
local GetWinningKey = table.GetWinningKey
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