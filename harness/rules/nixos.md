---
description: NixOS system config (flake, common.nix, host dirs)
paths:
  - "nixos/**"
  - "flake.nix"
  - "flake.lock"
globs: nixos/**, flake.nix, flake.lock
alwaysApply: false
---

# NixOS rules

Why behind each: `docs/nixos.md`. Full procedure: skill `nixos-change` (new machine: `new-host`).

- Format `nixfmt` (RFC 166). Lint `statix check -i 'nixos/hosts/*/hardware.nix' .`. One block per top-level option (`services = { ... }`), no repeated keys. `bin/check static` runs both.
- `nixos/hosts/*/hardware.nix` = `nixos-generate-config` output, verbatim. Never edit, never format. Change = regenerate on that machine.
- `common.nix` = every machine. Hostname, GPU driver + options, PRIME, `i915`, `thermald`, anything one machine needs = `nixos/hosts/<hostname>/default.nix`.
- New file = `git add` before `nix build`, `nix flake check`, `bin/check`. Flake sees tracked files only; untracked = "does not exist".
- Verify before handing over: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` then `nix store diff-closures /run/current-system ./result`. Refactor = diff shows only version label.
- Never touch `system.stateVersion`.
- Agent never runs `sudo`. Ask owner: `sudo nixos-rebuild switch --flake ~/dotfiles`. Kernel, initrd, driver, `boot.*` change = `sudo nixos-rebuild boot --flake ~/dotfiles` + reboot instead (skill `nixos-change`).
- New command a stowed script calls = add package here (Sway-only tool: `programs.sway.extraPackages`), plus `dotfiles-doctor` `commands` list when its absence breaks the desktop.
- Portals = sway package defaults. `programs.nix-ld` runs mise/Mason binaries. greetd autologins into `~/.config/sway/bin/start` (LUKS passphrase gates boot). `prime-run` keeps Arch name (Steam launch options). `programs.fzf.keybindings` + NixOS bash completion replace old `/usr/share` sourcing.
- Input method = plain `fcitx5` + `/etc/xdg/fcitx5` (keyboard only, no hotkeys), started by sway: Chromium/Electron ignore `~/.XCompose` (ç). Never `i18n.inputMethod` (adds configtool + KDE Frameworks, ~470 MiB).
- Known dead ends, do not retry: Nautilus as FileChooser portal (25 s startup deadlock), `gtk-theme = "Adwaita-dark"` (plain GTK3 lacks it, use `adw-gtk3-dark`), `nix.settings.auto-optimise-store` (slows every build, `nix.optimise.automatic` instead).
- Comments: why only, compressed, wrap ~120.
