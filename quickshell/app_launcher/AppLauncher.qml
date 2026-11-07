import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import ".."
import "Colors"
import QtQuick.Effects
PanelWindow {
    id: root
    property var screen
    property string font: "GohuFont 14 Nerd Font"
    property bool panelExpanded: false

    Timer {
        id: openDelay
        // Let the dock finish its 280 ms slide before the launcher emerges.
        interval: 120
        repeat: false
        onTriggered: {
            if (AppLauncherState.launcherVisible)
                root.panelExpanded = true
        }
    }

    Timer {
        id: dockIconsReturnDelay
        interval: 520
        repeat: false
        onTriggered: {
            if (!AppLauncherState.launcherVisible)
                AppLauncherState.dockIconsVisible = true
        }
    }

    IpcHandler {
        target: "applauncher"
        function toggle() {
	    AppLauncherState.toggle();
        }
    }
    
    Dock{
     id: dock
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: AppLauncherState.launcherVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-launcher"

    anchors {
	top: true
        bottom: true
        left: true
        right: true
    }

    mask: Region {
        item: AppLauncherState.launcherVisible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    color: "transparent"

    
    property string searchQuery: ""
    property int selectedIndex: 0
    readonly property bool isSearching: searchQuery.trim() !== ""
    

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        var vals = DesktopEntries.applications.values;

        if (q !== "") {
            // Search mode: filter by name / genericName / keywords, alpha sort
            return vals.filter(function (e) {
                if (e.name.toLowerCase().indexOf(q) !== -1)
                    return true;
                if (e.genericName && e.genericName.toLowerCase().indexOf(q) !== -1)
                    return true;
                for (var i = 0; i < e.keywords.length; i++)
                    if (e.keywords[i].toLowerCase().indexOf(q) !== -1)
                        return true;
                return false;
            }).sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        }

        // Default mode: recent apps first, then alphabetical
        var recent = AppLauncherState.recentIds;
        return vals.slice().sort(function (a, b) {
            var ai = recent.indexOf(a.id);
            var bi = recent.indexOf(b.id);
            if (ai !== -1 && bi !== -1)
                return ai - bi;
            if (ai !== -1)
                return -1;
            if (bi !== -1)
                return 1;
            return a.name.localeCompare(b.name);
        });
    }

    onFilteredAppsChanged: selectedIndex = 0

    // ── Launch ─────────────────────────────────────────────────────────────
    function launchEntry(entry) {
        AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        AppLauncherState.hide();
    }

    // ── Navigation ─────────────────────────────────────────────────────────
    function navigate(delta) {
        if (filteredApps.length === 0)
            return;
        selectedIndex = (selectedIndex + delta + filteredApps.length) % filteredApps.length;
        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

 Connections {
    target: AppLauncherState

    function onLauncherVisibleChanged() {
        if (AppLauncherState.launcherVisible) {
            backgroundCloseAnimation.stop()
            dockIconsReturnDelay.stop()
            AppLauncherState.dockIconsVisible = false
            panel.color = Colors.md3.background
            panel.visible = true
            dock.shown = true
            openDelay.restart()
            searchInput.text = ""
            root.searchQuery = ""
            root.selectedIndex = 0
            searchInput.forceActiveFocus()
        } else {
            openDelay.stop()
            dockIconsReturnDelay.restart()
            root.panelExpanded = false
            backgroundCloseAnimation.from = panel.color
            backgroundCloseAnimation.restart()
            close.restart()
        }
    }
}

    // ── Accent colours ─────────────────────────────────────────────────────
    readonly property color accentFill: Colors.md3.primary
    readonly property color accentIcon: Colors.md3.primary
    readonly property color fgDim: Colors.palette.primary5

    readonly property int maxVisible: 7
    readonly property int itemH: 55
    readonly property int panelW: 550
    
    // The launcher grows from a compact dock-sized card into its full panel.
    readonly property real collapsedW: dock.implicitWidth - 100 
    readonly property int collapsedH: 0

    // Keep the launcher's footprint fixed as search results change.
    readonly property int panelH: 88 + root.maxVisible * root.itemH


    // Click outside → close
    MouseArea {
        anchors.fill: parent
        enabled: AppLauncherState.launcherVisible
        onClicked: AppLauncherState.hide()
    }
      Timer {
        id: close
        interval: 150
        repeat: false

        onTriggered: {
            root.searchQuery = "";
            root.selectedIndex = 0;
            searchInput.forceActiveFocus();
            searchInput.text = "";
        }
    }
    

    // ── Panel ──────────────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: root.panelExpanded ? root.panelW : root.collapsedW 
        Behavior on width {
            NumberAnimation { duration: 1100; easing.type: Easing.OutBack }
        }
        // Smooth height shrink/grow when filteredApps count changes
        height: root.panelExpanded ? root.panelH : root.collapsedH
        Behavior on height {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutCubic

            }
        }
    Rectangle {
        id: blobsMask
        anchors.fill: parent
        bottomLeftRadius: panel.bottomLeftRadius
        bottomRightRadius: panel.bottomRightRadius
        visible: false
        layer.enabled: true
    }

    Item {
        id: blobs
        anchors.fill: parent
        z: 0

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false      
            maskEnabled: true
            maskSource: blobsMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 0.05
            blurEnabled: true
            blur: 0.5
            blurMax: 48
        }
        Repeater {
          
            model: [
                { size: 250, x0: 0.60, x1: 0.30, y0: 0.0, y1: 1.0, dx: 10000, dy: 10000, op: 0.35 },
                { size: 200, x0: 1.00, x1: 0.00, y0: 1.0, y1: 0.3, dx: 20000, dy: 20000, op: 0.30 }
            ]

            delegate: Rectangle {
                id: blob
                required property var modelData

                property real nx: modelData.x0
                property real ny: modelData.y0

                width: modelData.size
                height: width
                radius: width / 2
                color: Colors.md3.primary_container
                opacity: modelData.op

                x: nx * blobs.width - width / 2
                y: ny * blobs.height - height / 2

                SequentialAnimation on nx {
                    loops: Animation.Infinite
                    running: root.panelExpanded
                    NumberAnimation { to: blob.modelData.x1; duration: blob.modelData.dx; easing.type: Easing.InOutSine }
                    NumberAnimation { to: blob.modelData.x0; duration: blob.modelData.dx; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on ny {
                    loops: Animation.Infinite
                    running: root.panelExpanded
                    NumberAnimation { to: blob.modelData.y1; duration: blob.modelData.dy; easing.type: Easing.InOutSine }
                    NumberAnimation { to: blob.modelData.y0; duration: blob.modelData.dy; easing.type: Easing.InOutSine }
                }
            }
        }
    }
        anchors.horizontalCenterOffset: 1

        clip: true   // keep list items inside during height animation

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        // The launcher expands from the screen edge and covers the dock.
        anchors.bottomMargin: 0

        // Semi-translucent frosted panel
        color: "transparent"
        topLeftRadius: root.panelExpanded ? 18 : 28
        topRightRadius: root.panelExpanded ? 18 : 28
      
        Behavior on topLeftRadius {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on topRightRadius {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on bottomLeftRadius {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on bottomRightRadius {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        border.color: Qt.alpha(Colors.md3.primary, 1)
        border.width: 0

        // ── Content ────────────────────────────────────────────────────────
        Column {
            

            Behavior on opacity {
                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
            }

            anchors {
                top: parent.top
                topMargin: 12
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            spacing: 0

            // Drag handle
     

            Item {
                width: 1
                height: 8
            }

            // ── Search box ─────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.07)

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: Colors.md3.primary
                    border.width: 0
                    opacity: searchInput.activeFocus ? 0.55 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }
                    spacing: 10 

                    Item {
                        width: parent.width - 40
                        height: parent.height

                        Text {
                            anchors.fill: parent
                            text: root.isSearching ? "" : "Search apps…"
                            color: Colors.md3.primary
                            opacity: 0.28
                            font {
                                pixelSize: 13
                                family: root.font
                            }
                            verticalAlignment: Text.AlignVCenter
                            visible: searchInput.text === ""
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            color: Colors.md3.primary
                            selectionColor: root.accentFill
                            font {
                                pixelSize: 13
                                family: root.font
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            onTextChanged: root.searchQuery = text

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Up) {
                                    root.navigate(-1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    root.navigate(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (root.filteredApps.length > 0)
                                        root.launchEntry(root.filteredApps[root.selectedIndex]);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    AppLauncherState.hide();
                                    event.accepted = true;
                                    
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 8
            }

            // ── App list ───────────────────────────────────────────────────
            ListView {
                id: listView
                width: parent.width 
                height: root.maxVisible * root.itemH
                model: root.filteredApps
                clip: true
                interactive: false
                currentIndex: root.selectedIndex
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 150
                highlightMoveVelocity: -1   
                highlightResizeDuration: 150

                highlight: Component {
                    Rectangle {
                        radius: 10
                        color: root.accentFill
                        Behavior on y {
                            NumberAnimation { duration: 1500; easing.type: Easing.OutExpo }
                        }
                    }
                }
                
                

                // Wheel on list (belt-and-suspenders alongside panel MouseArea)
                MouseArea {
                    anchors.fill: parent
                    onWheel: function (wheel) {
                        if (wheel.angleDelta.y < 0)
                            root.navigate(1);
                        else
                            root.navigate(-1);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    text: "No apps found"
                    color: Colors.md3.primary
                    opacity: 0.28
                    font {
                        pixelSize: 13
                        family: root.font
                    }
                }
               

                delegate: Item {
                    id: appRow
                    width: listView.width 
                    height: root.itemH 
                    opacity: root.panelExpanded ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }

                    transform: Translate {
                        y: root.panelExpanded ? 0 : 14
                        Behavior on y {
                            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                        }
                    }

        
                    readonly property bool sel: root.selectedIndex === index
                    readonly property bool isRecent: !root.isSearching && AppLauncherState.recentIds.indexOf(modelData.id) !== -1 && AppLauncherState.recentIds.indexOf(modelData.id) < 5
                     
                                

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 12
                            

                            // Icon bubble
                            Rectangle {
                                width: 36
                                height: 36
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                color: appRow.sel ? root.accentIcon : Qt.rgba(1, 1, 1, 0.08)
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: modelData.icon !== "" ? "image://icon/" + modelData.icon : ""
                                    smooth: true
                                    mipmap: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: appIcon.status !== Image.Ready
                                    text: modelData.name.charAt(0).toUpperCase()
                                    font {
                                        pixelSize: 15
                                        family: font.root
                                        weight: Font.Bold
                                    }
                                    color: appRow.sel ? Colors.md3.primary : Colors.md3.primary
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 100
                                        }
                                    }
                                }
                            }

                            // Name + subtitle
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: modelData.name
                                    font {
                                        pixelSize: 14
                                        family: root.font
                                        weight: appRow.sel ? Font.Medium : Font.Normal
                                    }
                                    color: appRow.sel ? Colors.md3.background : Colors.md3.primary
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 100
                                        }
                                    }
                                }

                                // "Recently used" pill OR generic name
                                Row {
                                    spacing: 6
                                    visible: appRow.isRecent || modelData.genericName !== ""

                                    Rectangle {
                                        visible: appRow.isRecent
                                        width: recentLabel.width + 8
                                        height: 14
                                        radius: 4
                                        color: appRow.sel? Qt.alpha(Colors.md3.background , 0.7) : Qt.alpha(Colors.md3.tertiary , 0.5)
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: recentLabel
                                            anchors.centerIn: parent
                                            text: "recent"
                                            font {
                                                pixelSize: 9
                                                family: root.font
                                            }
                                            color: Colors.md3.primary
                                        }
                                    }

                                    Text {
                                        visible: modelData.genericName !== ""
                                        text: modelData.genericName
                                        font {
                                            pixelSize: 11
                                            family: root.font
                                        }
                                        color: appRow.sel ? Colors.palette.primary5 : Colors.md3.secondary  
                                        opacity: 0.9
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: root.launchEntry(modelData)
                            onWheel: function (wheel) {
                                if (wheel.angleDelta.y < 0)
                                    root.navigate(1);
                                else
                                    root.navigate(-1);
                            }
                        }
                    
                }
            }

            Item {
                width: 1
                height: 4
            }
        }
    }

    ColorAnimation {
        id: backgroundCloseAnimation
        target: panel
        duration: 800
        easing.type: Easing.OutCubic
        onFinished: {
            panel.visible = false
        }
    }
}
