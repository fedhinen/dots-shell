/*-------------------------
--- shell.qml by andrel ---
-------------------------*/

//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services as Service
import qs.widgets
import Niri 0.1
import qs.widgets.cc

Scope {
    id: root
    property var colour: GlobalVariables.colours
    property alias controlCenter: ccLoader.item

    Niri {
        id: niri
        Component.onCompleted: {
            niri.workspaces.maxCount = 6;
            connect();
        }

        onConnected: {
            console.log("Niri connected to shell services");
        }
        onErrorOccurred: function (error) {
            console.error("Niri connection error:", error);
        }
    }

    LazyLoader {
        id: ccLoader
        active: true
        component: ControlCenter {
            id: controlCenterInstance
        }
    }

    // create bar on every screen
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            // barHeight: 36

            leftItems: [
                Clock {}
            ]

            centreItems: [
                NiriWorkspaces_Alt {}
            ]

            rightItems: [
                Tray {},
                Battery {},
                Network {}
            ]
        }
    }

    // only show on main/active monitor
    Brightness {}

    // connect to shell services
    Component.onCompleted: [Service.Shell.init(), Settings_Alpha.init(), Lockscreen.init(), Notifications.init(), AppLauncher.init(10 // the maximum number of lines to display
        , true // hide category filters
        ), Service.Redeye.init(5500 // temperature in K
        , 95 // gamma (0-100)
        , true // enable geo located sunset/sunrise times (static times will be ignored if 'true')
        , "19:00" // static start time
        , "7:00" // static end time
        )]
}
