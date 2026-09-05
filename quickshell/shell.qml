//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import qs.bar
import qs.Bottom
import qs.Popups
import qs.services
import qs.app_launcher
ShellRoot {
    Scope {
        Variants {
            model: Quickshell.screens

            delegate: PanelWindow {
                required property var modelData

                screen: modelData

                color: "transparent"

                anchors {
                    left: true
                    right: true
                    top: true
                    bottom: true
                }
                Clock{}
                
                Music2{}
                mask: Region { }
                
                
            }
        }
        
    }
    AppLauncher {}
    Bar {}
    //Volume{}
    PowerMenu{}
    Time{}
    Notifications{}
    ConcaveCurves{}
}