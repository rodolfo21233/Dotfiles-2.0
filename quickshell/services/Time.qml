
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Wayland
import "."
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Hyprland
import qs.bar


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

     
    }
          
}