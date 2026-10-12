import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root

    property alias source: albumArt.source
    property bool spinning: true
    property real spinDuration: 6000
    property real pauseDuration: 0

    property int bumps: 10
    property real baseRadius: 0.36
    property real bumpDepth: 0.030

    property bool showProgress: true
    property real progress: 0
    property real ringThickness: 4
    property real ringGap: 6
    property color ringTrackColor: "#33ffffff"
    property color ringProgressColor: "#c7ff5e"

    readonly property real outerFlowerRadius: width * (baseRadius + bumpDepth)
    readonly property real ringRadius: outerFlowerRadius + ringGap + ringThickness / 2

    implicitWidth: 160
    implicitHeight: 160

    Shape {
        id: ringTrack
        visible: root.showProgress
        anchors.centerIn: parent
        width: (root.ringRadius + root.ringThickness / 2) * 2
        height: width

        property string trackPath: {
            var cx = width / 2
            var cy = height / 2
            var r = root.ringRadius

            return "M " + (cx + r) + " " + cy + " " +
                   "A " + r + " " + r + " 0 1 1 " + (cx - r) + " " + cy + " " +
                   "A " + r + " " + r + " 0 1 1 " + (cx + r) + " " + cy
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.ringTrackColor
            strokeWidth: root.ringThickness
            capStyle: ShapePath.RoundCap

            PathSvg {
                path: ringTrack.trackPath
            }
        }
    }

    Shape {
        id: ringProgress
        visible: root.showProgress && root.progress > 0
        anchors.centerIn: parent
        width: ringTrack.width
        height: ringTrack.height

        property string progressPath: {
            var cx = width / 2
            var cy = height / 2
            var r = root.ringRadius
            var pct = Math.max(0, Math.min(1, root.progress))

            if (pct <= 0)
                return ""

            if (pct >= 0.9999) {
                return "M " + (cx + r) + " " + cy + " " +
                       "A " + r + " " + r + " 0 1 1 " + (cx - r) + " " + cy + " " +
                       "A " + r + " " + r + " 0 1 1 " + (cx + r) + " " + cy
            }

            var startAngle = -Math.PI / 2
            var endAngle = startAngle + pct * Math.PI * 2

            var sx = cx + r * Math.cos(startAngle)
            var sy = cy + r * Math.sin(startAngle)
            var ex = cx + r * Math.cos(endAngle)
            var ey = cy + r * Math.sin(endAngle)

            var largeArc = pct > 0.5 ? 1 : 0

            return "M " + sx.toFixed(2) + " " + sy.toFixed(2) + " " +
                   "A " + r + " " + r + " 0 " +
                   largeArc + " 1 " +
                   ex.toFixed(2) + " " + ey.toFixed(2)
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.ringProgressColor
            strokeWidth: root.ringThickness
            capStyle: ShapePath.RoundCap

            PathSvg {
                path: ringProgress.progressPath
            }
        }
    }

    Shape {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        property string flowerPath: buildFlowerPath()

        function buildFlowerPath() {
            var cx = width / 2
            var cy = height / 2
            var baseR = width * root.baseRadius
            var amp = width * root.bumpDepth
            var steps = 160
            var d = ""

            for (var i = 0; i <= steps; i++) {
                var t = (i / steps) * Math.PI * 2
                var r = baseR + amp * Math.cos(root.bumps * t)

                var x = cx + r * Math.cos(t)
                var y = cy + r * Math.sin(t)

                d += (i === 0 ? "M " : "L ") +
                     x.toFixed(2) + " " +
                     y.toFixed(2) + " "
            }

            return d + "Z"
        }

        ShapePath {
            fillColor: "white"
            strokeColor: "transparent"
            fillRule: ShapePath.WindingFill

            PathSvg {
                path: mask.flowerPath
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

        PauseAnimation {
            duration: root.pauseDuration
        }

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