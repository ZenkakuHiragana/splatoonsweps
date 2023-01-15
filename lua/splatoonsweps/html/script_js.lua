
// Query parameters:
// c: Cached number of threads on the client
// s: RenderTarget size
// u: Units to pixels
// r, g, b: RenderTarget background color

// Default branch seems to be unable to handle large canvas
// so I have to use an alternative way
const canvasx = [ 0, 8192, 0, 8192 ];
const canvasy = [ 0, 0, 8192, 8192 ];
const useAlt  = typeof OffscreenCanvas == "undefined" && rtsize == 16384;

const canvas         = document.getElementById("canvas");
const renderer       = document.createElement("canvas");
const ctx            = canvas.getContext("2d");
const rctx           = renderer.getContext("2d");
const params         = new URLSearchParams(window.location.search);
const rtsize         = params.get("s");
const unitsToPixels  = params.get("u");
const workers        = [];
const renderingQueue = [];
var indexProcessed   = 0;
var surfaceArraySize = 0;

function setup() {
    if (useAlt) {
        canvas.width = rtsize / 2;
        canvas.height = rtsize / 2;
    }
    else {
        canvas.width = rtsize;
        canvas.height = rtsize;
    }
    if (params.has("r") && params.has("g") && params.has("b")) {
        const r = params.get("r");
        const g = params.get("g");
        const b = params.get("b");
        const rgb = "rgb(" + r + ", " + g + ", " + b + ")";
        canvas.style.backgroundColor = rgb;
    }
}

// Draws lightmap of each surface to the canvas
// If I have to do a workaround (useAlt), draw quarter and save to png four times.
function draw() {
    console.log("SplatoonSWEPs/LightmapPrecache: Drawing lightmap to canvas...");
    for (var i = 0; i < 4; ++i) {
        var dx = useAlt ? canvasx[i] : 0;
        var dy = useAlt ? canvasy[i] : 0;
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        renderingQueue.forEach(function(surf) {
            const c = surf.clip;
            const s = surf.size;
            const t = surf.transform;
            const image = ctx.createImageData(s.x, s.y);
            for (var j = 0; j < surf.image.length; ++j) image.data[j] = surf.image[j];
            renderer.width = s.x;
            renderer.height = s.y;
            rctx.putImageData(image, 0, 0);
            ctx.save();
            ctx.beginPath();
            ctx.rect(c.x - dx, c.y - dy, c.w, c.h);
            ctx.clip();
            ctx.transform(t.sx, t.sy, t.tx, t.ty, t.x0 - dx, t.y0 - dy);
            ctx.drawImage(renderer, 0, 0, s.x + s.offset, s.y + s.offset);
            ctx.restore();
        });
        if (!useAlt) return;
        console.log("SplatoonSWEPs/LightmapPrecache: Saving image... #" + (i + 1));
        ss.save(canvas.toDataURL("image/png"), i + 1);
    }
}
function save() {
    if (useAlt) return;
    console.log("SplatoonSWEPs/LightmapPrecache: Saving image...");
    const w = canvas.width / 2;
    const h = canvas.height / 2;
    const x = [ 0, w, 0, w ];
    const y = [ 0, 0, h, h ];
    renderer.width = w;
    renderer.height = h;
    for (var i = 0; i < 4; ++i) {
        rctx.drawImage(canvas, x[i], y[i], w, h, 0, 0, w, h);
        ss.save(renderer.toDataURL("image/png"), i + 1);
    }
}
// https://stackoverflow.com/questions/63078550/event-that-fires-after-a-certain-element-successfully-painted
function render() {
    console.log("SplatoonSWEPs/LightmapPrecache: Drawing to RenderTarget...");
    if (useAlt) return ss.paste();
    var x = 0;
    var y = 0;
    var alreadyQueued = true;
    const dx = window.innerWidth;
    const dy = window.innerHeight;
    if (!window.requestAnimationFrame) {
        var lastTime = 0;
		requestAnimationFrame = function(callback) {
			const now = performance.now();
			const nextTime = Math.max(lastTime + 30, now);
			setTimeout(function() {
                lastTime = nextTime;
                callback();
            }, nextTime - now);
		};
    }
    function onpaint() {
        function renderingFinished() {
            if (alreadyQueued) return;
            x += dx;
            if (x >= canvas.width) {
                x = 0;
                y += dy;
            }
            else if (x > canvas.width - dx) {
                x = canvas.width - dx;
            }
            if (y >= canvas.height) {
                console.log("SplatoonSWEPs/LightmapPrecache: Finished!");
                return;
            }
            else if (y > canvas.height - dy) {
                y = canvas.height - dy;
            }
            alreadyQueued = true;
            window.scroll(x, y);
            requestAnimationFrame(onpaint);
        }
        requestAnimationFrame(function() {
            alreadyQueued = false;
            if (ss.render(x, y, renderingFinished)) renderingFinished();
        });
    }
    window.scroll(x, y);
    requestAnimationFrame(function() { requestAnimationFrame(onpaint); });
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
            image:     e.data.image,
            clip:      e.data.clip,
            size:      e.data.size,
            transform: e.data.transform,
        });
    }
    if (indexProcessed < surfaceArraySize) {
        send(e.data.worker_id, indexProcessed++);
    }
    else if (!workers.some(function(w) { return w.processing; })) {
        draw();
        save();
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
