import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property string label: ""

    property color bgColor: Appearance.elevated
    property color hoverBgColor: Appearance.elevatedHover
    property color textColor: Appearance.foreground
    property bool enabled: true

    signal clicked()

    radius: Appearance.radius
    color: {
        if (!enabled)
            return Appearance.backgroundRaised

        return (mouseArea.containsMouse ? hoverBgColor : bgColor)
    }

    width: contentRow.implicitWidth + 24
    height: 32

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 6

        Text {
            id: iconItem

            text: root.icon
            font.family: Icons.font
            font.pixelSize: Appearance.fontSize
            color: root.enabled ? root.textColor : Appearance.disabled

            visible: root.icon !== ""
            height: root.height
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: labelItem

            text: root.label
            font.pixelSize: Appearance.fontSize
            color: root.enabled ? root.textColor : Appearance.disabled

            visible: root.label !== ""
            height: root.height
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor

        onClicked: {
            if (root.enabled) {
                root.clicked();
            }
        }
    }
}
