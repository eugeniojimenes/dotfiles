# Emoji picker

Files: `sway/.config/sway/bin/emoji`, bound in `sway/.config/sway/config.d/30-apps`, listed in `sway/.config/sway/panels/menu/menu.mjs`. `wtype` and `unicode-emoji` come from `nixos/common.nix`, which also links `/share/unicode` into the system profile.

## Purpose

`emoji` opens fuzzel over Unicode's emoji list, searched by English name, then types the chosen emoji into the focused window and leaves it on the clipboard. The list comes from the `unicode-emoji` package, so it works offline and follows nixpkgs updates.

## Acceptance criteria

1. The list holds only fully-qualified emoji from `emoji-test.txt`, one per line as the emoji and its name, skin tones as entries of their own. Test: `tests/unit/sway/.config/sway/bin/emoji.bats: "list: fully-qualified emoji only, each as emoji and name"`
2. The chosen emoji is typed with wtype and copied to the clipboard without a trailing newline. Test: `tests/unit/sway/.config/sway/bin/emoji.bats: "pick: emoji typed into the focused window and left on the clipboard"`
3. Esc types and copies nothing. Test: `tests/unit/sway/.config/sway/bin/emoji.bats: "Esc: nothing typed or copied"`
4. The root menu has Emoji. Test: `tests/unit/sway/.config/sway/panels/menu/menu.bats: "entries: each runs its script or panel toggle"`
5. `Super + .` opens the picker. Searching "thumbs" lists the thumbs up emoji, and picking one types it into a browser text field and into the terminal. Test: manual
