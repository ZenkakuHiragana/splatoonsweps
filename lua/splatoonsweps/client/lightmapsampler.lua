
local ss = SplatoonSWEPs
if not ss then return end

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
    dhtml:StopLoading()
    dhtml:AddFunction("ss", "end", function()
        timer.Simple(2, function() dhtml:UpdateHTMLTexture() end)
    end)
    dhtml:Call(([[
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
