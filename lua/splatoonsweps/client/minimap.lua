
local ss = SplatoonSWEPs
if not ss then return end

local toggle = false
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
    local mins, maxs = bb.mins, bb.maxs
    local bbsize = maxs - mins
    local org = Vector(mins.x, mins.y, maxs.z + 1)
    local props = vgui.Create("DProperties")
    local frame = vgui.Create("DFrame")
    local panel = vgui.Create("DButton", frame)
    props:Dock(FILL)
    frame:SetSizable(true)
    frame:SetSize(ScrH() * 0.6, ScrH() * 0.85)
    frame:SetPos(10, 10)
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
        -- bottom = bottom - height * 0.5 * cos(rad(currentAngle.pitch))
        -- height = bottom - top
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

        return {
            left   = left,
            right  = right,
            top    = top,
            bottom = bottom,
        }
    end

    local function DrawMap(x, y, w, h, ortho)
        ss.IsDrawingMinimap = true
        render.PushCustomClipPlane(Vector( 0,  0, -1), -maxs.z - 0.5)
        render.PushCustomClipPlane(Vector( 0,  0,  1),  mins.z - 0.5)
        render.PushCustomClipPlane(Vector(-1,  0,  0), -maxs.x - 0.5)
        render.PushCustomClipPlane(Vector( 1,  0,  0),  mins.x - 0.5)
        render.PushCustomClipPlane(Vector( 0, -1,  0), -maxs.y - 0.5)
        render.PushCustomClipPlane(Vector( 0,  1,  0),  mins.y - 0.5)
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

    local keydown = input.IsKeyDown(KEY_LSHIFT)
    function panel:Think()
        local k = input.IsKeyDown(KEY_LSHIFT)
        if Either(toggle, not keydown and k, not k) then frame:Close() end
        keydown = k
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
            end
        end
    end

    function panel:Paint(w, h)
        local x, y = self:LocalToScreen(0, 0)
        local ortho = GetOrthoPos(w, h)
        UpdateCameraAngles()
        DrawMap(x, y, w, h, ortho)
        DrawBeakons(w, h, ortho)
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
