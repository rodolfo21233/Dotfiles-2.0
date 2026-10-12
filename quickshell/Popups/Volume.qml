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

PanelWindow {
    id: windowRoot
    anchors {
        left: true
        bottom: true
        top: true
    }
    color: "transparent"
    width: 3

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property bool stripHovered: false
    property bool panelHovered: false
    property bool volumePressed: false
    property bool brightnessPressed: false

    function shouldStayOpen() {
        return stripHovered || panelHovered || volumePressed || brightnessPressed
    }

    function evaluateClose() {
        if (shouldStayOpen()) closeTimer.stop()
        else closeTimer.restart()
    }

    onStripHoveredChanged: {
        if (stripHovered) {
            closeTimer.stop()
            volume.active = true
            volume.visible = true
        } else {
            evaluateClose()
            
        }
    }
    onPanelHoveredChanged: evaluateClose()
    onVolumePressedChanged: evaluateClose()
    onBrightnessPressedChanged: evaluateClose()

    HoverHandler {
        onHoveredChanged: windowRoot.stripHovered = hovered
    }

  
    component SpeakerIcon: Canvas {
        property color strokeColor: "#000000"
        width: 16
        height: 16
        onStrokeColorChanged: requestPaint()
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = strokeColor
            ctx.strokeStyle = strokeColor
            ctx.lineWidth = 1.3
            ctx.beginPath()
            ctx.moveTo(1, 6)
            ctx.lineTo(4.5, 6)
            ctx.lineTo(8.5, 2.5)
            ctx.lineTo(8.5, 13.5)
            ctx.lineTo(4.5, 10)
            ctx.lineTo(1, 10)
            ctx.closePath()
            ctx.fill()
            ctx.beginPath()
            ctx.arc(8.5, 8, 3, -0.7, 0.7)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(8.5, 8, 5.3, -0.6, 0.6)
            ctx.stroke()
        }
    }

    
    component SunIcon: Canvas {
        property color strokeColor: "#000000"
        width: 16
        height: 16
        onStrokeColorChanged: requestPaint()
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = strokeColor
            ctx.strokeStyle = strokeColor
            ctx.lineWidth = 1.3
            ctx.beginPath()
            ctx.arc(8, 8, 3, 0, Math.PI * 2)
            ctx.fill()
            for (var i = 0; i < 8; i++) {
                var a = i * Math.PI / 4
                ctx.beginPath()
                ctx.moveTo(8 + Math.cos(a) * 5, 8 + Math.sin(a) * 5)
                ctx.lineTo(8 + Math.cos(a) * 7, 8 + Math.sin(a) * 7)
                ctx.stroke()
            }
        }
    }

    component NoteIcon: Canvas {
        property color strokeColor: "#000000"
        width: 16
        height: 16
        onStrokeColorChanged: requestPaint()
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = strokeColor
            ctx.beginPath()
            ctx.arc(5, 11, 2.3, 0, Math.PI * 2)
            ctx.fill()
            ctx.fillRect(7.1, 3, 1.3, 8)
            ctx.beginPath()
            ctx.moveTo(8.4, 3)
            ctx.lineTo(11.5, 4.5)
            ctx.lineTo(8.4, 6.5)
            ctx.closePath()
            ctx.fill()
        }
    }

    PanelWindow {
        id: volume
        property bool active: false
        color: "transparent"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
       
        anchors {
            left: true
            top: true
        }

        width: active ? 140 : 0
        height: 250
        

        Behavior on width {
            NumberAnimation { duration: 400; easing.type: Easing.OutBack }
        }

        margins {
            top: (windowRoot.height - height) / 2
        }

        HoverHandler {
            onHoveredChanged: windowRoot.panelHovered = hovered
        }
        Rectangle{
            anchors.fill: parent
            color: Colors.md3.background
            topRightRadius: 8
            bottomRightRadius: 8
        RowLayout {
            anchors.centerIn: parent
            spacing: 18

            
            ColumnLayout {
                spacing: 8

                Rectangle {
                    id: volumeBg
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 220
                    radius: width / 2
                    color: Colors.palette.secondary15
                    clip: true

                    property real level: volumeBg.height * (verticalSlider.value / verticalSlider.to)
                    property real fillHeight: Math.max(48, level)

                    Behavior on fillHeight {
                        NumberAnimation { duration: 70; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: volumeBg.fillHeight
                        radius: volumeBg.radius
                        color: Colors.md3.primary
                    }

                
                    Rectangle {
                        width: 30
                        height: 30
                        radius: width / 2
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#ffffff"
                        SpeakerIcon { anchors.centerIn: parent; strokeColor: "#3a3a42" }
                    }

                    Slider {
                        id: verticalSlider
                        anchors.fill: parent
                        orientation: Qt.Vertical
                        from: 0
                        to: 100

                        property bool syncing: false

                        background: Item {}
                        handle: Item { implicitWidth: 0; implicitHeight: 0 }

                        onPressedChanged: windowRoot.volumePressed = pressed

                        Connections {
                            target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
                            function onVolumeChanged() {
                                if (verticalSlider.syncing) return
                                verticalSlider.syncing = true
                                verticalSlider.value = Pipewire.defaultAudioSink.audio.volume * 100
                                verticalSlider.syncing = false
                            }
                        }

                        Component.onCompleted: {
                            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                                syncing = true
                                value = Pipewire.defaultAudioSink.audio.volume * 100
                                syncing = false
                            }
                        }

                        onValueChanged: {
                            if (syncing) return
                            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                                syncing = true
                                Pipewire.defaultAudioSink.audio.volume = value / 100
                                syncing = false
                            }
                        }
                    }
                }

    
            }

            ColumnLayout {
                spacing: 8

                Rectangle {
                    id: brightnessBg
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 220
                    radius: width / 2
                    color:  Colors.palette.secondary15
                    clip: true

                    property real level: brightnessBg.height * (brightnessSlider.value / brightnessSlider.to)
                    property real fillHeight: Math.max(48, level)

                    Behavior on fillHeight {
                        NumberAnimation { duration: 70; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: brightnessBg.fillHeight
                        radius: brightnessBg.radius
                        color: Colors.md3.primary
                    }

                  

                    Rectangle {
                        width: 30
                        height: 30
                        radius: width / 2
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#ffffff"
                        SunIcon { anchors.centerIn: parent; strokeColor: "#3a3a42" }
                    }

                    Slider {
                        id: brightnessSlider
                        anchors.fill: parent
                        orientation: Qt.Vertical
                        from: 0
                        to: 100
                        value: 100

                        property bool syncing: false

                        background: Item {}
                        handle: Item { implicitWidth: 0; implicitHeight: 0 }

                        onPressedChanged: windowRoot.brightnessPressed = pressed

                        onValueChanged: {
                            if (syncing) return
                            brightnessDebounce.restart()
                        }
                    }

                    Process {
                        id: brightnessInit
                        command: ["brightnessctl", "-m", "i"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                const parts = text.trim().split(",")
                                if (parts.length >= 4) {
                                    const pct = parseInt(parts[3].replace("%", ""))
                                    if (!isNaN(pct)) {
                                        brightnessSlider.syncing = true
                                        brightnessSlider.value = pct
                                        brightnessSlider.syncing = false
                                    }
                                }
                            }
                        }
                    }

                    Component.onCompleted: brightnessInit.running = true

                    Timer {
                        id: brightnessDebounce
                        interval: 40
                        repeat: false
                        onTriggered: brightnessSet.running = true
                    }

                    Process {
                        id: brightnessSet
                        command: ["brightnessctl", "set", Math.round(brightnessSlider.value) + "%"]
                    }
                }

              
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 150
        repeat: false
        onTriggered: {
            volume.active = false
            closeTimer2.start()
        }
    }
    Timer {
        id: closeTimer2
        interval: 150
        repeat: false
        onTriggered: {
            volume.visible = false
        }
    }
}
   }