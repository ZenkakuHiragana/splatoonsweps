
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

    local packer = ss.MakeRectanglePacker(rects):packall()
    local RT_MARGIN_PIXELS = 4
    local rtSize = rt.BaseTexture:Width()
    local margin = packer.maxsize / rtSize * RT_MARGIN_PIXELS
    for i, surf in ipairs(ss.SurfaceArray) do
        rects[i] = ss.MakeRectangle(surf.Boundary2D.x + margin, surf.Boundary2D.y + margin, 0, 0, surf)
    end

    packer = ss.MakeRectanglePacker(rects):packall()

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

    for _, index in ipairs(packer.results) do
        local r = packer.rects[index]
        local surf = r.tag
        local v3 = surf.Vertices3D
        local textureUV = surf.Vertices2D
        local lightmapUV = surf.LightmapInfo.Vertices2D
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
        end

        for _, t in ipairs(surf.Triangles) do
            local n = (v3[t[1]] - v3[t[2]]):Cross(v3[t[3]] - v3[t[2]]):GetNormalized()
            for _, i in ipairs(t) do
                mesh.Normal(n)
                mesh.Position(v3[i] + n * INK_SURFACE_DELTA_NORMAL)
                mesh.TexCoord(0, textureUV[i].x, textureUV[i].y)
                if #lightmapUV > 0 then
                    mesh.TexCoord(1, lightmapUV[i].x, lightmapUV[i].y)
                end
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

function ss.PrepareInkSurface(data)
    util.TimerCycle()

    ss.Lightmap = data.Lightmap
    ss.MinimapAreaBounds = ss.DesanitizeJSONLimit(data.MinimapAreaBounds)
    ss.SurfaceArray = ss.DesanitizeJSONLimit(data.SurfaceArray)
    ss.WaterSurfaces = ss.DesanitizeJSONLimit(data.WaterSurfaces)
    ss.SURFACE_ID_BITS = select(2, math.frexp(#ss.SurfaceArray))

    file.Write("splatoonsweps/lightmap.png", ss.Lightmap.png)
    local lightmap = Material("../data/splatoonsweps/lightmap.png", "smooth")
    if not lightmap:IsError() then
        rt.Lightmap = lightmap:GetTexture "$basetexture"
    end
    if rt.Lightmap and render.GetHDREnabled() then -- If HDR lighting computation has been done
        local intensity = 128
        if ss.Lightmap.lightColor then -- If there is light_environment
            local lightIntensity = Vector(unpack(ss.Lightmap.lightColor)):Dot(ss.GrayScaleFactor) / 255
            local brightness = ss.Lightmap.lightColor[4] or 0
            local scale = ss.Lightmap.lightScaleHDR or 1
            intensity = intensity + lightIntensity * brightness * scale
        end
        rt.Material:SetVector("$color", ss.vector_one * intensity / 4096)
    end

    ss.GenerateHashTable()
    ss.BuildInkMesh()
    ss.BuildWaterMesh()
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
