import QtQuick
import Quickshell
pragma Singleton

Singleton {
    function truncateText(text, maxLength) {
        return text.length > maxLength ? text.substring(0, maxLength) + "…" : text;
    }

    function formatTime(seconds) {
        const s = Math.floor(seconds);
        const minutes = Math.floor(s / 60);
        const remainingSeconds = s % 60;

        return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
    }
}
