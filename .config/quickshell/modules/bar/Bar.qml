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

            // LEFT SECTION
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                Row {
                    spacing: Appearance.margin
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Appearance.margin

                    WorkspacesRow {
                    }

                    WindowTitleRow {
                    }

                }

            }

            // CENTER SECTION
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                Row {
                    anchors.centerIn: parent
                    spacing: Appearance.margin

                    Text {
                        text: `${Qt.formatDateTime(clock.date, "ddd MMM d hh:mm")}`
                        font.pixelSize: Appearance.fontSize
                        color: Appearance.foreground
                    }

                    MusicStatus {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // RIGHT SECTION
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 1

                RowLayout{
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.margin
                    anchors.rightMargin: Appearance.margin

                    SystemTrayRow {
                    }

                    Text {
                        text: `${Icons.speakerHigh} ${Math.round(Audio.value * 100)}`
                        color: Appearance.foreground
                        font.family: "Phosphor-Bold"
                        font.pixelSize: Appearance.fontSize

                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: (event) => {
                                if (event.angleDelta.y > 0) {
                                    Audio.incrementVolume()
                                } else {
                                    Audio.decrementVolume()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
