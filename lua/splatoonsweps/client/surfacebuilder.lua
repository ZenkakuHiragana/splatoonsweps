
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
        ss.IMesh[#ss.IMesh + 1] = Mesh(ss.RenderTarget.Material)
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
end

function ss.PrecacheLightmap()
    local path = string.format("maps/%s.bsp", game.GetMap())
    local bsp = file.Open(path, "rb", "GAME")
    if not bsp then return end

    local header = ss.ReadHeader(bsp)
    local lightmapSamples = util.TableToJSON(ss.ReadLump(bsp, header.lumps, "LIGHTING"))
    bsp:Close()

    local surfaceArray = util.TableToJSON(ss.SurfaceArray)
    local dhtml = ss.RenderTarget.DHTML
    local basetexture = ss.RenderTarget.BaseTexture
    dhtml:AddFunction("ss", "end", function()
        timer.Simple(2, function() dhtml:UpdateHTMLTexture() end)
    end)
    function dhtml:OnFinishLoadingDocument(url)
        dhtml:QueueJavascript(([[
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            (function (surfaceArray, samples, unitsToPixels) {
                surfaceArray.forEach(function(surf) {
                    const li = surf.LightmapInfo;
                    if (!li.Available) return;

                    const basisS = toMatrix(li.BasisS);
                    const basisT = toMatrix(li.BasisT);
                    const basisN = math.cross(basisS, basisT);
                    const lightmapOffset = math.subtract(toMatrix(li.MinsInLuxels), toMatrix(li.Offset));
                    const lightmapToWorld = math.inv(math.matrixFromRows(basisS, basisT, basisN));
                    const lightmapBasisS = math.squeeze(math.column(lightmapToWorld, 0));
                    const lightmapBasisT = math.squeeze(math.column(lightmapToWorld, 1));
                    const lightmapNormal = math.squeeze(math.column(lightmapToWorld, 2));
                    const lightmapOriginWorld = surf.IsDisplacement ? toMatrix(li.DispOrigin) : math.multiply(lightmapToWorld, lightmapOffset);

                    const anglesUV = toMatrix(surf.AnglesUV);
                    const uvStart = math.multiply(toMatrix(surf.OffsetUV), canvas.width);
                    const uvBound = math.multiply(toMatrix(surf.BoundaryUV), canvas.width);
                    const renderBasisU = math.squeeze(math.column(anglesUV, 1)); // Right
                    const renderBasisV = math.squeeze(math.column(anglesUV, 2)); // Up
                    const renderOrigin = toMatrix(surf.OriginUV);

                    const worldToUV = math.inv(math.matrixFromColumns(renderBasisU, renderBasisV, lightmapNormal));
                    const worldToUVOffset = math.unaryMinus(math.multiply(worldToUV, renderOrigin, unitsToPixels));
                    const uvStartClip = math.subtract(math.round(uvStart), math.matrix([1, 1, 0]));
                    const uvBoundClip = math.add(math.round(uvBound), math.matrix([2, 2, 0]));

                    const lightmapSizeInLuxels = toMatrix(li.SizeInLuxels);
                    const w = lightmapSizeInLuxels.get([0]) + 1;
                    const h = lightmapSizeInLuxels.get([1]) + 1;
                    const sizeOffset = surf.IsDisplacement ? 1 : 0;
                    const pixelBasisS = surf.IsDisplacement ? math.matrix([uvBound.get([0]) / w, 0]) : math.multiply(worldToUV, lightmapBasisS, unitsToPixels);
                    const pixelBasisT = surf.IsDisplacement ? math.matrix([0, uvBound.get([1]) / h]) : math.multiply(worldToUV, lightmapBasisT, unitsToPixels);
                    const lightmapOrigin = surf.IsDisplacement ? uvStart : math.add(worldToUVOffset, uvStart, math.multiply(worldToUV, lightmapOriginWorld, unitsToPixels));
                    const sampleOffset = toMatrix(li.SampleOffset) / 4;
                    const image = ctx.createImageData(w, h);
                    writeLightmap(image, w, h, sampleOffset, samples);
                    renderer.width = image.width;
                    renderer.height = image.height;
                    renderer.getContext("2d").putImageData(image, 0, 0);
                    ctx.save();
                    ctx.beginPath();
                    ctx.rect(uvStartClip.get([0]), uvStartClip.get([1]), uvBoundClip.get([0]), uvBoundClip.get([1]));
                    ctx.clip();
                    ctx.transform(
                        pixelBasisS.get([0]), pixelBasisS.get([1]),
                        pixelBasisT.get([0]), pixelBasisT.get([1]),
                        lightmapOrigin.get([0]), lightmapOrigin.get([1]));
                    ctx.imageSmoothingEnabled = true;
                    ctx.drawImage(renderer, -0.5, -0.5, w + sizeOffset, h + sizeOffset);
                    ctx.restore();
                });
                ss.end();
            })(%s, %s, %16.8f);
        ]]):format(surfaceArray, lightmapSamples, ss.UnitsToPixels * dhtml:GetWide() / basetexture:Width()))
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

    ss.RenderTarget.Ready = true
    collectgarbage "collect"
    print("MAKE", util.TimerCycle())
end
