# NixOS

The system configuration lives in `nixos/` and in `flake.nix` at the repo root. `nixos/` is not a stow module: it has no dot-prefixed contents, so stow and `dotfiles-doctor` skip it.

## Layout

`flake.nix` defines one `nixosConfigurations.<hostname>` per machine. The attribute name is the hostname, so `sudo nixos-rebuild switch --flake ~/dotfiles` picks the right system by itself. The flake follows the `nixos-26.05` branch, and `flake.lock` pins the exact nixpkgs revision. `nix flake update` moves the lock to the newest revision of that branch.

`nixos/common.nix` holds everything every machine shares: packages, services, Sway, login. `nixos/hosts/<hostname>/default.nix` holds what one machine needs and imports `../../common.nix` and `./hardware.nix`. `/etc/nixos` is not used.

`hardware.nix` is the output of `nixos-generate-config` for that machine, committed verbatim. It contains disk UUIDs and kernel modules and no secrets. Regenerate it instead of editing it by hand. It is also excluded from `nixfmt` and `statix`, so the file stays exactly as the tool wrote it.

A flake only sees files that git tracks. A new file has to be added with `git add` before any `nix` command reads the flake, or the build fails as if the file did not exist.

There is no home-manager. System packages and services live in `nixos/`, and user configuration goes through the stow modules.

## Notebook (loc-nixos)

The notebook is a Lenovo LOQ with Intel UHD graphics and an RTX 3050 Laptop GPU. Its host file sets:

- The NVIDIA open kernel module (Ampere supports it) with PRIME offload. Intel renders the desktop and the NVIDIA card runs programs started with `prime-run`. The command keeps its Arch name (`offloadCmdMainProgram = "prime-run"`) so Steam launch options carried over unchanged.
- `hardware.nvidia.powerManagement.enable` for suspend.
- `i915` in the initrd. Connector names (`eDP-1`, `DP-1`, `HDMI-A-1` and so on) come from one counter shared by both GPUs, in the order their drivers load. Without this line a race between the two drivers sometimes renamed the built-in panel. Loading `i915` first fixes the order on every boot, and as a side effect the LUKS prompt shows at native resolution.
- `services.xserver.videoDrivers = [ "nvidia" ]` and `thermald` (Intel CPU thermal management).

## Login

greetd logs straight into Sway by running `~/.config/sway/bin/start`. The disk is LUKS-encrypted, so the passphrase at boot already gates the machine and a second password would add nothing. Leaving Sway shows tuigreet.

## Shell support

`programs.fzf.keybindings` and the NixOS bash completion replace what the `bash` module used to source from `/usr/share` on Arch.

`programs.nix-ld` lets prebuilt binaries run. mise and Mason download binaries (Node, Python, Ruby, rustup, language servers) that expect `/lib64/ld-linux-x86-64.so.2`. `icu` is added to the default library set because .NET binaries such as Mason's marksman abort without `libicu`.

## Portals

The portals come from the defaults of the NixOS Sway module: `xdg-desktop-portal-wlr` handles screen sharing and screenshots, and `xdg-desktop-portal-gtk` handles everything else, including the file chooser.

Nautilus as the FileChooser backend was tried and dropped. At startup the portal activates Nautilus, and Nautilus calls the portal back while it is still starting, so both wait on each other for 25 seconds. Every GTK app started during that window hung, and waybar died at login.

## Theme and cursor

Dark mode is set through dconf defaults, which `gsettings set` can still override. `color-scheme = "prefer-dark"` covers GTK4, libadwaita and Chromium. GTK3 ignores that key and needs a theme by name. Plain GTK3 does not ship an `Adwaita-dark` theme, and an unknown theme name falls back to light Adwaita, which is why the file chooser and other GTK3 apps stayed light. `adw-gtk3-dark` (from the `adw-gtk3` package) makes GTK3 apps look like libadwaita apps.

NixOS sets no default cursor theme, so Sway drew the old X11 core cursors. `adwaita-icon-theme` was already in the closure as a GTK dependency. It is now installed explicitly and set both in Sway (`seat * xcursor_theme Adwaita 24`) and in dconf for GTK.

## Generations and garbage collection

Every rebuild creates a new generation and a new boot entry, which is what makes rollback possible: `sudo nixos-rebuild switch --rollback`, or pick an older entry in the boot menu. systemd-boot keeps 10 entries so the 1 GB ESP does not fill up.

Old generations keep their whole closure on disk. `nix.gc` runs weekly and deletes generations older than 30 days. Store deduplication uses `nix.optimise.automatic`, which hard-links identical files on a timer. `auto-optimise-store` would do the same during every build and make each build slower.

`system.stateVersion` stays at the release of the first install. It pins state formats such as database layouts and paths, not package versions, so it is never bumped on upgrades.

## Making a change

Format with `nixfmt` (the official style, RFC 166) and lint with `statix check -i nixos/hosts/*/hardware.nix .`. statix wants one block per top-level option (`services = { ... }`) and no repeated keys.

Build before switching:

```sh
nix build .#nixosConfigurations.loc-nixos.config.system.build.toplevel
nix store diff-closures /run/current-system ./result
```

For a refactor, `diff-closures` should show nothing except the version label. Then `sudo nixos-rebuild switch --flake ~/dotfiles` activates the new system. Changes to the kernel, initrd or drivers need a reboot to take effect.
