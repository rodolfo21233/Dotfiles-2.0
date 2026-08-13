import Quickshell
import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    property string windowName: ""
    property string workspace: ""

    implicitWidth: windowText.implicitWidth
    implicitHeight: windowText.implicitHeight

    Process {
        id: niriProcess

        command: [
            "sh",
            "-c",
            "output=$(niri msg focused-window 2>/dev/null); " +
            "app=$(printf '%s\\n' \"$output\" | sed -n 's/.*App ID: \"\\(.*\\)\"/\\1/p'); " +
            "ws=$(printf '%s\\n' \"$output\" | sed -n 's/.*Workspace ID: //p'); " +
            "printf '%s|%s\\n' \"${app:-desktop}\" \"$ws\""
        ]

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("|")

                if (parts.length >= 1)
                    root.windowName = parts[0] || "workspace"

                if (parts.length >= 2)
                    root.workspace = parts[1]
            }
        }

        onExited: {
            // Ejecutar nuevamente cuando termine
            niriProcess.running = true
        }
    }

    Component.onCompleted: {
        niriProcess.running = true
    }

    Text {
        id: windowText
        font.family: "Varela Round"
        text: " " + root.windowName
        color: Colors.md3.primary
        opacity: 0.7
        font.pixelSize: 12
        y: -9
        x: -5
    }

    Text {
        id: windowText2
        font.family: "Varela"
        text: "Workspace " + root.workspace
        color: Colors.md3.primary
        font.pixelSize: 12
        y: 4
    }
}