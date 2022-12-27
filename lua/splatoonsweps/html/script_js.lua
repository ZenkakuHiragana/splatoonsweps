
// Query parameters:
// c: Cached number of threads on the client
// s: RenderTarget size
// u: Units to pixels
// r, g, b: RenderTarget background color

const canvas        = document.getElementById("canvas");
const renderer      = document.createElement("canvas");
const ctx           = canvas.getContext("2d");
const params        = new URLSearchParams(window.location.search);
const rtsize        = params.get("s");
const unitsToPixels = params.get("u");
canvas.width = rtsize;
canvas.height = rtsize;
(function() {
    if (params.has("r") && params.has("g") && params.has("b")) {
        const r = params.get("r");
        const g = params.get("g");
        const b = params.get("b");
        const rgb = "rgb(" + r + ", " + g + ", " + b + ")";
        canvas.style.backgroundColor = rgb;
    }
})();

function copyToRenderTarget(delay) {
    const dx = window.innerWidth;
    const dy = window.innerHeight;
    document.body.scrollLeft = 0;
    document.body.scrollTop = 0;
    delay = delay || 50;
    setTimeout(function () {
        var x = 0;
        var y = 0;
        var refresh = true;
        const id = setInterval(function () {
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

var workers = [];
var indexProcessed = 0;
var surfaceArrayLength = 0;
function send(workerIndex, surfaceIndex) {
    workers[workerIndex].processing = true;
    workers[workerIndex].postMessage({
        worker_id: workerIndex,
        index: surfaceIndex,
    });
}
function draw(e) {
    if (!e.data.skip) {
        const c = e.data.clip;
        const s = e.data.size;
        const t = e.data.transform;
        const image = ctx.createImageData(s.x, s.y);
        for (var i = 0; i < e.data.image.length; ++i) image.data[i] = e.data.image[i];
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
    }

    workers[e.data.worker_id].processing = false;
    if (indexProcessed < surfaceArrayLength) {
        send(e.data.worker_id, ++indexProcessed);
    }
    else if (!workers.some(function(w) { return w.processing; })) {
        copyToRenderTarget();
    }
}

function main(surfaceArray, samples64) {
    surfaceArrayLength = surfaceArray.length;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    navigator.getHardwareConcurrency(function(cores) {
        ss.storeNumThreads(cores);
        for (var i = 0; i < cores; ++i) {
            workers[i] = new Worker("worker_js.lua?s=" + rtsize + "&u=" + unitsToPixels);
            workers[i].onmessage = draw;
            workers[i].postMessage({
                sendSurfaces: true,
                surfaces: surfaceArray,
                samples: atob(samples64),
            });
            send(i, indexProcessed++);
        }
    });
}
