import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property var tagStates: ({
    })
    property string focusedWindowTitle: ""
    property string focusedWindowAppID: ""

    function switchTag(n) {
        tagSwitchProc.command = ["mmsg", "dispatch", "view," + n.toString()];
        tagSwitchProc.running = true;
    }

    Process {
        id: tagSwitchProc
    }

    Process {
        id: focusedWatcher

        command: ["mmsg", "watch", "focusing-client"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    const client = JSON.parse(data);
                    root.focusedWindowTitle = client.title || client.name || "";
                    root.focusedWindowAppID = client.appid || "";
                } catch (e) {
                    console.warn("Window parsing error:", e);
                }
            }
        }

    }

    Process {
        id: tagWatcher

        command: ["mmsg", "watch", "all-tags"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                const trimmed = line.trim();
                if (!trimmed)
                    return ;

                let data;
                try {
                    data = JSON.parse(trimmed);
                } catch (e) {
                    console.warn("JSON parse error:", e);
                    return ;
                }
                if (!data.all_tags)
                    return ;

                const updated = {
                };
                for (const monitor of data.all_tags) {
                    const monitorTags = {
                    };
                    for (const tag of monitor.tags) {
                        monitorTags[tag.index.toString()] = {
                            "active": tag.is_active,
                            "urgent": tag.is_urgent,
                            "clients": tag.client_mount
                        };
                    }
                    updated[monitor.monitor] = monitorTags;
                }
                root.tagStates = updated;
            }
        }

    }

}
