
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

    local RT_MARGIN_PIXELS = 2
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
    local units  = ss.UnitsToPixels
    local dhtml  = rt.DHTML
    local rtsize = math.min(rt.BaseTexture:Width(), rt.Size[rt.RESOLUTION.DMEDIUM])
    local amb    = render.GetAmbientLightColor():ToColor()
    local surf   = util.TableToJSON(ss.SurfaceArray)
    local path   = string.format("maps/%s.bsp", game.GetMap())
    local bsp    = file.Open(path, "rb", "GAME")
    local header = ss.ReadHeader(bsp).lumps[ss.LookupLump "LIGHTING"]
    bsp:Seek(header.fileOffset)
    local samples = util.Base64Encode(bsp:Read(header.fileLength), true)
    bsp:Close()
    dhtml:AddFunction("ss", "render", function(x, y)
        dhtml:UpdateHTMLTexture()
        local mat = dhtml:GetHTMLMaterial()
        if not mat then return end
        local mul = rt.BaseTexture:Width() / rtsize
        render.PushRenderTarget(rt.Lightmap)
        cam.Start2D()
        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x * mul, y * mul, mat:Width() * mul, mat:Height() * mul)
        cam.End2D()
        render.PopRenderTarget()
    end)
    dhtml:SetHTML(string.format([[
        <style>* { margin: 0; padding: 0; background: rgb(%d, %d, %d); overflow: visible; } body { overflow: hidden; }</style>
        <canvas id="canvas" width="%d" height="%d"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjs/10.6.4/math.min.js"></script>
        <script>
            const canvas   = document.getElementById("canvas");
            const renderer = document.createElement("canvas");
            const ctx      = canvas.getContext("2d");
            const gamma    = 1 / 2.2;
            const unitsToPixels = %16.8f;
            function getRGB(r, g, b, e) {
                if (e > 127) e -= 256;
                const mul = Math.pow(2, e);
                const rMul = Math.min(255, Math.pow((r * mul) / 255, gamma) * 255);
                const gMul = Math.min(255, Math.pow((g * mul) / 255, gamma) * 255);
                const bMul = Math.min(255, Math.pow((b * mul) / 255, gamma) * 255);
                return math.matrix([rMul, gMul, bMul]);
            }
            function toMatrix(str) {
                if (typeof(str) !== "string") return str;
                const matrix = math.matrix(str.match(/[^ \[\]{}]+/g).map(Number));
                if (matrix == null) return Number(str);
                const isAngle = str.match("{.*?}");
                if (isAngle == null) return math.squeeze(matrix);
                const pitch = math.rotationMatrix(matrix.get([0]) * math.pi / 180, math.matrix([0, 1, 0]));
                const yaw   = math.rotationMatrix(matrix.get([1]) * math.pi / 180, math.matrix([0, 0, 1]));
                const roll  = math.rotationMatrix(matrix.get([2]) * math.pi / 180, math.matrix([1, 0, 0]));
                return math.multiply(yaw, pitch, roll);
            }
            function clamp(x, min, max) {
                return Math.min(Math.max(x, min), max);
            }
            function writeLightmap(image, w, h, sampleOffset, samples) {
                for (var t = -1; t < h + 1; ++t) {
                    for (var s = -1; s < w + 1; ++s) {
                        var i = (clamp(s, 0, w - 1) + clamp(t, 0, h - 1) * w) * 4 + sampleOffset;
                        var r = samples.charCodeAt(i + 0);
                        var g = samples.charCodeAt(i + 1);
                        var b = samples.charCodeAt(i + 2);
                        var e = samples.charCodeAt(i + 3);
                        var c = getRGB(r, g, b, e);
                        var j = ((s + 1) + (t + 1) * image.width) * 4;
                        image.data[j + 0] = Math.round(c.get([0]));
                        image.data[j + 1] = Math.round(c.get([1]));
                        image.data[j + 2] = Math.round(c.get([2]));
                        image.data[j + 3] = 255;
                    }
                }
            }
            function copyToRenderTarget(delay) {
                const dx = document.body.clientWidth;
                const dy = document.body.clientHeight;
                document.body.scrollLeft = 0;
                document.body.scrollTop = 0;
                delay = delay || 35;
                setTimeout(function() {
                    var x = 0;
                    var y = 0;
                    var refresh = true;
                    const id = setInterval(function() {
                        if (refresh) {
                            ss.render(x, y);
                            refresh = false;
                        }
                        else {
                            x += dx;
                            if (x >= canvas.width) {
                                x = 0;
                                y += dy;
                            }
                            else if (x > canvas.width - dx) {
                                x = canvas.width - dx;
                            }
                            if (y >= canvas.height) {
                                clearInterval(id);
                            }
                            else if (y > canvas.height - dy) {
                                y = canvas.height - dy;
                            }
                            document.body.scrollLeft = x;
                            document.body.scrollTop = y;
                            refresh = true;
                        }
                    }, delay);
                }, delay);
            }
        </script>
    ]], amb.r, amb.g, amb.b, rtsize, rtsize, units))
    function dhtml:OnDocumentReady(url)
        timer.Simple(0, function()
            dhtml:Call(string.format([[(function() {
                const surfaces = %s;
                const sample64 = "%s";
                const samples  = atob(sample64);
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                surfaces.forEach(function(surf) {
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
                    const lightmapOrigin = surf.IsDisplacement ? toMatrix(li.DispOrigin) : math.multiply(lightmapToWorld, lightmapOffset);

                    const anglesUV = toMatrix(surf.AnglesUV);
                    const uvStart = math.multiply(toMatrix(surf.OffsetUV), canvas.width);
                    const uvBound = math.multiply(toMatrix(surf.BoundaryUV), canvas.width);
                    const renderBasisU = math.squeeze(math.column(anglesUV, 1)); // Right
                    const renderBasisV = math.squeeze(math.column(anglesUV, 2)); // Up
                    const renderOrigin = toMatrix(surf.OriginUV);

                    const worldToUV = math.inv(math.matrixFromColumns(renderBasisU, renderBasisV, lightmapNormal));
                    const worldToUVOffset = math.unaryMinus(math.multiply(worldToUV, renderOrigin, unitsToPixels));
                    const uvStartClip = math.subtract(math.round(uvStart), math.matrix([2, 2, 0]));
                    const uvBoundClip = math.add(math.round(uvBound), math.matrix([4, 4, 0]));

                    const lightmapSizeInLuxels = toMatrix(li.SizeInLuxels);
                    const w = lightmapSizeInLuxels.get([0]) + 1;
                    const h = lightmapSizeInLuxels.get([1]) + 1;
                    const sizeOffset = surf.IsDisplacement ? 1 : 0;
                    const pixelBasisS = surf.IsDisplacement ? math.matrix([uvBound.get([0]) / w, 0, 0]) : math.multiply(worldToUV, lightmapBasisS, unitsToPixels);
                    const pixelBasisT = surf.IsDisplacement ? math.matrix([0, uvBound.get([1]) / h, 0]) : math.multiply(worldToUV, lightmapBasisT, unitsToPixels);
                    const pixelOrigin = surf.IsDisplacement ? uvStart : math.add(worldToUVOffset, uvStart, math.multiply(worldToUV, lightmapOrigin, unitsToPixels));
                    const pixelOriginShift = math.subtract(math.subtract(pixelOrigin, math.multiply(pixelBasisS, 1.5)), math.multiply(pixelBasisT, 1.5));
                    const sampleOffset = toMatrix(li.SampleOffset);
                    const image = ctx.createImageData(w + 2, h + 2);
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
                        pixelOriginShift.get([0]), pixelOriginShift.get([1]));
                    ctx.imageSmoothingEnabled = true;
                    ctx.drawImage(renderer, 0, 0, w + 2 + sizeOffset, h + 2 + sizeOffset);
                    ctx.restore();
                });
                copyToRenderTarget();
            })();]], surf, samples))
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
