# dotfiles-doctor

`local-bin/.local/bin/dotfiles-doctor` is a health check for a machine using this repo. It only reads by default and prints the repair for each problem it finds. `dotfiles-doctor --fix` applies the repairs that are safe to apply automatically. The behaviour and its tests are listed in [specs/dotfiles-doctor.md](specs/dotfiles-doctor.md).

The repo root is found through `readlink -f "$0"`, so the script works both when stowed and when run straight from a fresh clone (`~/dotfiles/local-bin/.local/bin/dotfiles-doctor`).

## What it checks

- Stow state of every module. The module list is every top-level directory with dot-prefixed contents, so a new module is covered without editing the script. Shared parents such as `~/.local/share` must be real directories, not links into the repo.
- Commands that `nixos/common.nix` should provide. A missing one means the system has not been rebuilt since the command was added.
- The pre-commit hook: `core.hooksPath` must be `.githooks`. `--fix` sets it.
- The forbidden-terms list. When `~/.private/forbidden-terms` is absent, it prints a warning, because `bin/check terms` and the hook then skip the term scan. It never prints the list's contents.
- mise tools, including the Neovim hosts installed by `postinstall` hooks, which fail without any message.
- External installs: TPM and the tmux plugins, uosc, the lazy.nvim plugins.
- Machine-local files: `~/.claude/settings.json`, the default app for images, and the cedilla mapping.

## Reading stow's output

Stow has no status command. The script runs `stow -n -v <module>` and reads three signals, verified against stow 2.4.1. None of them is documented.

- Exit code 0 and no output: the module is linked.
- Exit code 0 and `LINK:` lines: the module is not linked.
- Exit code 1 and `WARNING! ... conflicts`: a real file sits where a symlink belongs.

Conflicts are never fixed automatically, because the real file may hold changes worth keeping. Diff it against the repo first.

## Image viewer

Images must open in `imv-dir.desktop`. It ships with `imv` and opens the clicked file together with its directory, so next and previous work. The default is set in `~/.config/mimeapps.list` with `xdg-mime default`. `mimeapps.list` itself is not tracked, because apps rewrite it constantly.

## Cedilla

With a US international layout, `'` followed by `c` produces ć instead of ç. The check compiles the Compose table with `xkbcli compile-compose` and expects `<dead_acute> <c>` to map to ç.

The fix is an override at the end of the machine-local `~/.XCompose`. That file starts with `include "%L"`, which pulls in the system Compose table, and a later definition wins over an earlier one. The README has the exact lines.

The script captures the `xkbcli` output before running `grep -q` on it. If `grep -q` read the pipe directly, its early exit would send SIGPIPE to `xkbcli`, and with `pipefail` set the pipeline would report failure even on a match.

The check only runs when the Sway config sets `xkb_variant intl`. The notebook's built-in ABNT2 keyboard has a real ç key, and only a US international external keyboard reaches `dead_acute`. The check only reports. Its repair edits a file outside the repo, so `--fix` leaves it alone.
