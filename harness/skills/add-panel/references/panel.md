# Panel skeleton

Cut from `sway/.config/sway/panels/wifi.qml`. Replace `<name>`. Colours come from `common/Theme.qml` through `PanelShell` (`win.fg`, `win.accent`...).

`sway/.config/sway/panels/<name>/toggle` (mode 755):

```sh
#!/bin/sh
# <Icon> click: open the <name> panel, or close it when already open.
pkill -f 'quickshell -p .*/sway/panels/<name>.qml' || exec quickshell -p ~/.config/sway/panels/<name>.qml
```

`sway/.config/sway/panels/<name>.qml` (entry file, top of `panels/`, never in a subdir):

```qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import "common"           // panels/common/, beside this file

// <Name> panel for the waybar <icon>: <what it shows>. Esc or a click outside closes it. One process per open: nothing
// runs once it is closed.
ShellRoot {
  PanelShell {              // common/PanelShell.qml: overlay, outside click + workspace switch close, theme
    id: win

    WlrLayershell.namespace: "sway-<name>"

    PanelCard {             // common/PanelCard.qml: under the bar, right edge, swallows clicks
      id: card

      width: 380
      height: content.implicitHeight + 32

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

- `sway/.config/sway/apps/waybar.jsonc`: module `"on-click": "~/.config/sway/panels/<name>/toggle"`.
- `sway/.config/sway/bin/menu`: `entry <icon> "<Label>" "run:$dir/panels/<name>/toggle"` in the Setup submenu.
