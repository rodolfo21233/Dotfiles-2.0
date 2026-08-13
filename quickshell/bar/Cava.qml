import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import ".."
RowLayout {
    id: root
    property var audioBars: []
    property int bars: 16
    property int width2: 19
    property int height2: 100
    property int y2: 0
    anchors.verticalCenter: parent.verticalCenter 

    Process {
        id: cavaProc
        running: true
        command: ["sh", "-c", `cava -p /dev/stdin <<EOF
[general]
bars = ${root.bars}
framerate = 15
autosens = 1
[input]
method = pulse
source = $(pactl get-default-sink).monitor
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 1000
EOF`]
        stdout: SplitParser {
            onRead: data => {
                root.audioBars = data.split(";").map(p => {
                    const v = parseFloat(p.trim());
                    return isNaN(v) ? 0 : v / 1000;
                });
            }
        }
    }

    Rectangle {
        id: cavaRect
        clip: true
        
        implicitHeight: height2 + 50
        implicitWidth: 340222
        color: 'transparent'

        bottomRightRadius: 25
        bottomLeftRadius: 2
        topRightRadius: 25
        topLeftRadius: 20
        z:-5
        radius: 30
        Row {
            y: y2
            height: parent.height
            leftPadding: 4
            spacing: 2
            Repeater {
                id: cavarepeater
                model: root.bars
                Rectangle {
                    
                    opacity: 0.5
                    width: root.width2
                    height: Math.max((root.audioBars[index] ?? 0) * height2, 1)
                    color: Colors.md3.primary
                    anchors.bottom: parent.bottom
                    Behavior on height { NumberAnimation { duration: 55 } }
                    radius: 30
                }
            }
        }
    }
}