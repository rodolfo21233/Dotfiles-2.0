import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import ".."
Item {
    id: tray

    width: 12
    height: 24

    property bool expanded: false
    property bool canhide: false
    readonly property int iconSize: 5
    readonly property int iconSpacing: 8
    readonly property int itemCount: repeater.count


    readonly property int iconsWidth: itemCount > 2
        ? itemCount * iconSize + (itemCount - 1) * iconSpacing 
        : 0
    Timer{
        id: wait
        repeat: no
        interval: 500
        onTriggered: {
            tray.expanded = false
            canhide = true
        }
    }
    Timer{
        id: close
        repeat: no
        interval: 300
        onTriggered: {
            if (canhide){
                canhide = false
                tray.expanded = false
            }
        }
    }

    Connections {
        target: tray

        function onExpandedChanged() {
            if (tray.expanded) {
                wait.restart()
            } else {
                wait.stop()
                
            }
        }
    }
    Rectangle {
        width: 25
        height: 33
        
        z: 20
        x: -12
        color: "transparent"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

           
            onEntered: {tray.expanded = true; close.stop() ; canhide = true ; wait.stop}
            onExited: close.start() 
        }
        
        Text {
            text: "chevron_right"
            font.family: "Material Symbols Outlined"
            font.pixelSize: 23
            color: Colors.md3.primary
            rotation: expanded? 180: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0
            Behavior on rotation {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutBack
                }
            }
        }
    }


    Row {
        id: icons

        spacing: 8
        z: 10
        y: 1

        // siempre tienen su tamaño
        x: tray.expanded? -width -12  : 0
        
        Behavior on x {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
            }
        }
        Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }
    

        Repeater {
            id: repeater
            model: SystemTray.items

            delegate: Item {
                width: tray.expanded ? 22: 0
                height: 22
                Behavior on width{
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutBack
                }
            }

                IconImage {
                    anchors.fill: parent
                    source: modelData.icon
                }

                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            modelData.display(parent, mouse.x, mouse.y)
                        } else {
                            modelData.activate()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {tray.expanded = true; close.stop() ; canhide = true ; wait.stop()}
                    onExited: close.start() 
                }
            }
        }
    }
}