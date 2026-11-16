#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  stub fuzzel --rc 1
}

# Fixture config: what each case needs, nothing else. $sway named so gawk visits it before $lock: one expansion pass
# would then leave "$sway" in the lock command.
fixture() {
  local d=$HOME/.config/sway
  mkdir -p "$d/config.d"
  ln -s "$SWAY/bin" "$d/bin"
  printf '%s\n' 'set $mod Mod4' 'set $sway ~/.config/sway' 'set $lock $sway/lock/lock' 'include config.d/*' >"$d/config"
  printf '%s\n' \
    '#: Lock the screen' \
    'bindsym $mod+Shift+l exec $lock' \
    'bindsym --locked --to-code $mod+Escape exec $sway/bin/dnd toggle' \
    'bindcode $mod+10 workspace number 1' \
    'bindcode $mod+19 workspace number 10' \
    'bindcode $mod+Shift+11 move container to workspace number 2; workspace number 2' \
    'bindcode $mod+Ctrl+12 move container to workspace number 3' \
    '#: Orphan title' \
    '' \
    'bindsym Mod1+Tab focus next' >"$d/config.d/10-test"
}

row() { printf '%-34s %s\t%s' "$1" "$2" "$3"; }

@test "#: title shown; \$vars expanded twice in the command" {
  fixture
  run "$SWAY/bin/keybindings"
  run cat "$STUBS/fuzzel.stdin"
  assert_line "$(row 'Super + Shift + l' 'Lock the screen' 'exec ~/.config/sway/lock/lock')"
}

@test "workspace bindcodes: number row key and a generated title" {
  fixture
  run "$SWAY/bin/keybindings"
  run cat "$STUBS/fuzzel.stdin"
  assert_line "$(row 'Super + 1' 'Switch to workspace 1' 'workspace number 1')"
  assert_line "$(row 'Super + 0' 'Switch to workspace 10' 'workspace number 10')"
  assert_line "$(row 'Super + Shift + 2' 'Move window to workspace 2' 'move container to workspace number 2; workspace number 2')"
  assert_line "$(row 'Super + Ctrl + 3' 'Move window silently to workspace 3' 'move container to workspace number 3')"
}

@test "untitled binding falls back to the command, flags and exec and config dir stripped" {
  fixture
  run "$SWAY/bin/keybindings"
  run cat "$STUBS/fuzzel.stdin"
  assert_line "$(row 'Super + Escape' 'bin/dnd toggle' 'exec ~/.config/sway/bin/dnd toggle')"
}

@test "a title covers only the line right below it; Mod1 shown as Alt" {
  fixture
  run "$SWAY/bin/keybindings"
  run cat "$STUBS/fuzzel.stdin"
  assert_line "$(row 'Alt + Tab' 'focus next' 'focus next')"
  refute_output --partial 'Orphan title'
}

@test "picked line runs its command through swaymsg" {
  fixture
  stub fuzzel 'exec ~/.config/sway/lock/lock'
  rm "$STUBS/fuzzel.rc"
  run "$SWAY/bin/keybindings"
  run calls
  assert_line 'swaymsg -q -- exec ~/.config/sway/lock/lock'
}

@test "menu closed: nothing runs" {
  fixture
  run "$SWAY/bin/keybindings"
  run calls
  refute_line --partial swaymsg
}

@test "real config: one row per binding, every variable expanded" {
  link_sway
  run "$SWAY/bin/keybindings"
  bindings=$(cat "$SWAY/config" "$SWAY"/config.d/* | grep -cE '^\s*bind(sym|code)')
  rows=$(wc -l <"$STUBS/fuzzel.stdin")
  ((rows == bindings))
  run awk -F'\t' 'NF != 2 || $2 ~ /\$/' "$STUBS/fuzzel.stdin"
  assert_output ''
}
