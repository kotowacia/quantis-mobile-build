// Перемотка по «форме волны» трека — порт настольного WaveformSeekSlider:
// сыгранное закрашено градиентом цветов трека (accent2 → accent), остальное —
// полупрозрачными «чернилами» темы. Форма своя у каждого трека (зерно — его
// ключ), чтобы треки не выглядели одинаково. Касание/перетаскивание — перемотка.
import QtQuick

Item {
    id: wave

    // Внешние значения: диапазон и текущая позиция (мс).
    property real from: 0
    property real to: 1
    property real position: 0
    // Ключ формы волны (название трека / исполнителя).
    property string seed: ""
    // Пользователь тянет ползунок (для подсказки времени).
    readonly property bool dragging: area.pressed
    // Показываемое значение: при перетаскивании — палец, иначе позиция.
    readonly property real shown: area.pressed ? dragValue : position
    signal seekRequested(real value)

    readonly property real progress: to > from
        ? Math.max(0, Math.min(1, (shown - from) / (to - from)))
        : 0
    readonly property bool idle: seed.length === 0

    property real dragValue: from
    property var peaks: []

    // Псевдослучайная, но устойчивая форма: зерно — ключ трека.
    function makePeaks(key) {
        var hash = 0
        for (var i = 0; i < key.length; i++)
            hash = (hash * 31 + key.charCodeAt(i)) & 0x7fffffff
        var state = (hash || 1) >>> 0
        function rnd() {
            state ^= state << 13
            state ^= state >>> 17
            state ^= state << 5
            return (state >>> 0) / 4294967296
        }
        var n = 72
        var raw = []
        for (var j = 0; j < n; j++)
            raw.push(rnd())
        var smooth = []
        for (j = 0; j < n; j++) {
            var lo = Math.max(0, j - 2)
            var hi = Math.min(n - 1, j + 2)
            var sum = 0, cnt = 0
            for (var k = lo; k <= hi; k++) { sum += raw[k]; cnt++ }
            var v = sum / cnt
            smooth.push(0.18 + 0.82 * Math.pow(v, 1.4)
                        * (0.55 + 0.45 * Math.pow(Math.sin(j / n * Math.PI * 3 + 1), 2)))
        }
        peaks = smooth
    }
    onSeedChanged: makePeaks(seed)
    Component.onCompleted: makePeaks(seed)

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        function roundRect(ctx, x, y, w, hgt, r) {
            ctx.beginPath()
            ctx.moveTo(x + r, y)
            ctx.lineTo(x + w - r, y)
            ctx.quadraticCurveTo(x + w, y, x + w, y + r)
            ctx.lineTo(x + w, y + hgt - r)
            ctx.quadraticCurveTo(x + w, y + hgt, x + w - r, y + hgt)
            ctx.lineTo(x + r, y + hgt)
            ctx.quadraticCurveTo(x, y + hgt, x, y + hgt - r)
            ctx.lineTo(x, y + r)
            ctx.quadraticCurveTo(x, y, x + r, y)
            ctx.closePath()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (width < 8 || height < 8)
                return
            var bars = wave.peaks.length
            if (!wave.idle && bars === 0) {
                wave.makePeaks(wave.seed)
                bars = wave.peaks.length
            }
            var step = width / Math.max(1, bars)
            var playedTo = width * wave.progress
            for (var i = 0; i < bars; i++) {
                var peak = wave.idle ? 0 : wave.peaks[i]
                var bh = Math.max(2, (height - 6) * peak)
                var x = i * step + step * 0.18
                var w = Math.max(1.5, step * 0.64)
                if (x + w <= playedTo + 0.5) {
                    var g = ctx.createLinearGradient(0, 0, Math.max(1, playedTo), 0)
                    g.addColorStop(0, theme.accent2)
                    g.addColorStop(1, theme.accent)
                    ctx.fillStyle = g
                } else {
                    ctx.fillStyle = Qt.rgba(1, 1, 1, 0.22)
                }
                roundRect(ctx, x, (height - bh) / 2, w, bh, Math.min(2, w / 2))
                ctx.fill()
            }
            if (wave.idle)
                return
            // «Голова» ползунка.
            ctx.fillStyle = Qt.rgba(1, 1, 1, 0.92)
            ctx.fillRect(playedTo - 1, 0, 2, height)
        }
    }

    function setFromMouse(mx) {
        if (wave.to <= wave.from)
            return
        var ratio = Math.max(0, Math.min(1, mx / width))
        wave.dragValue = wave.from + ratio * (wave.to - wave.from)
        wave.seekRequested(wave.dragValue)
    }

    MouseArea {
        id: area
        anchors.fill: parent
        preventStealing: true
        onPressed: wave.setFromMouse(mouseX)
        onPositionChanged: if (pressed) wave.setFromMouse(mouseX)
    }

    Connections {
        target: wave
        function onProgressChanged() { canvas.requestPaint() }
    }
    Connections {
        target: theme
        function onAccentChanged() { canvas.requestPaint() }
        function onAccent2Changed() { canvas.requestPaint() }
    }
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
}
