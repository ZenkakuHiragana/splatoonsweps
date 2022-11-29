
local ss = SplatoonSWEPs
if not ss then return end

local function PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
    local triarc, inner, outer = {}, {}, {}
    local step = math.max(roughness or 20, 1) -- Define step
    thickness = thickness or radius
    startang, endang = startang or 0, endang or 360 -- Correct start/end ang
    if startang > endang then endang = endang + 360 end

    -- Create the inner and outer circle's points.
    for t, r in pairs {[inner] = radius - thickness, [outer] = radius} do
        for deg = startang, endang, step do
            local rad = math.rad(deg)
            local rx, ry = math.cos(rad) * r, math.sin(rad) * r
            t[#t + 1] = {
                x = cx + rx, y = cy - ry,
                u = .5 + rx / radius,
                v = .5 - ry / radius,
            }
        end
    end

    -- Triangulate the points.
    for tri = 1, #inner * 2 do -- Twice as many triangles as there are degrees.
        local p1 = outer[math.floor(tri / 2) + 1]
        local p2 = (tri % 2 > 0 and inner or outer)[math.floor(tri / 2 + .5)]
        local p3 = inner[math.floor(tri / 2 + .5) + 1]
        triarc[#triarc + 1] = {p1, p2, p3}
    end

    -- Return a table of triangles to draw.
    return triarc
end

-- Draws an arc on your screen.
-- startang and endang are in degrees,
-- radius is the total radius of the outside edge to the center.
-- cx, cy are the x, y coordinates of the center of the arc.
-- roughness determines how many triangles are drawn. Number between 1-360; 2 or 3 is a good number.
function ss.DrawArc(cx, cy, radius, thickness, startang, endang, roughness)
    for _, v in ipairs(PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)) do
        surface.DrawPoly(v)
    end
end

ss.DrawCrosshair = {}
local SCRH_REF = 1080 -- Reference of screen height for crosshairs.

local function DrawCircle(x, y, color, d1, d2, mul)
    local r1, r2 = d1 / 2, d2 / 2
    local thickness = r1 - r2
    local scale = ScrH() / SCRH_REF * (mul or 1)
    draw.NoTexture()
    surface.SetDrawColor(color)
    ss.DrawArc(x, y, r1 * scale, thickness * scale)
end

-- Draws an inner circle of shooter's crosshair.
-- I separate the circle into two functions
-- as the four lines of the crosshair are placed between the inner one and the outer one.
local INNER_CIRCLE_OUTER_DIAMETER = 46 - 1 -- in pixels
local INNER_CIRCLE_INNER_DIAMETER = 34 + 2 -- in pixels
function ss.DrawCrosshair.InnerCircle(x, y)
    DrawCircle(x, y, color_white,
    INNER_CIRCLE_OUTER_DIAMETER, INNER_CIRCLE_INNER_DIAMETER)
end

-- Draws an outer circle of shooter's crosshair.
local OUTER_CIRCLE_OUTER_DIAMETER = 52 -- in pixels
local OUTER_CIRCLE_INNER_DIAMETER = 32 -- in pixels
function ss.DrawCrosshair.OuterCircle(x, y, color)
    DrawCircle(x, y, color,
    OUTER_CIRCLE_OUTER_DIAMETER, OUTER_CIRCLE_INNER_DIAMETER)
end

-- Draws a black background circle of shooter's crosshair when it hits an enemy.
local BG_CIRCLE_OUTER_DIAMETER = 56 -- in pixels
local BG_CIRCLE_INNER_DIAMETER = 52 -- in pixels
function ss.DrawCrosshair.OuterCircleBG(x, y)
    DrawCircle(x, y, color_black,
    BG_CIRCLE_OUTER_DIAMETER, BG_CIRCLE_INNER_DIAMETER)
end

-- Draws a circle of shooter's crosshair when it doesn't hit anything.
function ss.DrawCrosshair.CircleNoHit(x, y)
    local OUTER_DARK   = 48 -- in pixels
    local INNER_DARK   = 32 -- in pixels
    local OUTER_BRIGHT = 44 -- in pixels
    local INNER_BRIGHT = 38 -- in pixels
    DrawCircle(x, y, ss.CrosshairDarkColor, OUTER_DARK, INNER_DARK)
    DrawCircle(x, y, ss.CrosshairBaseColor, OUTER_BRIGHT, INNER_BRIGHT)
