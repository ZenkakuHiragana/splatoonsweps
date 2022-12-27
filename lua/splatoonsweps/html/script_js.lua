
// Query parameters:
// c: Cached number of threads on the client
// s: RenderTarget size
// u: Units to pixels
// r, g, b: RenderTarget background color

const canvas         = document.getElementById("canvas");
const renderer       = document.createElement("canvas");
const ctx            = canvas.getContext("2d");
const params         = new URLSearchParams(window.location.search);
const rtsize         = params.get("s");
const unitsToPixels  = params.get("u");
const workers        = [];
const renderingQueue = [];
var indexProcessed   = 0;
var surfaceArraySize = 0;

(function() {
    canvas.width = rtsize;
    canvas.height = rtsize;
    if (params.has("r") && params.has("g") && params.has("b")) {
        const r = params.get("r");
        const g = params.get("g");
        const b = params.get("b");
        const rgb = "rgb(" + r + ", " + g + ", " + b + ")";
        canvas.style.backgroundColor = rgb;
    }
})();

// https://stackoverflow.com/questions/63078550/event-that-fires-after-a-certain-element-successfully-painted
function copyToRenderTarget() {
    var x = 0;
    var y = 0;
    var alreadyQueued = true;
    const dx = window.innerWidth;
    const dy = window.innerHeight;
    if (!window.requestAnimationFrame) {
        var lastTime = 0;
		requestAnimationFrame = function(callback) {
			const now = performance.now();
			const nextTime = Math.max(lastTime + 25, now);
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
                return;
            }
            else if (y > canvas.height - dy) {
                y = canvas.height - dy;
            }
            alreadyQueued = true;
            document.body.scrollLeft = x;
            document.body.scrollTop = y;
            requestAnimationFrame(onpaint);
        }
        requestAnimationFrame(function() {
            alreadyQueued = false;
            const out = ss.render(x, y, renderingFinished);
            if (out) renderingFinished();
        });
    }
    document.body.scrollLeft = 0;
    document.body.scrollTop = 0;
    requestAnimationFrame(function() { requestAnimationFrame(onpaint); });
}
function draw() {
    renderingQueue.forEach(function(surf) {
        const c = surf.clip;
        const s = surf.size;
        const t = surf.transform;
        const image = ctx.createImageData(s.x, s.y);
        for (var i = 0; i < surf.image.length; ++i) image.data[i] = surf.image[i];
        renderer.width = s.x;
        renderer.height = s.y;
        renderer.getContext("2d").putImageData(image, 0, 0);
        ctx.save();
        ctx.beginPath();
        ctx.rect(c.x, c.y, c.w, c.h);
        ctx.clip();
        ctx.transform(t.sx, t.sy, t.tx, t.ty, t.x0, t.y0);
        ctx.drawImage(renderer, 0, 0, s.x + s.offset, s.y + s.offset);
        ctx.restore();
    });
    copyToRenderTarget();
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
    }
}
function main(surfaceArray, samples64) {
    const samples = atob(samples64);
    surfaceArraySize = surfaceArray.length;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    navigator.getHardwareConcurrency(function(cores) {
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
        }
    });
}
