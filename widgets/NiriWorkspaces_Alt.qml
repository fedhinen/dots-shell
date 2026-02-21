/*--------------------------------------
--- NiriWorkspaces_Alt.qml by andrel ---
--------------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs

Row {
    id: root
    spacing: 12
    width: GlobalVariables.controls.barHeight
    height: 38
    Rectangle {
        id: workspaceContainer
        anchors.centerIn: parent
        width: workspaceRow.implicitWidth + 16
        height: parent.height - 8
        color: "#1b1d1e"
        radius: height / 2
        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                model: niri.workspaces
                Rectangle {
                    id: workspaceDot
                    width: model.isFocused ? 28 : model.isActive ? 16 : 10
                    height: 8
                    radius: 5
                    color: (model.isFocused || model.isActive || model.isUrgent) ? "#6791c9" : "#2c2e2f"

                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    MouseArea {
                        id: dotMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: niri.focusWorkspaceById(model.id)
                    }
                    ToolTip {
                        visible: dotMouseArea.containsMouse
                        text: model.name || ("Workspace " + (model.index + 1))
                    }
                }
            }
        }
    }
}