end

-- Draws shooter's four lines when they hit an enemy.
local sin45 = math.sin(math.rad(45))
local LINEHIT_SIZE_BG = 41 -- in pixels
local LINEHIT_WIDTH_BG = 5
local LINEHIT_SIZE = 38
local LINEHIT_WIDTH = 3
local function DrawLinesHit(x, y, distanceRatio, distanceReference, mul, size, width, t)
    local scale = ScrH() / SCRH_REF
    local length = ((size - width) / sin45) * scale * mul
    size = size * scale -- = width + length
    width = (width / sin45) * scale * mul
    local diff = distanceReference * distanceRatio * mul
    for _, v in ipairs(t) do
        local mat = "Line" .. v[1]
        local c = v[2]
        surface.SetMaterial(ss.Materials.Crosshair[mat])
        surface.SetDrawColor(c)
        for i = 1, 4 do
            local dx = diff * (i > 2 and 1 or -1)
            local dy = diff * (bit.band(i, 3) > 1 and 1 or -1)
            surface.DrawTexturedRectRotated(x + dx, y + dy, length, width, 90 * i + 45)
        end
    end
end

function ss.DrawCrosshair.LinesHitBG(x, y, distanceRatio, mul)
    DrawLinesHit(x, y, distanceRatio, LINEHIT_SIZE_BG, mul,
    LINEHIT_SIZE_BG, LINEHIT_WIDTH_BG, {{"", color_black}})
end

function ss.DrawCrosshair.LinesHit(x, y, color, distanceRatio, mul)
    DrawLinesHit(x, y, distanceRatio, LINEHIT_SIZE_BG, mul,
    LINEHIT_SIZE, LINEHIT_WIDTH, {{"", color_white}, {"Color", color}})
end

local function FourLinesAround(org, right, dir, range, degx, degy, dx, dy, drawfunc)
    local ndir = dir:GetNormalized()
    local up = right:Cross(ndir)
    for i = 1, 4 do
        local rot = dir:Angle()
        local sgnx = i > 2 and 1 or -1
        local sgny = bit.band(i, 3) > 1 and 1 or -1
        rot:RotateAroundAxis(up, degx * sgnx)
        rot:RotateAroundAxis(right, degy * sgny)

        local endpos = org + rot:Forward() * range
        local hit = endpos:ToScreen()
        if hit.visible then
            local ang = 90 * i - 45
            drawfunc(hit.x + dx, hit.y + dy, sgnx, sgny, ang)
        end
    end
end

function ss.DrawCrosshair.FourLinesAround(org, right, dir, range, degx, degy, dx, dy, adjust, bgcolor, forecolor)
    local SIZE_ORIGINAL = 18 -- in pixels
    local WIDTH_ORIGINAL = 4 -- in pixels
    local scale = ScrH() / SCRH_REF
    local width = (WIDTH_ORIGINAL / sin45) * scale
    local length = ((SIZE_ORIGINAL - WIDTH_ORIGINAL) / sin45) * scale
    local diff = OUTER_CIRCLE_OUTER_DIAMETER / 2 * scale
    if adjust then diff = diff - width * sin45 end
    FourLinesAround(org, right, dir, range, degx, degy, dx, dy,
    function(x, y, sx, sy, ang)
        x = x - diff * sx
        y = y - diff * sy
        surface.SetDrawColor(bgcolor)
        surface.SetMaterial(ss.Materials.Crosshair.Line)
        surface.DrawTexturedRectRotated(x, y, length, width, ang)

        if not forecolor then return end
        surface.SetDrawColor(forecolor)
        surface.SetMaterial(ss.Materials.Crosshair.LineColor)
        surface.DrawTexturedRectRotated(x, y, length, width, ang)
    end)
end

-- Draws a center dot of shooter's crosshair.
function ss.DrawCrosshair.CenterDot(x, y, color)
    local CENTER_DOT_SIZE = 3 -- Radius of the center dot in pixels
    color = color or color_white
    draw.NoTexture()
    surface.SetDrawColor(color)
    ss.DrawArc(x, y, CENTER_DOT_SIZE)
end

