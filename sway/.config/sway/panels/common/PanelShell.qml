import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Wayland

// The window every popup panel is built on: a transparent overlay over the whole screen that holds the keyboard.
// It closes on a click anywhere outside the panel's card and on a workspace switch. Each panel only sets
// WlrLayershell.namespace ("sway-<name>"), draws its card and handles its own keys (Esc included).
// Theme colours are re-exported here, so panels write `win.fg` instead of importing Theme.
// Closing quits the process (one process per open). A panel inside a long-running process (the notification centre) sets
// keepAlive and handles dismissed() instead; its own keys call win.dismiss() too.
PanelWindow {
  property bool keepAlive: false
  signal dismissed()
  function dismiss() {
    if (keepAlive) dismissed()
    else Qt.quit()
  }

  readonly property color bg: Theme.bg
  readonly property color fg: Theme.fg
  readonly property color dim: Theme.dim
  readonly property color accent: Theme.accent
  readonly property color error: Theme.error
  readonly property color track: Theme.track
  readonly property string font: Theme.font

  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  // HACK: Exclusive keyboard focus does not follow a workspace switch: every window would stay without input until the
  // panel closed. So the panel closes with the switch, like a popup. Sway skips its own mouse warping while a layer
  // surface holds the keyboard, so when the switch lands on another output the cursor is moved here.
  I3IpcListener {
    subscriptions: ["workspace"]
    onIpcEvent: event => {
      if (event.type !== "workspace") return
      const change = JSON.parse(event.data)
      if (change.change !== "focus") return
      if (change.old && change.current && change.old.output !== change.current.output) {
        const rect = change.current.rect
        Quickshell.execDetached(["swaymsg", "seat", "-", "cursor", "set",
                                 String(Math.round(rect.x + rect.width / 2)),
                                 String(Math.round(rect.y + rect.height / 2))])
      }
      dismiss()
    }
  }

  // Anywhere outside the card closes. First child, so the panel's card (declared later) sits above it; the card
  // swallows its own clicks with a MouseArea of its own.
  MouseArea {
    anchors.fill: parent
    onClicked: dismiss()
  }
}
