
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta http-equiv="Cache-Control" content="no-store">
    <style>* { margin: 0; padding: 0; overflow: visible; } body { overflow: hidden; }</style>
    <script src="https://polyfill.io/v3/polyfill.min.js?features=URLSearchParams"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjs/10.6.4/math.min.js"></script>
    <script type="text/javascript">
        const wasHardwareConcurrencyUndefined = !navigator.hardwareConcurrency;
        (function() {
            const params = new URLSearchParams(window.location.search);
            if (wasHardwareConcurrencyUndefined && params.has("c")) {
                const cores = Number(params.get("c"));
                if (cores >= 1) navigator.hardwareConcurrency = cores;
            }
        })();
    </script>
    <script src="core_estimator_js.lua"></script>
</head>
<body>
    <canvas id="canvas"/>
    <script src="script_js.lua"></script>
</body>
</html>
