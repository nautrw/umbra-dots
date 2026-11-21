import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.modules.bar
import qs.modules.common
import qs.services

RowLayout {
    implicitHeight: 24
    Layout.leftMargin: Appearance.margin

    Image {
        Layout.preferredWidth: source != "" ? 24 : 0
        Layout.preferredHeight: 24
        source: {
            const entry = DesktopEntries.heuristicLookup(Mango.focusedWindowAppID);
            return entry ? Quickshell.iconPath(entry.icon) : "";
        }
        sourceSize.width: 24
        sourceSize.height: 24
        fillMode: Image.PreserveAspectFit
        visible: source !== "" && Mango.focusedWindowTitle !== ""
    }

    Text {
        text: Utils.truncateText(Mango.focusedWindowTitle, 25)
        color: Appearance.foreground
        font.pixelSize: Appearance.fontSize
    }

}
