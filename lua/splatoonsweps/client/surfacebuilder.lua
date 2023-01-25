
local ss = SplatoonSWEPs
if not ss then return end

-- local IMAGE_FORMAT_BGRA5551 = 21
-- local IMAGE_FORMAT_BGRA4444 = 19
local rt = ss.RenderTarget
local MAX_TRIANGLES = math.floor(32768 / 3) -- mesh library limitation
local INK_SURFACE_DELTA_NORMAL = .8 -- Distance between map surface and ink mesh
if ss.SplatoonMapPorts[game.GetMap()] then INK_SURFACE_DELTA_NORMAL = 2 end
function ss.BuildInkMesh()
    local rects = {}
    local NumMeshTriangles = 0
    for i, surf in ipairs(ss.SurfaceArray) do
        rects[i] = ss.MakeRectangle(surf.Boundary2D.x + 1, surf.Boundary2D.y + 1, 0, 0, surf)
        NumMeshTriangles = NumMeshTriangles + #surf.Triangles
    end

    local packer = ss.MakeRectanglePacker(rects)
    packer:packall()

    local RT_MARGIN_PIXELS = 4
    local rtSize = rt.BaseTexture:Width()
    local margin = packer.maxsize / rtSize * RT_MARGIN_PIXELS
    for i, surf in ipairs(ss.SurfaceArray) do
        rects[i] = ss.MakeRectangle(surf.Boundary2D.x + margin, surf.Boundary2D.y + margin, 0, 0, surf)
    end

    packer = ss.MakeRectanglePacker(rects)
    packer:packall()

    local rectSizeHU = packer.maxsize -- Size of generated rectangle in Hammer Units
    local unitsPerPixel = rectSizeHU / rtSize
    ss.PixelsToUnits = unitsPerPixel
    ss.UVToUnits = rectSizeHU
    ss.UVToPixels = rtSize
    ss.UnitsToPixels = 1 / ss.PixelsToUnits
    ss.UnitsToUV = 1 / ss.UVToUnits
    ss.PixelsToUV = 1 / ss.UVToPixels
    print("SplatoonSWEPs: Total mesh triangles = ", NumMeshTriangles)

    local meshindex = 1
    for _ = 1, math.ceil(NumMeshTriangles / MAX_TRIANGLES) do
        ss.IMesh[#ss.IMesh + 1] = Mesh(rt.Material)
    end

    -- Building MeshVertex
    if #ss.IMesh == 0 then return end
    mesh.Begin(ss.IMesh[meshindex], MATERIAL_TRIANGLES, math.min(NumMeshTriangles, MAX_TRIANGLES))
    local function ContinueMesh()
        if mesh.VertexCount() < MAX_TRIANGLES * 3 then return end
        mesh.End()
        mesh.Begin(ss.IMesh[meshindex + 1], MATERIAL_TRIANGLES,
        math.min(NumMeshTriangles - MAX_TRIANGLES * meshindex, MAX_TRIANGLES))
        meshindex = meshindex + 1
    end

    for _, index in ipairs(packer.dones) do
        local r = packer.rects[index]
        local surf = r.tag
        local v3 = surf.Vertices3D
        local textureUV = surf.Vertices2D
        local lightmapUV = {}
        surf.OffsetUV = ss.PixelsToUV * Vector(
            math.Round(r.left * ss.UnitsToPixels),
            math.Round(r.bottom * ss.UnitsToPixels))
        surf.BoundaryUV = ss.PixelsToUV * Vector(
            math.Round((r.width - margin) * ss.UnitsToPixels),
            math.Round((r.height - margin) * ss.UnitsToPixels))
        surf.AnglesUV = Angle(surf.Angles)
        surf.OriginUV = Vector(surf.Origin)
        if r.istall then
            surf.AnglesUV.roll = surf.AnglesUV.roll + 90
            surf.OriginUV:Sub(surf.AnglesUV:Up() * (r.height - margin))
        end

        for i in ipairs(textureUV) do
            if r.istall then
                textureUV[i].x, textureUV[i].y = textureUV[i].y, r.height - margin - textureUV[i].x
            end

            textureUV[i]:Mul(ss.UnitsToUV)
            textureUV[i]:Add(surf.OffsetUV)

            lightmapUV[i] = Vector(textureUV[i])
            if surf.IsDisplacement then
                local sideLength = math.sqrt(#textureUV)
                local divisor = sideLength - 1
                lightmapUV[i].x =            (i - 1) % sideLength  / divisor
                lightmapUV[i].y = math.floor((i - 1) / sideLength) / divisor
                lightmapUV[i]:Mul(surf.BoundaryUV)
                lightmapUV[i]:Add(surf.OffsetUV)
            end
        end

        for _, t in ipairs(surf.Triangles) do
            local n = (v3[t[1]] - v3[t[2]]):Cross(v3[t[3]] - v3[t[2]]):GetNormalized()
            for _, i in ipairs(t) do
                mesh.Normal(n)
                mesh.Position(v3[i] + n * INK_SURFACE_DELTA_NORMAL)
                mesh.TexCoord(0, textureUV[i].x, textureUV[i].y)
                mesh.TexCoord(1, lightmapUV[i].x, lightmapUV[i].y)
                mesh.AdvanceVertex()
            end

            ContinueMesh()
        end

        surf.Triangles, surf.Vertices3D, surf.Vertices2D = nil
    end
    mesh.End()
end

function ss.BuildWaterMesh()
    local NumMeshTriangles, meshindex = 0, 1
    for _, surf in ipairs(ss.WaterSurfaces) do
        NumMeshTriangles = NumMeshTriangles + #surf.Vertices3D - 2
    end
    for _ = 1, math.ceil(NumMeshTriangles / MAX_TRIANGLES) do
        ss.WaterMesh[#ss.WaterMesh + 1] = Mesh(ss.GetWaterMaterial())
    end

    if #ss.WaterMesh == 0 then return end
    mesh.Begin(ss.WaterMesh[meshindex], MATERIAL_TRIANGLES, math.min(NumMeshTriangles, MAX_TRIANGLES))
    local function ContinueMesh()
        if mesh.VertexCount() < MAX_TRIANGLES * 3 then return end
        mesh.End()
        mesh.Begin(ss.WaterMesh[meshindex + 1], MATERIAL_TRIANGLES,
        math.min(NumMeshTriangles - MAX_TRIANGLES * meshindex, MAX_TRIANGLES))
        meshindex = meshindex + 1
    end

    for _, surf in ipairs(ss.WaterSurfaces) do
        for _, t in ipairs(surf.Triangles) do
            local v3 = surf.Vertices3D
            local n = (v3[t[1]] - v3[t[2]]):Cross(v3[t[3]] - v3[t[2]]):GetNormalized()
            for _, i in ipairs(t) do
                mesh.Normal(n)
                mesh.Position(v3[i] + n * INK_SURFACE_DELTA_NORMAL)
                mesh.TexCoord(0, v3[i].x, v3[i].y)
                mesh.TexCoord(1, v3[i].x, v3[i].y)
                mesh.AdvanceVertex()
            end

            ContinueMesh()
        end
    end
    mesh.End()

    ss.WaterSurfaces = nil
end

function ss.PrecacheLightmap()
    local dhtml  = rt.DHTML
    local rtsize = rt.Lightmap:Width()
    local url    = "asset://garrysmod/lua/splatoonsweps/html/lightmap_html.lua?c=%d&r=%d&g=%d&b=%d&s=%d&u=%16.8f"
    local lpath  = string.format("splatoonsweps/%s_lightmap%d%%d.png",
        game.GetMap(), rt.SizeFromPixels[rtsize] or ss.GetOption "rtresolution")
    local mpath  = "../data/" .. lpath
    local mats = {
        file.Exists(lpath.format(1), "DATA") and Material(mpath:format(1)),
        file.Exists(lpath.format(2), "DATA") and Material(mpath:format(2)),
        file.Exists(lpath.format(3), "DATA") and Material(mpath:format(3)),
        file.Exists(lpath.format(4), "DATA") and Material(mpath:format(4)),
    }
    local function exist()
        for i = 1, 4 do
            if not mats[i] then
                if not file.Exists(lpath:format(i), "DATA") then return false end
                mats[i] = Material(mpath:format(i))
            else
                mats[i]:GetTexture "$basetexture":Download()
            end
            if mats[i]:IsError() then return false end
        end
        return true
    end
    local function pastePNG()
        if not exist() then return end
        local w, h = rt.Lightmap:Width() / 2, rt.Lightmap:Height() / 2
        local x, y = { 0, w, 0, w }, { 0, 0, h, h }
        render.PushRenderTarget(rt.Lightmap)
        render.OverrideAlphaWriteEnable(true, true)
        render.ClearDepth()
        render.ClearStencil()
        render.Clear(0, 0, 0, 0)
        render.OverrideAlphaWriteEnable(false)
        cam.Start2D()
        surface.SetDrawColor(color_white)
        for i, m in ipairs(mats) do
            surface.SetMaterial(m)
            surface.DrawTexturedRect(x[i], y[i], w, h)
        end
        cam.End2D()
        render.PopRenderTarget()
    end

    if exist() then
        return hook.Add("PostRender", "SplatoonSWEPs: Precache lightmap", function()
            hook.Remove("PostRender", "SplatoonSWEPs: Precache lightmap")
            pastePNG()
        end)
    end

    local units  = ss.UnitsToPixels
    local amb    = render.GetAmbientLightColor():ToColor()
    local surf   = util.TableToJSON(ss.SurfaceArray)
    local path   = string.format("maps/%s.bsp", game.GetMap())
    local bsp    = file.Open(path, "rb", "GAME")
    local header = ss.ReadHeader(bsp).lumps[ss.LookupLump "LIGHTING"]
    bsp:Seek(header.fileOffset)
    local samples = util.Base64Encode(bsp:Read(header.fileLength) or "", true)
    bsp:Close()

    dhtml:OpenURL(url:format(ss.GetOption "numthreads", amb.r, amb.g, amb.b, rtsize, units))
    dhtml:AddFunction("ss", "storeNumThreads", function(cores) ss.SetOption("numthreads", cores) end)
    dhtml:AddFunction("ss", "paste", pastePNG)
    dhtml:AddFunction("ss", "save", (function()
        local called = 0
        return function(dataurl, index)
            file.Write(lpath:format(index), util.Base64Decode(dataurl:sub(23)))
            called = called + 1
            if called == 4 then dhtml:Call "if (!useAlt) render();" end
            return true
        end
    end)())
    dhtml:AddFunction("ss", "render", function(x, y)
        dhtml:UpdateHTMLTexture()
        local mat = dhtml:GetHTMLMaterial()
        if not mat then return true end
        local mul = rt.Lightmap:Width() / rtsize
        render.PushRenderTarget(rt.Lightmap)
        cam.Start2D()
        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x * mul, y * mul, mat:Width() * mul, mat:Height() * mul)
        cam.End2D()
        render.PopRenderTarget()
        return true
    end)

    function dhtml:OnFinishLoadingDocument()
        timer.Simple(0.5, function()
            dhtml:Call(string.format([[main(%s, "%s");]], surf, samples))
        end)
    end
end

function ss.PrepareInkSurface(data)
    util.TimerCycle()
    ss.MinimapAreaBounds = ss.DesanitizeJSONLimit(data.MinimapAreaBounds)
    ss.SurfaceArray = ss.DesanitizeJSONLimit(data.SurfaceArray)
    ss.WaterSurfaces = ss.DesanitizeJSONLimit(data.WaterSurfaces)
    ss.SURFACE_ID_BITS = select(2, math.frexp(#ss.SurfaceArray))
    ss.GenerateHashTable()
    ss.BuildInkMesh()
    ss.BuildWaterMesh()
    ss.PrecacheLightmap()
    ss.ClearAllInk()
    ss.InitializeMoveEmulation(LocalPlayer())
    net.Start "SplatoonSWEPs: Ready to splat"
    net.WriteString(LocalPlayer():SteamID64() or "")
    net.SendToServer()
    ss.WeaponRecord[LocalPlayer()] = util.JSONToTable(
    util.Decompress(file.Read "splatoonsweps/record/stats.txt" or "") or "") or {
        Duration = {},
        Inked = {},
        Recent = {},
    }

    rt.Ready = true
    collectgarbage "collect"
    print("MAKE", util.TimerCycle())
end
