import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import qs.services
import qs.modules.common

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

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // WORKSPACES
            Item {
                id: workspacesContainer

                Layout.fillWidth: true
                Layout.preferredWidth: 1

                implicitWidth: workspaceRow.implicitWidth
                implicitHeight: workspaceRow.implicitHeight

                property var monitorTags:
                    Mango.tagStates[modelData.name] || ({})

                Row {
                    id: workspaceRow
                    spacing: 4

                    Repeater {
                        model: 9

                        delegate: Rectangle {
                            id: wsDelegate

                            required property int index

                            property var tagObj:
                            workspacesContainer.monitorTags[
                                (index + 1).toString()
                            ] || null

                            property bool isActive:
                            tagObj ? tagObj.active : false

                            property bool isUrgent:
                            tagObj ? tagObj.urgent : false

                            width: 22
                            height: 21
                            radius: 3

                            color: {
                                if (isActive)
                                return Appearance.elevated

                                if (isUrgent)
                                return Appearance.accent

                                return Appearance.surface
                            }

                            Text {
                                anchors.centerIn: parent

                                text: index + 1
                                color: Appearance.foreground
                                font.pixelSize: Appearance.fontSize
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    Mango.switchTag(wsDelegate.index + 1)
                                }
                            }
                        }
                    }
                }

                WheelHandler {
                    target: null
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                    onWheel: event => {
                        let current = 1

                        for (const [index, tag] of Object.entries(
                            workspacesContainer.monitorTags
                        )) {
                            if (tag.active) {
                                current = Number(index)
                                break
                            }
                        }

                        const delta = event.angleDelta.y > 0 ? -1 : 1
                        const nextTag = ((current - 1 + delta + 9) % 9) + 1

                        Mango.switchTag(nextTag)
                    }
                }
            }

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

            Row {
                id: systemTrayRow
                spacing: 4

                Repeater {
                    model: SystemTray.items

                    delegate: Item {
                        id: trayItem
                        required property var modelData

                        implicitWidth: 20
                        implicitHeight: 20

                        QsMenuAnchor {
                            id: trayMenu
                            anchor.item: trayItem
                            menu: trayItem.modelData.menu
                            anchor.edges: Edges.Bottom
                            anchor.gravity: Edges.Bottom
                        }

                        Image {
                            anchors.centerIn: parent
                            source: trayItem.modelData.icon
                            width: 20
                            height: 20
                            sourceSize.width: 20
                            sourceSize.height: 20
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton && !trayItem.modelData.onlyMenu)
                                    trayItem.modelData.activate()
                                else if (trayItem.modelData.hasMenu)
                                    trayMenu.open()
                            }
                        }
                    }
                }
            }
        }
    }
}
