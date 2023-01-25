
importScripts("https://cdnjs.cloudflare.com/ajax/libs/mathjs/10.6.4/math.min.js");
importScripts("https://polyfill.io/v3/polyfill.min.js?features=URLSearchParams");
const params        = new URLSearchParams(self.location.search);
const rtsize        = Number(params.get("s"));
const unitsToPixels = Number(params.get("u"));
const gamma         = 1 / 2.2;

var samples = null;
var surfaces = null;

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
function writeLightmap(image, w, h, sampleOffset) {
    for (var t = -1; t < h + 1; ++t) {
        for (var s = -1; s < w + 1; ++s) {
            var i = (clamp(s, 0, w - 1) + clamp(t, 0, h - 1) * w) * 4 + sampleOffset;
            var r = samples.charCodeAt(i + 0);
            var g = samples.charCodeAt(i + 1);
            var b = samples.charCodeAt(i + 2);
            var e = samples.charCodeAt(i + 3);
            var c = getRGB(r, g, b, e);
            var j = ((s + 1) + (t + 1) * (w + 2)) * 4;
            image[j + 0] = Math.round(c.get([0]));
            image[j + 1] = Math.round(c.get([1]));
            image[j + 2] = Math.round(c.get([2]));
            image[j + 3] = 255;
        }
    }
}

onmessage = function(e) {
    if (e.data.sendSurfaces) {
        surfaces = e.data.surfaces;
        samples = e.data.samples;
        return;
    }
    if (e.data.index >= surfaces.length) {
        this.postMessage({
            skip: true,
            worker_id: e.data.worker_id,
            index: e.data.index,
        });
        return;
    }

    const surf = surfaces[e.data.index];
    const li = surf.LightmapInfo;
    if (!li.Available) {
        this.postMessage({
            skip: true,
            worker_id: e.data.worker_id,
            index: e.data.index,
        });
        return;
    }

    const basisS = toMatrix(li.BasisS);
    const basisT = toMatrix(li.BasisT);
    const basisN = math.cross(basisS, basisT);
    const lightmapOffset =  math.subtract(toMatrix(li.MinsInLuxels), toMatrix(li.Offset));
    const lightmapToWorld = math.inv(math.matrixFromRows(basisS, basisT, basisN));
    const lightmapBasisS  = math.squeeze(math.column(lightmapToWorld, 0));
    const lightmapBasisT  = math.squeeze(math.column(lightmapToWorld, 1));
    const lightmapNormal  = math.squeeze(math.column(lightmapToWorld, 2));
    const lightmapOrigin  = surf.IsDisplacement ? toMatrix(li.DispOrigin) : math.multiply(lightmapToWorld, lightmapOffset);
    const anglesUV        = toMatrix(surf.AnglesUV);
    const uvStart         = math.multiply(toMatrix(surf.OffsetUV), rtsize);
    const uvBound         = math.multiply(toMatrix(surf.BoundaryUV), rtsize);
    const renderBasisU    = math.squeeze(math.column(anglesUV, 1)); // Right
    const renderBasisV    = math.squeeze(math.column(anglesUV, 2)); // Up
    const renderOrigin    = toMatrix(surf.OriginUV);
    const worldToUV       = math.inv(math.matrixFromColumns(renderBasisU, renderBasisV, lightmapNormal));
    const worldToUVOffset = math.unaryMinus(math.multiply(worldToUV, renderOrigin, unitsToPixels));
    const uvStartClip     = math.subtract(uvStart, math.matrix([2, 2, 0]));
    const uvBoundClip     = math.add     (uvBound, math.matrix([4, 4, 0]));

    const lightmapSizeInLuxels = toMatrix(li.SizeInLuxels);
    const w = lightmapSizeInLuxels.get([0]) + 1;
    const h = lightmapSizeInLuxels.get([1]) + 1;
    const sizeOffset  = surf.IsDisplacement ? 1 : 0;
    const pixelBasisS = surf.IsDisplacement ? math.matrix([uvBound.get([0]) / w, 0, 0]) :  math.multiply(worldToUV, lightmapBasisS, unitsToPixels);
    const pixelBasisT = surf.IsDisplacement ? math.matrix([0, uvBound.get([1]) / h, 0]) :  math.multiply(worldToUV, lightmapBasisT, unitsToPixels);
    const pixelOrigin = surf.IsDisplacement ? uvStart : math.add(worldToUVOffset, uvStart, math.multiply(worldToUV, lightmapOrigin, unitsToPixels));
    const pixelOriginShift = math.subtract(math.subtract(pixelOrigin, math.multiply(pixelBasisS, 1.5)), math.multiply(pixelBasisT, 1.5));
    const sampleOffset = toMatrix(li.SampleOffset);
    const image = new Uint8Array((w + 2) * (h + 2) * 4);
    writeLightmap(image, w, h, sampleOffset);

    this.postMessage({
        worker_id: e.data.worker_id,
        index: e.data.index,
        image: image,
        clip: {
            x: uvStartClip.get([0]),
            y: uvStartClip.get([1]),
            w: uvBoundClip.get([0]),
            h: uvBoundClip.get([1]),
        },
        size: {
            x: w + 2, y: h + 2, offset: sizeOffset,
        },
        transform: {
            sx: pixelBasisS.get([0]),      sy: pixelBasisS.get([1]),
            tx: pixelBasisT.get([0]),      ty: pixelBasisT.get([1]),
            x0: pixelOriginShift.get([0]), y0: pixelOriginShift.get([1]),
        },
    }, [ image.buffer ]);
}
