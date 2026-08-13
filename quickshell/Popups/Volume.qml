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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true 
        
        
        onEntered: windowRoot.color = "yellow"
        onExited: windowRoot.color = "transparent"
    }



PanelWindow {
    //WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors {
        left: true
        top: true
        bottom: true
    }

    mask: Region {
        item: maskCover
    }

    Item {
        id: maskCover

        width: 10
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }
}
}