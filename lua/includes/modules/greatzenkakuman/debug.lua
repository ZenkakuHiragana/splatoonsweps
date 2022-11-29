
-- Debugging code
AddCSLuaFile()
module("greatzenkakuman.debug", package.seeall)

local t = 5 -- Debugoverlay time
local csv = Color(0, 255, 255)
local ccl = Color(255, 255, 0) -- Debugoverlay color
local igz = true -- Debugoverlay ignoreZ
local sp = game.SinglePlayer()
local d = sp or CLIENT
local dcolor = "greatzenkakuman.debug.DColor(%s,%s,%s,%s,1)"
local daxis = "greatzenkakuman.debug.DAxis(Vector(%f,%f,%f),Angle(%f,%f,%f),%s,%f)"
local dline = "greatzenkakuman.debug.DLine(Vector(%f,%f,%f),Vector(%f,%f,%f),%s,1)"
local dtext = "greatzenkakuman.debug.DText(Vector(%f,%f,%f),\"%s\",%s)"
local dtri = "greatzenkakuman.debug.DTri(Vector(%f,%f,%f),Vector(%f,%f,%f),Vector(%f,%f,%f),%s,1)"
local dplane = "greatzenkakuman.debug.DPlane(Vector(%f,%f,%f),Vector(%f,%f,%f),%s,1)"
local dpoint = "greatzenkakuman.debug.DPoint(Vector(%f,%f,%f),%s,1)"
local dstext = "greatzenkakuman.debug.DSText(%d,%d,%s,1)"
local dsphere = "greatzenkakuman.debug.DSphere(Vector(%f,%f,%f),%f,%s,1)"
local dvector = "greatzenkakuman.debug.DVector(Vector(%f,%f,%f),Vector(%f,%f,%f),%s,1)"
local dbox = "greatzenkakuman.debug.DBox(Vector(%f,%f,%f),Vector(%f,%f,%f),1)"
local dsbox = "greatzenkakuman.debug.DSBox(Vector(%f,%f,%f),Vector(%f,%f,%f),Vector(%f,%f,%f),Vector(%f,%f,%f),Angle(%f,%f,%f),1)"
local dabox = "greatzenkakuman.debug.DABox(Vector(%f,%f,%f),Vector(%f,%f,%f),Vector(%f,%f,%f),Angle(%f,%f,%f),1)"
if SERVER then
    util.AddNetworkString "greatzenkakuman.debug.DPoly"
else
    net.Receive("greatzenkakuman.debug.DPoly", function() DPoly(net.ReadTable(), net.ReadBool(), 1) end)
end

function DTick() if d then t = .08 else BroadcastLua "greatzenkakuman.debug.DTick()" end end
function DShort() if d then t = 5 else BroadcastLua "greatzenkakuman.debug.DShort()" end end
function DLong() if d then t = 10 else BroadcastLua "greatzenkakuman.debug.DLong()" end end
function DColor(r, g, b, a, sv)
    if d then
        r = r or sv and 0 or 255
        g = g or 255
        b = b or sv and 255 or 0
        a = a or 255
        local c = Color(r, g, b, a)
        if sv then csv = c else ccl = c end
    else
        BroadcastLua(dcolor:format(r, g, b, a))
    end
end

function DAxis(v, a, z, l)
    a, z, l = a or angle_zero, Either(z ~= nil, z, igz), l or 20
    if d then
        debugoverlay.Axis(v, a, l, t, z)
    else
        BroadcastLua(daxis:format(v.x, v.y, v.z, a.p, a.y, a.r, tostring(z), t, l))
    end
end

function DLine(x, y, z, sv)
    z = Either(z ~= nil, z, igz)
    if d then
        debugoverlay.Line(x, y, t, sv and csv or ccl, z)
    else
        BroadcastLua(dline:format(x.x, x.y, x.z, y.x, y.y, y.z, tostring(z)))
    end
end

function DText(v, x, z)
    z = Either(z ~= nil, z, igz)
    x = tostring(x)
    if d then
        debugoverlay.Text(v, x, t, not z)
    else
        BroadcastLua(dtext:format(v.x, v.y, v.z, x, tostring(z)))
    end
