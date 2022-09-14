
-- Clientside ink manager

local ss = SplatoonSWEPs
if not ss then return end
local CVarWireframe = GetConVar "mat_wireframe"
local CVarMinecraft = GetConVar "mat_showlowresimage"
local inkhdrscale = ss.vector_one * 0.5^2.2
local inkmaterials = {}
local rt = ss.RenderTarget
local MAX_QUEUE_TIME = ss.FrameToSec / 4
local MAX_QUEUES_TOLERANCE = 5 -- Possible number of queues to be processed at once without losing FPS.
for i = 1, 14 do
    inkmaterials[i] = {}
    for j = 1, 4 do
        inkmaterials[i][j] = Material(string.format("splatoonsweps/inkshot/%d/%d.vmt", i, j))
    end
end

local function LightmapSample(pos, normal)
    local p = pos + normal * 0.5
    local c = render.ComputeLighting(p, normal)
    - render.ComputeDynamicLighting(p, normal)
    local gamma_recip = 1 / 2.2
    c.x = c.x ^ gamma_recip
    c.y = c.y ^ gamma_recip
    c.z = c.z ^ gamma_recip
    return c:ToColor()
end

local function DrawMeshes(bDrawingDepth, bDrawingSkybox)
    if ss.GetOption "hideink" then return end
    if not rt.Ready or bDrawingSkybox or CVarWireframe:GetBool() or CVarMinecraft:GetBool() then return end
    local hdrscale = render.GetToneMappingScaleLinear()
    render.SetToneMappingScaleLinear(inkhdrscale) -- Set HDR scale for custom lightmap
    render.SetMaterial(rt.Material) -- Ink base texture
    render.SetLightmapTexture(rt.Lightmap) -- Set custom lightmap
    render.OverrideDepthEnable(true, true) -- Write to depth buffer for translucent surface culling
    for _, m in ipairs(ss.IMesh) do m:Draw() end -- Draw ink surface
    render.OverrideDepthEnable(false) -- Back to default
    render.SetToneMappingScaleLinear(hdrscale) -- Back to default

    if not LocalPlayer():FlashlightIsOn() and #ents.FindByClass "*projectedtexture*" == 0 then return end
    render.PushFlashlightMode(true) -- Ink lit by player's flashlight or projected texture
    render.SetMaterial(rt.Material) -- Ink base texture
    for _, m in ipairs(ss.IMesh) do m:Draw() end -- Draw once again
    render.PopFlashlightMode() -- Back to default
end

function ss.ReceiveInkQueue(index, radius, ang, ratio, color, inktype, pos, order, tick)
    if color == 0 or inktype == 0 then return end
    local s = ss.SurfaceArray[index]
    local angle = Angle(s.Angles)
    if s.Moved then angle:RotateAroundAxis(s.Normal, -90) end
    local pos2d = ss.To2D(pos, s.Origin, angle) * ss.UnitsToPixels
    local b = s.Bound * ss.UnitsToPixels
    local bound_offset = Vector(0, b.x, 0)
    if s.Moved then
        b.x, b.y = b.y, b.x
        pos2d = bound_offset - pos2d
    end

    local start = Vector(s.u, s.v) * ss.UVToPixels
    local center = Vector(math.Round(pos2d.x + start.x), math.Round(pos2d.y + start.y))
    local endpos = Vector(math.ceil(start.x + b.x) + 1, math.ceil(start.y + b.y) + 1)
    start = Vector(math.floor(start.x) - 1, math.floor(start.y) - 1)
    local r = radius * ss.UnitsToPixels
    local vr = ss.vector_one * r
    if not ss.CollisionAABB2D(start, endpos, center - vr, center + vr) then return end
    local lightmapoffset = r / 2
    ss.PaintQueue[tick * 512 + order + 256] = {
        angle = ang,
        center = center,
        color = ss.GetColor(color),
        colorid = color,
        done = 0,
        endpos = endpos,
        height = 2 * r,
        lightmapradius = r,
        lightmapx = center.x - lightmapoffset,
        lightmapy = center.y - lightmapoffset,
        pos = pos,
        radius = radius,
        ratio = ratio,
        start = start,
        surf = s,
        t = inktype,
        width = 2 * r * ratio,
    }
end

