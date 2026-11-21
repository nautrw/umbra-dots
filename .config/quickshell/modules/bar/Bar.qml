import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import qs.services
import qs.modules.common
import qs.modules.bar

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: panel

        required property var modelData
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 27
        exclusiveZone: 27
        color: Appearance.backgroundDark

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // WORKSPACES
            WorkspacesRow {}

            // FOCUSED WINDOW TITLE
            Text {
                text: Utils.truncateText(Mango.focusedWindowTitle, 75)

                color: Appearance.foreground
                font.pixelSize: Appearance.fontSize

                Layout.alignment: Qt.AlignVCenter
            }

            // RIGHT SPACER
            Item {
                Layout.fillWidth: true
            }

            SystemTrayRow {}

            RowLayout {
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
