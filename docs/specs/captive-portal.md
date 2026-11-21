# Captive portal

Files: `sway/.config/sway/bin/portal`, started by `sway/.config/sway/config.d/90-autostart`. The connectivity check it reads is `networking.networkmanager.settings.connectivity` in `nixos/common.nix`.

## Purpose

Public Wi-Fi often asks for a login on a web page before it lets traffic through, and nothing on this desktop noticed that: the network looked connected and every site failed. `portal` shows a notification when NetworkManager's connectivity check finds such a page, and its button opens a login window. The window is a separate Brave profile that also maps the login name some Aruba access points expect the network's DNS to answer, `securelogin.hpe.com`, to a public address the access point intercepts, because networks that hand out a public DNS server never resolve that name.

## Acceptance criteria

1. `portal watch` shows a "Wi-Fi needs a login" notification with an "Open login" button each time NetworkManager reports the connectivity state `portal`, and none for other states. Test: `tests/unit/sway/.config/sway/bin/portal.bats: "watch: login page reported, notification with Open login button"`
2. When the session starts already behind a login page, `portal watch` shows the notification right away. Test: `tests/unit/sway/.config/sway/bin/portal.bats: "watch: already behind a login page at start, notification right away"`
3. Clicking the notification or its button opens the login window, and dismissing it opens nothing. Test: `tests/unit/sway/.config/sway/bin/portal.bats: "watch: Open login clicked, login window opens"`, `tests/unit/sway/.config/sway/bin/portal.bats: "watch: notification dismissed, no window"`
4. `portal login` opens Brave with a throwaway profile in `$XDG_RUNTIME_DIR`, the Aruba login names mapped to a public address, on a plain HTTP page the network can redirect. Test: `tests/unit/sway/.config/sway/bin/portal.bats: "login: throwaway profile, Aruba login names mapped, plain HTTP page"`
5. `portal` with no argument prints the usage and exits 2. Test: `tests/unit/sway/.config/sway/bin/portal.bats: "no argument: usage, exit 2"`
6. On a public Wi-Fi with a login page, the notification shows up within a few seconds of connecting, the login window reaches the network's page, and after the login the network gives full access. Test: manual