end

function DTri(a, b, c, z, sv)
    z = Either(z ~= nil, z, igz)
    if d then
        debugoverlay.Triangle(a, b, c, t, sv and csv or ccl, z)
    else
        BroadcastLua(dtri:format(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, tostring(z)))
    end
end

function DPlane(v, n, z, sv)
    z = Either(z ~= nil, z, igz)
    if d then
        local l = 50
        local a = n:Angle()
        local x, y = a:Right() * l, a:Up() * l
        DPoly({v + x + y, v + x - y, v - x - y, v - x + y}, z, sv)
        DLine(v + x + y, v - x - y, z, sv)
        DLine(v + x - y, v - x + y, z, sv)
        DVector(v, n * l, z, sv)
    else
        BroadcastLua(dplane:format(v.x, v.y, v.z, n.x, n.y, n.z, tostring(z)))
    end
end

function DPoint(v, s, z, sv)
    if s == nil or isbool(s) then s, z, sv = 10, s, z end
    z = Either(z ~= nil, z, igz)
    if d then
        debugoverlay.Cross(v, s, t, sv and csv or ccl, z)
    else
        BroadcastLua(dpoint:format(v.x, v.y, v.z, tostring(z)))
    end
end

function DSText(u, v, x, sv)
    v = tostring(v)
    if d then
        debugoverlay.ScreenText(u, v, x, t, sv and csv or ccl)
    else
        BroadcastLua(dstext:format(u, v, x))
    end
end

function DSphere(v, r, z, sv)
    z = Either(z ~= nil, z, igz)
    if d then
        debugoverlay.Sphere(v, r, t, sv and csv or ccl, z)
    else
        BroadcastLua(dsphere:format(v.x, v.y, v.z, r, tostring(z)))
    end
end

function DVector(v, n, z, sv)
    z = Either(z ~= nil, z, igz)
    if d then
        debugoverlay.Line(v, v + n, t, sv and csv or ccl, z)
    else
        BroadcastLua(dvector:format(v.x, v.y, v.z, n.x, n.y, n.z, tostring(z)))
    end
end

function DPoly(v, z, sv)
    z = Either(z ~= nil, z, g)
    if d then
        local n = #v
        for k = 1, n do
            local a, b = v[k], v[k % n + 1]
            DLine(a, b, z, sv)
        end
    else
        net.Start "greatzenkakuman.debug.DPoly"
        net.WriteTable(v)
        net.WriteBool(z)
        net.Broadcast()
    end
end

function DBox(a, b, sv)
    if d then
        local c = sv and csv or ccl
        debugoverlay.Box(vector_origin, a, b, t, ColorAlpha(c, math.min(c.a, 64)))
    else
        BroadcastLua(dbox:format(a.x, a.y, a.z, b.x, b.y, b.z))
    end
end

function DSBox(a, b, x, y, o, sv)
    o = o or angle_zero
    if d then
        debugoverlay.SweptBox(x, y, a, b, o, t, sv and csv or ccl)
    else
        BroadcastLua(dsbox:format(a.x, a.y, a.z, b.x, b.y, b.z, x.x, x.y, x.z, y.x, y.y, y.z, o.p, o.y, o.r))
    end
end

function DABox(v, a, b, o, sv)
    o = o or angle_zero
    if d then
        local c = sv and csv or ccl
        debugoverlay.BoxAngles(v, a, b, o, t, ColorAlpha(c, math.min(c.a, 64)))
    else
        BroadcastLua(dabox:format(v.x, v.y, v.z, a.x, a.y, a.z, b.x, b.y, b.z, o.p, o.y, o.r))
    end
end

function DTrace(v, z, sv)
    if v.mins and v.maxs then
        DSBox(v.mins, v.maxs, v.start, v.endpos, nil, SERVER)
    else
        z = Either(z ~= nil, z, igz)
        DLine(v.StartPos or v.start, v.HitPos or v.endpos, z)
    end
end

hook.Add("Think", "greatzenkakuman.debug.DLoop", function()
    sp = game.SinglePlayer()
    d = sp or CLIENT
    if isfunction(DLoop) then DLoop() end
end)
