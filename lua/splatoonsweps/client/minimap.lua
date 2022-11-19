
local ss = SplatoonSWEPs
if not ss then return end

local cos, sin, rad = math.cos, math.sin, math.rad
function ss.OpenMiniMap()
    local bb = ss.GetMinimapAreaBounds(LocalPlayer():WorldSpaceCenter())
    if not bb then return end
    local inclined = true
    local inclinedYaw = 30
    local inclinedPitch = 30
    local angleRate = 90
    local upAngle = Angle(90, 0, 0)
    local inclinedAngle = Angle(90 - inclinedPitch, inclinedYaw, 0)
    local desiredAngle = Angle(inclinedAngle)
    local currentAngle = Angle(desiredAngle)
    local bbmins, bbmaxs, bbsize = bb.mins, bb.maxs, bb.maxs - bb.mins
    local org = Vector(bbmins.x, bbmins.y, bbmaxs.z + 1)
    local mul = bbsize:Length2D() / 1000
    local mx,  my  = 0, 0 -- Mouse position stored on right click
    local dx2, dy2 = 0, 0 -- Panning backup
    local dx,  dy  = 0, 0 -- Panning
    local zoom, zoommul = 0, mul * 10
    local maxzoom = bbsize:Length() -- FIXME: Find the correct maximum zoom

    -- Minimap window margin taken from spawnmenu.lua
    local spawnmenu_border = GetConVar "spawnmenu_border"
    local border = spawnmenu_border and spawnmenu_border:GetFloat() or 0.1
    local windowMarginX = math.Clamp((ScrW() - 1024) * border, 25, 256 )
    local windowMarginY = math.Clamp((ScrH() - 768) * border, 25, 256 )
    if ScrW() < 1024 or ScrH() < 768 then
        windowMarginX = 0
        windowMarginY = 0
    end

    local frame = vgui.Create("DFrame")
    local panel = vgui.Create("DButton", frame)
    frame:SetSizable(true)
    frame:DockMargin(windowMarginX, windowMarginY, windowMarginX, windowMarginY)
    frame:Dock(FILL)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    frame:SetMouseInputEnabled(true)
    frame:SetTitle("Splatoon SWEPs: Minimap")
    panel:Dock(FILL)
    panel:SetText("")

    local function UpdateCameraAngles()
        currentAngle.yaw = math.ApproachAngle(
            currentAngle.yaw, desiredAngle.yaw, angleRate * RealFrameTime())
        currentAngle.pitch = math.ApproachAngle(
            currentAngle.pitch, desiredAngle.pitch, angleRate * RealFrameTime())
    end

    local function GetOrthoPos(w, h)
        local left   = -bbsize.y * cos(rad(currentAngle.yaw))
        local right  =  bbsize.x * sin(rad(currentAngle.yaw))
        local top    = -bbsize.z * cos(rad(currentAngle.pitch))
        local bottom =  bbsize.x * cos(rad(currentAngle.yaw))
                     +  bbsize.y * sin(rad(currentAngle.yaw))
                     +  bbsize.z * cos(rad(currentAngle.pitch))
        local width  = right - left
        local height = bottom - top
        local aspectratio = w / h
        bottom = bottom - height * 0.5 * cos(rad(currentAngle.pitch))
        height = bottom - top
        local addMarginAxisY = aspectratio < (width / height)
        if addMarginAxisY then
            local diff = width / aspectratio - height
            local margin = diff / 2
            top = top - margin
            bottom = bottom + margin
        else
            local diff = height * aspectratio - width
            local margin = diff / 2
            left = left - margin
            right = right + margin
        end

        left, right = left - dx, right - dx
        top, bottom = top + dy, bottom + dy

        return {
            left   = left   + zoom * zoommul * aspectratio,
            right  = right  - zoom * zoommul * aspectratio,
            top    = top    + zoom * zoommul,
            bottom = bottom - zoom * zoommul,
        }
    end

    local function DrawMap(x, y, w, h, ortho)
        ss.IsDrawingMinimap = true
        render.PushCustomClipPlane(Vector( 0,  0, -1), -bbmaxs.z - 0.5)
        render.PushCustomClipPlane(Vector( 0,  0,  1),  bbmins.z - 0.5)
        render.PushCustomClipPlane(Vector(-1,  0,  0), -bbmaxs.x - 0.5)
        render.PushCustomClipPlane(Vector( 1,  0,  0),  bbmins.x - 0.5)
        render.PushCustomClipPlane(Vector( 0, -1,  0), -bbmaxs.y - 0.5)
        render.PushCustomClipPlane(Vector( 0,  1,  0),  bbmins.y - 0.5)
        render.RenderView {
            drawviewmodel = false,
            origin = org,
            angles = currentAngle,
            x = x, y = y,
            w = w, h = h,
            ortho = ortho,
            znear = 1,
            zfar = 56756,
        }
        render.PopCustomClipPlane()
        render.PopCustomClipPlane()
        render.PopCustomClipPlane()
        render.PopCustomClipPlane()
        render.PopCustomClipPlane()
        render.PopCustomClipPlane()
        ss.IsDrawingMinimap = false
    end

    local function TransformPosition(pos, w, h, ortho)
        local localpos = WorldToLocal(pos, angle_zero, org, currentAngle)
        local x = math.Remap(localpos.y, -ortho.right, -ortho.left,   w, 0)
        local y = math.Remap(localpos.z,  ortho.top,    ortho.bottom, h, 0)
        return x, y
    end

    local rgbmin = 64
    local beakonmat = Material("splatoonsweps/icons/beakon.png", "alphatest")
    local function DrawBeakons(w, h, ortho)
        local s = math.min(w, h) * 0.025 -- beakon icon size
        surface.SetMaterial(beakonmat)
        for _, b in ipairs(ents.FindByClass "ent_splatoonsweps_squidbeakon") do
            local pos = b:GetPos()
            local x, y = TransformPosition(pos, w, h, ortho)
            local c = b:GetInkColorProxy():ToColor()
            c.r = math.max(c.r, rgbmin)
            c.g = math.max(c.g, rgbmin)
            c.b = math.max(c.b, rgbmin)
            surface.SetDrawColor(c)
            surface.DrawTexturedRect(x - s / 2, y - s / 2, s, s)
            local t = CurTime() - b.MinimapEffectTime
            local f = math.TimeFraction(0, b.MinimapEffectDuration, t)
            local a = Lerp(f, 255, 64)
            surface.DrawCircle(x, y, s, c)
            surface.DrawCircle(x, y, Lerp(f, 0, s), ColorAlpha(c, a))
        end
    end

    local keydown = input.IsShiftDown()
    local mousedown = input.IsMouseDown(MOUSE_RIGHT)
    function panel:Think()
        local k = input.IsShiftDown()
        local m = input.IsMouseDown(MOUSE_RIGHT)
        local x, y = input.GetCursorPos()
        if not keydown and k then frame:Close() end
        keydown = k

        if not mousedown and m then
            mx,  my  = x, y
            dx2, dy2 = dx, dy
        elseif m then
            dx = dx2 + (x - mx) * mul
            dy = dy2 + (y - my) * mul
        end
        mousedown = m
    end

    function panel:DoDoubleClick()
        inclined = not inclined
        desiredAngle = inclined and inclinedAngle or upAngle
    end

    function panel:DoClick()
        local weapon = ss.IsValidInkling(LocalPlayer())
        if not weapon then return end
        local x, y = self:ScreenToLocal(input.GetCursorPos())
        local w, h = panel:GetSize()
        local ortho = GetOrthoPos(w, h)
        local pc = weapon:GetNWInt "inkcolor"
        local s = math.min(w, h) * 0.025 -- beakon icon size
        for _, b in ipairs(ents.FindByClass "ent_splatoonsweps_squidbeakon") do
            local c = b:GetNWInt "inkcolor"
            if c ~= pc then continue end
            local pos = b:WorldSpaceCenter()
            local bx, by = TransformPosition(pos, w, h, ortho)
            if math.Distance(x, y, bx, by) < s then
                ss.EnterSuperJumpState(LocalPlayer(), b)
                net.Start "SplatoonSWEPs: Super jump"
                net.WriteEntity(b)
                net.SendToServer()
                frame:Close()
                return
            end
        end
    end

    function panel:OnMouseWheeled(scrollDelta)
        zoom = math.min(zoom + scrollDelta, maxzoom)
    end

    function panel:Paint(w, h)
        local x, y = self:LocalToScreen(0, 0)
        local ortho = GetOrthoPos(w, h)
        UpdateCameraAngles()
        DrawMap(x, y, w, h, ortho)
        DrawBeakons(w, h, ortho)
    end

    ss.IsOpeningMinimap = true
    function frame:OnClose()
        timer.Simple(0, function()
            ss.IsOpeningMinimap = nil
        end)
    end
end

local WaterMaterial = Material "gm_construct/water_13_beneath"
hook.Add("PreDrawTranslucentRenderables", "SplatoonSWEPs: Draw water surfaces", function(bDrawingDepth, bDrawingSkybox)
    if not ss.IsDrawingMinimap then return end
    render.SetMaterial(WaterMaterial)
    for _, m in ipairs(ss.WaterMesh) do m:Draw() end
    render.OverrideDepthEnable(true, true)
    render.UpdateRefractTexture()
    render.SetMaterial(ss.GetWaterMaterial())
    for _, m in ipairs(ss.WaterMesh) do m:Draw() end
    render.OverrideDepthEnable(false)
end)

hook.Add("PreDrawSkyBox", "SplatoonSWEPs: Disable rendering skybox in a minimap", function()
    if ss.IsDrawingMinimap then return true end
end)
