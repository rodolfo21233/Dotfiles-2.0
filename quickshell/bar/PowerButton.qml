import QtQuick
import ".."

Item {
    id: root

    property string icon: ""
    property string label: ""
    property color accentColor: Colors.md3.primary
    property int index: 0          // orden en el que aparece
    property int staggerDelay: 90  // ms entre cada botón
    property bool revealed: false  // lo controla el menú padre

    signal triggered()

    width: 110
    height: 130

    property bool ready: false

    opacity: ready ? 1 : 0
    scale: ready ? 1 : 0.55
    y: ready ? 0 : 24

    // Aquí a diferencia de la barra, el rebote de OutBack SÍ queda bien,
    // porque son botones "apareciendo", no algo que crece lateralmente.
    Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    Behavior on scale   { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
    Behavior on y        { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    Timer {
        id: revealTimer
        interval: root.index * root.staggerDelay
        onTriggered: root.ready = true
    }

    onRevealedChanged: {
        if (revealed) {
            revealTimer.restart()
        } else {
            revealTimer.stop()
            ready = false // al cerrar, todos se van juntos (no escalonado)
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 22
        color: Colors.md3.surface_container

        Behavior on color { ColorAnimation { duration: 150 } }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.icon
                font.family: "Material Symbols Outlined"
                font.pixelSize: 38
                color: root.accentColor
            }

            Text {
                font.family: "Syne"
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.label
                font.pixelSize: 14
                color: Colors.md3.primary // cámbialo por tu color de texto si tienes uno distinto
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: card.color = Qt.lighter(Colors.md3.surface_container, 1.25)
            onExited: card.color = Colors.md3.surface_container
            onClicked: root.triggered()
        }
    }
}