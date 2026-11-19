# mpv

The mpv interface is [uosc](https://github.com/tomasklaen/uosc) by tomasklaen. mpv and uosc both come from `nixos/common.nix`, and the `mpv` module only holds the user config.

## What is tracked

Only `mpv/.config/mpv/mpv.conf`, with three settings: `vo=gpu`, `gpu-api=opengl` and `target-colorspace-hint=no`.

`gpu-api=opengl` is there for the notebook's two GPUs. mpv's default API is Vulkan, and the Vulkan loader starts the driver of every GPU it finds, so each start woke the NVIDIA card from its sleep and took about 1.1 seconds to the first frame, 3 seconds when the card was fully asleep. With OpenGL, mpv renders on the Intel GPU alone and starts in about 0.17 seconds. Vulkan would only matter with `vo=gpu-next` and heavy shaders, which are not used here. To play something on the NVIDIA card anyway, run `prime-run mpv --gpu-api=vulkan <file>`.

## uosc from nixpkgs

`nixos/common.nix` installs mpv as `mpv.override { scripts = [ mpvScripts.uosc mpvScripts.mpris ]; }`. The `mpris` script puts mpv on MPRIS, so the bar, the media keys and the sound panel show and control it like any other player. The wrapper passes the uosc script to mpv and points it at the uosc fonts, so nothing is installed into `~/.config/mpv`. The version follows `flake.lock`: it changes with `bin/update`, with the same 2-day wait as the rest of the system, and rolls back with a NixOS generation. nixpkgs builds uosc's `ziggy` helper from source, so no prebuilt binary without a checksum reaches the machine.

Before this, uosc came from its own installer, `curl … | bash` from the HEAD of the uosc repo, which runs whatever is there at that moment as the user and leaves the version unpinned. The nixpkgs version can lag one release behind upstream, which is the price of the pin.

Do not use uosc's own installer or the **Update uosc** entry in its menu. Both write a copy into `~/.config/mpv/scripts`, and mpv then loads two copies of uosc. `dotfiles-doctor` reports such a copy and prints the command that removes it. `~/.config/mpv` is a link into this repo, so `.gitignore` keeps that copy out of a commit until it is removed.

## Settings

uosc runs with its defaults. To change a setting, write `mpv/.config/mpv/script-opts/uosc.conf` with only the lines that differ and track it.
