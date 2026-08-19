# MPV Setup

UI = [uosc](https://github.com/tomasklaen/uosc) by tomasklaen.

Omarchy ships mpv itself (`mpv` + `mpv-mpris` in `omarchy-base.packages`), its own
`applications/mpv.desktop`, a `mimeapps.list` pointing every `video/*` type at it, and float
rules in `default/hypr/apps/system.lua`. It ships **no mpv config**, so nothing here layers over
an Omarchy default and no migration ever rewrites these files. This module is entirely ours.

## Tracked here

`mpv.conf` only. Two settings, both real: `vo=gpu` and `target-colorspace-hint=no`.

## Not tracked

`scripts/`, `fonts/`, `script-opts/`, `.uosc-backup/` are gitignored.

uosc tree = ~18 MB, ~17 MB of it three prebuilt `ziggy` binaries (Linux, macOS, Windows `.exe`),
no checksum, no provenance. Not for a public repo, and two of three never run on this machine.

`script-opts/uosc.conf` left too: ours held zero customizations, just upstream's stock default
one version behind. Tracking it only froze a stale default. Track it again if a setting actually
changes.

## Install uosc on fresh machine

**Stow first, then install.** Order matters: the installer runs `mkdir -p ~/.config/mpv`, and a
real directory there blocks the directory symlink stow needs. Stow first and `~/.config/mpv`
is already a symlink into this repo, so everything the installer writes lands in the gitignored
paths above and stays out of git.

```sh
stow mpv
curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
```

The installer writes `scripts/uosc`, `fonts/uosc_icons.otf`, `fonts/uosc_textures.ttf`, and a
current `script-opts/uosc.conf`. It only downloads that conf when the file is absent, so a
tracked one would win.

AUR alternative:

```sh
yay -S mpv-uosc
```

Installs to `/usr/share/mpv/`, needs symlinks into `~/.config/mpv/` to take effect. Prefer the
installer: a symlink inside a stowed module pointing outside the repo is exactly what `CLAUDE.md`
warns against. Do not use `mpv-uosc-git`, untouched upstream since 2024-02.

## Update uosc

uosc updates itself. Open its menu in mpv (right click, or `menu` key), pick **Update uosc**.
`main.lua` binds it to `script-binding uosc/update`, so a keybind works too:

```
Ctrl+u script-binding uosc/update
```

Updater shells out to the same `installers/unix.sh` a fresh install uses, with `MPV_CONFIG_DIR`
set to mpv's own config dir. Needs `curl` and `unzip` on PATH. Curl line above is equivalent.
Restart mpv after.

Everything it writes lands in gitignored paths, so an update never dirties `git status`.
Upstream notes the self-updater does not work on macOS; irrelevant here.

Running version: `uosc_version` at the top of `scripts/uosc/main.lua`, or the `uosc-version`
script message.

The installer only downloads `script-opts/uosc.conf` when absent, so ours never refreshes. To
pick up new defaults after a big upgrade, delete it and re-run.
