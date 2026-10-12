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
    id: top

    visible: false

    anchors {
        top: true
        left: true
    }

    margins {
        top: 50
        left: 550
    }

    property bool canHide: false
    property bool isactive: false

    property bool hasPlayer: Players.activePlayer !== null

    property bool isPlaying:
        Players.activePlayer?.isPlaying ?? false

    property string trackTitleOutput:
        Players.activePlayer?.trackTitle ?? ""

    property string trackArtistOutput:
        Players.activePlayer?.trackArtist ?? ""

    property string trackOutput:
        hasPlayer
            ? trackArtistOutput + trackTitleOutput
            : ""

    property int tracklength:
        Players.activePlayer
            ? Math.floor(Players.activePlayer.length / 60)
            : 0

    property int trackseconds:
        Players.activePlayer
            ? Math.floor(Players.activePlayer.length % 60)
            : 0

    property real position:
        Players.activePlayer
            ? Players.activePlayer.position / 60
            : 0

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

    Timer {
        id: openTimer

        interval: 800
        repeat: false

        onTriggered: {
            top.canHide = true

            if (hover.hovered)
                hideTimer.stop()
            else
                hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer

        interval: 100
        repeat: false

        onTriggered: {
            close()
        }
    }

    function active() {
        top.visible = true
        top.isactive = true
        top.canHide = false
        openTimer.restart()
    }

    function close() {
        top.isactive = false
        top.canHide = true
        openTimer.stop()
    }

    mask: Region {
        item: top.isactive ? maskCover : null
    }

    Item {
        id: maskCover
        anchors.fill: parent
    }

    FrameAnimation {
        running:
            Players.activePlayer?.playbackState ===
            MprisPlaybackState.Playing

        onTriggered: {
            if (Players.activePlayer)
                Players.activePlayer.positionChanged()
        }
    }

    Rectangle {
        id: popup

        implicitHeight: 150
        implicitWidth: 350

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -70

        scale: top.isactive ? 1 : 0.9
        opacity: top.isactive ? 1 : 0

        color: "#a9010101"
        radius: 30
        z: 5

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCirc
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutExpo
                easing.overshoot: 1.5
            }
        }

        Behavior on anchors.verticalCenterOffset {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 1.5
            }
        }

        HoverHandler {
            id: hover
        }

        Connections {
            target: hover

            function onHoveredChanged() {
                if (!top.canHide)
                    return

                if (hover.hovered)
                    hideTimer.stop()
                else
                    hideTimer.restart()
            }
        }

        ImageM {
            anchors.left: parent.left
            anchors.top: parent.top
        }

        Rectangle {
            id: cover

            visible: true

            color: "transparent"

            width: 130
            height: 130

            anchors.left: parent.left
            anchors.top: parent.top

            MultiEffect {
                source: image
                anchors.fill: image
                maskEnabled: true
                maskSource: mask
            }

            Image {
                id: image

                source:
                    Players.activePlayer?.trackArtUrl ?? ""

                visible: false

                width: cover.width
                height: cover.height

                smooth: true
                fillMode: Image.PreserveAspectCrop

                y: 10
                x: 5
            }

            Item {
                id: mask

                anchors.fill: image

                layer.enabled: true
                visible: false

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                }
            }
        }

        Text {
            font.family: "Varela"

            text: trackTitleOutput

            anchors.left: cover.right
            anchors.leftMargin: 12
            anchors.top: cover.top
            anchors.topMargin: 20

            width: parent.width - x - 20

            color: "white"
            font.pixelSize: 15

            elide: Text.ElideRight
        }

        Text {
            font.family: "Varela"

            text: trackArtistOutput

            anchors.left: cover.right
            anchors.leftMargin: 14
            anchors.top: cover.top
            anchors.topMargin: 40

            width: parent.width - x - 20

            color: "white"
            font.pixelSize: 12

            elide: Text.ElideRight
        }

        Text {
            font.family: "Varela"

            text:
                tracklength +
                ":" +
                (trackseconds < 10
                    ? "0" + trackseconds
                    : trackseconds)

            anchors.left: cover.right
            anchors.leftMargin: 10
            anchors.top: cover.top
            anchors.topMargin: 95

            color: "white"
            font.pixelSize: 12
        }

        Text {
            font.family: "Varela"

            text:
                Math.floor(position) +
                ":" +
                (
                    "0" +
                    Math.floor((position % 1) * 60)
                ).slice(-2)

            anchors.left: cover.right
            anchors.leftMargin: 180
            anchors.top: cover.top
            anchors.topMargin: 95

            color: "white"
            font.pixelSize: 12
        }

        Slider {
            id: progress

            width: 200
            height: 20

            from: 0

            to:
                Players.activePlayer?.length ?? 1

            value:
                Players.activePlayer?.position ?? 0

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
                    width:
                        progress.visualPosition *
                        parent.width

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

                x:
                    progress.visualPosition *
                    (progress.width - width)

                y:
                    (progress.height - height) / 2
            }

            Row {
                anchors.centerIn: parent

                spacing: 8

                anchors.verticalCenterOffset: -20
                anchors.horizontalCenterOffset: 0

                Text {
                    text: "skip_previous"

                    font.pixelSize: 20
                    color: Colors.palette.primary70
                    font.family: "Material Symbols Outlined"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (Players.activePlayer)
                                Players.activePlayer.previous()
                        }
                    }
                }

                Rectangle {
                    color:
                        Players.activePlayer?.isPlaying
                            ? Qt.alpha(
                                Colors.palette.primary80,
                                1
                            )
                            : Qt.alpha(
                                Colors.palette.primary80,
                                0.5
                            )

                    y: -2

                    width: 28
                    height: 28

                    radius: 30

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: "play_pause"

                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 25

                        color:
                            Players.activePlayer?.isPlaying
                                ? Qt.alpha(
                                    Colors.palette.primary20,
                                    1
                                )
                                : Qt.alpha(
                                    Colors.palette.primary20,
                                    0.8
                                )

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (Players.activePlayer)
                                    Players.activePlayer.togglePlaying()
                            }
                        }
                    }
                }

                Text {
                    text: "skip_next"

                    font.pixelSize: 20
                    color: Colors.palette.primary70
                    font.family: "Material Symbols Outlined"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (Players.activePlayer)
                                Players.activePlayer.next()
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible)
            hideTimer.stop()
    }
}