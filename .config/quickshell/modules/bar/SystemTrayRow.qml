import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

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
                sourceSize.width: 50
                sourceSize.height: 50
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
