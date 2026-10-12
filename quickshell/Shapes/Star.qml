import QtQuick
import QtQuick.Shapes

Shape {
    width: 16
    height: 16
    scale: width / 16
    ShapePath {
        strokeWidth: 0
        fillColor: "#2b1f1d"

        startX: 8
        startY: 0

        PathCubic {
            x: 10; y: 6
            control1X: 8; control1Y: 2
            control2X: 10; control2Y: 4
        }

        PathCubic {
            x: 16; y: 8
            control1X: 12; control1Y: 6
            control2X: 14; control2Y: 8
        }

        PathCubic {
            x: 10; y: 10
            control1X: 14; control1Y: 8
            control2X: 12; control2Y: 10
        }

        PathCubic {
            x: 8; y: 16
            control1X: 10; control1Y: 12
            control2X: 8; control2Y: 14
        }

        PathCubic {
            x: 6; y: 10
            control1X: 8; control1Y: 14
            control2X: 6; control2Y: 12
        }

        PathCubic {
            x: 0; y: 8
            control1X: 4; control1Y: 10
            control2X: 2; control2Y: 8
        }

        PathCubic {
            x: 6; y: 6
            control1X: 2; control1Y: 8
            control2X: 4; control2Y: 6
        }

        PathCubic {
            x: 8; y: 0
            control1X: 6; control1Y: 4
            control2X: 8; control2Y: 2
        }
    }
}