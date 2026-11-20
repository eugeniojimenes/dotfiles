# NixOS

The system configuration lives in `nixos/` and in `flake.nix` at the repo root. `nixos/` is not a stow module: it has no dot-prefixed contents, so stow and `dotfiles-doctor` skip it.

## Layout

`flake.nix` defines one `nixosConfigurations.<hostname>` per machine. The attribute name is the hostname, so `sudo nixos-rebuild switch --flake ~/dotfiles` picks the right system by itself. The flake follows the `nixos-26.05` branch, and `flake.lock` pins the exact nixpkgs revision. `bin/update` moves the lock (see [Updating](#updating)). A second input, `nixpkgs-unstable`, supplies the few packages the stable branch has too old, mise and Quickshell for now. The mise 2026.5.12 in 26.05 fails `mise install` on a `.tool-versions` entry listed in `disable_tools`, which 2026.6.4 fixed. The Quickshell 0.3.0 in 26.05 crashes the network panel when the last access point of a Wi-Fi network without a saved profile goes away (a use-after-free that 0.3.1 fixed). The flake builds Quickshell once and hands it to both the system and the static check, so `panels-load` tests the same version the desktop runs. `bin/update` does not move that input; `nix flake update nixpkgs-unstable` does. It goes away with the move to 26.11.

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
- A copy of PipeWire's `analog-input-internal-mic.conf` in `/etc/alsa-card-profile` that pins `Internal Mic Boost` at 0 dB. The stock file adds the boost to the microphone volume, so 100% meant +60 dB of gain and the built-in mic clipped on room noise alone. Apps with automatic gain, such as Google Meet, push the volume to 100%. With the boost pinned, 100% is +30 dB from the `Capture` control alone. PipeWire reads `/etc/alsa-card-profile` before its own files, and the build fails if a PipeWire update renames the section, so the fix cannot silently stop working.

## Login

greetd logs straight into Sway by running `~/.config/sway/bin/start`. The disk is LUKS-encrypted, so the passphrase at boot already gates the machine and a second password would add nothing. Leaving Sway shows tuigreet.

## Shell support

`programs.fzf.keybindings` and the NixOS bash completion replace what the `bash` module used to source from `/usr/share` on Arch.

`programs.nix-ld` lets prebuilt binaries run. mise and Mason download binaries (Node, Python, Ruby, rustup, language servers) that expect `/lib64/ld-linux-x86-64.so.2`. `icu` is added to the default library set because .NET binaries such as Mason's marksman abort without `libicu`.

`services.envfs` does the same for shebangs. NixOS has only `/bin/sh` and `/usr/bin/env`, so a script that starts with `#!/bin/bash` fails, and many scripts outside this repo do, such as those in work repositories. envfs mounts `/bin` and `/usr/bin` as a FUSE filesystem that finds each program in the `PATH` of the process asking for it. The scripts in this repo still use `#!/usr/bin/env bash` and do not depend on it.

Gems with native extensions, such as `pg`, `rugged` and `fast_excel`, need C headers and build tools that NixOS does not install globally. The flake's `ruby-native` dev shell provides them, and the `bundle-native` alias in the bash config runs `bundle` inside it: `bundle-native install` in the project. It is only needed when a native gem is compiled, so on the first install, when the lockfile adds or updates one, or when the Ruby version changes. The compiled extensions point straight at the libraries in the Nix store, so the alias keeps the shell as a profile in `~/.local/state/ruby-native`, which protects those libraries from garbage collection. After a nixpkgs update and a garbage collection, `bundle-native pristine pg rugged fast_excel` rebuilds them.

## Portals

The portals come from the defaults of the NixOS Sway module: `xdg-desktop-portal-wlr` handles screen sharing and screenshots, and `xdg-desktop-portal-gtk` handles everything else, including the file chooser. The screen-share picker is set in `xdg.portal.wlr.settings`, since the module starts the wlr portal with a config generated from those settings and never reads `~/.config/xdg-desktop-portal-wlr`. The portal's user service also gets `/run/current-system/sw` in its `PATH`, because its own holds little more than coreutils, grim and slurp, and the picker needs fuzzel and Quickshell.

Nautilus as the FileChooser backend was tried and dropped. At startup the portal activates Nautilus, and Nautilus calls the portal back while it is still starting, so both wait on each other for 25 seconds. Every GTK app started during that window hung, and waybar died at login.

## Bluetooth

No Bluetooth pairing agent runs, since the Sway panel does not register one. Without an agent BlueZ keeps the adapter non-bondable, so a pairing works but is never stored: `bluetoothctl info` shows `Bonded: no`, and the device has to pair again after its first disconnect. `hardware.bluetooth.settings.General.AlwaysPairable = true` keeps the adapter bondable. Devices that ask for a PIN or a passkey still need an agent, which `bluetoothctl` provides.

## Wi-Fi MAC address

NetworkManager connects with a MAC address generated per network name (`wifi.macAddress = "stable-ssid"`) instead of the card's real one. The home router keeps seeing the same address every time, while each other network sees a different one, so visits to different places cannot be linked through the MAC. The MAC used while scanning is already random by NetworkManager's default.

The MAC goes out in every frame over the air, so anyone nearby can log it without joining the network, and the per-network MAC covers that. It is the only thing that changes per network, though. DHCP still sends the hostname, `loc-nixos`, to every network, and DHCPv6 sends a DUID made from the machine ID, the same everywhere, because NetworkManager's defaults are kept. A network that logs either one can link visits, and this repo is public and names the host. Networks with the same name in different places, such as eduroam or a café chain, also get the same MAC. Turning both off is three NetworkManager settings (`ipv4.dhcp-send-hostname` and `ipv6.dhcp-send-hostname` set to false, `ipv6.dhcp-duid` set to `stable-uuid`); the cost is that the home router lists the notebook by its MAC instead of its name.

## DNS

DNS stays as the network hands it out: plain queries to the router at home, to whoever runs the network elsewhere. That network can see every domain looked up and could answer with a false address, though HTTPS still protects the content of the connections. Two changes were weighed in November 2026 and left for later, since the notebook rarely uses public Wi-Fi.

- Strict DNS over TLS: `services.resolved` with `DNSOverTLS=true` and a fixed resolver (Quad9 or Cloudflare), with the DNS from DHCP ignored. Every query is encrypted and cannot be changed on the way. Captive portals in hotels and airports stop loading until it is turned off for that network, a work VPN with internal names needs `dns-over-tls=no` on its NetworkManager connection, and the resolver company sees the queries instead of the ISP.
- Opportunistic DNS over TLS: the same with `DNSOverTLS=opportunistic`. Nothing breaks, and it hides the queries from anyone who only watches the network, but a hostile network can block TLS and the queries fall back to plain text. Omarchy's `omarchy-setup-dns cloudflare` does this (Cloudflare, Quad9 as fallback), and its default is the network's DNS like here.

Before either one, check that NetworkManager stops passing the DHCP DNS to resolved (`resolvectl status` lists only the chosen servers), or the change protects nothing.

## Docker

Containers often reach a service published by another container through the host's address on the Docker bridge (`172.17.0.1`), for example an nginx container in front of an app container's published port. That traffic goes through `docker-proxy` on the host's INPUT chain, and the NixOS firewall dropped it silently, so the request timed out. `docker0` and every compose bridge (`br-+`) are therefore trusted interfaces.

Published ports work the other way round: Docker rewrites them in PREROUTING, so they never reach INPUT and the NixOS firewall does not guard them. Without a rule, anyone on the same network reached the databases the containers publish. A rule in the `DOCKER-USER` chain, which Docker runs first and never rewrites, drops forwarded traffic that does not come from a Docker bridge, except replies to connections already open. Binding published ports to `127.0.0.1` with `virtualisation.docker.daemon.settings.ip` looks simpler, but containers could then no longer reach each other through the host's address.

The log driver is `json-file`, Docker's own default, instead of the journald that NixOS picks: compose files that set `logging.options.max-size` without a driver fail under journald with "unknown log opt". A small `docker-compose` wrapper runs `docker compose`, for scripts that still call the old name. The standalone `docker-compose` binary is not used, because it does not find buildx and falls back to the classic builder.

The work setup depends on this section and on envfs, the `ruby-native` dev shell and the mise from `nixpkgs-unstable`. Changing any of them can break the work containers, so check with the owner first.

## Hibernation

Only the notebook hibernates. `nixos/hosts/loc-nixos/default.nix` adds a 16 GiB swapfile at `/var/lib/swapfile`, the same size as the RAM so a full memory still fits. It lives on the LUKS root, so the RAM image written to it is encrypted like everything else on the disk. zram keeps priority 5 and the swapfile -2, so everyday swapping still goes to zram first.

The kernel finds the image through `boot.resumeDevice`, which reads the root device from `hardware.nix`, and `resume_offset`, the physical position of the swapfile's first block on that device. The offset comes from `sudo filefrag -v /var/lib/swapfile` (the `physical_offset` of extent 0) after the file exists, so a new machine sets it up in two steps: a switch with the swapfile alone, then the offset and a `nixos-rebuild boot` with a reboot. Recreating the swapfile, for example with another size, moves it and needs a new offset.

Closing the lid runs `suspend-then-hibernate`. On battery, the notebook hibernates after 2 hours suspended (`HibernateDelaySec`), and on AC it stays suspended (`HibernateOnACPower = false`). The delay is set because this battery has an ACPI trip point: without a delay, systemd skips its estimate of the discharge and hibernates only when the firmware wakes the machine at the trip point and marks the wake as its battery alarm, and this notebook's firmware leaves that mark at "Power Switch" after a resume from deep sleep, so without the delay the battery would run out in suspend. System › Suspend in the menu does the same, and System › Hibernate hibernates at once; the menu shows that entry only when `/sys/power/resume` is set, so the desktop without a swapfile does not offer it. UPower hibernates at 4% battery instead of powering off. 4% leaves room for a battery reading that drifts near empty as the battery ages, and the critical warning moves to 7% so it still comes a few minutes before. swayidle locks the session before any of these. The NVIDIA open driver keeps the video memory across hibernation by itself (`UseKernelSuspendNotifiers=1`), with no `nvidia-hibernate` service. The spec is [docs/specs/hibernation.md](specs/hibernation.md).

## Theme and cursor

Dark mode is set through dconf defaults, which `gsettings set` can still override. `color-scheme = "prefer-dark"` covers GTK4, libadwaita and Chromium. GTK3 ignores that key and needs a theme by name. Plain GTK3 does not ship an `Adwaita-dark` theme, and an unknown theme name falls back to light Adwaita, which is why the file chooser and other GTK3 apps stayed light. `adw-gtk3-dark` (from the `adw-gtk3` package) makes GTK3 apps look like libadwaita apps.

NixOS sets no default cursor theme, so Sway drew the old X11 core cursors. `adwaita-icon-theme` was already in the closure as a GTK dependency. It is now installed explicitly and set both in Sway (`seat * xcursor_theme Adwaita 24`) and in dconf for GTK.

## Generations and garbage collection

Every rebuild creates a new generation and a new boot entry, which is what makes rollback possible: `sudo nixos-rebuild switch --rollback`, or pick an older entry in the boot menu. systemd-boot keeps 10 entries so the 1 GB ESP does not fill up. The menu shows for 1 second instead of 5; pressing an arrow key in that second stops the countdown. The menu does not allow editing the kernel command line (`boot.loader.systemd-boot.editor = false`). With it, adding `init=/bin/sh` at the menu gives a root shell without a password. The LUKS passphrase still guards the data, but the option costs nothing, and a broken boot is fixed by picking an older entry.

Old generations keep their whole closure on disk. `nix.gc` runs weekly and deletes generations older than 30 days. Store deduplication uses `nix.optimise.automatic`, which hard-links identical files on a timer. `auto-optimise-store` would do the same during every build and make each build slower.

`system.stateVersion` stays at the release of the first install. It pins state formats such as database layouts and paths, not package versions, so it is never bumped on upgrades.

## Updating

`bin/update` runs one step per source and stops at the first that fails, so a breakage points at one source: the system, the mise tools, the lazy.nvim plugins, then a firmware check that only reports what `fwupdmgr` offers. It never runs `sudo` and never commits. At the end, and also when a later step fails or the run is stopped with Ctrl-C, it prints the command that applies the system and the lock files to commit, `flake.lock` as `build(nixos): flake update` and `lazy-lock.json` as `build(lazyvim): plugin update`.

The system step reads the list of NixOS channel releases. A channel release has passed Hydra's tests and its packages are in the binary cache, which a random commit of the branch does not guarantee. The script takes the newest release that was published at least 2 days ago. On a stable branch the changes are reviewed backports, so the wait is there to let regressions surface. A younger release skips the wait when it fixes a CVE with a CVSS score of 7.0 or more on this machine: vulnix scans the current system and the newer one, and a CVE found only in the current one counts as fixed when its package is part of the running system. The scan also covers tools used only to build packages, which never reach the machine, so those are left out. vulnix matches package names and versions against NVD and reports false positives, but those show on both sides and cancel out. Its first run downloads the NVD data, about 400 MB. `bin/update --now` takes the newest release without waiting. A release already locked that is newer than the one the wait picks, taken with `--now` or for a CVE, stays locked, so a later run never goes back to an older one. When a vulnix scan fails, the wait holds. While `flake.lock` points at a release that is not built yet, a failure or Ctrl-C puts it back.

After locking, `bin/check` runs against the new packages, so the Quickshell panels load with the new Quickshell and `sway -C` reads the config with the new Sway before anything is applied. A failure restores `flake.lock`. The new system is then built and compared with the running one with `nvd diff`. When the kernel, its modules or the initrd changed, the script says to run `sudo nixos-rebuild boot` and reboot: a `switch` would keep the old NVIDIA kernel module loaded under a new userspace driver, and GPU apps fail until the reboot. Otherwise it says to run `sudo nixos-rebuild test`, which reverts on the next boot, and `switch` once the system works.

mise waits 7 days for new releases (`minimum_release_age` in its config). Its tools are published straight by their maintainers, and the agent CLIs among them run with access to the shell and the code, so they get the longer supply-chain wait. Analyses of known supply-chain attacks found that most malicious releases were pulled within a week. The built-in default of mise is 24 hours, so the 7 days are set explicitly.

## Making a change

Format with `nixfmt` (the official style, RFC 166) and lint with `statix check -i 'nixos/hosts/*/hardware.nix' .`. statix wants one block per top-level option (`services = { ... }`) and no repeated keys.

Build before switching:

```sh
nix build .#nixosConfigurations.loc-nixos.config.system.build.toplevel
nix store diff-closures /run/current-system ./result
```

For a refactor, `diff-closures` should show nothing except the version label. Then `sudo nixos-rebuild switch --flake ~/dotfiles` activates the new system. Changes to the kernel, initrd or drivers need a reboot to take effect.
