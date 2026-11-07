import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root

    property alias source: albumArt.source
    property bool spinning: true
    property real spinDuration: 6000
    property real pauseDuration: 0

    property int bumps: 8
    property real baseRadius: 0.36
    property real bumpDepth: 0.030

    // Giro compartido por la flor y los anillos (en grados)
    property real flowerSpin: 0
    property real flowerSpinDuration: 20000
    readonly property real flowerPhase: flowerSpin * Math.PI / 180

    property bool showProgress: true
    property real progress: 0
    property real ringThickness: 4
    property real ringGap: 6
    property color ringTrackColor: "#33ffffff"
    property color ringProgressColor: "#c7ff5e"

    readonly property real ringRadius: width * baseRadius + ringGap + ringThickness / 2
    readonly property real ringAmp: width * bumpDepth

    implicitWidth: 160
    implicitHeight: 160

    NumberAnimation on flowerSpin {
        from: 0; to: 360
        duration: root.flowerSpinDuration
        loops: Animation.Infinite
        running: root.spinning
    }

    // Genera un tramo del contorno ondulado entre los ángulos a0 y a1
    function wavePath(r0, amp, phase, a0, a1, cx, cy, closed) {
        var span = a1 - a0
        var steps = Math.max(2, Math.ceil(180 * Math.abs(span) / (Math.PI * 2)))
        var d = ""
        for (var i = 0; i <= steps; i++) {
            var t = a0 + span * i / steps
            var r = r0 + amp * Math.cos(root.bumps * (t - phase))
            d += (i === 0 ? "M " : "L ") +
                 (cx + r * Math.cos(t)).toFixed(2) + " " +
                 (cy + r * Math.sin(t)).toFixed(2) + " "
        }
        return closed ? d + "Z" : d
    }

    Shape {
        id: ringTrack
        visible: root.showProgress
        anchors.centerIn: parent
        width: (root.ringRadius + root.ringAmp + root.ringThickness / 2) * 2
        height: width

        property string trackPath: root.wavePath(
            root.ringRadius, root.ringAmp, root.flowerPhase,
            0, Math.PI * 2, width / 2, height / 2, true)

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.ringTrackColor
            strokeWidth: root.ringThickness
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg { path: ringTrack.trackPath }
        }
    }

    Shape {
        id: ringProgress
        visible: root.showProgress && root.progress > 0
        anchors.centerIn: parent
        width: ringTrack.width
        height: ringTrack.height

        property string progressPath: {
            var pct = Math.max(0, Math.min(1, root.progress))
            if (pct <= 0)
                return ""

            var start = -Math.PI / 2
            var full = pct >= 0.9999
            var end = full ? start + Math.PI * 2 : start + pct * Math.PI * 2

            return root.wavePath(
                root.ringRadius, root.ringAmp, root.flowerPhase,
                start, end, width / 2, height / 2, full)
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.ringProgressColor
            strokeWidth: root.ringThickness
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg { path: ringProgress.progressPath }
        }
    }

    Item {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Shape {
            id: flower
            anchors.fill: parent

            property string flowerPath: buildFlowerPath()

            function buildFlowerPath() {
                var cx = width / 2
                var cy = height / 2
                var baseR = width * root.baseRadius
                var amp = width * root.bumpDepth
                var steps = 120
                var d = ""
                for (var i = 0; i <= steps; i++) {
                    var t = (i / steps) * Math.PI * 2
                    var r = baseR + amp * Math.cos(root.bumps * t)
                    d += (i === 0 ? "M " : "L ") +
                         (cx + r * Math.cos(t)).toFixed(2) + " " +
                         (cy + r * Math.sin(t)).toFixed(2) + " "
                }
                return d + "Z"
            }

            transform: Rotation {
                origin.x: flower.width / 2
                origin.y: flower.height / 2
                angle: root.flowerSpin
            }

            ShapePath {
                fillColor: "white"
                strokeColor: "transparent"
                fillRule: ShapePath.WindingFill
                PathSvg { path: flower.flowerPath }
            }
        }
    }

    Image {
        id: albumArt
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: false
        layer.enabled: true
        asynchronous: true
        transformOrigin: Item.Center
    }

    SequentialAnimation {
        id: spinAnim
        running: root.spinning
        loops: Animation.Infinite

        PauseAnimation { duration: root.pauseDuration }

        NumberAnimation {
            target: albumArt
            property: "rotation"
            from: 0
            to: 360
            duration: root.spinDuration
            easing.type: Easing.Linear
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: albumArt
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 0.05
    }
}