import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Wayland
import ".."
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Hyprland
import qs.Popups
import qs.services
import QtQuick.Effects
ShellRoot {
    Scope {
        Variants {
            model: Quickshell.screens

            delegate: Component {
                PanelWindow {
                    id: top

                    required property var modelData
                    property string font: "GohuFont 14 Nerd Font"
                    readonly property int trayExtraWidth:
                        tray.expanded && tray.itemCount > 2
                            ? tray.iconsWidth + tray.iconSpacing
                            : 0

                    WlrLayershell.layer: WlrLayer.Top
                    color: "transparent"
                    screen: modelData

                    property bool expanded: false
                    
                    Music2 {
                        id: music2
                    }

                    Time {
                        id: time
                    }

                    Info{
                        id: panel2
                        bar: top
                    }
             

                    anchors {
                        top: true
                    }

                    PowerMenu {
                        id: powerMenu
                    }

                   


                    implicitWidth: 1920
                    implicitHeight: 38

                    Rectangle {
                        visible: true
                        anchors.centerIn: parent
                        id: panel
                        implicitWidth: 900 + trayExtraWidth
                        implicitHeight: top.implicitHeight
                        x: 25
                        bottomLeftRadius: 12
                        bottomRightRadius: 12
                        color: Colors.md3.background
                        opacity: 1
                        z: -4


                

                        ConcaveCurves {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.rightMargin: -20
                            radius: 20
                            color: Colors.md3.background
                            isTop: true
                            mirrored: false
                            anchors.topMargin: 0
                        }

                        ConcaveCurves {
                            anchors.top: parent.top
                            anchors.right: parent.left
                            anchors.rightMargin: 0
                            radius: 20
                            color: Colors.md3.background
                            isTop: true
                            mirrored: true
                            anchors.topMargin: 0
                        }
                         Behavior on implicitWidth {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutBack
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 50
                                
                            }
                        }
                    }
                    
                    
                    function barExpand(){
                        panel.opacity = 0
                        row.opacity = 0
                        tray.expanded = false
                    }
                     function barOpen(){
                        panel.opacity = 1
                        row.opacity =1
                    }

                    Rectangle {
                        width: 1920
                        height: 5
                        z: -5
                        color: Colors.md3.background
                        visible: false
                    }

                    RowLayout {
                        visible: panel.visible
                        anchors.fill: panel
                        id: row
                        opacity: 1
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Active_Window {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                y: 0
                            }

                            Rectangle {
                                id: capsule

                                width: music.hasPlayer
                                    ? Math.min(music.trackTextWidth + 50, 220)
                                    : 120

                                height: 25
                                color: Colors.md3.surface_container
                                opacity: 1
                                z: -1

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: 70 - trayExtraWidth / 2
                                y: -12

                                radius: 30

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 500
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.5
                                    }
                                }

                                Behavior on anchors.horizontalCenterOffset {
                                    NumberAnimation {
                                        duration: 400
                                        easing.type: Easing.OutBack
                                    }
                                }

                                Row {
                                    x: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5

                                    Text {
                                        text: "music_note"
                                        font.family: "Material Symbols Outlined"
                                        color: "#9effa3"
                                        font.pixelSize: 19
                                        rotation: 10
                                        opacity: music.hasPlayer ? 1 : 0

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }
                                    }

                                    Music {
                                        id: music

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onEntered: {
                                                if (music.hasPlayer) {
                                                    barExpand()
                                                    panel2.open()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                text: music.hasPlayer ? "" : "Nothing playing"
                                color: Colors.md3.primary
                                font: top.font
                                opacity: 0.9
                                anchors.centerIn: capsule
                                anchors.verticalCenterOffset: 0
                            }
                        }

                        Item {
                            Layout.fillWidth: true

                            Row {
                                x: 145

                                Rectangle {
                                    id: workspaces

                                    width: 155
                                    height: 25
                                    color: Colors.md3.surface_container
                                    radius: 30
                                    z: 0

                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.horizontalCenterOffset: -10 - (trayExtraWidth / 2)

                                    Behavior on anchors.horizontalCenterOffset {
                                        NumberAnimation {
                                            duration: 400
                                            easing.type: Easing.OutBack
                                        }
                                    }

                                    Workspaces {
                                        id: workspaceWidget
                                        anchors.centerIn: workspaces
                                        anchors.horizontalCenterOffset: -70
                                        anchors.verticalCenterOffset: -6
                                    }

                                    Text {
                                        anchors.left: workspaces.right
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: workspaces.verticalCenter
                                        font.family: top.font
                                        font.pixelSize: 13
                                        text: time.time + "· " + time.day
                                        color: Colors.md3.primary
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Tray {
                                    id: tray
                                    y: 2
                                }

                                Battery {
                                    y: 2
                                }

                                Rectangle {
                                    width: 20
                                    height: 28
                                    y: -1

                                    radius: 8
                                    color: "transparent"
                                    opacity: 0.5

                                    Text {
                                        font.family: "Material Symbols Outlined"
                                        text: "power_settings_new"
                                        anchors.centerIn: parent
                                        color: "red"
                                        font.pixelSize: 16
                                        anchors.verticalCenterOffset: 0
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked:
                                            powerMenu.active = !powerMenu.active
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}