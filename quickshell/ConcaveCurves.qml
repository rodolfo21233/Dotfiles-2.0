import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import ".."

Item {
    id: root

    property int radius: 12
    property color color: Colors.md3.background
    property bool isTop: true
    property bool mirrored: false

    implicitWidth: radius
    implicitHeight: radius

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#000000"
        shadowBlur: 0.8
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 3
    }

    Shape {
        id: shape

        anchors.fill: parent

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
}