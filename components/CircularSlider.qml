import QtQuick

// A circular/arc slider for Quickshell (QuickShell.io) widgets.
// Drag along the arc between `startAt` and `endAt` (both 0..1, fractions of
// a full turn starting at 3 o'clock, going clockwise) to change `value`.
Item {
    id: root

	implicitWidth: 250
	implicitHeight: 250

    // --- Public API -----------------------------------------------------
    property real value: 0          // current position, 0..1
    property real startAt: 0        // 0..1, start of the arc (fraction of full circle)
    property real endAt: 1          // 0..1, end of the arc
    property real radius: 0         // 0 = auto (fit to available space)
    property real sliderWidth: 10   // stroke width of the arc ("width" is reserved by Item)
	readonly property bool inverted: startAt > endAt   // draw/track from endAt back to startAt

    property color arcColor: "white"
    property color borderColor: "gray"
    property real borderWidth: 1

    property real hitTolerance: 10  // px, how close to the arc you must click/drag

    signal moved(real value)

    // --- Internal helpers -------------------------------------------------
    function _clampValue(v) {
        if (v < 0.02)
            return 0;
        if (v > 0.98)
            return 1;
        return Math.max(0, Math.min(1, v));
    }

    function _setValue(v) {
        const clamped = _clampValue(v);
        if (clamped !== value) {
            value = clamped;
            moved(value);
        }
    }

    function _newValue(percent) {
        const range = Math.abs(startAt - endAt);
        const v = inverted ? (startAt - percent) / range : (percent - startAt) / range;
        _setValue(v);
    }

    // Returns [percent, distance] for a point relative to the widget center
    function _getPoint(x, y) {
        const cx = width / 2;
        const cy = height / 2;
        const dx = x - cx;
        const dy = y - cy;

        const fullCircle = Math.PI * 2;
        const angle = (Math.atan2(dy, dx) + fullCircle) % fullCircle;
        const percent = angle / fullCircle;
        const distance = Math.sqrt(dx * dx + dy * dy);

        return [percent, distance];
    }

    function _contains(percent) {
        return (Math.min(startAt, endAt) <= percent) && (Math.max(startAt, endAt) >= percent);
    }

    // Repaint whenever anything visual changes
    onValueChanged: canvas.requestPaint()
    onInvertedChanged: canvas.requestPaint()
    onStartAtChanged: canvas.requestPaint()
    onEndAtChanged: canvas.requestPaint()
    onRadiusChanged: canvas.requestPaint()
    onSliderWidthChanged: canvas.requestPaint()
    onArcColorChanged: canvas.requestPaint()
    onBorderColorChanged: canvas.requestPaint()
    onBorderWidthChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        // Effective radius used both for drawing and hit-testing;
        // mirrors the "auto-fit, else clamp to available space" logic.
        property real effectiveRadius: 0

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const cx = width / 2;
            const cy = height / 2;
            const maxRadius = Math.min(width, height) / 2 - root.sliderWidth / 2 - root.borderWidth;

            effectiveRadius = root.radius === 0 ? maxRadius : Math.min(root.radius, maxRadius);

            const fullCircle = Math.PI * 2;
            const range = Math.abs(root.startAt - root.endAt);
            let startAngle, endAngle;

            if (root.inverted) {
                startAngle = root.endAt * fullCircle + (1 - root.value) * range * fullCircle;
                endAngle = root.startAt * fullCircle;
            } else {
                startAngle = root.startAt * fullCircle;
                endAngle = root.startAt * fullCircle + root.value * range * fullCircle;
            }

            // Filled arc showing the current value
            ctx.strokeStyle = root.arcColor;
            ctx.lineWidth = root.sliderWidth;
            ctx.beginPath();
            ctx.arc(cx, cy, effectiveRadius, startAngle, endAngle);
            ctx.stroke();

            const trackStart = root.inverted ? root.endAt * fullCircle : root.startAt * fullCircle;
            const trackEnd = root.inverted ? root.startAt * fullCircle : root.endAt * fullCircle;

            // Inner and outer border tracks
            ctx.strokeStyle = root.borderColor;
            ctx.lineWidth = root.borderWidth;

            ctx.beginPath();
            ctx.arc(cx, cy, effectiveRadius - root.sliderWidth / 2, trackStart, trackEnd);
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(cx, cy, effectiveRadius + root.sliderWidth / 2, trackStart, trackEnd);
            ctx.stroke();

            // End caps at startAt and endAt
            ctx.beginPath();
            ctx.moveTo(Math.cos(root.startAt * fullCircle) * (effectiveRadius - root.sliderWidth / 2) + cx //
            , Math.sin(root.startAt * fullCircle) * (effectiveRadius - root.sliderWidth / 2) + cy);
            ctx.lineTo(Math.cos(root.startAt * fullCircle) * (effectiveRadius + root.sliderWidth / 2) + cx //
            , Math.sin(root.startAt * fullCircle) * (effectiveRadius + root.sliderWidth / 2) + cy);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(Math.cos(root.endAt * fullCircle) * (effectiveRadius - root.sliderWidth / 2) + cx //
            , Math.sin(root.endAt * fullCircle) * (effectiveRadius - root.sliderWidth / 2) + cy);
            ctx.lineTo(Math.cos(root.endAt * fullCircle) * (effectiveRadius + root.sliderWidth / 2) + cx //
            , Math.sin(root.endAt * fullCircle) * (effectiveRadius + root.sliderWidth / 2) + cy);
            ctx.stroke();
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        property bool dragging: false

        onPressed: mouse => {
            const result = root._getPoint(mouse.x, mouse.y);
            const percent = result[0];
            const distance = result[1];

            if (Math.abs(distance - canvas.effectiveRadius) <= root.hitTolerance && root._contains(percent)) {
                root._newValue(percent);
                dragging = true;
            }
        }

        onReleased: dragging = false
        onCanceled: dragging = false

        onPositionChanged: mouse => {
            if (!dragging)
                return;
            const result = root._getPoint(mouse.x, mouse.y);
            const percent = result[0];

            if (root._contains(percent)) {
                root._newValue(percent);
            }
        }
    }

    Component.onCompleted: canvas.requestPaint()
}
