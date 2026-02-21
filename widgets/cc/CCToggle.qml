import QtQuick
import QtQuick.Layouts
import "../.."

// GNOME-style quick toggle button
Rectangle {
    id: toggle

    property string icon: "󰀂"
    property string label: "Toggle"
    property string subtitle: ""
    property bool active: false

    signal clicked

    implicitWidth: 70
    implicitHeight: 70
    radius: 20
    color: active ? "#007aff" : "#2c2c2e"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: active ? "#ffffff" : "#999999"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.family: "SF Pro Display, Inter, Cantarell, sans-serif"
            font.pixelSize: 10
            font.weight: Font.Medium
            color: active ? "#ffffff" : "#ffffff"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: subtitle !== ""
            text: subtitle
            font.family: "SF Pro Display, Inter, Cantarell, sans-serif"
            font.pixelSize: 9
            color: active ? Qt.rgba(1, 1, 1, 0.7) : "#999999"
            elide: Text.ElideRight
            Layout.maximumWidth: toggle.width - 8
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: toggle.clicked()

        Rectangle {
            anchors.fill: parent
            radius: parent.parent.radius
            color: parent.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        }
    }
}
