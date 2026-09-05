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
            font.family: "Material Symbols Outlined"
           
            text: {
                var percent = Math.round(container.battery.percentage * 100)
                    
                if (percent < 100) {
                    (container.battery.state === UPowerDeviceState.Charging ? "bolt" : "battery_0_bar") 
                }
                else{
                    text = ""
                }
            }
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -10
            color: "black"
            font.pixelSize: 13
            font.bold: false
            
        }
        Text {
            font.family: "Varela"

            x: Math.round(container.battery.percentage * 100) < 100 ? 14 : 6
            y: 2

            text: Math.round(container.battery.percentage * 100)
        }
    }
}