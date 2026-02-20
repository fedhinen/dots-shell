/*-------------------------
--- Clock.qml by andrel ---
-------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs
import qs.controls
import qs.styles as Style
import qs.services as Service

Item {
    id: root
    width: layout.width
    height: layout.height

    QsButton {
        anchors.fill: parent
        shade: false
        anim: false
        onClicked: popout.toggle()
        content: Item {
            anchors.fill: parent
        }
    }

    Row {
        id: layout
        spacing: 4

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        // date
        Text {
            text: Qt.formatDateTime(clock.date, "ddd MMM d")
            color: GlobalVariables.colours.light
            font: GlobalVariables.font.semibold
        }

        // time
        Text {
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            color: GlobalVariables.colours.light
            font: GlobalVariables.font.semibold
        }
    }

    Popout {
        id: popout
        readonly property date today: clock.date
        readonly property int totalDays: popout.daysInMonth(popout.year, popout.month)
        readonly property int startOffset: popout.firstWeekday(popout.year, popout.month)

        property int month: today.getMonth()
        property int year: today.getFullYear()

        function daysInMonth(y, m) {
            return new Date(y, m + 1, 0).getDate();
        }
        function firstWeekday(y, m) {
            return new Date(y, m, 1).getDay();
        }
        function resetDate() {
            popout.month = today.getMonth();
            popout.year = today.getFullYear();
        }

        onIsOpenChanged: if (!isOpen)
            popout.resetDate()
        anchor: root
        xOffset: -30
        header: ColumnLayout {
            width: screen.width / 6
            Layout.margins: GlobalVariables.controls.padding

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: GlobalVariables.controls.padding

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDateTime(clock.date, "hh:mm AP")
                    color: GlobalVariables.colours.text
                    font: GlobalVariables.font.semibold
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDateTime(clock.date, "dddd MMMM d")
                    color: GlobalVariables.colours.text
                    font: GlobalVariables.font.regular
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            RowLayout {
                width: screen.width / 6

                // goto previous calendar month
                QsButton {
                    Layout.margins: GlobalVariables.controls.padding
                    tooltip: Text {
                        text: "Go to previous calendar month"
                        color: GlobalVariables.colours.text
                        font: GlobalVariables.font.italic
                    }
                    onClicked: {
                        if (popout.month === 0) {
                            popout.month = 11;
                            popout.year--;
                        } else
                            popout.month--;
                    }
                    content: Style.Button {
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: GlobalVariables.controls.iconSize
                            source: Quickshell.iconPath("arrow-left")
                        }
                    }
                }

                QsButton {
                    id: calendarMonth
                    Layout.fillWidth: true

                    onClicked: popout.resetDate()
                    content: Text {
                        width: calendarMonth.width
                        text: Qt.formatDate(new Date(popout.year, popout.month, 1), "MMMM yyyy")
                        color: GlobalVariables.colours.text
                        font: GlobalVariables.font.semibold
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // goto next calendar month
                QsButton {
                    Layout.margins: GlobalVariables.controls.padding
                    Layout.alignment: Qt.AlignRight
                    tooltip: Text {
                        text: "Go to next calendar month"
                        color: GlobalVariables.colours.text
                        font: GlobalVariables.font.italic
                    }
                    onClicked: {
                        if (popout.month === 11) {
                            popout.month = 0;
                            popout.year++;
                        } else
                            popout.month++;
                    }
                    content: Style.Button {
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: GlobalVariables.controls.iconSize
                            source: Quickshell.iconPath("arrow-right")
                        }
                    }
                }
            }
        }
        body: Item {
            width: screen.width / 6
            height: calendarGrid.height + weatherSection.height

            GridLayout {
                id: calendarGrid
                anchors {
                    left: parent.left
                    right: parent.right
                }
                anchors.margins: GlobalVariables.controls.padding
                columns: 7
                uniformCellWidths: true
                uniformCellHeights: true

                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    delegate: Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: GlobalVariables.controls.iconSize
                        Layout.topMargin: GlobalVariables.controls.padding
                        text: modelData
                        color: GlobalVariables.colours.text
                        font: GlobalVariables.font.smallbold
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Repeater {
                    model: popout.startOffset + popout.totalDays
                    delegate: QsButton {
                        id: calendarDay
                        required property var modelData
                        required property int index

                        readonly property bool isToday: (index >= popout.startOffset && (index - popout.startOffset + 1) === popout.today.getDate() && popout.year === popout.today.getFullYear() && popout.month === popout.today.getMonth())

                        Layout.fillWidth: true
                        content: Text {
                            width: calendarDay.width
                            text: (index >= popout.startOffset) ? (index - popout.startOffset + 1).toString() : ""
                            color: isToday ? GlobalVariables.colours.accent : GlobalVariables.colours.text
                            font: isToday ? GlobalVariables.font.semibold : GlobalVariables.font.regular
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Item {
                id: weatherSection
                visible: Service.Weather.weather
                anchors {
                    top: calendarGrid.bottom
                    left: parent.left
                    right: parent.right
                }
                width: parent.width
                height: visible ? weatherRowLayout.height : 0

                Rectangle {
                    anchors {
                        left: parent.left
                        leftMargin: GlobalVariables.controls.padding
                        verticalCenter: parent.verticalCenter
                    }
                    width: (parent.width - (GlobalVariables.controls.padding * 2) - (weatherRowLayout.spacing * 6)) / 7
                    height: parent.height - GlobalVariables.controls.spacing * 2
                    radius: GlobalVariables.controls.radius
                    color: GlobalVariables.colours.accent
                    opacity: 0.4
                }

                RowLayout {
                    id: weatherRowLayout
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - GlobalVariables.controls.padding * 2
                    uniformCellSizes: true

                    Repeater {
                        model: Service.Weather.weather ? 7 : 0
                        delegate: ColumnLayout {
                            required property int index

                            readonly property date today: new Date()

                            spacing: GlobalVariables.controls.spacing
                            Layout.fillWidth: true
                            Layout.topMargin: GlobalVariables.controls.padding
                            Layout.bottomMargin: GlobalVariables.controls.padding

                            Text {
                                Layout.fillWidth: true
                                text: Qt.formatDate(new Date(today.getFullYear(), today.getMonth(), today.getDate() + index), "ddd")
                                color: GlobalVariables.colours.text
                                font: GlobalVariables.font.bold
                                horizontalAlignment: Text.AlignHCenter
                            }

                            IconImage {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                implicitSize: GlobalVariables.controls.iconSize
                                source: Quickshell.iconPath(Service.Weather.getWeatherIcon(Service.Weather.weather.daily.weather_code[index]))
                            }

                            Text {
                                Layout.fillWidth: true
                                text: `${parseInt(Service.Weather.weather.daily.temperature_2m_min[index])}${Service.Weather.weather.daily_units.temperature_2m_min}\n${parseInt(Service.Weather.weather.daily.temperature_2m_max[index])}${Service.Weather.weather.daily_units.temperature_2m_max}`
                                color: GlobalVariables.colours.text
                                font: GlobalVariables.font.small
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
