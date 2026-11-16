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

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 27
            exclusiveZone: 27
            color: Colors.background

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

                Row {
                    spacing: 4

                    Repeater {
                        model: 9

                        delegate: Rectangle {
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
                                color: Colors.foreground
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}
