# Clipboard history

Files: `sway/.config/sway/bin/clipboard`, started by `sway/.config/sway/config.d/90-autostart`, bound in `sway/.config/sway/config.d/30-apps`, listed in `sway/.config/sway/bin/menu`. `cliphist` comes from `nixos/common.nix`.

## Purpose

`clipboard` keeps every copy of the session with cliphist and lets the user pick an older one back with fuzzel. The history lives in `$XDG_RUNTIME_DIR`, which is in memory, so it is gone at logout and never reaches the disk. Copies that a password manager marks as sensitive are never stored.

## Acceptance criteria

1. `clipboard watch` runs `wl-paste --watch cliphist store` with the database in `$XDG_RUNTIME_DIR/cliphist/db`, creating the directory. Test: `tests/unit/sway/.config/sway/bin/clipboard.bats: "watch: every copy stored in the session's runtime dir"`
2. `clipboard pick` shows the history in fuzzel, newest first, showing and matching only the preview, and puts the chosen entry back on the clipboard through `cliphist decode`. Test: `tests/unit/sway/.config/sway/bin/clipboard.bats: "pick: history in fuzzel, the chosen entry decoded back onto the clipboard"`
3. Esc in the picker leaves the clipboard as it was. Test: `tests/unit/sway/.config/sway/bin/clipboard.bats: "pick: Esc leaves the clipboard alone"`
4. `clipboard clear` wipes the history. Test: `tests/unit/sway/.config/sway/bin/clipboard.bats: "clear: history wiped"`
5. The root menu has Clipboard history, and System has Clear clipboard history. Test: `tests/unit/sway/.config/sway/bin/menu.bats: "root: Clipboard history and Emoji run their scripts, System clears the history"`
6. `Super + V` opens the picker. Text and images copied in any app show up, newest first, and the chosen one pastes with `Ctrl + V`. A password copied from a password manager that marks it as sensitive does not show up. After logging out and back in, the history is empty. Test: manual
7. `clipboard` with no argument prints the usage and exits 2. Test: `tests/unit/sway/.config/sway/bin/clipboard.bats: "no argument: usage, exit 2"`
