import QtQuick
import Quickshell

pragma Singleton

Singleton {
    readonly property color backgroundDark: "#111111"
    readonly property color background: "#242424"
    readonly property color backgroundRaised: "#303030"
    readonly property color backgroundHover: "#3D3D3D"

    readonly property color surface: "#2B2B2B"
    readonly property color surfaceHover: "#454545"
    readonly property color elevated: "#3D3D3D"
    readonly property color elevatedHover: "#595959"

    readonly property color border: "#505050"
    readonly property color borderSubtle: "#383838"
    readonly property color borderStrong: "#777777"
    readonly property color borderHover: "#A0A0A0"

    readonly property color foreground: "#F6F5F4"
    readonly property color foregroundSecondary: "#DEDDDA"
    readonly property color muted: "#B5B3B0"
    readonly property color subtle: "#858585"
    readonly property color disabled: "#666666"

    readonly property color accent: "#3584E4"
    readonly property color accentHover: "#62A0EA"
    readonly property color accentActive: "#1C71D8"
    readonly property color accentSubtle: "#1C3B5A"
    readonly property color accentForeground: "#FFFFFF"

    readonly property color red: "#E01B24"
    readonly property color redHover: "#F66151"
    readonly property color redActive: "#C01C28"
    readonly property color redBackground: "#3D1A1A"
    readonly property color redBorder: "#A51D2D"

    readonly property color green: "#2EC27E"
    readonly property color greenHover: "#57E389"
    readonly property color greenBackground: "#173B2B"

    readonly property color yellow: "#F6D32D"
    readonly property color yellowHover: "#F9E56D"
    readonly property color yellowBackground: "#3D3215"

    readonly property color purple: "#9141AC"
    readonly property color purpleHover: "#C061CB"
    readonly property color purpleBackground: "#301A3A"

    readonly property int fontSize: 16
    readonly property string fontFamily: "sans"
    readonly property int margin: 10
}
