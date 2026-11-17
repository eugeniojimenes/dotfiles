# Machines

The repo serves the notebook `loc-nixos` today. A desktop with an AMD GPU and two monitors will join later and has no hostname yet. Anything true for only one machine goes in that machine's files, never in the shared ones.

## What is per machine

- `nixos/hosts/<hostname>/default.nix`: the hostname, the GPU driver and its options (NVIDIA PRIME bus IDs, `i915` in the initrd, `services.xserver.videoDrivers`) and CPU-vendor services such as `thermald`, which is for Intel CPUs.
- `nixos/hosts/<hostname>/hardware.nix`: the generated hardware config, committed verbatim.
- `flake.nix`: one `nixosConfigurations.<hostname>` line per machine.
- `sway/.config/sway/hosts/<hostname>`: that machine's `output` lines. Sway includes it after `config.d/*`, so it can override anything there, and a machine without the file simply runs on the shared pieces.
- `tests/manual.md`: one section of hardware checks per machine.

Outputs are matched by `"make model serial"` as printed by `swaymsg -t get_outputs -p`, never by connector name. Connector names such as `eDP-1` shift with driver load order: the notebook panel was `eDP-2` on Arch and is `eDP-1` here.

## Notebook-only items to revisit for the desktop

These are in shared files today and only matter on the notebook. Check each one when the desktop arrives.

- `sway/.config/sway/panels/display/reinit` is the after-resume hook for external monitors on NVIDIA. It does no harm on other hardware.
- The GPU ordering in `sway/.config/sway/bin/start` does nothing on a machine with one GPU.
- The touchpad `input` block does nothing on a machine without a touchpad.
- AMD GPU monitoring tools (`amdgpu_top`, `rocm-smi`) belong in the desktop host file.
- Battery support: UPower with `criticalPowerAction`, `poweralertd` in `config.d/90-autostart`, the poweralertd rules in `panels/notifications/notify.mjs` and waybar's battery module. Without a battery they do nothing; check that the battery module stays hidden. The power panel hides its charge section and the charge limit without a laptop battery and opens from Setup › Power.
- The `bin/record` header says no VA-API driver is installed. That is the notebook's Intel GPU; an AMD GPU gets VA-API from Mesa, so `h264_vaapi` becomes an option there if x264 on two large monitors costs too much CPU.
- The internal microphone fix lives in the notebook's host file. Check the desktop's microphone with the same recording test before calling it done.

## Adding a machine

Install plain NixOS first. Then, inside the clone, create `nixos/hosts/<hostname>/` and write the machine's hardware config into it with `nixos-generate-config --show-hardware-config > nixos/hosts/<hostname>/hardware.nix`. Write `default.nix` using the notebook's file as a template, and leave out the NVIDIA, PRIME, `i915` and `thermald` parts unless the new machine has that hardware. Add a `nixosConfigurations.<hostname>` entry to `flake.nix`.

Next, write `sway/.config/sway/hosts/<hostname>` with the machine's `output` lines, add a section for it in `tests/manual.md`, and run `git add` on every new file, since the flake only sees tracked files. Build and install with `sudo nixos-rebuild boot --flake ~/dotfiles#<hostname>` and reboot. After the reboot the hostname matches and plain `nixos-rebuild switch --flake ~/dotfiles` works.

If the machine needs a monitor output line before Sway has run on it, start Sway once without the host file, read the names from `swaymsg -t get_outputs -p` and add them afterwards.

AI agents working in this repo have a `new-host` skill in `harness/skills/` that follows the same steps.
