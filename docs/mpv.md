# mpv

The mpv interface is [uosc](https://github.com/tomasklaen/uosc) by tomasklaen. mpv itself comes from `nixos/common.nix`. Its package ships no user config, so the `mpv` module holds everything there is.

## What is tracked

Only `mpv/.config/mpv/mpv.conf`, with two settings: `vo=gpu` and `target-colorspace-hint=no`.

## What is not tracked

`scripts/`, `fonts/`, `script-opts/` and `.uosc-backup/` are in `.gitignore`.

The uosc tree is about 18 MB, and about 17 MB of that is three prebuilt `ziggy` binaries for Linux, macOS and Windows. They come with no checksum and no provenance, which rules them out for a public repo. Two of the three never run on this machine anyway.

`script-opts/uosc.conf` is left out too. The tracked copy held no customizations, only the upstream default from one version back, so tracking it only froze a stale default. Track it again if a setting ever changes.

`.uosc-backup/` is the installer's scratch directory. It is removed on success and left behind when an install fails.

## Install uosc on a fresh machine

Stow the module first, then run the installer. The installer runs `mkdir -p ~/.config/mpv`, and a real directory there blocks the directory symlink stow needs. When stow runs first, `~/.config/mpv` is already a symlink into the repo, so everything the installer writes lands in the ignored paths above and stays out of git.

```sh
stow mpv
curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
```

The installer writes `scripts/uosc`, `fonts/uosc_icons.otf`, `fonts/uosc_textures.ttf` and a current `script-opts/uosc.conf`. It only downloads that conf file when it is absent, so a tracked copy would win over the new default.

nixpkgs has `mpvScripts.uosc`, which could be added through an mpv wrapper in `nixos/common.nix`. It is not used here because the installer keeps uosc next to this config and updates itself.

## Update uosc

uosc updates itself. Open its menu in mpv (right click, or the `menu` key) and pick **Update uosc**. `main.lua` binds the update to `script-binding uosc/update`, so a key binding works too:

```
Ctrl+u script-binding uosc/update
```

The updater runs the same `installers/unix.sh` that a fresh install uses, with `MPV_CONFIG_DIR` set to mpv's config directory. It needs `curl` and `unzip` on `PATH`, and the `curl` line above does the same thing. Restart mpv afterwards.

Everything the update writes lands in ignored paths, so it never shows up in `git status`. Upstream notes that the self-updater does not work on macOS, which does not matter here.

The running version is `uosc_version` at the top of `scripts/uosc/main.lua`, or the `uosc-version` script message.

Because the installer only downloads `script-opts/uosc.conf` when it is absent, the local copy never refreshes. To pick up new defaults after a big upgrade, delete it and run the installer again.
