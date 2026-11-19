import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "screensaver/screensaver.mjs" as Saver
import "common"

// Screensaver: swayidle starts it after 5 min idle and ends it on any activity (bin/idle, ./screensaver/screensaver).
// Every output shows the wallpapers of ~/Pictures/Wallpapers in turn, dimmed, under a big clock that moves at each
// slide. Not a lock: a key, a click or a mouse move also ends it. It holds the keyboard, so the key that wakes the
// machine never reaches the focused window.
ShellRoot {
  id: root

  property list<string> images: []
  property int step: 0
  property date now: new Date()

  // Same folder and formats as bin/wallpaper.
  Process {
    running: true
    command: ["find", Quickshell.env("HOME") + "/Pictures/Wallpapers", "-type", "f", "(", "-iname", "*.png", "-o",
              "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.webp", ")"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.images = String(text).split("\n").filter(f => f !== "").sort()
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  Timer {
    interval: Saver.SLIDE_MS
    running: true
    repeat: true
    onTriggered: root.step++
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win

      required property var modelData
      readonly property int index: Quickshell.screens.indexOf(modelData)
      readonly property int image: Saver.imageIndex(root.step, index, Quickshell.screens.length, root.images.length)
      readonly property var spot: Saver.clockSpot(root.step, index)
      property bool front: true
      property point start: Qt.point(-1, -1)

      // The hidden image loads the next slide; the swap waits until it is ready, so a fade never shows a blank. Already
      // holding that slide (two images, one output): no load, so no ready signal, swap at once.
      function show() {
        const next = image < 0 ? "" : "file://" + root.images[image]
        const hidden = front ? back : face
        if (hidden.source.toString() === next && hidden.status === Image.Ready) front = !front
        else hidden.source = next
      }

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      color: Theme.crust
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "sway-screensaver"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      onImageChanged: show()
      Component.onCompleted: show()

      Image {
        id: face
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(win.width, win.height)
        opacity: win.front ? 1 : 0
        onStatusChanged: if (status === Image.Ready && !win.front) win.front = true
        Behavior on opacity { NumberAnimation { duration: 1500 } }
      }

      Image {
        id: back
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(win.width, win.height)
        opacity: win.front ? 0 : 1
        onStatusChanged: if (status === Image.Ready && win.front) win.front = false
        Behavior on opacity { NumberAnimation { duration: 1500 } }
      }

      Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.base, 0.85) // 85%: light wallpapers stay dark enough for the clock
      }

      Column {
        id: clock
        x: win.spot.x * (win.width - width)
        y: win.spot.y * (win.height - height)
        spacing: 4

        // From the first slide change on: the first spot is taken at once, not glided to from the corner.
        Behavior on x { enabled: root.step > 0; NumberAnimation { duration: 3000; easing.type: Easing.InOutQuad } }
        Behavior on y { enabled: root.step > 0; NumberAnimation { duration: 3000; easing.type: Easing.InOutQuad } }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          textFormat: Text.PlainText
          text: Qt.formatTime(root.now, "HH:mm")
          color: Theme.fg
          font.family: Theme.font
          font.pixelSize: 128
          font.bold: true
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          textFormat: Text.PlainText
          text: Qt.formatDate(root.now, "dddd, MMMM d")
          color: Theme.subtext0
          font.family: Theme.font
          font.pixelSize: 26
        }
      }

      // Ends on any input. The first pointer event only records where the pointer is: entering the surface is no move.
      Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: Qt.quit()

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.AllButtons
          cursorShape: Qt.BlankCursor
          onPressed: Qt.quit()
          onWheel: Qt.quit()
          onPositionChanged: mouse => {
            if (win.start.x < 0) win.start = Qt.point(mouse.x, mouse.y)
            else if (Math.abs(mouse.x - win.start.x) + Math.abs(mouse.y - win.start.y) > 20) Qt.quit()
          }
        }
      }
    }
  }
}
