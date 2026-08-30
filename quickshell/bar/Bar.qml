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

ShellRoot {
    Scope {
        Variants {
            model: Quickshell.screens

            delegate: Component {
                PanelWindow {
                    id: top

                    required property var modelData
                    readonly property int trayExtraWidth:
                    tray.expanded && tray.itemCount > 32
                        ? tray.iconsWidth + tray.iconSpacing
                        : 0

                    WlrLayershell.layer: WlrLayer.Top
                    color: "transparent"
                    screen: modelData

                    Music2 {
                        id: music2
                    }

                    Time {
                        id: time
                    }

                    anchors {
                        top: true
                    }

                    PowerMenu {
                        id: powerMenu
                    }

                    implicitWidth: 900 + trayExtraWidth
                    implicitHeight: 33

                    Rectangle {
                        anchors.fill: parent
                        bottomLeftRadius: 12
                        bottomRightRadius: 12
                        color: Colors.md3.background
                        opacity: 1
                        z: -10
                    }

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutBack
                        }
                    }

                    // =========================
                    // WORKSPACES 
                    // =========================

                

                

                    // =========================
                    // MAIN LAYOUT
                    // =========================

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15

                        spacing: 0

                        // =========================
                        // LEFT
                        // =========================

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
                                    : 0

                                height: 25
                                color: Colors.md3.surface_container
                                opacity: 1
                                z: -1

                                
                                anchors.horizontalCenter: parent.horizontalCenter 
                                anchors.horizontalCenterOffset: 70-trayExtraWidth /2
                                y:-12
                                

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
                                                if (music.hasPlayer)
                                                    music2.active()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // =========================
                        // CENTER 
                        // =========================

                        Item {
                            Layout.fillWidth: true
                        Row{
                            x: 145
                      
                            Rectangle {
                                id: workspaces

                                width: 155
                                height: 25
                                color: Colors.md3.primary
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
                                    anchors.centerIn:workspaces
                                    anchors.horizontalCenterOffset: -70
                                    anchors.verticalCenterOffset: -6
                                
                                    
                                }
                                Text {
                                        anchors.left: workspaces.right
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: workspaces.verticalCenter
                                        font.family: "Varela"
                                        text: time.time + " " + time.day
                                        color: Colors.md3.primary
                                }
                            }
                        }
                    }

                        // =========================
                        // RIGHT
                        // =========================

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
                                    Text{
                                        font.family: "Material Symbols Outlined"
                                        text: "power_settings_new"
                                        anchors.centerIn:parent
                                        color: "red"
                                        font.pixelSize: 16
                                        anchors.verticalCenterOffset: 0
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: powerMenu.active = !powerMenu.active
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