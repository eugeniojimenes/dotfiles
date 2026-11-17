import QtQuick
import Quickshell
import Quickshell.Wayland
import "common"

// Recording indicator: bin/record starts it with wf-recorder and kills it when the recording ends. Red dot, REC and the
// elapsed time in the bottom-right corner; a click stops the recording. No keyboard, no full-screen overlay, unlike the
// popup panels. Sway cannot keep a surface out of the capture: the box is in the video when the recorded area holds it.
ShellRoot {
  PanelWindow {
    id: win

    readonly property real started: Date.now()
    property int elapsed: 0

    function clock(s) {
      const pad = n => String(n).padStart(2, "0")
      const h = Math.floor(s / 3600)
      return (h > 0 ? h + ":" : "") + pad(Math.floor(s / 60) % 60) + ":" + pad(s % 60)
    }

    anchors { bottom: true; right: true }
    // qmllint: Quickshell's qmltypes name the margins type without its namespace; Quickshell itself loads it.
    margins.bottom: 16 // qmllint disable unresolved-type
    margins.right: 16 // qmllint disable unresolved-type
    implicitWidth: row.implicitWidth + 28
    implicitHeight: row.implicitHeight + 14
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sway-recording"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // From the wall clock, not a tick count: a late tick never makes the time drift.
    Timer {
      interval: 1000
      repeat: true
      running: true
      onTriggered: win.elapsed = Math.floor((Date.now() - win.started) / 1000)
    }

    Rectangle {
      anchors.fill: parent
      radius: height / 2
      color: Theme.bg
      border.color: Theme.error
      border.width: 2

      Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
        Text { text: "●"; color: Theme.error; font.family: Theme.font; font.pixelSize: 14 }
        Text { text: "REC"; color: Theme.error; font.family: Theme.font; font.pixelSize: 14; font.bold: true }
        Text { text: win.clock(win.elapsed); color: Theme.fg; font.family: Theme.font; font.pixelSize: 14 }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/bin/record", "stop"])
      }
    }
  }
}
