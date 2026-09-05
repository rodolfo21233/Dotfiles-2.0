import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import qs.bar
import qs.services
PanelWindow {
    id: powerMenu
   
    property bool active: false

    // mantiene la ventana viva mientras dura la animación de salida
    visible: active || hideTimer.running

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:powermenu"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    Time {
        id: time
    }

    onActiveChanged: {
        if (!active) hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 400 // >= la animación de salida más larga (scale = 380ms)
        repeat: false
    }

    // Cerrar con Escape
    Item {
        anchors.fill: parent
        focus: powerMenu.active
        Keys.onEscapePressed: powerMenu.active = false
    }

    // FONDO 
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: powerMenu.active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: powerMenu.active = false
        }
    }
   
    // BOTONES
   
    Row {
        anchors.centerIn: parent
        spacing: 36

        PowerButton {
            index: 0
            icon: "power_settings_new"
            label: "Poweroff"
            accentColor: "#ff6b6b"
            revealed: powerMenu.active
            onTriggered: {
                powerMenu.active = false
                Quickshell.execDetached(["systemctl", "poweroff"])
            }
        }

        PowerButton {
            index: 1
            icon: "restart_alt"
            label: "Reboot"
            accentColor: "#ffd166"
            revealed: powerMenu.active
            onTriggered: {
                powerMenu.active = false
                Quickshell.execDetached(["systemctl", "reboot"])
            }
        }

        PowerButton {
            index: 2
            icon: "lock"
            label: "lock"
            accentColor: "#06d6a0"
            revealed: powerMenu.active
            onTriggered: {
                powerMenu.active = false
                Quickshell.execDetached(["hyprlock"])
            }
        }

        PowerButton {
            index: 3
            icon: "logout"
            label: "logout"
            accentColor: "#4d96ff"
            revealed: powerMenu.active
            onTriggered: {
                powerMenu.active = false
                Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
            }
        }
    }

     Text{
        font.family: "Syne"
        opacity: active? 1 :0
        scale: active? 1 : 0.9
        text: time.time
        color: Colors.md3.primary
        font.pixelSize: 100
        anchors.centerIn:parent
        anchors.verticalCenterOffset: -200
        font.bold: true
        Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }

    }
}