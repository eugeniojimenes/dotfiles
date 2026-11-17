# Panel skeleton

Cut from `sway/.config/sway/wifi/shell.qml`. Replace `<name>`. Colours come from `common/Theme.qml` through `PanelShell` (`win.fg`, `win.accent`...).

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
import Quickshell.Wayland
import "../common"

// <Name> panel for the waybar <icon>: <what it shows>. Esc or a click outside closes it. One process per open: nothing
// runs once it is closed.
ShellRoot {
  PanelShell {              // common/PanelShell.qml: overlay, outside click + workspace switch close, theme
    id: win

    WlrLayershell.namespace: "sway-<name>"

    Rectangle {
      id: card
      anchors.right: parent.right
      anchors.rightMargin: 8
      y: 34                 // below waybar
      width: 380
      height: content.implicitHeight + 32
      radius: 12
      color: win.bg
      border.color: win.accent
      border.width: 2

      MouseArea { anchors.fill: parent }   // swallows clicks so they do not reach the close-on-outside area

      Item {
        focus: true
        Keys.onPressed: event => { if (event.key === Qt.Key_Escape) Qt.quit() }
      }

      Column {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 12

        // content

        Rectangle { width: parent.width; height: 1; color: win.track }

        AdvancedLink {      // only when a full TUI exists
          text: "󰒓  Advanced (<tui>)"
          command: ["<tui>"]
        }
      }
    }
  }
}
```

Wiring:

- `sway/.config/sway/apps/waybar.jsonc`: module `"on-click": "~/.config/sway/<name>/toggle"`.
- `sway/.config/sway/bin/menu`: `entry <icon> "<Label>" "run:$dir/<name>/toggle"` in the Setup submenu.
