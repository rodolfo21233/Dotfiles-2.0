import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.app_launcher
import "Colors"
import "qs.Bar"
PanelWindow {
    id: dockWindow

    property var pinned: ["kitty", "org.gnome.Nautilus", "firefox", "vesktop", "steam","swiftify"]
    property int hideDelay: 500
    readonly property int edgeGap: 0
    property bool shown: true
    property Item activeItem: null

    readonly property bool noWindow: ToplevelManager.activeToplevel === null
    readonly property bool hasUnpinned: ToplevelManager.toplevels.values.some(t => !isPinned(t.appId))

    function isPinned(appId) {
        return pinned.some(p => p.toLowerCase() === (appId ?? "").toLowerCase());
    }

    function windowsFor(appId) {
        return ToplevelManager.toplevels.values
            .filter(t => (t.appId ?? "").toLowerCase() === appId.toLowerCase());
    }

    function launchPinned(appId) {
        const e = DesktopEntries.heuristicLookup(appId);
        if (e)
            e.execute();
        else
            Quickshell.execDetached([appId]);
    }

    onNoWindowChanged: {
        if (noWindow) {
            hideTimer.stop()
            shown = true
        } else if (!AppLauncherState.launcherVisible) {
            hideTimer.restart()
        }
    }

    anchors.bottom: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    implicitWidth: dockSurface.implicitWidth + 100
    implicitHeight: dockSurface.implicitHeight + edgeGap

    mask: Region { item: hitbox }

    Timer {
        id: hideTimer
        interval: dockWindow.hideDelay
        onTriggered: {
            if (dockWindow.noWindow || AppLauncherState.launcherVisible || hoverHandler.hovered)
                dockWindow.shown = true
            else
                dockWindow.shown = false
        }
    }

    Timer {
        id: launcherCloseDelay
        interval: 10
        onTriggered: {
            if (!AppLauncherState.launcherVisible && !dockWindow.noWindow)
                dockWindow.shown = false
        }
    }

    Connections {
        target: AppLauncherState
        function onLauncherVisibleChanged() {
            if (AppLauncherState.launcherVisible) {
                hideTimer.stop()
                launcherCloseDelay.stop()
                dockWindow.shown = true
            } else {
                hideTimer.stop()
                launcherCloseDelay.restart()
            }
        }
    }

    Component.onCompleted: hideTimer.start()

    Item {
        id: hitbox
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: dockSurface.implicitWidth
        height: dockWindow.shown ? parent.height : 6

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hovered) {
                    hideTimer.stop();
                    dockWindow.shown = true;
                } else {
                    hideTimer.restart();
                }
            }
        }

        Rectangle {
            id: dockSurface
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dockWindow.shown ? dockWindow.edgeGap : -implicitHeight

            implicitWidth: dockRow.implicitWidth + 25
            implicitHeight: 60
            radius: 0
            color: Colors.md3.background

            topLeftRadius: 14
            topRightRadius: 14

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: dockWindow.shown ? 280 : 200
                    easing.type: Easing.OutCubic
                }
            }

            ConcaveCurves {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: -20
                radius: 20
                color: Colors.md3.background
                isTop: true
                mirrored: false
                anchors.topMargin: 0
                rotation: 270
            }

            ConcaveCurves {
                anchors.bottom: parent.bottom
                anchors.right: parent.left
                anchors.rightMargin: 0
                radius: 20
                color: Colors.md3.background
                isTop: true
                mirrored: false
                anchors.topMargin: 0
                rotation: 180
            }

            Row {
                id: dockRow
                anchors.centerIn: parent
                spacing: 10
                opacity: AppLauncherState.dockIconsVisible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                }

                Repeater {
                    model: dockWindow.pinned

                    Rectangle {
                        id: pinBtn
                        required property string modelData

                        property var entry: {
                            const dep = DesktopEntries.applications.values;
                            return DesktopEntries.heuristicLookup(modelData);
                        }
                        property var wins: {
                            const dep = ToplevelManager.toplevels.values;
                            return dockWindow.windowsFor(modelData);
                        }
                        property bool isActive: wins.some(w => w.activated)

                        onIsActiveChanged: {
                            if (isActive)
                                dockWindow.activeItem = pinBtn;
                            else if (dockWindow.activeItem === pinBtn)
                                dockWindow.activeItem = null;
                        }
                        Component.onCompleted: if (isActive) dockWindow.activeItem = pinBtn
                        Component.onDestruction: if (dockWindow.activeItem === pinBtn) dockWindow.activeItem = null

                        implicitWidth: 45
                        implicitHeight: 45
                        radius: 8
                        color: pinMouse.pressed ? Colors.md3.primary
                             : (pinMouse.containsMouse ? Colors.md3.primary : Colors.md3.surface_container_high)
                        scale: pinMouse.pressed ? 0.95 : (pinMouse.containsMouse ? 1.10 : 1.0)

                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 28
                            source: Quickshell.iconPath(pinBtn.entry?.icon ?? pinBtn.modelData,
                                                        "application-x-executable")
                        }

                        Rectangle {
                            visible: pinBtn.wins.length > 0
                            width: 4; height: 4; radius: 2
                            color: Colors.md3.primary
                            opacity: 0.5
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                        }

                        MouseArea {
                            id: pinMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const open = dockWindow.windowsFor(pinBtn.modelData);
                                if (open.length > 0)
                                    open[0].activate();
                                else
                                    dockWindow.launchPinned(pinBtn.modelData);
                            }
                        }
                    }
                }

                Rectangle {
                    visible: dockWindow.hasUnpinned
                    width: 2
                    height: 30
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.md3.primary
                    opacity: 0.4
                }

                Repeater {
                    model: ToplevelManager.toplevels

                    Rectangle {
                        id: appBtn
                        required property var modelData
                        visible: !dockWindow.isPinned(modelData.appId)
                        property bool isActive: visible && modelData.activated

                        onIsActiveChanged: {
                            if (isActive)
                                dockWindow.activeItem = appBtn;
                            else if (dockWindow.activeItem === appBtn)
                                dockWindow.activeItem = null;
                        }
                        Component.onCompleted: if (isActive) dockWindow.activeItem = appBtn
                        Component.onDestruction: if (dockWindow.activeItem === appBtn) dockWindow.activeItem = null

                        implicitWidth: 45
                        implicitHeight: 45
                        radius: 8
                        color: appMouse.pressed ? Colors.md3.primary
                             : (appMouse.containsMouse ? Colors.md3.secondary : Colors.md3.surface_container_high)
                        scale: appMouse.pressed ? 0.95 : (appMouse.containsMouse ? 1.1 : 1.0)

                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 33
                            source: {
                                const e = DesktopEntries.heuristicLookup(appBtn.modelData.appId ?? "");
                                return Quickshell.iconPath(e?.icon ?? appBtn.modelData.appId ?? "",
                                                           "application-x-executable");
                            }
                        }

                        Rectangle {
                            width: 4; height: 4; radius: 2
                            color: Colors.md3.primary
                            opacity: 0.5
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.MiddleButton)
                                    appBtn.modelData.close();
                                else
                                    appBtn.modelData.activate();
                            }
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 48
                    implicitHeight: 48
                    radius: 22
                    color: launcherMouse.pressed ? Colors.md3.primary
                         : (launcherMouse.containsMouse ? Colors.md3.secondary : Colors.md3.background)
                    scale: launcherMouse.pressed ? 0.95 : (launcherMouse.containsMouse ? 1.1 : 1.0)

                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "apps"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 26
                        color: Colors.md3.primary
                    }

                    MouseArea {
                        id: launcherMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            hideTimer.stop()
                            dockWindow.shown = true
                            AppLauncherState.show()
                        }
                    }
                }
            }
        }
    }
}
