# Network panel

Files: `sway/.config/sway/panels/network.qml` (Quickshell), `sway/.config/sway/panels/network/flow.mjs` (pick, password and connect flow), `sway/.config/sway/panels/network/toggle` (run by a click on the waybar network icon and by the menu entry Setup > Network).

## Purpose

The panel shows the wired connection while a cable is plugged in, and lists Wi-Fi networks live from NetworkManager and connects to one with a click or the keyboard. With both up, NetworkManager sends the traffic through the cable (lower route metric) and keeps Wi-Fi connected as a fallback, which is its default and Omarchy's, so the panel shows both. It asks for a password only when a personal (PSK or SAE) network has no saved profile. Anything it cannot handle goes to `nmtui`.

## Acceptance criteria

1. The panel file parses, every type, property and import resolves against Qt and Quickshell, and Quickshell loads it in a headless Sway. Test: `tests/static.sh: qmllint`, `tests/static.sh: panels-load`
2. Networks are listed with the connected one first and the rest by signal strength. Hidden networks with no name are left out. Test: `tests/unit/sway/.config/sway/panels/network/flow.bats: "list: connected first, then by signal, hidden networks left out"`
3. While the panel is open it scans for networks and shows "Searching…" until the scan ends, then "Scanned". Test: manual
4. The switch on the Wi-Fi line turns the Wi-Fi radio on and off. Test: manual
5. Picking an open network, or one with a saved profile, connects without a prompt, and the panel closes once the connection is up. Test: `tests/unit/sway/.config/sway/panels/network/flow.bats: "saved or open network: connects without a prompt, panel closes once it is up"`, manual
6. Picking a PSK or SAE network with no saved profile opens a password row under it, with the keyboard focus already in it. The row keeps its focus and typed text while the list updates. Enter submits the password. Esc closes the row. Test: `tests/unit/sway/.config/sway/panels/network/flow.bats: "new PSK network: password row, Enter connects with it, panel closes once up"`, `tests/unit/sway/.config/sway/panels/network/flow.bats: "saved network, secret refused: Wrong password, Esc closes the row"`, manual
7. A failed connection shows a message: "Wrong password" for a saved network whose secret was refused, "Enterprise network: use Advanced (nmtui)" for a network that needs secrets the panel cannot ask for, and "Connection failed" otherwise. Test: `tests/unit/sway/.config/sway/panels/network/flow.bats: "saved network, secret refused: Wrong password, Esc closes the row"`, `tests/unit/sway/.config/sway/panels/network/flow.bats: "enterprise network and other failures: message shown, panel stays"`
8. Up and Down move the selection, Enter picks the selected network, and Esc closes the panel. Test: manual
9. A click on a network that is already connected or changing state does nothing. Test: `tests/unit/sway/.config/sway/panels/network/flow.bats: "connected or changing network: click ignored"`
10. A Wired section above Wi-Fi shows while a cable is plugged in or the wired connection is up, and is hidden otherwise. It names the connection, says "Connected" with the link speed ("1 Gb/s", "100 Mb/s"), "Connecting…", "Disconnecting…" or "Not connected", and offers Disconnect or Connect, with no button while NetworkManager is busy. Test: `tests/unit/sway/.config/sway/panels/network/flow.bats: "wired row: hidden without a cable, status with link speed, connect or disconnect, nothing while busy"`
11. Plugging the cable in or out while the panel is open shows or hides the Wired section and updates its status, and Disconnect and Connect act on the wired connection while Wi-Fi stays as it was. Test: manual
