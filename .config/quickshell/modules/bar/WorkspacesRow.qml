import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.services

Item {
    id: workspacesContainer

    property var monitorTags: Mango.tagStates[modelData.name] || ({
    })

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight
    Layout.fillWidth: false
    Layout.preferredWidth: implicitWidth

    Row {
        id: workspaceRow

        spacing: 4

        Repeater {
            model: 9

            delegate: Rectangle {
                id: wsDelegate

                required property int index
                property var tagObj: workspacesContainer.monitorTags[(index + 1).toString()] || null
                property bool isActive: tagObj ? tagObj.active : false
                property bool isUrgent: tagObj ? tagObj.urgent : false

                width: 22
                height: 21
                radius: 3
                color: {
                    if (isActive)
                        return Appearance.elevated;

                    if (isUrgent)
                        return Appearance.accent;

                    return Appearance.surface;
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
                        Mango.switchTag(wsDelegate.index + 1);
                    }
                }

            }

        }

        WheelHandler {
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => {
                let current = 1;
                for (const [index, tag] of Object.entries(workspacesContainer.monitorTags)) {
                    if (tag.active) {
                        current = Number(index);
                        break;
                    }
                }
                const delta = event.angleDelta.y > 0 ? -1 : 1;
                const nextTag = ((current - 1 + delta + 9) % 9) + 1;
                Mango.switchTag(nextTag);
            }
        }

    }

}
