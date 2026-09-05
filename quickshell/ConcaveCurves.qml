import QtQuick
import QtQuick.Shapes
import ".."

Shape {
    id: root

    property int radius: 12
    property color color: Colors.md3.background
    property bool isTop: true
    property bool mirrored: false

    implicitWidth: radius
    implicitHeight: radius

    // CurveRenderer falla en silencio en el primer frame dentro de
    // ventanas wlr-layer-shell (Quickshell/PanelWindow). GeometryRenderer
    // es el default y es estable desde el arranque en frío.
    preferredRendererType: Shape.GeometryRenderer

    transform: Scale {
        xScale: root.mirrored ? -1 : 1
        origin.x: root.radius / 2
        origin.y: root.radius / 2
    }

    ShapePath {
        fillColor: root.color
        strokeColor: "transparent"
        startX: root.isTop ? root.radius : 0
        startY: 0

        PathLine {
            x: 0
            y: root.isTop ? 0 : root.radius
        }
        PathLine {
            x: root.isTop ? 0 : root.radius
            y: root.radius
        }
        PathArc {
            x: root.isTop ? root.radius : 0
            y: 0
            radiusX: root.radius
            radiusY: root.radius
            direction: root.isTop ? 0 : 1
        }
    }
}