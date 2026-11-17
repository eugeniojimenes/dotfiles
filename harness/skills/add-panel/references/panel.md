# Panel skeleton

Cut from `sway/.config/sway/wifi/shell.qml`. Replace `<name>`. Colors = Catppuccin Mocha, same as the other panels.

`sway/.config/sway/<name>/toggle` (mode 755):

```sh
#!/bin/sh
# <Icon> click: open the <name> panel, or close it when already open.
pkill -f 'quickshell -p .*/sway/<name>/shell.qml' || exec quickshell -p ~/.config/sway/<name>/shell.qml
```

`sway/.config/sway/<name>/shell.qml`:

```qml
import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Wayland

// <Name> panel for the waybar <icon>: <what it shows>. Esc or a click outside closes it. One process per open: nothing
// runs once it is closed.
ShellRoot {
  PanelWindow {
    id: win

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "sway-<name>"

    // Exclusive keyboard focus follows nothing: switching workspace would leave every window without input until this
    // closes. Close with it, like a popup. Sway skips mouse_warping while a layer surface holds the keyboard, so a jump
    // to another output warps the cursor here instead.
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

    readonly property color bg: "#f21e1e2e"
    readonly property color fg: "#cdd6f4"
    readonly property color accent: "#89b4fa"

    MouseArea {             // click outside the card closes
      anchors.fill: parent
      onClicked: Qt.quit()
    }

    Rectangle {
      id: card
      anchors.right: parent.right
      anchors.rightMargin: 8
      y: 34                 // below waybar
      width: 380
      height: 200
      radius: 12
      color: win.bg
      border.color: win.accent
      border.width: 2

      MouseArea { anchors.fill: parent }   // swallows clicks so they do not reach the close-on-outside area

      Item {
        focus: true
        Keys.onPressed: event => { if (event.key === Qt.Key_Escape) Qt.quit() }
      }

      // content
    }
  }
}
```

Wiring:

- `sway/.config/sway/apps/waybar.jsonc`: module `"on-click": "~/.config/sway/<name>/toggle"`.
- `sway/.config/sway/bin/menu`: `entry <icon> "<Label>" "run:$dir/<name>/toggle"` in the Setup submenu.