local function ProcessPaintQueue()
    while not rt.Ready do coroutine.yield() end
    local NumRepetition = 4
    local Painted = 0
    local BaseTexture = rt.BaseTexture
    local Lightmap = rt.Lightmap
    local ceil = math.ceil
    local Clamp = math.Clamp
    local Lerp = Lerp
    local PaintQueue = ss.PaintQueue
    local SortedPairs = SortedPairs
    local yield = coroutine.yield

    local Start2D = cam.Start2D
    local End2D = cam.End2D
    local OverrideBlend = render.OverrideBlend
    local PushRenderTarget = render.PushRenderTarget
    local PopRenderTarget = render.PopRenderTarget
    local SetScissorRect = render.SetScissorRect
    local DrawTexturedRectRotated = surface.DrawTexturedRectRotated
    local SetDrawColor = surface.SetDrawColor
    local SetMaterial = surface.SetMaterial
    while true do
        NumRepetition = ceil(Lerp(Painted / MAX_QUEUES_TOLERANCE, 4, 0))
        for order, q in SortedPairs(PaintQueue) do
            local alpha = Clamp(NumRepetition - q.done, 1, 4)
            if q.t > 12 then alpha = 1 end
            local inkmaterial = inkmaterials[q.t][alpha]

            PushRenderTarget(BaseTexture)
            Start2D()
            SetDrawColor(q.color)
            SetMaterial(inkmaterial)
            SetScissorRect(q.start.x, q.start.y, q.endpos.x, q.endpos.y, true)
            OverrideBlend(true, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
            DrawTexturedRectRotated(q.center.x, q.center.y, q.width, q.height, q.angle)
            OverrideBlend(false)
            SetScissorRect(0, 0, 0, 0, false)
            End2D()
            PopRenderTarget()

            -- Draw on lightmap
            PushRenderTarget(Lightmap)
            SetScissorRect(q.start.x, q.start.y, q.endpos.x, q.endpos.y, true)
            Start2D()
            SetDrawColor(LightmapSample(q.pos, q.surf.Normal))
            OverrideBlend(true, BLEND_ONE_MINUS_DST_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
            DrawTexturedRectRotated(q.center.x, q.center.y, q.width + 2, q.height + 2, q.angle)
            OverrideBlend(false)
            End2D()
            SetScissorRect(0, 0, 0, 0, false)
            PopRenderTarget()

            q.done = q.done + 1
            Painted = Painted + 1
            if q.done > NumRepetition then
                ss.AddInkRectangle(q.colorid, q.t, q.angle, q.pos, q.radius, q.ratio, q.surf)
                PaintQueue[order] = nil
            end

            -- if ss.Debug then ss.Debug.ShowInkDrawn(q.start, q.center, q.endpos, q.surf, q, q.surf.Moved) end
        end

        Painted = 0
        yield()
    end
end

local process = coroutine.create(ProcessPaintQueue)
function ss.ClearAllInk()
    table.Empty(ss.InkQueue)
    table.Empty(ss.PaintSchedule)
    if rt.Ready then table.Empty(ss.PaintQueue) end
    for _, s in ipairs(ss.SurfaceArray) do table.Empty(s.InkColorGrid) end
    local amb = ss.AmbientColor
    if not amb then
        amb = render.GetAmbientLightColor():ToColor()
        ss.AmbientColor = amb
    end

    render.PushRenderTarget(rt.BaseTexture)
    render.OverrideAlphaWriteEnable(true, true)
    render.ClearDepth()
    render.ClearStencil()
    render.Clear(0, 0, 0, 0)
    render.OverrideAlphaWriteEnable(false)
    render.PopRenderTarget()

    render.PushRenderTarget(rt.Lightmap)
    render.OverrideAlphaWriteEnable(true, true)
    render.ClearDepth()
    render.ClearStencil()
    render.Clear(amb.r, amb.g, amb.b, 0)
    render.OverrideAlphaWriteEnable(false)
    render.PopRenderTarget()
end

hook.Add("Tick", "SplatoonSWEPs: Register ink clientside", function()
    if coroutine.status(process) == "dead" then return end
    local ok, msg = coroutine.resume(process)
    if not ok then ErrorNoHalt(msg) end
end)

hook.Add("PreDrawTranslucentRenderables", "SplatoonSWEPs: Draw ink", DrawMeshes)
