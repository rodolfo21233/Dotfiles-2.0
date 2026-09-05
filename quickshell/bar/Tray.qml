//@ pragma UseQApplication
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
   
    readonly property int iconSize: 5
    readonly property int iconSpacing: 8
    readonly property int itemCount: repeater.count


    readonly property int iconsWidth: itemCount > 2
        ? itemCount * iconSize + (itemCount - 1) * iconSpacing 
        : 0

    
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
        id: chevronButton

        width: 25
        height: 33
        x: -12
        z: 100
        color: "transparent"

        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -1

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton

            onClicked: {
                tray.expanded = !tray.expanded
                close.stop()
                wait.stop()
                canhide = false
            }
        }

        Text {
            text: "chevron_right"
            font.family: "Material Symbols Outlined"
            font.pixelSize: 23
            color: Colors.md3.primary

            rotation: tray.expanded ? 180 : 0

            anchors.centerIn: parent

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
                width: tray.expanded ? 22 : 0
                height: 22
                Behavior on width {
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
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                 
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            if (modelData.hasMenu) {
                                const pos = mapToItem(tray.QsWindow.window.contentItem, mouse.x, mouse.y)
                                modelData.display(tray.QsWindow.window, pos.x, pos.y)
                                canhide = false
                            }
                        } else {
                            modelData.activate()
                        }
                    }
                }
            }
        }
    }
}