import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.modules.bar
import qs.modules.common
import qs.services

RowLayout {
    id: playerControls

    Layout.fillWidth: true
    Layout.topMargin: 0
    spacing: 0

    ShellButton {
        icon: Icons.previous
        enabled: MprisController.canGoPrevious;
        onClicked: MprisController.previous();
    } 

    Item {
        Layout.fillWidth: true
    }

    ShellButton {
        icon: MprisController.isPlaying ? Icons.pause : Icons.play
        onClicked: MprisController.togglePlaying();
    }

    Item {
        Layout.fillWidth: true
    }

    ShellButton {
        icon: Icons.next
        enabled: MprisController.canGoNext;
        onClicked: MprisController.next();
    }
}
