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
import "Colors"
import "Bar"
PanelWindow {
    id: panel1
    property string font: "GohuFont 14 Nerd Font"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    property var bar
    

    visible: false

    mask: Region {
        item: visible ? maskCover : null
    }

    Item {
        id: maskCover
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        enabled: true

        onClicked: {
            close()
        }
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

    // ---------- LETRAS ----------
    property string lyricsBaseUrl: "http://localhost:8080"
    property var lyricLines: []          // [{ t: ms, text: "..." }]
    property int lyricIndex: -1
    property string lyricsState: "idle"  // idle | loading | ok | none | error

    // ID de Spotify desde MPRIS: /com/spotify/track/XXXX  ->  XXXX
    property string trackId: {
        var md = Players.activePlayer?.metadata
        var raw = md ? md["mpris:trackid"] : ""
        if (!raw) return ""
        var m = ("" + raw).match(/track[\/:]([A-Za-z0-9]+)/)
        return m ? m[1] : ""
    }

    onTrackIdChanged: fetchLyrics()
    Component.onCompleted: fetchLyrics()

    function fetchLyrics() {
        lyricLines = []
        lyricIndex = -1
        if (trackId === "") { lyricsState = "idle"; return }

        lyricsState = "loading"
        var requested = trackId
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (requested !== trackId) return          // cambio la cancion mientras llegaba
            if (xhr.status === 0) { lyricsState = "error"; return }   // servidor apagado
            try {
                var data = JSON.parse(xhr.responseText)
                if (data.error || data.syncType !== "LINE_SYNCED") {
                    lyricsState = "none"
                    return
                }
                lyricLines = data.lines.map(function(l) {
                    return { t: Number(l.startTimeMs), text: l.words }
                })
                lyricsState = "ok"
                updateLyricIndex()
            } catch (e) {
                lyricsState = "error"
            }
        }
        xhr.open("GET", lyricsBaseUrl + "/?trackid=" + requested)
        xhr.send()
    }

    function updateLyricIndex() {
        var p = Players.activePlayer
        if (!p || lyricLines.length === 0) return
        var posMs = Number(p.position) * 1000
        var idx = -1
        for (var k = 0; k < lyricLines.length; k++) {
            if (lyricLines[k].t <= posMs) idx = k
            else break
        }
        if (idx !== lyricIndex) lyricIndex = idx
    }

    Timer {
        interval: 150
        repeat: true
        running: panel1.visible && panel1.isPlaying && panel1.lyricsState === "ok"
        onTriggered: {
            Players.activePlayer.positionChanged()   // Quickshell no refresca position solo
            panel1.updateLyricIndex()
        }
    }
    // ---------- FIN LETRAS ----------

    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    implicitWidth: 1920
    implicitHeight: 38

    Rectangle {
        id: panel

        
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: 900
        implicitHeight: panel1.implicitHeight

       

        bottomLeftRadius: 12
        bottomRightRadius: 12

        color: Colors.md3.background
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
            }
        }
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


        AlbumArtFlower {
            id: cover

            width: 260
            height: 260

            opacity: 1

            anchors.left: parent.left
            anchors.top: parent.top

            source: Players.activePlayer?.trackArtUrl ?? ""

            spinning: Players.activePlayer?.isPlaying ?? false

            progress: playerProgress

            ringProgressColor: Colors.md3.primary
            anchors.verticalCenterOffset: -70
              Behavior on opacity {
                NumberAnimation {
                    duration: 100
                }
            }
            
          Text {
            font.family: panel1.font
            font.bold: false

            text: trackArtistOutput
            width: controls.width + 12

            anchors.left: parent.left
            anchors.leftMargin: 284
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -10

            color: Colors.md3.secondary

            font.pixelSize: 16

            elide: Text.ElideRight
        }
            Text {
            font.family: panel1.font
            font.bold: false
        
            text: trackTitleOutput
            width: controls.width + 12

            anchors.left: parent.left
            anchors.leftMargin: 284
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -40

            color: Colors.md3.primary
            font.pointSize: 16
          

            elide: Text.ElideRight
        }
        }

        Row {
            id: controls

            anchors.left: cover.right
            anchors.leftMargin: 24
            anchors.verticalCenter: cover.verticalCenter
            anchors.verticalCenterOffset: 60

            spacing: 4

            opacity: cover.opacity

            Rectangle {
                id: prevButton

                width: 64
                height: 56

                topLeftRadius: 28
                bottomLeftRadius: 28
                topRightRadius: prevArea.pressed ? 6 : 10
                bottomRightRadius: prevArea.pressed ? 6 : 10

                scale: prevArea.pressed ? 0.93 : 1

                color: Qt.alpha(
                    Colors.palette.primary70,
                    prevArea.pressed
                        ? 0.38
                        : prevArea.containsMouse ? 0.28 : 0.16
                )

                Behavior on topRightRadius {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: "skip_previous"

                    font.pixelSize: 28
                    color: Colors.palette.primary70
                    font.family: "Material Symbols Outlined"
                }

                MouseArea {
                    id: prevArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (Players.activePlayer)
                            Players.activePlayer.previous()
                    }
                }
            }

            Rectangle {
                id: playButton

                width: 88
                height: 56

                radius: playArea.pressed
                    ? 10
                    : (Players.activePlayer?.isPlaying ? 16 : 28)

                scale: playArea.pressed ? 0.93 : 1

                color: Players.activePlayer?.isPlaying
                    ? Qt.alpha(Colors.palette.primary80, 1)
                    : Qt.alpha(Colors.palette.primary80, playArea.containsMouse ? 0.75 : 0.6)

                Behavior on radius {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: "play_pause"

                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 34

                    color: Players.activePlayer?.isPlaying
                        ? Qt.alpha(Colors.palette.primary20, 1)
                        : Qt.alpha(Colors.palette.primary20, 0.8)

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }

                MouseArea {
                    id: playArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (Players.activePlayer)
                            Players.activePlayer.togglePlaying()
                    }
                }
            }

            Rectangle {
                id: nextButton

                width: 64
                height: 56

                topRightRadius: 28
                bottomRightRadius: 28
                topLeftRadius: nextArea.pressed ? 6 : 10
                bottomLeftRadius: nextArea.pressed ? 6 : 10

                scale: nextArea.pressed ? 0.93 : 1

                color: Qt.alpha(
                    Colors.palette.primary70,
                    nextArea.pressed
                        ? 0.38
                        : nextArea.containsMouse ? 0.28 : 0.16
                )

                Behavior on topLeftRadius {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on bottomLeftRadius {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: "skip_next"

                    font.pixelSize: 28
                    color: Colors.palette.primary70
                    font.family: "Material Symbols Outlined"
                }

                MouseArea {
                    id: nextArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (Players.activePlayer)
                            Players.activePlayer.next()
                    }
                }
            }
        }

        // Letras: columna a la derecha, texto centrado y con salto de linea automatico.
        // Va dentro de `panel` para poder anclarse a `controls`.
        Item {
            id: lyricsBox

            anchors.left: controls.right
            anchors.leftMargin: 28
            anchors.right: parent.right
            anchors.rightMargin: 28
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            clip: true
            opacity: cover.opacity

            // centro (en coordenadas de la tira) de la linea que debe quedar en el medio
            property real curCenter: 0

            // Mensajes de estado (cargando / sin letra / error)
            Text {
                visible: panel1.lyricsState !== "ok" && panel1.lyricsState !== "idle"
                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: panel1.font
                font.pixelSize: 18
                color: Colors.md3.secondary
                text: {
                    if (panel1.lyricsState === "loading") return "Loading :|"
                    if (panel1.lyricsState === "none")    return "No lyric :("
                    if (panel1.lyricsState === "error")   return "No API >:c"
                    return ""
                }
            }

            // Tira con todas las lineas: se desliza para dejar la actual en el centro
            Item {
                id: strip

                visible: panel1.lyricsState === "ok"
                width: parent.width
                height: 500
                y: lyricsBox.height / 2 - lyricsBox.curCenter

                // sin animar mientras el panel se abre o se cierra
                Behavior on y {
                    enabled: panel1.implicitHeight >= 300
                    NumberAnimation {
                        duration: 650
                        easing.type: Easing.OutCubic
                    }
                }

                Column {
                    id: col
                    width: parent.width

                    Repeater {
                        model: panel1.lyricsState === "ok" ? panel1.lyricLines : []

                        delegate: Item {
                            id: line

                            required property int index
                            required property var modelData

                            // distancia a la linea actual (0 = actual, negativo = ya paso)
                            readonly property int dist: index - panel1.lyricIndex
                            readonly property bool isCur: index === panel1.lyricIndex
                            // antes de la primera linea la primera es la que se centra
                            readonly property bool isPos: index === Math.max(0, panel1.lyricIndex)
                            readonly property real center: y + height / 2

                            width: col.width
                            height: label.implicitHeight + 18

                            onCenterChanged: if (isPos) lyricsBox.curCenter = center
                            onIsPosChanged: if (isPos) lyricsBox.curCenter = center
                            Component.onCompleted: if (isPos) lyricsBox.curCenter = center

                            Text {
                                id: label

                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                font.family: panel1.font
                                font.pixelSize: 20
                                text: line.modelData.text || "♪"

                                color: line.isCur ? Colors.md3.primary : Colors.md3.secondary
                                transformOrigin: Item.Center
                                scale: line.isCur ? 1 : 0.84
                                // actual 100%; las siguientes y las ya cantadas se apagan poco a poco
                                opacity: line.dist === 0 ? 1
                                       : line.dist > 0 ? Math.max(0, 0.65 - (line.dist - 1) * 0.13)
                                       : Math.max(0, 0.32 + (line.dist + 1) * 0.11)

                                Behavior on opacity {
                                    NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
                                }
                                Behavior on scale {
                                    NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 350 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    NumberAnimation {
        id: openAnimation

        target: panel1
        property: "implicitHeight"

        from: 38
        to: 300
    
        duration: 300

        easing.type: Easing.OutCubic

        onFinished: {
            panel1.implicitHeight = 300
        }
       
    }
    NumberAnimation {
        id: closeOpacity

        target: panel
        property: "opacity"

        from: 1
        to: 0
    
        duration: 450

        easing.type: Easing.OutCubic

        onFinished: {
           
        }
       
    }

    NumberAnimation {
        id: closeAnimation

        target: panel1
        property: "implicitHeight"

        from: 300
        to: 38

        duration: 300

        easing.type: Easing.OutCubic

        onFinished: {
            panel.opacity = 0
            panel1.visible = false
            
        }
    }

    function open() {
        closeAnimation.stop()
        cover.opacity = 1
        panel1.implicitHeight = 38
        panel1.visible = true
        panel.opacity = 1
        panel.implicitWidth = 950
        openAnimation.start()
        updateLyricIndex()
    }

    function close() {
        openAnimation.stop()
        cover.opacity = 0
        if (!panel1.visible)
            return
        
        closeAnimation.start()
        panel.implicitWidth = 900
        wait.start()
    }
    Timer{
        id: wait
        interval: 130
        repeat: false

        onTriggered: {
           closeOpacity.start()
           bar.barOpen()
        }
    }
     

}
