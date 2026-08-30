pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root
    readonly property list<MprisPlayer> playerList: Mpris.players.values
    property int activeIndex: 0
    readonly property MprisPlayer selectedPlayer: playerList.length > activeIndex ? playerList[activeIndex] : null
    readonly property MprisPlayer activePlayer: selectedPlayer
    property string playerName: selectedPlayer?.identity ?? ""

    onPlayerListChanged: {
        if (playerName !== "") {
            const index = playerList.findIndex(item => item.identity === playerName);
            activeIndex = index !== -1 ? index : 0;
        } else {
            activeIndex = 0;
        }
    }

    readonly property real percentageProgress: {
        if (!activePlayer || !activePlayer.lengthSupported)
            return 0;
        return activePlayer.position / (activePlayer.length);
    }

    onActivePlayerChanged: {
        if (activePlayer) {
            activePlayer.positionChanged();
        }
    }

    function cyclePlayer(x) {
        if (playerList.length === 0) return
        activeIndex = (activeIndex + x + playerList.length) % playerList.length
    }

    function selectPlayerByIndex(i) {
        if (i >= 0 && i < playerList.length)
            activeIndex = i
    }

    FrameAnimation {
        running: root.activePlayer && root.activePlayer.playbackState == MprisPlaybackState.Playing
        onTriggered: if (root.activePlayer) {
            root.activePlayer.positionChanged();
        }
    }
}