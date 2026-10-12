pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property list<MprisPlayer> playerList: Mpris.players.values

    property int activeIndex: 0

    readonly property MprisPlayer selectedPlayer:
        playerList.length > activeIndex
            ? playerList[activeIndex]
            : null

    readonly property MprisPlayer activePlayer: selectedPlayer

    property string playerName: selectedPlayer?.identity ?? ""

    onPlayerListChanged: {
        if (playerList.length === 0) {
            activeIndex = 0
            playerName = ""
            return
        }

        if (playerName !== "") {
            const index = playerList.findIndex(
                item => item.identity === playerName
            )

            activeIndex = index !== -1 ? index : 0
        } else if (activeIndex >= playerList.length) {
            activeIndex = 0
        }
    }

    onActiveIndexChanged: {
        if (activeIndex < 0)
            activeIndex = 0

        if (activeIndex >= playerList.length && playerList.length > 0)
            activeIndex = playerList.length - 1
    }

    readonly property real percentageProgress: {
        if (!activePlayer || !activePlayer.lengthSupported)
            return 0

        if (activePlayer.length <= 0)
            return 0

        return activePlayer.position / activePlayer.length
    }

    onActivePlayerChanged: {
        if (activePlayer)
            activePlayer.positionChanged()
    }

    function cyclePlayer(x) {
        if (playerList.length === 0)
            return

        activeIndex =
            (activeIndex + x + playerList.length) % playerList.length
    }

    function selectPlayerByIndex(i) {
        if (i >= 0 && i < playerList.length)
            activeIndex = i
    }

    FrameAnimation {
        running: root.activePlayer?.playbackState === MprisPlaybackState.Playing

        onTriggered: {
            if (root.activePlayer)
                root.activePlayer.positionChanged()
        }
    }
}