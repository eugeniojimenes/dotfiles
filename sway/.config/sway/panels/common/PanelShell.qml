import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Wayland

// What every popup panel shares: full-screen transparent overlay holding the keyboard, a click anywhere outside the
// card closes, and a workspace switch closes. Each panel sets WlrLayershell.namespace ("sway-<name>"), draws its card
// and handles its keys (Esc included). Theme colours re-exported, so panels write `win.fg`.
PanelWindow {
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  readonly property color bg: Theme.bg
  readonly property color fg: Theme.fg
  readonly property color dim: Theme.dim
  readonly property color accent: Theme.accent
  readonly property color error: Theme.error
  readonly property color track: Theme.track
  readonly property string font: Theme.font

  // Exclusive keyboard focus follows nothing: switching workspace (key or click on another output) would leave every
  // window without input until this closes. Close with it, like a popup. Sway skips its mouse_warping while a layer
  // surface holds the keyboard, so a jump to another output warps the cursor here instead.
  I3IpcListener {
    subscriptions: ["workspace"]
    onIpcEvent: event => {
      if (event.type !== "workspace") return
      const e = JSON.parse(event.data)
      if (e.change !== "focus") return
      if (e.old && e.current && e.old.output !== e.current.output) {
        const r = e.current.rect
        Quickshell.execDetached(["swaymsg", "seat", "-", "cursor", "set",
                                 String(Math.round(r.x + r.width / 2)), String(Math.round(r.y + r.height / 2))])
      }
      Qt.quit()
    }
  }

  // Anywhere outside the card closes. First child, so the panel's card (declared later) sits above it; the card
  // swallows its own clicks with a MouseArea of its own.
  MouseArea {
    anchors.fill: parent
    onClicked: Qt.quit()
  }
}
