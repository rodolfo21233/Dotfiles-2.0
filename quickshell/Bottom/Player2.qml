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

PanelWindow {
    WlrLayershell.layer: WlrLayer.Bottom

    width: 300
    height: 400

    color: "transparent"

    anchors {
        left: true
        top: true
    }

    margins {
        left: 100
        top: 120
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.md3.background
        radius: 8
    }

    property real playerProgress: {
        var player = Players.activePlayer

        if (!player)
            return 0

        var length = Number(player.length)
        var position = Number(player.position)

        if (!isFinite(length) || !isFinite(position) || length <= 0)
            return 0

        return Math.max(0, Math.min(1, position / length))
    }

    property bool hasPlayer: Players.activePlayer !== null

    property bool isPlaying:
        Players.activePlayer?.isPlaying ?? false

    property string trackTitleOutput:
        Players.activePlayer?.trackTitle
        ? Players.activePlayer.trackTitle + ""
        : ""

    property string trackArtistOutput:
        Players.activePlayer?.trackArtist
        ? Players.activePlayer.trackArtist + ""
        : ""

    property string trackOutput:
        hasPlayer
        ? trackTitleOutput + trackArtistOutput
        : ""

    property real scrollSpeed: 70
    property real pauseDuration: 0

    AlbumArtFlower {
        id: cover

        width: 260
        height: 260

        anchors.centerIn:parent
        anchors.left: parent.left
        anchors.top: parent.top

        source: Players.activePlayer?.trackArtUrl ?? ""

        spinning: Players.activePlayer?.isPlaying ?? false

        progress: playerProgress

        ringProgressColor: Colors.md3.primary
        anchors.verticalCenterOffset: -70
    }
    Text {
        text: "music_note"
         font.family: "Material Symbols Outlined"
        anchors.centerIn: parent

        color: Colors.md3.primary

        font.pixelSize: 80

        anchors.verticalCenterOffset: -70

        opacity: Players.activePlayer?.hasPlayer?  0 : 0.6
        rotation: 10
        z: -2
    }
    Text {
        font.family: "Varela"
        font.bold: true

        text: trackTitleOutput

        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60

        color: Colors.md3.primary

        font.pixelSize: 20

        elide: Text.ElideRight
    }

    Text {
        font.family: "Varela"

        text: trackArtistOutput

        anchors.centerIn: parent
        anchors.verticalCenterOffset: 90

        color: Colors.md3.secondary

        font.pixelSize: 18

        elide: Text.ElideRight
    }
}