import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.modules.bar
import qs.modules.common
import qs.services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: panel

        required property var modelData

        screen: modelData
        implicitHeight: 26
        exclusiveZone: 26
        color: Appearance.backgroundDark

        anchors {
            top: true
            left: true
            right: true
        }

        SystemClock {
            id: clock

            precision: SystemClock.Seconds
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // WORKSPACES
            WorkspacesRow {
                Layout.leftMargin: Appearance.margin
            }

            WindowTitleRow {}

            // FOCUSED WINDOW TITLE

            // RIGHT SPACER
            Item {
                Layout.fillWidth: true
            }

            SystemTrayRow {
            }

            RowLayout {
                Layout.rightMargin: Appearance.margin

                Text {
                    id: clockTime

                    text: Qt.formatDateTime(clock.date, "hh:mm MM/dd/yyyy")
                    font.pixelSize: Appearance.fontSize
                    color: Appearance.foreground
                }
            }

        }

    }

}
