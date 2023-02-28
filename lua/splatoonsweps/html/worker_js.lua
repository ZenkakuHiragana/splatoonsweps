
importScripts("https://cdnjs.cloudflare.com/ajax/libs/mathjs/10.6.4/math.min.js");
importScripts("https://polyfill.io/v3/polyfill.min.js?features=URLSearchParams");
const params           = new URLSearchParams(self.location.search);
const rtsize           = Number(params.get("s"));
const unitsToPixels    = Number(params.get("u"));
const gamma            = 2.2;
const gamma_inv        = 1 / gamma;
const overBrightFactor = 0.5;

var samples = null;
var surfaces = null;

function getRGB(r, g, b, e) {
    if (e > 127) e -= 256;
    const rLinear = r * Math.pow(2, e) / 255;
    const gLinear = g * Math.pow(2, e) / 255;
    const bLinear = b * Math.pow(2, e) / 255;
    const rVertex = Math.min(1, Math.pow(rLinear, gamma_inv) * overBrightFactor);
    const gVertex = Math.min(1, Math.pow(gLinear, gamma_inv) * overBrightFactor);
    const bVertex = Math.min(1, Math.pow(bLinear, gamma_inv) * overBrightFactor);
    return math.matrix([
        Math.round(rVertex * 65535),
        Math.round(gVertex * 65535),
        Math.round(bVertex * 65535),
    ]);
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
function getIndex(x, y, w, h, offset) {
    return (clamp(x, 0, w - 1) + clamp(y, 0, h - 1) * w) * 4 + (offset || 0);
}
function writeLightmap(image, w, h, sampleOffset) {
    for (var t = -1; t < h + 1; ++t) {
        for (var s = -1; s < w + 1; ++s) {
            var i = getIndex(s, t, w, h, sampleOffset);
            var j = getIndex(s + 1, t + 1, w + 2, h + 2);
            var r = samples.charCodeAt(i + 0);
            var g = samples.charCodeAt(i + 1);
            var b = samples.charCodeAt(i + 2);
            var e = samples.charCodeAt(i + 3);
            var c = getRGB(r, g, b, e);
            image[j + 0] = c.get([0]);
            image[j + 1] = c.get([1]);
            image[j + 2] = c.get([2]);
            image[j + 3] = 255;
        }
    }
}

// transformInfo:
//    / x \   / sx tx x0 \/ s \
//    | y | = | sy ty y0 || t |
//    \ 1 /   \  0  0  1 /\ 1 /
//          xc
//    +------+-------------->  x
//    |      |
//    |                       texture
//    |      |   w              coordinates:
// yc +- - - +------+   ---+    x-y, w x h
//    |      |      |   ^
//    |    h |      |   |  t = (tx, ty)
//    |      +------+   H  ^
//    |                 |  |  lightmap
//    |      |<-----W---v->|    coordinates:
//    |      +      <======+    s-t, W x H
//    v      s = (sx, sy)   (x0, y0)
//
//    y
function transformImage(out, lightmap, transformInfo) {
    const cl = transformInfo.clip;
    const li = transformInfo.lightmap;
    const tr = transformInfo.transform;
    const lightmapToUV = math.matrix([
        [ tr.sx, tr.tx, tr.x0 - cl.xc ],
        [ tr.sy, tr.ty, tr.y0 - cl.yc ],
        [     0,     0,             1 ],
    ]);
    const uvToLightmap = math.inv(lightmapToUV);
    function bilinear(v) {
        const w   = math.multiply(uvToLightmap, v);
        const x   = v.get([0]);
        const y   = v.get([1]);
        const s   = w.get([0]) - 0.5;
        const t   = w.get([1]) - 0.5;
        const si  = Math.floor(s); // Integral part of s, t
        const ti  = Math.floor(t);
        const sf  = s - si; // Fractional part of s, t
        const tf  = t - ti;
        const i   = getIndex(x,      y,      cl.w, cl.h);
        const i00 = getIndex(si,     ti,     li.W, li.H); // / i00  i01 \
        const i01 = getIndex(si + 1, ti,     li.W, li.H); // \ i10  i11 /
        const i10 = getIndex(si,     ti + 1, li.W, li.H);
        const i11 = getIndex(si + 1, ti + 1, li.W, li.H);
        const r00 = lightmap[i00 + 0];
        const r01 = lightmap[i01 + 0];
        const r10 = lightmap[i10 + 0];
        const r11 = lightmap[i11 + 0];
        const g00 = lightmap[i00 + 1];
        const g01 = lightmap[i01 + 1];
        const g10 = lightmap[i10 + 1];
        const g11 = lightmap[i11 + 1];
        const b00 = lightmap[i00 + 2];
        const b01 = lightmap[i01 + 2];
        const b10 = lightmap[i10 + 2];
        const b11 = lightmap[i11 + 2];
        const r = (1 - sf) * (1 - tf) * r00
                +      sf  * (1 - tf) * r01
                + (1 - sf) *      tf  * r10
                +      sf  *      tf  * r11;
        const g = (1 - sf) * (1 - tf) * g00
                +      sf  * (1 - tf) * g01
                + (1 - sf) *      tf  * g10
                +      sf  *      tf  * g11;
        const b = (1 - sf) * (1 - tf) * b00
                +      sf  * (1 - tf) * b01
                + (1 - sf) *      tf  * b10
                +      sf  *      tf  * b11;
        out[i + 0] = r;
        out[i + 1] = g;
        out[i + 2] = b;
        out[i + 3] = 255;
    }
    for (var y = 0; y < cl.h; ++y) {
        for (var x = 0; x < cl.w; ++x) {
            bilinear(math.matrix([x, y, 1]));
        }
    }
}

onmessage = function(e) {
    if (e.data.sendSurfaces) {
        surfaces = e.data.surfaces;
        samples = e.data.samples;
        return;
    }
    if (e.data.render) {
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
    const lightmapOffset  = math.subtract(toMatrix(li.MinsInLuxels), toMatrix(li.Offset));
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
    const clipWidth   = uvBoundClip.get([0]);
    const clipHeight  = uvBoundClip.get([1]);
    const sizeOffset  = surf.IsDisplacement ? 1 : 0;
    const pixelBasisS = surf.IsDisplacement ? math.matrix([uvBound.get([0]) / w, 0, 0]) :  math.multiply(worldToUV, lightmapBasisS, unitsToPixels);
    const pixelBasisT = surf.IsDisplacement ? math.matrix([0, uvBound.get([1]) / h, 0]) :  math.multiply(worldToUV, lightmapBasisT, unitsToPixels);
    const pixelOrigin = surf.IsDisplacement ? uvStart : math.add(worldToUVOffset, uvStart, math.multiply(worldToUV, lightmapOrigin, unitsToPixels));
    const pixelOriginShift = math.subtract(math.subtract(pixelOrigin, math.multiply(pixelBasisS, 1.5)), math.multiply(pixelBasisT, 1.5));
    const sampleOffset = toMatrix(li.SampleOffset);
    const image = new Uint16Array((w + 2) * (h + 2) * 4);
    const imageTransformed = new Uint16Array(clipWidth * clipHeight * 4);
    writeLightmap(image, w, h, sampleOffset);
    transformImage(imageTransformed, image, {
        clip: {
            xc: uvStartClip.get([0]),
            yc: uvStartClip.get([1]),
            w: clipWidth,
            h: clipHeight,
        },
        lightmap: {
            W: w + 2,
            H: h + 2,
            sizeOffset: sizeOffset,
        },
        transform: {
            sx: pixelBasisS.get([0]),      sy: pixelBasisS.get([1]),
            tx: pixelBasisT.get([0]),      ty: pixelBasisT.get([1]),
            x0: pixelOriginShift.get([0]), y0: pixelOriginShift.get([1]),
        },
    });

    this.postMessage({
        worker_id: e.data.worker_id,
        index: e.data.index,
        image: imageTransformed,
        clip: {
            x: uvStartClip.get([0]),
            y: uvStartClip.get([1]),
            w: clipWidth,
            h: clipHeight,
        },
    }, [ imageTransformed.buffer ]);
}
