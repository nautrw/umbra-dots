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
                // property bool isUrgent: true
                property bool isHovered: false

                width: 22
                height: 21
                radius: 3
                color: {
                    if (isUrgent & isHovered) {
                        return Appearance.redHover
                    } else if (isUrgent & isActive) {
                        return Appearance.redActive
                    } else if (isUrgent) {
                        return Appearance.red
                    } else if (isActive & isHovered) {
                        return Appearance.accentHover
                    } else if (isActive) {
                        return Appearance.accent
                    } else if (isHovered) {
                        return Appearance.surfaceHover 
                    }

                    return Appearance.surface;
                }

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    color: Appearance.foreground
                    font.pixelSize: Appearance.fontSize
                }

                HoverHandler {
                    onHoveredChanged: {
                        wsDelegate.isHovered = hovered;
                    }
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
