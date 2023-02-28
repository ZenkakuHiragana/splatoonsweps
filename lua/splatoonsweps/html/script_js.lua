
// Query parameters:
// c: Cached number of threads on the client
// s: RenderTarget size
// u: Units to pixels
// r, g, b: RenderTarget background color

const canvasx        = [ 0, 0.5, 0, 0.5 ];
const canvasy        = [ 0, 0, 0.5, 0.5 ];
const params         = new URLSearchParams(window.location.search);
const rtsize         = params.get("s");
const unitsToPixels  = params.get("u");
const canvas         = new Uint16Array(rtsize * rtsize * 4);
const workers        = [];
const renderingQueue = [];
var indexProcessed   = 0;
var surfaceArraySize = 0;

function setup() {
    if (params.has("r") && params.has("g") && params.has("b")) {
        const r = params.get("r");
        const g = params.get("g");
        const b = params.get("b");
        for (var i = 0; i < rtsize * rtsize * 4; i += 4) {
            canvas[i + 0] = r;
            canvas[i + 1] = g;
            canvas[i + 2] = b;
            canvas[i + 3] = 255;
        }
    }
}

// Draws lightmap of each surface to the canvas
// If I have to do a workaround (useAlt), draw quarter and save to png four times.
function clamp(x, min, max) {
    return Math.min(Math.max(x, min), max);
}
function getIndex(x, y, w, h) {
    return (clamp(x, 0, w - 1) + clamp(y, 0, h - 1) * w) * 4;
}
function arrayBufferToBase64(buffer) {
    var binary = '';
    const bytes = new Uint8Array(buffer);
    const len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
}
function draw() {
    console.log("SplatoonSWEPs/LightmapPrecache: Drawing lightmap to canvas...");
    for (var i = 0; i < 4; ++i) {
        var dx = canvasx[i] * rtsize;
        var dy = canvasy[i] * rtsize;
        renderingQueue.forEach(function(surf) {
            const clip = surf.clip;
            const image = surf.image;
            for (var y = 0; y < clip.h; ++y) {
                for (var x = 0; x < clip.w; ++x) {
                    var i = getIndex(x, y, clip.w, clip.h);
                    var j = getIndex(x + clip.x - dx, y + clip.y - dy, rtsize, rtsize);
                    if (j < 0 || j >= canvas.length) continue;
                    canvas[j + 0] = image[i + 0];
                    canvas[j + 1] = image[i + 1];
                    canvas[j + 2] = image[i + 2];
                    canvas[j + 3] = image[i + 3];
                }
            }
        });
        if (!useAlt) return;
        console.log("SplatoonSWEPs/LightmapPrecache: Saving image... #" + (i + 1));

        var png = UPNG.encodeLL([ canvas.buffer ], clip.w, clip.h, 3, 1, 16);
        var b64 = arrayBufferToBase64(png);
        ss.save(b64, i + 1);
    }
}
function send(workerIndex, surfaceIndex) {
    workers[workerIndex].processing = true;
    workers[workerIndex].postMessage({
        worker_id: workerIndex,
        index: surfaceIndex,
    });
}
function onmessage(e) {
    workers[e.data.worker_id].processing = false;
    if (!e.data.skip) {
        renderingQueue.push({
            image: e.data.image,
            clip:  e.data.clip,
        });
    }
    if (indexProcessed < surfaceArraySize) {
        send(e.data.worker_id, indexProcessed++);
    }
    else if (!workers.some(function(w) { return w.processing; })) {
        draw();
    }
}
function main(surfaceArray, samples64) {
    const samples = atob(samples64);
    surfaceArraySize = surfaceArray.length;
    console.log("SplatoonSWEPs/LightmapPrecache: Loading lightmap...");
    navigator.getHardwareConcurrency(function(cores) {
        setup();
        if (wasHardwareConcurrencyUndefined) ss.storeNumThreads(cores);
        for (var i = 0; i < cores; ++i) {
            workers[i] = new Worker("worker_js.lua?s=" + rtsize + "&u=" + unitsToPixels);
            workers[i].onmessage = onmessage;
            workers[i].postMessage({
                sendSurfaces: true,
                surfaces: surfaceArray,
                samples: samples,
            });
            send(i, indexProcessed++);
            console.log("SplatoonSWEPs/LightmapPrecache: Creating Worker #" + (i + 1));
        }
    });
}
