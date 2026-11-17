---
name: new-host
description: Add a new machine to this repo - NixOS host dir with generated hardware.nix, flake entry, Sway output file, manual checklist section, first boot. Use when the owner installs NixOS on another machine (the AMD desktop is next) or asks to add a hostname.
---

# new-host

Why: `docs/machines.md`. Rules: `harness/rules/nixos.md`, `harness/rules/sway.md`.

## Inputs

Ask owner if unknown: hostname, CPU vendor, GPU(s) and driver, monitor count. Commands that must run on the new machine (it may not be this one): owner runs them and pastes output.

## Steps

1. `mkdir nixos/hosts/<h>`; on that machine: `nixos-generate-config --show-hardware-config > nixos/hosts/<h>/hardware.nix`. Commit verbatim, never edit.
2. `nixos/hosts/<h>/default.nix` from `nixos/hosts/loc-nixos/default.nix` as template: keep `imports`, set `networking.hostName = "<h>"`. Drop NVIDIA, PRIME, `i915` initrd, `thermald` unless that hardware exists. AMD GPU: `amdgpu` driver needs nothing extra beyond `hardware.graphics.enable` (common); add `amdgpu_top` / `rocm-smi` packages here, not in `common.nix`. Header comment = model + GPU.
3. `flake.nix`: `nixosConfigurations.<h> = nixpkgs.lib.nixosSystem { modules = [ ./nixos/hosts/<h> ]; };`. Attribute name = hostname.
4. `sway/.config/sway/hosts/<h>`: `output "<make> <model> <serial>" ...` lines from `swaymsg -t get_outputs -p` (needs Sway running once on that machine; first boot without the file is fine, missing file skipped). Never connector names.
5. `tests/manual.md`: new `## <h> (...)` section, items that apply to that hardware, specs' manual criteria included.
6. `docs/machines.md` + `docs/machines.pt-br.md`: host listed, notebook-only items revisited (`display/reinit`, `bin/start` GPU order, touchpad block).
7. `git add nixos flake.nix sway/.config/sway/hosts tests/manual.md docs`.
8. `nix fmt`, `bin/check` (static runs `sway -C` per host file, eval builds every host).
9. Owner on new machine: `sudo nixos-rebuild boot --flake ~/dotfiles#<h>` then reboot. Later rebuilds: plain `--flake ~/dotfiles` (hostname matches).
10. After boot: `hostname` = `<h>`, `systemctl --failed` empty, `dotfiles-doctor` clean, manual checklist pass for the new section.
11. Commit `feat(nixos): <h> host` (one commit: host dir, flake, sway host file, manual, docs).

## Acceptance

- `nix flake check` evaluates `nixosConfigurations.<h>`; `bin/check static` passes `sway -C` for `<h>`.
- New machine boots its generation, Sway outputs right, no failed units.
- No machine-specific line added to `common.nix` or `config.d/`.

## Pitfalls

- Forgot `git add`: flake does not see the host dir.
- Copying NVIDIA/PRIME bus IDs to a machine without that GPU: eval or boot fails.
- Hand-edited `hardware.nix`: next regenerate loses it. Machine tweaks go in `default.nix`.
- Output by connector name: renames on driver order change.
- Hostname with no Sway host file is valid; with no flake entry the switch picks nothing.
