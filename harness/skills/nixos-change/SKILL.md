---
name: nixos-change
description: Change the NixOS system config of this repo (nixos/common.nix, a host dir, flake.nix, flake.lock) end to end - edit, format, build, diff, hand the switch to the owner, verify, commit. Use for adding or removing a package, service, option, kernel module, or for `nix flake update`.
---

# nixos-change

Rules: `harness/rules/nixos.md`. Why: `docs/nixos.md`.

## Steps

1. Pick file. Every machine = `nixos/common.nix`. One machine = `nixos/hosts/<hostname>/default.nix`. Never `hardware.nix`.
2. Edit. Comment only a non-obvious why, compressed, wrap ~120.
3. Format + lint: `nix fmt` (treefmt.nix: nixfmt and the rest, skips `hardware.nix`), `statix check -i 'nixos/hosts/*/hardware.nix' .`.
4. `git add` every new or changed file under `nixos/` and `flake.*`.
5. Build: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` (host = `hostname`).
6. Diff: `nix store diff-closures /run/current-system ./result`. Read it: expected packages added or removed, versions moved only on `nix flake update`. Refactor = only version label. Surprise = stop, explain.
7. `bin/check` passes (eval of every host included).
8. Hand over. Ask owner to run `sudo nixos-rebuild switch --flake ~/dotfiles`. Kernel, initrd, driver, `boot.*` change = `sudo nixos-rebuild boot --flake ~/dotfiles` + reboot instead.
9. Verify after owner confirms:
   - `readlink /run/current-system` = the `./result` store path.
   - `systemctl --failed` and `systemctl --user --failed` empty.
   - Feature itself: `command -v <cmd>`, `systemctl status <svc>`, the option's effect.
   - New command scripts depend on: `dotfiles-doctor` clean.
10. Commit: `feat(nixos)`, `fix(nixos)`, `build(nixos)` for `flake.lock` moves. Docs touched = `docs/nixos.md` + `.pt-br.md` in same commit.

## Acceptance

- `nix build` ok, `diff-closures` matches intent, `bin/check` passes.
- Owner ran the switch; no failed units; feature works.
- Nothing machine-specific in `common.nix`.

## Pitfalls (from this repo)

- Untracked new file: flake build fails as if missing. `git add` first.
- Nautilus as FileChooser portal: 25 s deadlock at startup, every GTK app hung, waybar died. Portals stay sway module defaults.
- `gtk-theme = "Adwaita-dark"`: not shipped with plain GTK3, silently light. Use `adw-gtk3-dark`.
- No cursor theme set by NixOS: Sway drew X11 core cursors. Cursor theme set in Sway seat + dconf.
- Connector names renamed by GPU driver load race: `i915` in initrd on the notebook. Match outputs by make/model/serial.
- `auto-optimise-store` slows every build; `nix.optimise.automatic` is the timer variant.
- `system.stateVersion` never bumps.
- `hardware.bluetooth.settings` change: switch rewrites `/etc/bluetooth/main.conf` but does not restart bluetoothd. Owner runs `sudo systemctl restart bluetooth` (drops connected devices), then check `bluetoothctl show`.
- Agent never runs `sudo`.
