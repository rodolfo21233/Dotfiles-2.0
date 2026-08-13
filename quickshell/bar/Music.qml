pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import Quickshell.Io
import "Colors"
import ".."
import qs.services
import qs.bar

RowLayout {
    id: root
    property real trackTextWidth: trackText.implicitWidth
    anchors.verticalCenter: parent.verticalCenter

    property bool hasPlayer: Players.activePlayer !== null
    property bool isPlaying: Players.activePlayer?.isPlaying
    property string trackTitleOutput:  Players.activePlayer?.trackTitle  ?  Players.activePlayer?.trackTitle + " - " : ""
    property string trackArtistOutput:  Players.activePlayer?.trackArtist ? Players.activePlayer?.trackArtist   : ""
    property string trackOutput: hasPlayer?  trackTitleOutput + trackArtistOutput  : ""
    property real scrollSpeed: 80
    property real pauseDuration: 500

    SequentialAnimation {
        id: marqueeAnim
        loops: Animation.Infinite

        PauseAnimation {
            duration: pauseDuration
        }

        NumberAnimation {
            target: trackText
            property: "x"
            from: marqueeContainer.width
            to: -trackText.width
            duration: (trackText.implicitWidth + marqueeContainer.implicitWidth) / scrollSpeed * 1000
            easing.type: Easing.Linear
        }
    }
    function restartMarquee() {
        if (!hasPlayer) {
            marqueeAnim.stop();
            trackText.x = Qt.binding(() => (marqueeContainer.width - trackText.implicitWidth) / 2)
             
        } else {
            if (hasPlayer)
            {
             widthtext()
            }
            
        }
    }
   function widthtext() {
    if (trackText.implicitWidth > marqueeContainer.width) {
            marqueeAnim.start();
        }
     else {
        marqueeAnim.stop();
        trackText.x = 0;
    }
}
    
    

   Connections {
    target: Players.activePlayer

    function onTrackChanged() {
        restartMarquee()
    }

    function onIsPlayingChanged() {
        restartMarquee()
    }
}
    

    Rectangle {
        id: marqueeContainer
        implicitWidth: hasPlayer ? 170 : 100
        implicitHeight: 22
        color: "transparent"
        bottomRightRadius: 11
        topRightRadius: 11
        bottomLeftRadius: 11
        topLeftRadius: 11
        clip: true


        Behavior on implicitWidth {
            NumberAnimation { duration: 200 
            easing.type: Easing.OutCirc
            }
        }
        onWidthChanged: {
            if (isPlaying) {
                widthtext();
            }
        }

        Text {
            font.family: "Varela"
            anchors.verticalCenter: parent.verticalCenter 
            id: trackText
            text: trackOutput
            color: Colors.md3.primary
            onTextChanged: Qt.callLater(restartMarquee)
        }
        
        
    }
}