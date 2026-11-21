import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: systemTrayRow

    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem

            required property var modelData

            implicitWidth: 24
            implicitHeight: 24

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
                width: 24
                height: 24
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton && !trayItem.modelData.onlyMenu)
                        trayItem.modelData.activate();
                    else if (trayItem.modelData.hasMenu)
                        trayMenu.open();
                }
            }

        }

    }

}
