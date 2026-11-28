import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.modules.bar
import qs.modules.common
import qs.services

PopupWindow {
    id: root

    implicitWidth: 400
    implicitHeight: 200
    color: "transparent"
    visible: false

    Connections {
        target: MprisController

        function onActivePlayerChanged() {
            if (MprisController.activePlayer === null) {
                root.visible = false
            }
        }
    }

    anchor {
        window: panel
        rect.x: (panel.width / 2) - (root.width / 2)
        rect.y: panel.height + Appearance.margin
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.radius
        color: Appearance.background
        border.color: Appearance.borderSubtle
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.margin
            spacing: Appearance.margin

            // Album artwork
            Item {
                id: artSection

                Layout.preferredWidth: root.implicitHeight - Appearance.margin * 2
                Layout.preferredHeight: root.implicitHeight - Appearance.margin * 2

                Image {
                    id: artImage

                    anchors.fill: parent
                    source: MprisController.activeTrack?.artUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    cache: true
                    mipmap: true
                    visible: false
                }

                Rectangle {
                    id: artMask

                    anchors.fill: parent
                    radius: Appearance.radius
                    antialiasing: true
                    visible: false
                }

                MultiEffect {
                    anchors.fill: parent
                    source: artImage
                    maskEnabled: true
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                    visible: artImage.status === Image.Ready
                        && MprisController.activePlayer !== null

                    maskSource: ShaderEffectSource {
                        visible: false
                        hideSource: true
                        smooth: true
                        sourceItem: artMask
                    }
                }
            }

            // Track metadata
            ColumnLayout {
                id: metadataColumn

                Layout.fillWidth: true
                spacing: Appearance.margin

                Text {
                    Layout.fillWidth: true
                    text: MprisController.activeTrack?.title ?? "No track"
                    color: Appearance.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: MprisController.activeTrack?.artist ?? ""
                    color: Appearance.muted
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize - 2
                    elide: Text.ElideRight
                }

                MusicPlayerProgressBar {}

                RowLayout {
                    Text {
                        text: `${Utils.formatTime(MprisController.activePlayer.position)}`
                        color: Appearance.muted
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize - 4
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: `-${Utils.formatTime(Math.max(0, MprisController.activePlayer.length - MprisController.activePlayer.position))}`
                        color: Appearance.muted
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize - 4
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 0

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
            }
        }
    }
}
