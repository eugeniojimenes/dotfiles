# Keybindings cheat sheet

Files: `sway/.config/sway/bin/keybindings`, opened by `Super + K` (`sway/.config/sway/config.d/30-apps`) and from the menu.

## Purpose

The cheat sheet lists every Sway binding, read live from the config, so the list never goes stale. Picking a row runs that binding's command, so the sheet also works as a launcher.

## Acceptance criteria

1. It reads `config` first and then every file in `config.d/` in name order, and shows one row per `bindsym` or `bindcode` line. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "real config: one row per binding, every variable expanded"`
2. A `#: <title>` comment on the line directly above a binding becomes that row's title. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "#: title shown; $vars expanded twice in the command"`
3. A title applies only to the line right below it. A blank line or any other line in between drops it. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "a title covers only the line right below it; Mod1 shown as Alt"`
4. Config variables in a command are expanded, including a variable whose value contains another variable (`$lock` is `$dir/lock/lock`). Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "#: title shown; $vars expanded twice in the command"`, `tests/unit/sway/.config/sway/bin/keybindings.bats: "real config: one row per binding, every variable expanded"`
5. Workspace bindcodes 10 to 19 are shown as the number row keys 1 to 0, with a generated title: "Switch to workspace N", "Move window to workspace N" or "Move window silently to workspace N". Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "workspace bindcodes: number row key and a generated title"`
6. A binding without a title shows its command as the title, without `exec`, without option flags such as `--locked` and without the `~/.config/sway/` prefix. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "untitled binding falls back to the command, flags and exec and config dir stripped"`
7. Keys read `Super` for `$mod` and `Alt` for `Mod1`, with spaces around each `+`. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "a title covers only the line right below it; Mod1 shown as Alt"`, `tests/unit/sway/.config/sway/bin/keybindings.bats: "workspace bindcodes: number row key and a generated title"`
8. Picking a row runs its expanded command through `swaymsg`. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "picked line runs its command through swaymsg"`
9. Closing the menu without a pick runs nothing. Test: `tests/unit/sway/.config/sway/bin/keybindings.bats: "menu closed: nothing runs"`
10. `Super + K` opens the sheet in fuzzel, and the picked binding takes effect in the session. Test: manual
