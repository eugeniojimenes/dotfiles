# Manual pass

Files: `bin/manual-pass` (run by the owner from the repo after items of `tests/manual.md` pass), `tests/manual-passes.toml` (written by the script).

## Purpose

A check in `tests/manual.md` passes on one machine, with one set of drivers and one nixpkgs revision. The script keeps the last pass of each item per machine in `tests/manual-passes.toml`, with the machine and the software it passed on, so a regression after `nix flake update` can be compared with the versions of the last pass. The file holds the current state and git holds the history: `git log -p tests/manual-passes.toml` shows every earlier pass. The script commits nothing. The repo is public, so it reads model names and versions only. It never reads a serial number, a MAC address or a UUID.

## Acceptance criteria

1. With `-n`, the script prints the new file and writes nothing. The file has one table per machine with its model, board, CPU and GPUs, and one table per passed item with the date, the NixOS version, the kernel, the NVIDIA driver, the active displays (make and model) and the peripherals given with `--with`. Arrays are laid out the way `nix fmt` (taplo) lays them out, so the format check passes. Test: `tests/unit/bin/manual-pass.bats: "dry run: machine once, one table per item with versions, displays without serial, nothing written"`
2. No serial number shows in the file, even when the DMI data and the display data carry one. Test: `tests/unit/bin/manual-pass.bats: "dry run: machine once, one table per item with versions, displays without serial, nothing written"`
3. Without `-n`, the script updates the file in place: a passed item already there is replaced where it stands, a new one is added, the machine's details are refreshed, and other items and machines stay as they were. Test: `tests/unit/bin/manual-pass.bats: "write: passed item replaced in place, new one added, other items and hosts kept"`
4. Quotes and backslashes typed with `--with` are escaped, so the file stays valid TOML. Test: `tests/unit/bin/manual-pass.bats: "quotes and backslashes typed in --with stay valid TOML"`
5. An item that is not a row in the current host's section of `tests/manual.md` is refused, the host's items are listed, and nothing is written. Test: `tests/unit/bin/manual-pass.bats: "item unknown or of another host: refused with this host's items, nothing written"`
6. A field the machine lacks is left out instead of written empty: no NVIDIA driver loaded, no Sway session, or a DMI placeholder such as "To Be Filled By O.E.M.". Test: `tests/unit/bin/manual-pass.bats: "no NVIDIA, no Sway, DMI placeholders: those fields left out"`
7. Without an item, the script prints its usage and exits with status 2. Test: `tests/unit/bin/manual-pass.bats: "no item: usage, exit 2"`
