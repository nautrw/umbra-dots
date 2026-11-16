import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData
            screen: modelData

            property var tagStates: ({})
            property string focusedWindowTitle: ""

            function switchTag(n) {
                tagSwitchProc.command = ["mmsg", "dispatch", "view," + n.toString()]
                tagSwitchProc.running = true
            }

            Process {
                id: tagSwitchProc
            }

            Process {
                id: focusedWatcher
                command: ["mmsg", "watch", "focusing-client"]
                running: true

                stdout: SplitParser {
                    onRead: data => {
                        try {
                            const client = JSON.parse(data)
                            panel.focusedWindowTitle = client.title || client.name || ""
                        } catch (e) {
                            console.warn("Window parsing error:", e)
                        }
                    }
                }
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 27
            exclusiveZone: 27
            color: Theme.background

            Process {
                id: tagWatcher
                command: ["mmsg", "watch", "all-tags"]
                running: true

                stdout: SplitParser {
                    splitMarker: "\n"

                    onRead: (line) => {
                        const trimmed = line.trim()
                        if (!trimmed) return

                        let data
                        try {
                            data = JSON.parse(trimmed)
                        } catch (e) {
                            console.warn("JSON parse error:", e)
                            return
                        }

                        if (!data.all_tags) return

                        const screenName = panel.modelData.name

                        const monEntry = data.all_tags.find(
                            m => m.monitor === screenName
                        )

                        if (!monEntry) {
                            console.warn("Monitor not found:", screenName)
                            return
                        }

                        const updated = {}

                        for (const t of monEntry.tags) {
                            updated[t.index.toString()] = {
                                active: t.is_active,
                                urgent: t.is_urgent,
                                clients: t.client_mount
                            }
                        }

                        panel.tagStates = updated
                    }
                }
            }

            // Your existing layout goes here
            RowLayout {
                anchors.fill: parent

                // WORKSPACES
                Item {
                    id: workspacesContainer

                    Layout.fillWidth: true
                    Layout.preferredWidth: 1

                    width: workspaceRow.implicitWidth
                    height: workspaceRow.implicitHeight

                    Row {
                        id: workspaceRow
                        spacing: 4

                        Repeater {
                            model: 9

                            delegate: Rectangle {
                                id: wsDelegate
                                required property int index

                                property var tagObj:
                                    panel.tagStates[(index + 1).toString()] || null

                                property bool isActive:
                                    tagObj ? tagObj.active : false

                                width: 22
                                height: 21
                                radius: 3

                                color: isActive ? "#707070" : "#303030"

                                Text {
                                    anchors.centerIn: parent
                                    text: index + 1
                                    color: Theme.foreground
                                    font.pixelSize: Theme.fontSize
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: panel.switchTag(wsDelegate.index + 1)
                                }
                            }
                        }
                    }

                    WheelHandler {
                        target: null
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                        onWheel: (event) => {
                            let current = 1

                            for (const [index, tag] of Object.entries(panel.tagStates)) {
                                if (tag.active) {
                                    current = Number(index)
                                    break
                                }
                            }

                            // feels more natural when reversed
                            const delta = event.angleDelta.y > 0 ? -1 : 1
                            // panel.switchTag(Math.max(1, Math.min(9, current + delta)))
                            // above doesnt wraps around, this one does
                            const nextTag = ((current - 1 + delta + 9) % 9) + 1
                            panel.switchTag(nextTag)
                        }
                    }
                }

                Text {
                    text: panel.focusedWindowTitle
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSize
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