-- Draws a center dot of charger's crosshair.
function ss.DrawCrosshair.ChargerCenterDot(x, y, mul, darkcolor, brightcolor)
    local DARK_DIAMETER = 10
    local BRIGHT_DIAMETER = 6
    local screenscale = ScrH() / SCRH_REF
    local scale = 0.5 * screenscale * (mul or 1)
    local dr = DARK_DIAMETER * scale
    local br = BRIGHT_DIAMETER * scale
    darkcolor = darkcolor or ss.CrosshairDarkColor
    brightcolor = brightcolor or ss.CrosshairBaseColor
    draw.NoTexture()
    surface.SetDrawColor(darkcolor)
    ss.DrawArc(x, y, dr)
    surface.SetDrawColor(brightcolor)
    ss.DrawArc(x, y, br)
end

-- Draws a center circle of charger's crosshair.
function ss.DrawCrosshair.ChargerBaseCircle(x, y, mul)
    local OUTER_DIAMETER = 27
    local INNER_DIAMETER = 21
    DrawCircle(x, y, ss.CrosshairBaseColor, OUTER_DIAMETER, INNER_DIAMETER, mul)
end

local CHARGER_OUTER_DIAMETER = 40
local CHARGER_INNER_DIAMETER = 34 + 1
function ss.DrawCrosshair.ChargerColoredCircle(x, y, mul, color)
    DrawCircle(x, y, color, CHARGER_OUTER_DIAMETER, CHARGER_INNER_DIAMETER, mul)
end

local function DrawArc(x, y, color, d1, d2, start, endang, mul)
    local scale = ScrH() / SCRH_REF * (mul or 1) * 0.5
    local r1, r2 = d1 * scale, d2 * scale
    local thickness = r1 - r2
    draw.NoTexture()
    surface.SetDrawColor(color)
    ss.DrawArc(x, y, r1, thickness, start, endang, 1)
end

-- Draws the charger's crosshair.
-- progress ranges from 0 to 360.
local CHARGER_ALPHA = 96
function ss.DrawCrosshair.ChargerProgress(x, y, mul, progress)
    -- Black part of the arc
    local OUTER_DIAMETER = 40
    local INNER_DIAMETER = 28
    local start = 90
    local endang = 450 - progress
    DrawArc(x, y, ColorAlpha(ss.CrosshairDarkColor, CHARGER_ALPHA),
    OUTER_DIAMETER, INNER_DIAMETER, start, endang, mul)

    -- White part of the arc
    OUTER_DIAMETER = 40
    INNER_DIAMETER = 24
    start = 450 - progress
    endang = 450
    DrawArc(x, y, ColorAlpha(ss.CrosshairBaseColor, CHARGER_ALPHA),
    OUTER_DIAMETER, INNER_DIAMETER, start, endang, mul)
end

function ss.DrawCrosshair.ChargerFourLines(x, y, distanceRatio, mul, darkcolor, brightcolor)
    local SIZE_BG = 18 + 4
    local SIZE_FG = 14 + 2
    local WIDTH_BG = 7
    local WIDTH_FG = 3
    DrawLinesHit(x, y, distanceRatio, SIZE_BG, mul,
    SIZE_BG, WIDTH_BG, {{"", darkcolor}})
    DrawLinesHit(x, y, distanceRatio, SIZE_BG, mul,
    SIZE_FG, WIDTH_FG, {{"", brightcolor}})
end

local function Flash(x, y, mul, color, frac, diameter)
    local ALPHA_MAX = 255
    local ALPHA_MIN = 0
    local scale = ScrH() / SCRH_REF * (mul or 1)
    local d = diameter * scale
    local radius = d / 2
    local alpha = Lerp(frac, ALPHA_MAX, ALPHA_MIN)
    surface.SetMaterial(ss.Materials.Crosshair.Flash)
    surface.SetDrawColor(ColorAlpha(color, alpha))
    surface.DrawTexturedRect(x - radius, y - radius, d, d)
end

function ss.DrawCrosshair.ChargerFlash(x, y, mul, color, frac)
    Flash(x, y, mul, color, frac, CHARGER_OUTER_DIAMETER)
end

function ss.DrawCrosshair.SplatlingBaseCircle(x, y)
    local OUTER_DIAMETER = 54
    local INNER_DIAMETER = 44 + 2
    DrawCircle(x, y, ss.CrosshairBaseColor, OUTER_DIAMETER, INNER_DIAMETER)
