# Wi-Fi panel

Files: `sway/.config/sway/wifi/shell.qml` (Quickshell), `sway/.config/sway/wifi/flow.js` (pick, password and connect flow), `sway/.config/sway/wifi/toggle` (run by a click on the waybar network icon and by the menu entry Setup > Wi-Fi).

## Purpose

The panel lists Wi-Fi networks live from NetworkManager and connects to one with a click or the keyboard. It asks for a password only when a personal (PSK or SAE) network has no saved profile. Anything it cannot handle goes to `nmtui`.

## Acceptance criteria

1. The panel file parses, every type, property and import resolves against Qt and Quickshell, and Quickshell loads it in a headless Sway. Test: `tests/static.sh: qmllint`, `tests/static.sh: panels-load`
2. A click on the waybar network icon opens the panel, and a second click closes it. Test: manual
3. Networks are listed with the connected one first and the rest by signal strength. Hidden networks with no name are left out. Test: `tests/unit/sway/.config/sway/wifi/flow.bats: "list: connected first, then by signal, hidden networks left out"`
4. While the panel is open it scans for networks and shows "Searching…" until the scan ends, then "Scanned". Test: manual
5. The switch in the header turns the Wi-Fi radio on and off. Test: manual
6. Picking an open network, or one with a saved profile, connects without a prompt, and the panel closes once the connection is up. Test: `tests/unit/sway/.config/sway/wifi/flow.bats: "saved or open network: connects without a prompt, panel closes once it is up"`, manual
7. Picking a PSK or SAE network with no saved profile opens a password row under it. Enter submits the password. Esc closes the row. Test: `tests/unit/sway/.config/sway/wifi/flow.bats: "new PSK network: password row, Enter connects with it, panel closes once up"`, `tests/unit/sway/.config/sway/wifi/flow.bats: "saved network, secret refused: Wrong password, Esc closes the row"`, manual
8. A failed connection shows a message: "Wrong password" for a saved network whose secret was refused, "Enterprise network: use Advanced (nmtui)" for a network that needs secrets the panel cannot ask for, and "Connection failed" otherwise. Test: `tests/unit/sway/.config/sway/wifi/flow.bats: "saved network, secret refused: Wrong password, Esc closes the row"`, `tests/unit/sway/.config/sway/wifi/flow.bats: "enterprise network and other failures: message shown, panel stays"`
9. Up and Down move the selection, Enter picks the selected network, and Esc closes the panel. Test: manual
10. A click outside the panel or a workspace switch closes it. When the switch lands on another output, the cursor moves to the centre of that output. Test: manual
11. "Advanced (nmtui)" opens `nmtui` in a floating terminal. Test: manual
12. A click on a network that is already connected or changing state does nothing. Test: `tests/unit/sway/.config/sway/wifi/flow.bats: "connected or changing network: click ignored"`
