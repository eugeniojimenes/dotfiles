# Menu

Files: `sway/.config/sway/bin/menu` (run by `Super + Space` and by a click on the waybar menu icon), `sway/.config/sway/apps/fuzzel.ini` (root), `sway/.config/sway/apps/fuzzel-menu.ini` (submenus, Left = back).

## Purpose

One fuzzel menu holds the categories (Apps, Capture, Style, Setup, Toggle, System) and every installed app, so typing an app name at the top launches it and the categories lead to the desktop's settings and actions. This spec covers the menu itself: navigation, the app list and how entries run. What each entry does is in the spec of its feature (bluetooth-panel, clipboard-history, hibernation, update and others).

## Acceptance criteria

1. `Super + Space` and a click on the waybar menu icon open the menu. The root lists the categories and then every app, and typing part of an app's name and Enter launches it. Test: manual
2. Esc at the root closes the menu and launches nothing. Test: `tests/unit/sway/.config/sway/bin/menu.bats: "Esc at the top: exit 0, nothing launched"`
3. Left in a submenu goes back to the root, and so does Esc. Test: `tests/unit/sway/.config/sway/bin/menu.bats: "Left in a submenu: back to the root menu"`, manual
4. Apps come from the `.desktop` files in `XDG_DATA_HOME` and `XDG_DATA_DIRS`, the user's own first, so a local file overrides one with the same id. Entries marked `NoDisplay` or `Hidden` and anything that is not an application are left out. Test: manual
5. An app is launched by its desktop id through `gtk-launch`, as one argument, so nothing from a `.desktop` file reaches a shell. An app whose name holds a TAB still launches as an app, and the text after the TAB never runs. Test: `tests/unit/sway/.config/sway/bin/menu.bats: "app named with a TAB: still launched as an app, the text after the TAB never reaches a shell"`
6. Toggle > Power profile lists power-saver, balanced and performance with the current one checked, and a pick sets it and asks for the profile popup (`osd switch profile <name>`). Test: `tests/unit/sway/.config/sway/bin/menu.bats: "Toggle > Power profile: current one checked, pick sets it and shows the popup"`
