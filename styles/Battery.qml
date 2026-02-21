import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs

Item {
    id: root
    property color fillColour: {
        if (isCharging) {
            return "#67afc1";
        }

        switch (Math.round((percentage * 100) / 10) * 10) {
        case 10:
            return "#df5b61";
        case 20:
            return "#de8f78";
        case 30:
            return "#de8f78";
        default:
            return "#78b892";
        }
    }
    property real percentage
    property bool isCharging
    property bool material

    width: batteryItem.width + (4 + chargingText.implicitWidth)
    height: batteryItem.height

    Item {
        id: batteryItem
        width: 28
        height: 18
        Rectangle {
            id: batteryContainer
            readonly property bool isPortrait: parent.height > parent.width

            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            width: isPortrait ? parent.width : parent.width - 1
            height: isPortrait ? parent.height - 1 : parent.height
            radius: 5
            color: "transparent"
            border {
                width: 1
                color: GlobalVariables.colours.light
            }

            Item {
                id: fillContainer
                anchors.centerIn: parent
                width: parent.width - 7
                height: parent.height - 7
                layer.enabled: true

                Rectangle {
                    id: fill

                    anchors {
                        topMargin: 1
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                    }
                    visible: percentage > 0
                    width: batteryContainer.isPortrait ? parent.width : parent.width * percentage
                    height: batteryContainer.isPortrait ? parent.height * percentage : parent.height
                    color: fillColour
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: fill.width
                            height: fill.height

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    bottom: parent.bottom
                                }
                                width: fillContainer.width
                                height: fillContainer.height
                                radius: 3
                            }
                        }
                    }
                }

                Rectangle {
                    id: overlay
                    anchors.fill: parent
                    radius: 5
                    color: "transparent"
                    gradient: material ? null : sku

                    Gradient {
                        id: sku
                        orientation: batteryContainer.isPortrait ? Gradient.Horizontal : Gradient.Vertical
                        GradientStop {
                            position: 0.0
                            color: "#20000000"
                        }
                        GradientStop {
                            position: 0.1
                            color: "#80ffffff"
                        }
                        GradientStop {
                            position: 0.5
                            color: "#00000000"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#40000000"
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.right
                    leftMargin: batteryContainer.isPortrait ? -parent.width / 2 - width / 2 : 0
                    bottom: parent.top
                    bottomMargin: batteryContainer.isPortrait ? 0 : -parent.height / 2 - height / 2
                }
                width: batteryContainer.isPortrait ? parent.width / 3 : 1
                height: batteryContainer.isPortrait ? 1 : parent.height / 3
                color: GlobalVariables.colours.light
            }
        }
    }

    Text {
        id: chargingText
        anchors {
            left: batteryItem.right
            leftMargin: 4
            verticalCenter: batteryItem.verticalCenter
        }
        text: isCharging ? "󱐋" : Math.floor(percentage * 100) + "%"
        color: GlobalVariables.colours.light
        font {
            family: "Adwaita Sans"
            pointSize: 12
            weight: 600
        }
    }
}