end

local SPLATLING_OUTER_DIAMETER = 70
local SPLATLING_INNER_DIAMETER = 56
function ss.DrawCrosshair.SplatlingColoredCircle(x, y, color)
    DrawCircle(x, y, color, SPLATLING_OUTER_DIAMETER, SPLATLING_INNER_DIAMETER)
end

-- Draws the spaltling's crosshair.
-- p1 and p2 range from 0 to 360.
-- p1 is for the first charge, p2 is for the second charge.
local SPLATLING_ALPHA = 128
function ss.DrawCrosshair.SplatlingProgress(x, y, p1, p2)
    -- Black part of the arc.
    local OUTER_DIAMETER = 58
    local INNER_DIAMETER = 44
    local start = 90
    local endang = 450 - p1
    DrawArc(x, y, ColorAlpha(ss.CrosshairDarkColor, CHARGER_ALPHA),
    OUTER_DIAMETER, INNER_DIAMETER, start, endang)

    -- White part of the arc.
    OUTER_DIAMETER = 58
    INNER_DIAMETER = 40
    start = 450 - p1
    endang = 450
    DrawArc(x, y, ColorAlpha(ss.CrosshairBaseColor, CHARGER_ALPHA),
    OUTER_DIAMETER, INNER_DIAMETER, start, endang)

    -- The arc for the second charge.
    OUTER_DIAMETER = 64
    INNER_DIAMETER = 48
    start = 450 - p2
    endang = 450
    DrawArc(x, y, ColorAlpha(color_white, SPLATLING_ALPHA),
    OUTER_DIAMETER, INNER_DIAMETER, start, endang)
end

function ss.DrawCrosshair.SplatlingFourLinesAround(org, right, dir, range, degx, degy, dx, dy, adjust, bgcolor, forecolor)
    local LENGTH = 20 + 3 -- in pixels
    local WIDTH = 3 -- in pixels
    local scale = ScrH() / SCRH_REF
    local mul = 0.775
    LENGTH = LENGTH * scale
    WIDTH = WIDTH * scale
    local dy2 = (LENGTH * sin45) / 2 * mul
    local dx2 = (LENGTH * (1 + sin45)) / 2 * mul
    local diff = SPLATLING_OUTER_DIAMETER / 2 * scale
    if adjust then diff = diff - WIDTH * sin45 end
    FourLinesAround(org, right, dir, range, degx, degy, dx, dy,
    function(x, y, sx, sy, ang)
        x, y = x - diff * sx, y - diff * sy
        surface.SetDrawColor(bgcolor)
        surface.SetMaterial(ss.Materials.Crosshair.Line)
        surface.DrawTexturedRectRotated(x, y, LENGTH, WIDTH, ang)
        surface.DrawTexturedRectRotated(x + sx * dx2, y - sy * dy2, LENGTH, WIDTH, 0)
        surface.DrawTexturedRectRotated(x - sx * dy2, y + sy * dx2, LENGTH, WIDTH, 90)

        if not forecolor then return end
        surface.SetDrawColor(forecolor)
        surface.SetMaterial(ss.Materials.Crosshair.LineColor)
        surface.DrawTexturedRectRotated(x, y, LENGTH, WIDTH, ang)
        surface.DrawTexturedRectRotated(x + sx * dx2, y - sy * dy2, LENGTH, WIDTH, 0)
        surface.DrawTexturedRectRotated(x - sx * dy2, y + sy * dx2, LENGTH, WIDTH, 90)
    end)
end

function ss.DrawCrosshair.SplatlingFourLines(x, y, distanceRatio, darkcolor, brightcolor)
    local SIZE_BG = 26 + 5
    local SIZE_FG = 18 + 5
    local WIDTH_BG = 8
    local WIDTH_FG = 4
    DrawLinesHit(x, y, distanceRatio, 40, 1,
    SIZE_BG, WIDTH_BG, {{"", darkcolor}})
    DrawLinesHit(x, y, distanceRatio, 40, 1,
    SIZE_FG, WIDTH_FG, {{"", brightcolor}})
end

function ss.DrawCrosshair.SplatlingFlash(x, y, color, frac)
    Flash(x, y, 1, color, frac, SPLATLING_OUTER_DIAMETER)
end
