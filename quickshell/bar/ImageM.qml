import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick.Effects

import qs.services
import qs.bar

Rectangle {
    id: root

    visible: true
    color: "transparent"
    width: 350
    height: 150

    MultiEffect {
        source: image
        anchors.fill: image
        maskEnabled: true
        maskSource: mask
    }

    Image {
        id: image

        source: Players.activePlayer?.trackArtUrl ?? ""

        visible: false
        width: root.width
        height: root.height
        smooth: true
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: mask

        anchors.fill: image
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: 12
        }
    }

    Rectangle {
        width: root.width
        height: root.height + 0.8
        color: "black"
        opacity: 0.6
        radius: 10
    }

    Cava {}
}