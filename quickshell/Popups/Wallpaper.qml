import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "Colors"
import ".."

Scope {
    id: scope
    property bool open: false
    property bool visible: false

    IpcHandler {
        target: "wallpapers"

        function toggle(): void {
            if (scope.open)
                scope.close()
            else
                scope.open = true
        }

        function open(): void {
            scope.open = true
        }

        function close(): void {
	    scope.open = false
	    
        }
    }
 

    onOpenChanged: {
        if (open){
	close.stop()
	visible = true
	}
	else  {
	close.start()
	}
    }
    Timer{
	id: close
	repeat: false
	interval: 500
	running: false 
	onTriggered: {
	    background.opacity = 0
	}

    }


    FolderListModel {
        id: wallpapers
        folder: "file://" + Quickshell.env("HOME") + "/wallpapers"
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    LazyLoader {
        active: scope.visible

        PanelWindow {
            anchors.bottom: true
            margins.bottom: 20
            implicitWidth: 790
            implicitHeight: 190
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            mask: Region {
                item: scope.open? maskCover : null
            }
            Item {
                id: maskCover
                anchors.fill: parent
            }
            Rectangle {
                id: background
                anchors.fill: parent
                radius: 28
                color: Colors.md3.background

                property real progress: scope.open ? 1 : 0

                Behavior on progress {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                opacity: 1
                scale: 1
		transformOrigin: Item.Bottom

                transform: Translate {
		    y: (1 - background.progress) * 200
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: 20
                    focus: true

                    Keys.onEscapePressed: scope.open = false

                    ListView {
                        id: row
                        anchors.fill: parent
                        model: wallpapers
                        orientation: ListView.Horizontal
                        spacing: 20

                        delegate: Item {
                            id: listItem
                            required property string fileName
                            required property string filePath
                            required property url fileUrl
                            required property int index

                            width: 150
                            height: 150

                            readonly property real visibleAmount: {
                                let start = row.contentX;
                                let end = row.contentX + row.width;
                                let imageStart = x;
                                let imageEnd = x + width;

                                if (imageStart > start && imageEnd > end)
                                    return imageStart - end;

                                if (imageStart < start && imageStart < end)
                                    return imageEnd - start;

                                return width;
                            }

                            Item {
                                height: parent.height
                                width: Math.abs(listItem.visibleAmount)
                                x: listItem.visibleAmount > 0
                                    ? listItem.width - listItem.visibleAmount
                                    : 0

                                ClippingRectangle {
                                    anchors.fill: parent
                                    radius: 16

                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: listItem.fileUrl
                                        sourceSize.width: 300
                                        sourceSize.height: 300
                                        asynchronous: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        Quickshell.execDetached([
                                            "matugen",
                                            "image",
                                            listItem.filePath,
                                            "--source-color-index",
                                            "0"
                                        ])

                                        scope.open = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
