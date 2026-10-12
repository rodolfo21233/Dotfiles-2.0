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
import qs.bar
import "Colors"
PanelWindow {
    color: "transparent"
    implicitWidth: 400
    implicitHeight: 150
    WlrLayershell.layer: WlrLayer.Bottom
     anchors {
        bottom: true
        left: true
    }
  
    margins {
        bottom: 50
        left: -30
    }
    
    Item {
        id: root
        anchors.fill: parent

        property string time: ""
        property string day: ""

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                let now = new Date()

                root.time = Qt.formatDateTime(now, "hh:mm ")
                root.day = Qt.formatDateTime(now, "dddd dd MMMM ")
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 5

            Text {
                font.family: "Dyna puff"
                text: root.time
                font.pixelSize: 90
                color: Colors.palette.primary70
                font.bold: true
            }

            Text {
                font.family: "Dyna puff"
                color: Colors.palette.primary90
                text: root.day
                font.pixelSize: 16
                font.bold: true
            }
        }
          
    }
    
}