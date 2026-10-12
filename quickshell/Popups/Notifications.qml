import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "Colors"
import ".."

Scope {
    id: root

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: n => {
            n.tracked = true
        }
    }

    PanelWindow {
        anchors { top: true; right: true }
        margins { top: 12; right: 10 }
        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData
                    required property int index
                    readonly property real cardHeight: 60
                    property bool dismissing: false

                    Layout.fillWidth: true
                    Layout.preferredHeight: cardHeight
                    radius: 8
                    color: Colors.md3.background

                    opacity: 0
                    transform: Translate { id: entryOffset }

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    function requestDismiss() {
                        if (card.dismissing) return
                        card.dismissing = true
                        card.opacity = 0
                        exitAnim.start()
                    }

                    Component.onCompleted: {
                        if (card.index === 0) {
                            entryOffset.x = 420
                            entryXAnim.start()
                        } else {
                            entryOffset.y = -(cardHeight / 2 + column.spacing)
                            entryYAnim.start()
                        }
                        card.opacity = 1
                    }

                    NumberAnimation {
                        id: entryXAnim
                        target: entryOffset
                        property: "x"
                        to: 0
                        duration: 280
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        id: entryYAnim
                        target: entryOffset
                        property: "y"
                        to: 0
                        duration: 280
                        easing.type: Easing.OutCubic
                    }

                 
                    NumberAnimation {
                        id: exitAnim
                        target: card
                        property: "Layout.preferredHeight"
                        to: 0
                        duration: 220
                        easing.type: Easing.OutCubic
                        onFinished: card.modelData.dismiss()
                    }

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: 5000
                        onTriggered: card.requestDismiss()
                    }

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            visible: source.toString() !== ""
                            source: card.modelData.image || card.modelData.appIcon || ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Colors.md3.primary
                                font.family: "Varela"
                                font.pixelSize: 16
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Colors.md3.secondary
                                font.family: "Varela"
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.requestDismiss()
                    }
                }
            }
        }
    }
}
