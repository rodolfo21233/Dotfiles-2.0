import QtQuick
import qs.services
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Canvas {
    id: circle
    width: 33
    height: 33

    property bool isPlaying: Players.activePlayer?.isPlaying || false
    property real animatedValue: 0

    onIsPlayingChanged: {
        animacionProgreso.to = isPlaying ? (Players.percentageProgress || 0) : 0
        animacionProgreso.start()
    }

    PropertyAnimation {
        id: animacionProgreso
        target: circle
        property: "animatedValue"
        duration: 500
        easing.type: Easing.OutCubic
    }

    Connections {
        target: Players

        function onPercentageProgressChanged() {
            if (isPlaying) {
                animatedValue = Players.percentageProgress || 0
            }
        }

        function onActivePlayerChanged() {
            circle.requestPaint()
        }
    }

    onAnimatedValueChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var centerX = width / 2
        var centerY = height / 2
        var radius = width / 2 - 5

        ctx.beginPath()
        ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
        ctx.fillStyle = '#b8b8b8'
        ctx.fill()

        ctx.beginPath()
        ctx.moveTo(centerX, centerY)
        ctx.arc(
            centerX,
            centerY,
            radius,
            -Math.PI / 2,
            (-Math.PI / 2) + (Math.PI * 2 * animatedValue)
        )
        ctx.closePath()

        ctx.fillStyle = '#000000'
        ctx.fill()
    }

    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -0.5
        anchors.horizontalCenterOffset: -0.5
        color: "white"
        implicitHeight: 18
        implicitWidth: 18
        radius: 12
        
        Text {
            anchors.centerIn: parent
            text: "󰐎"
            font.pixelSize: 12
        }
        
        MouseArea {
            anchors.fill: parent 
            onClicked: {
                if (Players.activePlayer) {
                    Players.activePlayer.togglePlaying()
                }
            }
        }
    }
}