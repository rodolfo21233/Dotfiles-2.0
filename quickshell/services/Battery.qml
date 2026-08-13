import QtQuick
import Quickshell
import Quickshell.Services.UPower
import ".."
Item {
    width: 30
    height: 20

    Rectangle {
        id: container
        width: 35
        height: 18
        x: -10
        radius: 7
        color: Colors.palette.secondary30
        z: -2
        y:2
        property var battery: UPower.displayDevice

        Rectangle {
            z: 0
            color: Colors.md3.primary
            width: parent.width * container.battery.percentage 
            height: 18
            radius: 8
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            y: -3.1
            
        }

        Text {
            font.family: "DM Sans"
           
            text: {
                var percent = Math.round(container.battery.percentage * 100)

                if (percent < 100) {
                    return (container.battery.state === UPowerDeviceState.Charging ? "󱐋" : "󰂎") + " " + percent
                }

                return percent
            }
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -1
            color: "black"
            font.pixelSize: 13
            font.bold: false
            
        }
    }
}