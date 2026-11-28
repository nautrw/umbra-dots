import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.modules.bar
import qs.modules.common
import qs.services

Item {
    id: musicStatusItem

    visible: MprisController.activePlayer?.isPlaying ?? false

    implicitWidth: musicRow.implicitWidth
    implicitHeight: musicRow.implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse
            ? Appearance.surfaceHover
            : "transparent"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Row {
        id: musicRow
        anchors.centerIn: parent
        spacing: Appearance.margin

        // Text {
        //     text: ""
        //     font.family: Icons.font
        //     font.pixelSize: Appearance.fontSize
        //     color: Appearance.foreground
        //     opacity: 0.5
        //     anchors.verticalCenter: parent.verticalCenter
        // }

        Text {
            text: `${Utils.truncateText(MprisController.activeTrack?.title, 25)} – ${Utils.truncateText(MprisController.activeTrack?.artist, 25)}`
            color: Appearance.muted
            font.pixelSize: Appearance.fontSize
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: popup.visible = !popup.visible
    }

    MediaPlayer {
        id: popup
    } 
}
