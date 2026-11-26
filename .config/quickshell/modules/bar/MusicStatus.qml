import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.bar
import qs.modules.common
import qs.services

Item {
    visible: MprisController.activePlayer?.isPlaying ?? false

    implicitWidth: musicRow.implicitWidth
    implicitHeight: musicRow.implicitHeight

    Row {
        id: musicRow
        anchors.centerIn: parent
        spacing: Appearance.margin

        Text {
            text: ""
            font.family: Icons.font
            font.pixelSize: Appearance.fontSize
            color: Appearance.foreground
            opacity: 0.5
        }

        Text {
            text: `${Utils.truncateText(MprisController.activeTrack?.title, 25)} – ${Utils.truncateText(MprisController.activeTrack?.artist, 25)}`
            color: Appearance.foreground
            font.pixelSize: Appearance.fontSize
        }
    }
}
