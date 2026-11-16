# dotfiles-doctor

Files: `local-bin/.local/bin/dotfiles-doctor`, on `PATH` once `local-bin` is stowed.

## Purpose

`dotfiles-doctor` checks that a machine matches this repo: stow links, the commands the NixOS config installs, mise tools, external installs and a few machine-local files. It only reads by default and prints the repair for each problem. `--fix` runs the repairs that cannot lose data.

## Acceptance criteria

1. A stow module is a top-level directory with dot-prefixed entries. Other directories are skipped. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "only dirs with dot-prefixed contents are modules"`
2. A module whose `stow -n -v` exits 0 and prints nothing beyond the simulation warning is reported as ok. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "linked: rc 0 and only the simulation warning"`
3. A module whose `stow -n -v` exits 0 and prints `LINK:` lines is reported as not stowed, with `stow <module>` as the repair. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "not linked: LINK lines, repair printed"`
4. A module whose `stow -n -v` exits 1 is reported as a conflict with stow's message, and must be resolved by hand. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "conflict: rc 1, stow's message shown, resolved by hand"`
5. `--fix` stows a module that is not stowed and never touches a module in conflict. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "--fix stows the unlinked module, never the conflicting one"`
6. Each shared parent (`~/.config`, `~/.local`, `~/.local/share`, `~/.local/bin`, `~/.claude`) that is a symlink into the repo is reported. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "shared parent linked into the repo: flagged"`
7. `~/.claude/settings.json` must be a real file. A symlink or a missing file is reported. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "~/.claude/settings.json: real file ok, symlink or absent flagged"`
8. Every image type must open in `imv-dir.desktop`, and the repair is the matching `xdg-mime default` command. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "images must open in imv-dir"`
9. When the Sway config gives a keyboard the `intl` variant, the effective compose table must map `<dead_acute> <c>` to ç. Without `xkbcli` output this is a warning. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "cedilla: checked on the effective compose table"`
10. The script finds the repo through its own path, so it works from a fresh clone and through the stowed symlink in `~/.local/bin`. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "run through a symlink (stowed into ~/.local/bin): still finds the repo"`, `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "linked: rc 0 and only the simulation warning"`
11. It exits 1 when any check fails and 2 on an unknown argument. Test: `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "conflict: rc 1, stow's message shown, resolved by hand"`, `tests/unit/local-bin/.local/bin/dotfiles-doctor.bats: "unknown argument: exit 2"`
12. On a machine set up from this repo, every check passes and the script exits 0. This covers the commands from `nixos/common.nix`, the mise tools and their Neovim hosts, TPM and the tmux plugins, uosc and the lazy.nvim plugins. Test: manual
