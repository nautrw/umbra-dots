import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.modules.bar
import qs.modules.common
import qs.services

ColumnLayout {
    id: progressRoot

    property bool isVisibleOnScreen: true

    Layout.fillWidth: true
    Layout.topMargin: Appearance.margin
    spacing: Appearance.margin

    Item {
        id: progressArea

        Layout.fillWidth: true
        implicitHeight: 16

        readonly property real rawProgress: (
            MprisController.activePlayer
            && MprisController.activePlayer.length > 0
        )
            ? MprisController.activePlayer.position
                / MprisController.activePlayer.length
            : 0

        property real displayProgress: rawProgress
        property real seekProgress: 0

        readonly property real currentProgress: seekMouseArea.pressed
            ? seekProgress
            : Math.max(0, Math.min(1, displayProgress))

        property real lastRawProgress: 0
        property bool isDiscontinuous: false

        readonly property bool isInteractive:
            seekMouseArea.containsMouse || seekMouseArea.pressed

        readonly property real trackHeight: isInteractive ? 5 : 3

        property double playbackStartTime: Date.now()
        property real playbackStartPosition: 0

        Component.onCompleted: {
            if (MprisController.activePlayer) {
                playbackStartPosition =
                    MprisController.activePlayer.position;

                playbackStartTime = Date.now();
            }
        }

        onRawProgressChanged: {
            const diff = rawProgress - lastRawProgress;

            if (diff < 0 || diff > 0.04) {
                isDiscontinuous = true;
                discontinuousTimer.restart();
            }

            lastRawProgress = rawProgress;

            if (!seekMouseArea.pressed) {
                displayProgress = rawProgress;

                const player = MprisController.activePlayer;

                if (player && player.length > 0) {
                    playbackStartPosition = player.position;
                    playbackStartTime = Date.now();
                }
            }
        }

        Connections {
            target: MprisController

            function onActivePlayerChanged() {
                const player = MprisController.activePlayer;

                progressArea.playbackStartPosition =
                    player && player.length > 0
                    ? player.position
                    : 0;

                progressArea.playbackStartTime = Date.now();

                progressArea.displayProgress =
                    player && player.length > 0
                    ? player.position / player.length
                    : 0;
            }
        }

        Connections {
            target: MprisController.activePlayer

            function onPositionChanged() {
                if (seekMouseArea.pressed)
                    return;

                const player = MprisController.activePlayer;

                if (!player || player.length <= 0)
                    return;

                progressArea.playbackStartPosition = player.position;
                progressArea.playbackStartTime = Date.now();

                progressArea.displayProgress =
                    player.position / player.length;
            }
        }

        Connections {
            target: MprisController.activePlayer

            function onPlaybackStateChanged() {
                const player = MprisController.activePlayer;

                if (!player || player.length <= 0)
                    return;

                progressArea.playbackStartPosition = player.position;
                progressArea.playbackStartTime = Date.now();

                progressArea.displayProgress =
                    player.position / player.length;
            }
        }

        Timer {
            id: playbackTimer

            interval: 100
            repeat: true

            running: MprisController.isPlaying
                && MprisController.activePlayer !== null
                && !seekMouseArea.pressed

            onTriggered: {
                const player = MprisController.activePlayer;

                if (!player || player.length <= 0)
                    return;

                const elapsed = (
                    Date.now() - progressArea.playbackStartTime
                ) / 1000;

                const estimatedPosition =
                    progressArea.playbackStartPosition + elapsed;

                progressArea.displayProgress = Math.max(
                    0,
                    Math.min(1, estimatedPosition / player.length)
                );
            }
        }

        Timer {
            id: discontinuousTimer

            interval: 50

            onTriggered: {
                progressArea.isDiscontinuous = false;
            }
        }

        Rectangle {
            id: bgTrack

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            height: progressArea.trackHeight
            radius: height / 2

            color: Appearance.foreground
            opacity: 0.15

            Behavior on height {
                NumberAnimation {
                    duration: Appearance.animFast
                    easing.type: Easing.OutQuad
                }
            }
        }

        Rectangle {
            id: activeTrack

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            height: progressArea.trackHeight
            radius: height / 2

            color: Appearance.accent

            width: Math.max(
                0,
                Math.min(
                    parent.width,
                    progressArea.currentProgress * parent.width
                )
            )

            Behavior on height {
                NumberAnimation {
                    duration: Appearance.animFast
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on width {
                enabled: !seekMouseArea.pressed
                    && MprisController.isPlaying
                    && progressRoot.isVisibleOnScreen
                    && !progressArea.isDiscontinuous

                NumberAnimation {
                    duration: Appearance.animExpressive * 2
                    easing.type: Easing.Linear
                }
            }
        }

        Rectangle {
            id: thumb

            x: Math.max(
                0,
                Math.min(
                    parent.width - width,
                    progressArea.currentProgress * parent.width
                        - width / 2
                )
            )

            anchors.verticalCenter: parent.verticalCenter

            width: seekMouseArea.pressed
                ? 12
                : (seekMouseArea.containsMouse ? 10 : 6)

            height: width
            radius: width / 2

            color: Appearance.accent

            visible: MprisController.activePlayer !== null

            scale: progressArea.currentProgress > 0.001 ? 1 : 0

            layer.enabled: progressArea.isInteractive

            Behavior on x {
                enabled: !seekMouseArea.pressed
                    && MprisController.isPlaying
                    && progressRoot.isVisibleOnScreen
                    && !progressArea.isDiscontinuous

                NumberAnimation {
                    duration: Appearance.animExpressive * 2
                    easing.type: Easing.Linear
                }
            }

            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Appearance.accent

                blurMax: (Appearance.size2Xs + 2) * 2
                shadowBlur: 1

                shadowVerticalOffset: 0
                shadowHorizontalOffset: 0

                opacity: 0.4
            }
        }

        MouseArea {
            id: seekMouseArea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            function updateSeek(mouse) {
                const player = MprisController.activePlayer;

                if (!player || !player.canSeek || player.length <= 0)
                    return;

                const p = Math.max(
                    0,
                    Math.min(1, mouse.x / width)
                );

                progressArea.seekProgress = p;
                progressArea.displayProgress = p;

                progressArea.playbackStartPosition =
                    p * player.length;

                progressArea.playbackStartTime = Date.now();

                player.position = p * player.length;
            }

            onPressed: (mouse) => {
                updateSeek(mouse);
            }

            onPositionChanged: (mouse) => {
                if (pressed)
                    updateSeek(mouse);
            }

            onReleased: {
                progressArea.displayProgress =
                    progressArea.seekProgress;

                const player = MprisController.activePlayer;

                if (player && player.length > 0) {
                    progressArea.playbackStartPosition =
                        progressArea.seekProgress * player.length;

                    progressArea.playbackStartTime = Date.now();
                }
            }
        }
    }
}
