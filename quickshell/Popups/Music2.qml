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
import QtQuick.Shapes
import "../bar" 
import qs.services
import QtQuick.Effects
import "Colors"

PanelWindow{
    id: top
    visible: false
    anchors{
        top: true
        left: true
        
        
    }
    margins {
        top: 50
        left:550

       
    }
    property bool canHide: false
    
    Timer {
        id: openTimer
        interval: 800    // 300 ms para mover el cursor
        repeat: false

        onTriggered: {
            top.canHide = true
            if (hover.hovered)
                hideTimer.stop()
            else
                hideTimer.restart()
        }
    }
    function active(){
        top.visible = true
        top.isactive = true
        canHide = false
        openTimer.restart()
        
    
    }
     function close(){
        top.isactive = false
        canHide = true
        openTimer.stop()
    
    }
    mask: Region {
        item:  isactive? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }
    property bool isactive: false
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 300
    implicitWidth: 350

    color: "transparent"
    
    Behavior on implicitWidth {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuint
            }
        }
    property bool hasPlayer: Players.activePlayer !== null
    property bool isPlaying: Players.activePlayer?.isPlaying
    property string trackTitleOutput: Players.activePlayer?.trackTitle ? Players.activePlayer?.trackTitle : ""
    property string trackArtistOutput: Players.activePlayer?.trackArtist ? Players.activePlayer?.trackArtist : ""
    property string trackOutput: isPlaying ? trackArtistOutput + trackTitleOutput : ""
    

    Rectangle{
        id: popup
        
        HoverHandler {
            id: hover
        }

    Timer {
        id: hideTimer
        interval: 100  // espera 300 ms antes de ocultar
        repeat: false
        onTriggered: close()
    }

    onVisibleChanged: {
        if (visible)
            hideTimer.stop()
    }

    Connections {
    target: hover

    function onHoveredChanged() {
        if (!top.canHide)
            return
        if (hover.hovered) {
            hideTimer.stop()
        } else {
            hideTimer.restart()
        }
    }
}
        implicitHeight:150
        implicitWidth: 350
        anchors.verticalCenterOffset: -70
        scale: isactive? 1: 0.9
        anchors.centerIn:parent
        color: '#a9010101'
        radius: 30
        z: 5
        opacity: isactive? 1: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                 easing.type: Easing.OutCirc
            }
        }
         Behavior on scale{
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutExpo
                easing.overshoot: 1.5
            }
        }
         Behavior on anchors.verticalCenterOffset{
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 1.5
            }
        }
        
        ImageM {
            
        }
    Rectangle {
        id:root
        visible: true
        color: "transparent"
        width: 130
        height: 130

        MultiEffect {
            source: image
            anchors.fill: image
            maskEnabled: true
            maskSource: mask
        }

        Image {
            id: image
            source: Players.selectedPlayer.trackArtUrl
            visible: false

            width: root.width
            height: root.height
            smooth: true
            fillMode: Image.PreserveAspectCrop
            y: 10
            x: 5
        }

        Item {
            id: mask
            anchors.fill: image; layer.enabled: true; visible: false
            Rectangle { anchors.fill: parent; radius: 12 }
        }
       
    }

        
     Text {
        font.family: "Varela"
        text: trackTitleOutput

        anchors.left: root.right
        anchors.leftMargin: 12
        anchors.top: root.top
        anchors.topMargin: 20

        width: parent.width - x - 20

        color: "white"
        font.pixelSize: 15
        elide: Text.ElideRight
    }

       Text {
        font.family: "Varela"
        text: trackArtistOutput

        anchors.left: root.right
        anchors.leftMargin: 14
        y: 40

        width: parent.width - x - 20

        color: "white"
        font.pixelSize: 12
        elide: Text.ElideRight
    }

    Slider {
            id: progress

            width: 200
            height: 20

            from: 0
            to: Players.activePlayer?.length ?? 1
            value: Players.activePlayer?.position ?? 0

            anchors.centerIn: parent
            anchors.verticalCenterOffset: 40
            anchors.horizontalCenterOffset: 65

            onMoved: {
                if (Players.activePlayer)
                    Players.activePlayer.position = value
            }

            background: Rectangle {
                width: 200
                height: 3
                radius: 8
                anchors.centerIn: parent

                color: Colors.palette.secondary50

                Rectangle {
                    width: progress.visualPosition * parent.width
                    height: parent.height
                    radius: 8
                    color: Colors.md3.primary
                }
            }
            
            handle: Rectangle {
                width: 12
                height: 12
                radius: 30
                color: Colors.md3.secondary

                x: progress.visualPosition * (progress.width - width)
                y: (progress.height - height) / 2
            }
            Row{
                anchors.centerIn:parent
                spacing : 8
                anchors.verticalCenterOffset: -20
                anchors.horizontalCenterOffset: 0
                Text{
                    text: "skip_previous"
                    font.pixelSize: 20
                    color: Colors.palette.primary70
                    font.family: "Material Symbols Outlined"
                    MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                Players.activePlayer.previous()
                            }
                        }
                }
                Rectangle{
                    color: Players.activePlayer?.isPlaying? Qt.alpha(Colors.palette.primary80, 1) : Qt.alpha(Colors.palette.primary80, 0.5)
                    y: -2
                    width: 28
                    height: 28
                    radius: 30
                    Behavior on color{
                        ColorAnimation{
                            duration: 100
                        }
                    }
                     Text{
                        anchors.centerIn:parent
                        text: "play_pause"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 25
                        color: Players.activePlayer?.isPlaying? Qt.alpha(Colors.palette.primary20, 1) : Qt.alpha(Colors.palette.primary20, 0.8)
                        Behavior on color{
                            ColorAnimation{
                             duration: 100
                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                Players.activePlayer.togglePlaying()
                            }
                        }
                    }
                }
                Text{
                    text: "skip_next"
                    font.pixelSize: 20
                    color: Colors.palette.primary70
                    font.family: "Material Symbols Outlined"
                    MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                Players.activePlayer.next()
                            }
                        }
                }
            }
        }
    }
}

