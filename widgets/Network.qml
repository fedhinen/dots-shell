import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.services
import qs

Item {
    id: networkIndicator

    implicitWidth: row.implicitWidth
    implicitHeight: 38

    property bool connected: NetworkService.connected
    property string type: NetworkService.type
    property string strength: NetworkService.strength

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (!connected || type === "none")
                    return "󰤭";
                if (type === "ethernet")
                    return "󰈀";

                if (strength < 25)
                    return "󰤟";
                if (strength < 50)
                    return "󰤢";
                if (strength < 75)
                    return "󰤥";
                return "󰤨";
            }
            font {
                family: "Symbols Nerd Font, JetBrainsMono Nerd Font, Font Awesome 6 Free"
                pointSize: 12
                weight: 600
            }

            color: GlobalVariables.colours.light
            Layout.alignment: Qt.AlignVCenter
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.controlCenter) {
                root.controlCenter.toggle();
            }
        }
    }
}
