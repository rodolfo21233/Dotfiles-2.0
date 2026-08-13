import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Shapes
import ".."
import "Colors"
Item {
    id: root

    property var wsData: []

    function focusedIndex() {
        for (var i = 0; i < wsData.length; i++) {
            if (wsData[i].focused)
                return wsData[i].idx
        }
        return 1
    }

    Process {
        id: focusWorkspace

        function focus(idx) {
            command = ["niri", "msg", "action", "focus-workspace", idx.toString()]
            running = true
        }
    }

    Rectangle {
        width: 20
        height: 20
        radius: 30
        color: Colors.md3.tertiary
        x: (root.focusedIndex() - 1) * 25 - 5
        y: -3.5
        z: 1

        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCirc
            }
        }

        Item {
            Star {
                id: star
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 9.5
                anchors.horizontalCenterOffset: 10
            }
        }
    }

    Connections {
        target: root

        function onWsDataChanged() {
            spin.restart()
        }
    }

    NumberAnimation {
        id: spin
        target: star
        property: "rotation"
        from: star.rotation
        to: star.rotation + 180
        duration: 600
        easing.type: Easing.OutBack
    }

    RowLayout {
        y: -3
        x: -3
        spacing: 5

        Repeater {
            model: 6

            Item {
                width: 20
                height: 20

                property var ws: {
                    for (var i = 0; i < root.wsData.length; i++)
                        if (root.wsData[i].idx === index + 1)
                            return root.wsData[i]
                    return null
                }

                property bool isActive: ws && ws.focused

                Rectangle {
                    anchors.centerIn: parent
                    width: 7
                    height: 7
                    radius: 30

                    color: isActive
                           ? Colors.md3.primary
                           : (ws && ws.occupied
                              ? Colors.palette.primary60
                              : Colors.palette.primary10)

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCirc
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: focusWorkspace.focus(index + 1)
                }
            }
        }
    }

    Process {
        id: wsStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    var e = JSON.parse(data)
                    if (e.WorkspacesChanged)
                        root.parseWs(e.WorkspacesChanged.workspaces)
                    else if (e.WorkspaceActivated)
                        wsQuery.running = true
                } catch(_) {}
            }
        }

        onRunningChanged: if (!running) wsRestart.start()
    }

    Timer {
        id: wsRestart
        interval: 1500
        onTriggered: wsStream.running = true
    }

    Process {
        id: wsQuery
        command: ["niri", "msg", "--json", "workspaces"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    var p = JSON.parse(data)

                    var list = (p.Ok && p.Ok.Workspaces) ? p.Ok.Workspaces
                             : Array.isArray(p) ? p
                             : (p.Ok && Array.isArray(p.Ok)) ? p.Ok
                             : null

                    if (list)
                        root.parseWs(list)
                } catch(_) {}
            }
        }

        Component.onCompleted: running = true
    }

    function parseWs(list) {
        if (!Array.isArray(list))
            return

        var a = []

        for (var i = 0; i < list.length; i++) {
            var w = list[i]

            a.push({
                idx: w.idx !== undefined ? w.idx : i + 1,
                focused: !!w.is_focused,
                occupied: w.active_window_id != null
            })
        }

        a.sort(function(x, y) {
            return x.idx - y.idx
        })

        wsData = a
    }
}